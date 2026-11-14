extends Node3D
@export_group("Court")
@export var floor_y := -2.5
@export var court_center_x := -0.7
@export var court_half_width := 24.0
@export var net_z := -32.5

@export_group("Feel")
@export var serve_speed := 26.0      
@export var hit_speed := 32.0       
@export var hit_height := 4.0      
@export var far_bounce_speed := 8.0 
@export var land_z_near := -16.0     
@export var land_z_far := -58.0      
@export var bat_aim := 0.6           
@export var miss_margin := 4.0      

@onready var rigid_body: RigidBody3D = $RigidBody3D
@onready var bat: Node3D = get_node("../Player")

var _gravity := 9.8
var _radius := 0.4
var _hit_cooldown := 0.0
var _serve_timer := 0.0
var _stall_time := 0.0
var _rally := 0
var _best := 0
var _label: Label


func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * rigid_body.gravity_scale
	var cs: CollisionShape3D = rigid_body.get_node("CollisionShape3D")
	_radius = (cs.shape as SphereShape3D).radius * cs.scale.x
	_make_label()
	serve()


func serve() -> void:
	_serve_timer = 0.0
	_stall_time = 0.0
	_rally = 0
	_update_label()
	var start := Vector3(court_center_x + randf_range(-8.0, 8.0), floor_y + 8.0, -62.0)
	rigid_body.global_position = start
	rigid_body.angular_velocity = Vector3.ZERO
	rigid_body.linear_velocity = _arc_to(start, _near_target(), serve_speed)


func _physics_process(delta: float) -> void:
	_hit_cooldown = maxf(_hit_cooldown - delta, 0.0)
	if _serve_timer > 0.0:
		_serve_timer -= delta
		if _serve_timer <= 0.0:
			serve()
		return

	var p := rigid_body.global_position
	var v := rigid_body.linear_velocity
	_stall_time = _stall_time + delta if Vector2(v.x, v.z).length() < 1.0 else 0.0
	if p.z > bat.hit_plane_z + miss_margin or p.y < floor_y - 5.0 or _stall_time > 1.0:
		_point_over()


func _on_rigid_body_3d_body_entered(body: Node) -> void:
	var p := rigid_body.global_position
	var v := rigid_body.linear_velocity
	match body.name:
		"Floor":
			if p.z > net_z and v.z > 0.5:
				var t: float = (bat.hit_plane_z - p.z) / v.z
				if t > 0.05:
					v.y = clampf((floor_y + hit_height - p.y) / t + 0.5 * _gravity * t, 3.0, 30.0)
				else:
					v.y = 6.0
			elif p.z <= net_z:
				v.y = far_bounce_speed
			else:
				v.y = 4.0
		"FarWall":
			v = _arc_to(p, _near_target(), serve_speed)
		"Player":
			if _hit_cooldown > 0.0 or _serve_timer > 0.0:
				return
			_hit_cooldown = 0.3
			var swing: Vector3 = bat.swing_velocity.limit_length(40.0)
			var edge := court_half_width - 3.0
			var x := clampf(p.x + swing.x * bat_aim, court_center_x - edge, court_center_x + edge)
			v = _arc_to(p, Vector3(x, floor_y + _radius, land_z_far), hit_speed)
			_rally += 1
			_best = maxi(_best, _rally)
			_update_label()
		_:
			return 
	rigid_body.linear_velocity = v


func _point_over() -> void:
	_serve_timer = 1.0


func _arc_to(from: Vector3, to: Vector3, speed: float) -> Vector3:
	var t := maxf(Vector2(to.x - from.x, to.z - from.z).length() / speed, 0.3)
	return Vector3(
		(to.x - from.x) / t,
		(to.y - from.y) / t + 0.5 * _gravity * t,
		(to.z - from.z) / t)


func _near_target() -> Vector3:
	var x := court_center_x + randf_range(-0.55, 0.55) * court_half_width
	return Vector3(x, floor_y + _radius, land_z_near)


func _make_label() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_label = Label.new()
	_label.position = Vector2(16, 12)
	_label.add_theme_font_size_override("font_size", 28)
	layer.add_child(_label)
	_update_label()


func _update_label() -> void:
	if _label:
		_label.text = "Rally: %d   Best: %d" % [_rally, _best]
