@tool

extends Node3D

@export var WEAPON_TYPE : Weapons

@onready var mesh_instance_3d = %MeshInstance3D
@onready var mesh_instance_3d_2 = %MeshInstance3D2
@onready var mesh_instance_3d_shadow = %MeshInstance3DShadow
@onready var mesh_instance_3d_shadow_2 = %MeshInstance3DShadow2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_weapon()

func load_weapon() -> void:
	mesh_instance_3d.mesh = WEAPON_TYPE.mesh
	mesh_instance_3d_2.mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation
	mesh_instance_3d_shadow.visible = WEAPON_TYPE.shadow
	mesh_instance_3d_shadow_2.visible = WEAPON_TYPE.shadow
