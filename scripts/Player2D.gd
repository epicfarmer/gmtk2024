class_name Player2D

extends CharacterBody2D

@onready var camera: Camera2D = $Camera

const SPEED: float = 5.0 * 16
const JUMP_VELOCITY: float = 15 * 16

func _physics_process(_delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	if direction:
		velocity = SPEED * direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	var _collision: bool = move_and_slide()
	
func enable_camera() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and key_event.keycode == KEY_ESCAPE:
			print("Quitting")
			get_tree().quit()


func _on_level_area_entered(area):
	print("Enter")
	area.enter(self)
	pass # Replace with function body.


func _on_level_area_exited(area):
	print("Exit")
	area.exit(self)
	pass # Replace with function body.
	
func _on_level_body_entered(area):
	print("Enter Body")
	area.enter(self)
	pass # Replace with function body.


func _on_level_body_exited(area):
	print("Exit Body")
	area.exit(self)
	pass # Replace with function body.
