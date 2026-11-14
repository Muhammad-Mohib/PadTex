extends AnimatableBody3D

@export var hit_plane_z := -6.0  
@export var floor_y := -2.5
@export var min_height := 1.0     

var PlayerRotation: Vector3
var RotationSpeed: float = 30.0
var swing_velocity := Vector3.ZERO  

var isPaused := false

@onready var PauseMenu := $CanvasGroup/Panel 

func _ready() -> void:
	PlayerRotation = rotation_degrees

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			PlayerRotation.y += RotationSpeed
		elif event.button_index == MOUSE_BUTTON_LEFT:
			PlayerRotation.y -= RotationSpeed
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if(!isPaused):
				get_tree().paused = true
				PauseMenu.visible = true
				isPaused = true
			else:
				PauseMenu.visible = false
				get_tree().paused = false
				isPaused = false
			print("RESUME")

func _physics_process(delta: float) -> void:
	if(!isPaused):
		var cursor_pos = get_viewport().get_mouse_position()
		var camera = get_viewport().get_camera_3d()
		var origin: Vector3 = camera.project_ray_origin(cursor_pos)
		var direction: Vector3 = camera.project_ray_normal(cursor_pos)
		if direction.z > -0.001:
			return

		var target: Vector3 = origin + direction * ((hit_plane_z - origin.z) / direction.z)
		target.y = maxf(target.y, floor_y + min_height)
		swing_velocity = (target - global_position) / delta
		global_position = target
		rotation_degrees.y = PlayerRotation.y
