extends Spatial 
################################### R E A D M E ##################################
#
# Hints after first rework in 3.0:
# Main performance bottleneck is GDScript. I should rewrite those to shader at some point, but maybe it will be enough 
# to have this code in c# or as gdnative. You can easily test this by emitting 4000 particles with current code, observe
# fps drop and then disable logic (but not the rendering!) disableLogic()
#

##################################################################################
#####  Variables (Constants, Export Variables, Node Vars, Normal variables)  #####
######################### var myvar setget myvar_set,myvar_get ###################
const NMB_OF_PARTICLES = 12000; #max amount. feel fry to increase if the language you are testing is able to reach the limit, but ensure you have similar results with visualisation off
const WHITE_COLOR = Color(1,1,1,1);

export (Mesh) var particleMesh;

var waitingParticles = PoolIntArray();
var activeParticles  = PoolIntArray();

#var particleGlobalPosRoots = Vector3Array();
var particlesData = [];

var multimeshInstance;

##################################################################################
#########                          Init code                             #########
##################################################################################
var firstTimeInReady = true;
func _notification(what):
	if (what == NOTIFICATION_INSTANCED):
		pass
	elif(what == NOTIFICATION_READY):
		if(firstTimeInReady): 
			firstTimeInReady = false;
			initGlobalParticles();
			hide();
			set_process(false);

func initGlobalParticles():
	multimeshInstance = get_node("MultiMeshInst");
	
	var multimeshRes = MultiMesh.new();
	multimeshRes.transform_format = MultiMesh.TRANSFORM_3D;
	multimeshRes.color_format = MultiMesh.COLOR_FLOAT;
	multimeshRes.set_mesh(particleMesh);
	multimeshRes.set_instance_count(NMB_OF_PARTICLES);
	
	multimeshInstance.set_multimesh(multimeshRes);
	initParticlesData();
	
func initParticlesData():
	particlesData.resize(NMB_OF_PARTICLES);
	for idx in range(NMB_OF_PARTICLES):
		particlesData[idx] = ParticleData.new();

	var multimesh = multimeshInstance.get_multimesh();
	var particlesCount = multimesh.get_instance_count();
	for idxParticle in range(particlesCount):
		waitingParticles.append(idxParticle);
		hideParticle(multimesh, idxParticle);
		
		multimesh.set_instance_color(idxParticle, WHITE_COLOR);

##################################################################################
#########                       Getters and Setters                      #########
##################################################################################
func getAmountOfActiveParticles():
	return activeParticles.size();

func isLogicEnabled():
	return is_processing();

##################################################################################
#########              Should be implemented in inheritanced             #########
##################################################################################

##################################################################################
#########                    Implemented from ancestor                   #########
##################################################################################
func _process(delta):
	
	#
	var multimesh = multimeshInstance.get_multimesh();
	
	#
	var nmbOfActiveParticles = activeParticles.size();
	for idxInActiveParticlesList in range(nmbOfActiveParticles): #nmbOfActiveParticles):
		if(idxInActiveParticlesList>=activeParticles.size()): return;
		var activeParticleIdx = activeParticles[idxInActiveParticlesList];
		var particleData = particlesData[activeParticleIdx];
		particleData.lifeTime += delta;
		
		#
		var particlePercentLife = particleData.lifeTime / particleData.maxLifeTime;
		
		#life time end
		if(particlePercentLife>1.0):
			waitingParticles.append(activeParticleIdx);
			activeParticles.remove(idxInActiveParticlesList);
			nmbOfActiveParticles = nmbOfActiveParticles-1;
			hideParticle(multimesh, activeParticleIdx, (nmbOfActiveParticles==0));
			
			idxInActiveParticlesList = idxInActiveParticlesList-1;
			continue;
		
		#		
		var currentLocalBasePos = multimesh.get_instance_transform(activeParticleIdx).origin; #get_global_transform().origin;
		currentLocalBasePos = currentLocalBasePos + (particleData.direction*delta);
		
		var lscale;
		if(particlePercentLife<particleData.matureAtLifePercent): lscale = interpolateLinearBetween2Points(0.0, 0.0,particleData.matureAtLifePercent, particleData.maxScale, particlePercentLife); #ease(particlePercentLife*2.0, -0.5);
		elif(particlePercentLife<1.0): lscale = interpolateLinearBetween2Points(particleData.matureAtLifePercent, particleData.maxScale,1.0,0.0, particlePercentLife); #ease(1.0-particlePercentLife, -0.5);
		else: lscale = 0.0;
		
		particleData.rot_amount += particleData.rot_speed * delta;
		var trans = Transform(Basis().rotated(particleData.rot_direction, particleData.rot_amount).scaled(Vector3(lscale,lscale,lscale)), currentLocalBasePos);
