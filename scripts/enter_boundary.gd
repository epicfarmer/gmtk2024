extends Node2D

@export var rect_x = 50
@export var rect_y = 50

@onready var particles = $inwardparticles

# Called when the node enters the scene tree for the first time.
func _ready():
	$inwardparticles.emission_rect_extents = Vector2(rect_x, rect_y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
