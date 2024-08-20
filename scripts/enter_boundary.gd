@tool
extends Node2D

@export var rect_x = 50
@export var rect_y = 50

@onready var down = $down
@onready var up = $up
@onready var left = $left
@onready var right = $right

func scale_particles(length):
	var rate = int(length * 20/32)
	return min(rate, 50)

# Called when the node enters the scene tree for the first time.
func _ready():
	var origin = Vector2(-rect_x, -rect_y)
	var extents = Vector2(rect_x,rect_y)
	
	down.position = Vector2((extents.x + origin.x)/2, extents.y )
	down.emission_rect_extents = Vector2((extents.x - origin.x)/2 , 1)
	down.amount = scale_particles(rect_x)
	
	up.position = Vector2((extents.x + origin.x)/2 , origin.y )
	up.emission_rect_extents = Vector2((extents.x - origin.x)/2 , 1)
	up.amount = scale_particles(rect_x)
	
	left.position = Vector2(origin.x, (extents.y + origin.y)/2 )
	left.emission_rect_extents = Vector2(1, (extents.y - origin.y)/2)
	left.amount = scale_particles(rect_y)
	
	right.position = Vector2(extents.x, (extents.y + origin.y)/2 )
	right.emission_rect_extents = Vector2(1,  (extents.y - origin.y)/2)
	right.amount = scale_particles(rect_y)

