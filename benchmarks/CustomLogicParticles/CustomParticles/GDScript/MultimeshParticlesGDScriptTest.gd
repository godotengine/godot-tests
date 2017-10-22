extends Node

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# This is a language benchmark, not rendering one. Increased amount of particles should not have any
# influence on the fps change, since they are rendered even if not visible. 
# The reason of fps drop is because computations are made for each single particle.
# When performance will drop for couple consecutive frames, the logic for particles will be turned off, 
# so after that amount of fps should be the save as at the very beginning 


const SPAWN_EXTENDS = Vector3(10,1,10) * 1.0;
const NMB_OF_MEASUREMENTS_BEFORE_TURN_OFF = 10;

export var visualisation = true;
export var turnOffTheLogicBelowFps = 45;
export var amount2EmitInOneGameTick = 5;

onready var particles = get_node("MeshGlobalParticles");

var delay = 0.0;
var nmbOfConsequentLowFpsFrames = 0;

func _ready():
	set_process(false);

func _process(delta):
	var fps = round(1.0 / delta); #Engine.get_frames_per_second();
	var text = "fps: " + str(fps)  + " | particles: " + str(particles.getAmountOfActiveParticles());
	get_node("Label").set_text(text);
	
	if(!particles.isLogicEnabled()): 
		get_node("Label").set_text(text + " | logic turned off below fps: " + str(turnOffTheLogicBelowFps));
		return
		
	if(fps < turnOffTheLogicBelowFps):
		nmbOfConsequentLowFpsFrames+=1;
		if(nmbOfConsequentLowFpsFrames>NMB_OF_MEASUREMENTS_BEFORE_TURN_OFF):
			particles.disableLogic();
	else:
		nmbOfConsequentLowFpsFrames = 0;
		for idx in range(amount2EmitInOneGameTick):
			emit();

func emit():
	var randPosition = Vector3(rand_range(-1.0,1.0)*SPAWN_EXTENDS.x, 1.0 + rand_range(-1.0,1.0)*SPAWN_EXTENDS.y,
		rand_range(-1.0,1.0)*SPAWN_EXTENDS.z);
	var lifetime = 500.0;
	var maxScale = 0.1 + randf()*0.2;
	var direction = Vector3(rand_range(-1.0, 1.0),1.0 + randf(),rand_range(-1.0, 1.0)).normalized() * (0.5 + randf() * 0.3); 
	var rotDirection = Vector3(rand_range(-1.0, 1.0),rand_range(-1.0, 1.0),rand_range(-1.0, 1.0)).normalized(); 
	var rotSpeed = randf();
	var color =  Color(0.1+randf()*0.9,0.1+randf()*0.9,0.1+randf()*0.9,1.0);
	particles.emitParticle(randPosition, lifetime, maxScale, direction, rotDirection, rotSpeed, color);
		

func _on_InitTimer_timeout():
	set_process(true);
	particles.enableLogic();
	if(visualisation):
		particles.show();
