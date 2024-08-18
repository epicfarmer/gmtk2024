extends Node2D
@onready var sprite = $sprite
@onready var recoil_audio = $RecoilSound


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("idle")

func play_spring():
	sprite.play("spring")

func _on_playerdetect_body_entered(body):
	if body.name == "Player":
		body.spring = self
		sprite.play("recoil")
		recoil_audio.play()

func _on_playerdetect_body_exited(body):
	if body.name == "Player" and body.spring == self:
		body.spring = null

func _on_sprite_animation_finished():
	sprite.play("idle")
