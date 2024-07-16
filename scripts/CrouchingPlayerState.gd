class_name CrouchingPlayerState
extends State

func enter() -> void:
	Global.player.currentSPEED = Global.player.crouchingSPEED

func update(delta):
	if not Input.is_action_pressed("crouch"):
		transition.emit("IdlePlayerState")
	elif Input.is_action_just_pressed("jump") and Global.player.is_on_floor():
		transition.emit("JumpingPlayerState")

func physics_process(delta: float) -> void:
	# Add any physics-related logic for the crouching state here
	pass
