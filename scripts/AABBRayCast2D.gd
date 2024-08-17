extends RayCast2D

class_name AABBRayCast2D

@export var epsilon: float = 0.1

func _distance_squared(point_1: Vector2, point_2: Vector2) -> float:
	var squared_diff = (point_1 - point_2) * (point_1 - point_2)
	return squared_diff[0] + squared_diff[1]

func _init():
	collide_with_areas = true
	collide_with_areas = true
	collide_with_bodies = false
	hit_from_inside = true
	collision_mask = 2

func _cast_to_area(global_origin: Vector2, direction: Vector2, target: Area2D):
	global_position = global_origin
	target_position = direction
	force_raycast_update()
	if is_colliding():
		if get_collider() == target:
			return get_collision_point()
	return null

func _aabb_raycast(global_origin_position: Vector2, target: Node2D):
	if _distance_squared(global_origin_position, target.global_position) < epsilon:
		push_warning("This should probably not happen")
		return global_origin_position
	var direction: Vector2 = target.global_position - global_origin_position
	var x_collision = _cast_to_area(global_origin_position, direction * Vector2(1, 0), target)
	var y_collision = _cast_to_area(global_origin_position, direction * Vector2(0, 1), target)
	var x_collided: bool = x_collision != null
	var y_collided: bool = y_collision != null
	if x_collided and y_collided:
		var x_distance = _distance_squared(x_collision, global_origin_position)
		var y_distance = _distance_squared(y_collision, global_origin_position)
		if x_distance <= y_distance:
			return x_collision
		return y_collision
	if x_collided:
		return x_collision
	if y_collided:
		return y_collision
	return _aabb_raycast((1 - epsilon) * global_origin_position + epsilon * target.global_position, target)
