extends Node3D

@export var replayTime:float = 0
@export var replaySpeed:float = 1
@export var replayTimeLoopStart = 0
@export var replayTimeLoopEnd = 100 * 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	replayTime += delta * 1000 * replaySpeed
	if (replayTime > replayTimeLoopEnd):
		replayTime = replayTimeLoopStart
	if (replayTime < replayTimeLoopStart):
		replayTime = replayTimeLoopEnd
	
	if Input.is_action_just_pressed("reset_playback"):
		replayTime = replayTimeLoopStart
		$DebugTraces_LOScript_slerp.clear()
		$DebugTraces_LOScript_cubic_slerp.clear()

	$Label_PlaybackPos.text =  " %1.2f s (%1.1f %%)" % [((replayTime - replayTimeLoopStart) / 1000), 100.0 * ((replayTime - replayTimeLoopStart) / (replayTimeLoopEnd - replayTimeLoopStart))]

func _input(event):
	if event is InputEventKey and event.pressed:
		var keyEvent:InputEventKey = event
		if (keyEvent.keycode == KEY_0):
			replaySpeed = 0
		elif ((keyEvent.keycode >= KEY_1) && (keyEvent.keycode <= KEY_9)):
			var tempSpeed:float = pow(2, keyEvent.keycode - KEY_7)

			if (Input.is_action_pressed("replay_backward")):
				tempSpeed *= -1

			replaySpeed = tempSpeed;