#		var rotationBasis = Basis().rotated(Vector3(), particleData.rot_amount).scaled(Vector3(lscale,lscale,lscale));
#		var trans = Transform();
	
		multimesh.set_instance_transform(activeParticleIdx, trans);

#is there any way to actually not render a mesh in multimesh? Know for sure it was not possible in 2.0.
#if yes then will need to rewrite this node
func hideParticle(inMultimesh, inParticleId, forceTurnOffEmitter = false):
	var zeroScaleTransform = Transform()
	zeroScaleTransform = zeroScaleTransform.scaled(Vector3(0,0,0)) 
	inMultimesh.set_instance_transform(inParticleId, zeroScaleTransform);
	if(activeParticles.size()==0) || forceTurnOffEmitter:
		set_process(false);
		hide();

func showParticle(inMultimesh, inParticleId, inPos, inColor):
	inMultimesh.set_instance_transform(inParticleId, Transform(Basis().scaled(Vector3(0,0,0)), inPos));
	inMultimesh.set_instance_color(inParticleId, inColor);
	
##################################################################################
#########                         Public Methods                         #########
##################################################################################
func disableLogic():
	set_process(false);

func enableLogic():
	set_process(true);

func canEmitNewParticle():
	return waitingParticles.size()>0;

func emitParticle(inEmitPos, maxLifetime, maxScale = 1.0, direction = Vector3(0,1,0), rotationDirection = Vector3(0,1,0), 
	rotationSpeed = 0.0, inColor = Color()):
	if(activeParticles.size() > NMB_OF_PARTICLES): return;
	if(waitingParticles.size()<=0): return; 
	
	var multimesh = multimeshInstance.get_multimesh();
	#get first free particle;
	var freeParticleIdx = waitingParticles.size()-1;
	var particleID = waitingParticles[freeParticleIdx];
	waitingParticles.remove(freeParticleIdx);
	activeParticles.append(particleID);
	
	var particleData = particlesData[particleID];
	particleData.maxLifeTime = maxLifetime;
	particleData.maxScale = maxScale;
	particleData.direction = direction;
	particleData.rot_direction = rotationDirection;
	particleData.rot_speed = rotationSpeed;
	particleData.lifeTime = 0.0;
	particleData.rot_amount = randf() * 2 * PI; #0.0;
	
	showParticle(multimesh, particleID, inEmitPos, inColor);

##################################################################################
#########                         Inner Methods                          #########
##################################################################################



#as far as I know similar method is now part of godot core. But hey! It's a language benchmark after all!
static func interpolateLinearBetween2Points( inP1,  inP1Val,  inP2, inP2Val, interpolationPoint):
	return ((interpolationPoint * inP1Val) - (interpolationPoint * inP2Val) + (inP1 * inP2Val) - (inP2 * inP1Val))/ (inP1 - inP2);


##################################################################################
#########                         Inner Classes                          #########A
##################################################################################
class ParticleData:
	var lifeTime = 0.0;
	var maxLifeTime = 0.0;
	var maxScale = 0.75;
	var matureAtLifePercent = 0.005; 
	var direction = Vector3();
	var rot_direction = Vector3();
	var rot_amount = 0.0
	var rot_speed = 1.0;
