extends RayCast3D

@export var ray_length: float = 3.0
var interactable_script = preload("res://scenes/interactable.gd")

var interaction_panel: Panel
var interaction_label: Label

func _ready():
	enabled = true
	target_position = Vector3(0, 0, -ray_length)
	
	# Obtener HUD dinámicamente desde la escena actual
	var current_scene = get_tree().get_current_scene()
	interaction_panel = current_scene.get_node("HUD/InteractionPanel")
	interaction_label = interaction_panel.get_node("InteractionLabel")
	
	interaction_panel.visible = false

func _process(_delta: float) -> void:
	if not is_colliding():
		return

	var hit = get_collider()
	if hit == null:
		return

	var node = hit
	while node != null:
		if node.get_script() == interactable_script:
			if Input.is_action_just_pressed("interact"):
				interaction_label.text = node.interaction_text
				interaction_panel.visible = true
			break
		node = node.get_parent()

func _input(event):
	if event.is_action_pressed("ui_cancel") and interaction_panel.visible:
		interaction_panel.visible = false
