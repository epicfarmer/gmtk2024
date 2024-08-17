extends Node2D

@export var origin = Vector2(0,0)
@export var extents = Vector2(100, 100)

@onready var down = $down
@onready var up = $up
@onready var left = $left
@onready var right = $right

# Called when the node enters the scene tree for the first time.
#func _ready():
#	down.position = Vector2((extents.x - origin.x) / 2, extents.y )
#	down.emission_rect_extents = Vector2(extents.x - origin.x)

