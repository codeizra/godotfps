class_name WalkingPlayerState

extends State

func enter() -> void:
	Global.player.currentSPEED = Global.player.walkingSPEED

func update(delta):
	if Global.player.velocity.length() == 0.0 :
		transition.emit("IdlePlayerState")
	elif Input.is_action_just_pressed("jump") and Global.player.is_on_floor:
		transition.emit("JumpingPlayerState")
	elif Input.is_action_just_pressed("sprint"):
		transition.emit("SprintingPlayerState")
	elif Input.is_action_just_pressed("crouch"):
		transition.emit("CrouchingPlayerState")
	
