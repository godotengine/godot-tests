extends Node3D

@export var replaySpeed:float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("reset_playback"):
		$AnimationPlayer.seek(0, true)
		$DebugTraces_slerp.clear()
		$DebugTraces_cubic_slerp.clear()

	$Label_PlaybackPos.text =  " %1.2f s (%1.1f %%)" % [$AnimationPlayer.current_animation_position, 100.0 * ($AnimationPlayer.current_animation_position / $AnimationPlayer.current_animation_length)]

func _input(event):
	if event is InputEventKey and event.pressed:
		var keyEvent:InputEventKey = event
		if (keyEvent.keycode == KEY_0):
			replaySpeed = 0
			$AnimationPlayer.playback_speed = 0
		elif ((keyEvent.keycode >= KEY_1) && (keyEvent.keycode <= KEY_9)):
			var tempSpeed:float = pow(2, keyEvent.keycode - KEY_7)

			if (Input.is_action_pressed("replay_backward")):
				tempSpeed *= -1

			replaySpeed = tempSpeed;

	$AnimationPlayer.playback_speed = replaySpeed
