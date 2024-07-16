class_name JumpingPlayerState
extends State

func enter() -> void:
	Global.player.velocity.y = Global.player.JUMP_VELOCITY
	Global.player.animation_player.play("jump")
	
func physics_process(delta: float) -> void:
	if Global.player.is_on_floor:
		if Global.player.velocity.length() > 0.0:
			transition.emit("WalkingPlayerState")
		else:
			transition.emit("IdlePlayerState")
