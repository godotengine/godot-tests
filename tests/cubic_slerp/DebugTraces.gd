extends MeshInstance3D

@export var pointMaterial:Material
@export var tipHistoryLength:int = 240
@export var debugIndicatorPath = ""
@export var minDistanceBetweenPoints:float = 0.01

var immediate:ImmediateMesh

var tipXHistory = []
var tipYHistory = []
var tipZHistory = []

# Called when the node enters the scene tree for the first time.
func _ready():
	immediate = ImmediateMesh.new()
	mesh = immediate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var interpolatedTipX = get_node(debugIndicatorPath + "/XAxis/TipEnd")
	var interpolatedTipY = get_node(debugIndicatorPath + "/YAxis/TipEnd")
	var interpolatedTipZ = get_node(debugIndicatorPath + "/ZAxis/TipEnd")

	if not interpolatedTipX:
		return	
	if not interpolatedTipY:
		return
	if not interpolatedTipZ:
		return
	if (tipXHistory.size() == 0 or
		interpolatedTipX.global_transform.origin.distance_to(tipXHistory[tipXHistory.size()-1]) >= minDistanceBetweenPoints or
		interpolatedTipY.global_transform.origin.distance_to(tipYHistory[tipYHistory.size()-1]) >= minDistanceBetweenPoints or
		interpolatedTipZ.global_transform.origin.distance_to(tipZHistory[tipZHistory.size()-1]) >= minDistanceBetweenPoints
	):
		tipXHistory.push_back(interpolatedTipX.global_transform.origin)
		tipYHistory.push_back(interpolatedTipY.global_transform.origin)
		tipZHistory.push_back(interpolatedTipZ.global_transform.origin)

	while tipXHistory.size() > tipHistoryLength:
		tipXHistory.pop_front()
	while tipYHistory.size() > tipHistoryLength:
		tipYHistory.pop_front()
	while tipZHistory.size() > tipHistoryLength:
		tipZHistory.pop_front()

	immediate.clear_surfaces()
	
	immediate.surface_begin(Mesh.PRIMITIVE_POINTS, pointMaterial)
	immediate.surface_set_color(Color(0.5, 0, 0))
	for coords in tipXHistory:
		immediate.surface_add_vertex(coords)
	immediate.surface_end()

	immediate.surface_begin(Mesh.PRIMITIVE_POINTS, pointMaterial)
	immediate.surface_set_color(Color(0, 0.5, 0))
	for coords in tipYHistory:
		immediate.surface_add_vertex(coords)
	immediate.surface_end()

	immediate.surface_begin(Mesh.PRIMITIVE_POINTS, pointMaterial)
	immediate.surface_set_color(Color(0, 0, 0.5))
	for coords in tipZHistory:
		immediate.surface_add_vertex(coords)
	immediate.surface_end()

func clear():
	tipXHistory.clear()
	tipYHistory.clear()
	tipZHistory.clear()
	
