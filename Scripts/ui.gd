extends CanvasLayer

@onready var start_pause_button: Button = $Control/VBoxContainer/StartPauseButton
@onready var reset_button: Button = $Control/VBoxContainer/ResetButton
@onready var mass_toggle_button: Button = $Control/VBoxContainer/MassToggleButton
@onready var change_mass_button: Button = $Control/VBoxContainer/HBoxContainer/ChangeMassButton
@onready var celestial_dropdown: OptionButton = $Control/VBoxContainer/HBoxContainer/CelestialBodyDropdown
@onready var mass_input: LineEdit = $Control/VBoxContainer/HBoxContainer2/MassInput
@onready var apply_mass_button: Button = $Control/VBoxContainer/HBoxContainer2/ApplyMassButton
@onready var randomize_masses_button: Button = $Control/VBoxContainer/RandomizeMassesButton
@onready var status_label: Label = $Control/VBoxContainer/StatusLabel

var simulation_running := false
var masses_visible := true
var celestial_bodies := []

func _ready():
	get_tree().paused = true
	
	start_pause_button.pressed.connect(_on_start_pause_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	mass_toggle_button.pressed.connect(_on_mass_toggle_pressed)
	change_mass_button.pressed.connect(_on_change_mass_pressed)
	apply_mass_button.pressed.connect(_on_apply_mass_pressed)
	randomize_masses_button.pressed.connect(_on_randomize_masses_pressed)
	celestial_dropdown.item_selected.connect(_on_celestial_selected)
	
	update_ui()
	refresh_celestial_list()

func _on_start_pause_pressed():
	simulation_running = !simulation_running
	get_tree().paused = !simulation_running
	update_ui()

func _on_reset_pressed():
	get_tree().reload_current_scene()

func _on_mass_toggle_pressed():
	masses_visible = !masses_visible
	toggle_all_masses(masses_visible)
	update_ui()

func _on_change_mass_pressed():
	refresh_celestial_list()
	
	celestial_dropdown.visible = true
	mass_input.visible = true
	apply_mass_button.visible = true

func _on_apply_mass_pressed():
	if celestial_dropdown.selected >= 0 and mass_input.text.is_valid_int():
		var selected_index = celestial_dropdown.selected
		var new_mass = int(mass_input.text)
		
		if selected_index < celestial_bodies.size():
			var body = celestial_bodies[selected_index]
			body.mass = new_mass
			
			if body.has_method("update_mass_label"):
				body.update_mass_label()
			
			print("Changed mass of ", body.name, " to ", new_mass)

			mass_input.text = ""

			celestial_dropdown.visible = false
			mass_input.visible = false
			apply_mass_button.visible = false

			refresh_celestial_list()
		else:
			status_label.text = "Error: Invalid body selection"
	else:
		status_label.text = "Error: Please enter a valid whole number"

func _on_randomize_masses_pressed():
	if get_tree().paused:
		randomize_all_masses()
		status_label.text = "Masses Randomized!"
		await get_tree().create_timer(2.0).timeout
		update_ui()
	else:
		status_label.text = "Please pause simulation first"

func _on_celestial_selected(index):
	if index >= 0 and index < celestial_bodies.size():
		var body = celestial_bodies[index]
		mass_input.text = str(body.mass)
		mass_input.visible = true
		apply_mass_button.visible = true

func refresh_celestial_list():
	celestial_bodies = get_tree().get_nodes_in_group("celestial_bodies")
	celestial_dropdown.clear()
	
	for body in celestial_bodies:
		celestial_dropdown.add_item(body.name + " (Mass: " + str(body.mass) + ")")

func toggle_all_masses(should_show: bool):
	var bodies = get_tree().get_nodes_in_group("celestial_bodies")
	for body in bodies:
		if body.has_method("show_mass") and body.has_method("hide_mass"):
			if should_show:
				body.show_mass()
			else:
				body.hide_mass()

func randomize_all_masses():
	var bodies = get_tree().get_nodes_in_group("celestial_bodies")
	
	for body in bodies:
		if body.is_sun:
			continue
			
		var new_mass = randi_range(1, 30000)
		body.mass = new_mass
		
		if body.has_method("update_mass_label"):
			body.update_mass_label()
		
		print("Randomized ", body.name, " mass to ", new_mass)
	refresh_celestial_list()

func update_ui():
	if simulation_running:
		start_pause_button.text = "Pause"
		status_label.text = "Simulation Running"
	else:
		start_pause_button.text = "Start"
		status_label.text = "Simulation Paused"
	
	if masses_visible:
		mass_toggle_button.text = "Hide Masses"
	else:
		mass_toggle_button.text = "Show Masses"
	
