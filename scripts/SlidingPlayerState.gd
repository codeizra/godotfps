class_name SlidingPlayerState
extends State


func enter() -> void:
	Global.player.sliding = true
	Global.player.slide_timer = Global.player.slide_timer_max
	Global.player.slide_vector =Vector2(Global.player.direction.x, Global.player.direction.z)
	
func physics_process(delta: float) -> void:
	Global.player.slide_timer -= delta
	if Global.player.slide_timer <= 0:
		transition.emit("IdlePlayerState")
	elif Input.is_action_just_pressed("jump"):
		Global.player.sliding = false
		Global.player.velocity.y = Global.player.JUMP_VELOCITY
		Global.player.animation_player.play("jump")
		transition.emit("JumpingPlayerState")
