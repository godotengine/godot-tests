extends MeshInstance3D

@export var lineMaterial:Material
@export var debugIndicatorPath = ""

var immediate:ImmediateMesh

# Called when the node enters the scene tree for the first time.
func _ready():
	immediate = ImmediateMesh.new()
	mesh = immediate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	immediate.clear_surfaces()

	var preATipX = get_node(debugIndicatorPath + "/LOSolver_PreA/DebugIndicator/XAxis/TipEnd")
	var preATipY = get_node(debugIndicatorPath + "/LOSolver_PreA/DebugIndicator/YAxis/TipEnd")
	var preATipZ = get_node(debugIndicatorPath + "/LOSolver_PreA/DebugIndicator/ZAxis/TipEnd")

	var aTipX = get_node(debugIndicatorPath + "/LOSolver_A/DebugIndicator/XAxis/TipEnd")
	var aTipY = get_node(debugIndicatorPath + "/LOSolver_A/DebugIndicator/YAxis/TipEnd")
	var aTipZ = get_node(debugIndicatorPath + "/LOSolver_A/DebugIndicator/ZAxis/TipEnd")

	var bTipX = get_node(debugIndicatorPath + "/LOSolver_B/DebugIndicator/XAxis/TipEnd")
	var bTipY = get_node(debugIndicatorPath + "/LOSolver_B/DebugIndicator/YAxis/TipEnd")
	var bTipZ = get_node(debugIndicatorPath + "/LOSolver_B/DebugIndicator/ZAxis/TipEnd")

	var postBTipX = get_node(debugIndicatorPath + "/LOSolver_PostB/DebugIndicator/XAxis/TipEnd")
	var postBTipY = get_node(debugIndicatorPath + "/LOSolver_PostB/DebugIndicator/YAxis/TipEnd")
	var postBTipZ = get_node(debugIndicatorPath + "/LOSolver_PostB/DebugIndicator/ZAxis/TipEnd")
	
	if not preATipX:
		return
	if not aTipX:
		return
	if not bTipX:
		return
	if not postBTipX:
		return
	immediate.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, lineMaterial)
#	immediate.surface_set_color(Color(0, 0, 0))
	immediate.surface_add_vertex(preATipX.global_transform.origin)
	immediate.surface_add_vertex(aTipX.global_transform.origin)
	immediate.surface_add_vertex(bTipX.global_transform.origin)
	immediate.surface_add_vertex(postBTipX.global_transform.origin)
	immediate.surface_end()

	immediate.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, lineMaterial)
#	immediate.surface_set_color(Color(0, 0, 0))
	immediate.surface_add_vertex(preATipY.global_transform.origin)
	immediate.surface_add_vertex(aTipY.global_transform.origin)
	immediate.surface_add_vertex(bTipY.global_transform.origin)
	immediate.surface_add_vertex(postBTipY.global_transform.origin)
	immediate.surface_end()

	immediate.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, lineMaterial)
#	immediate.surface_set_color(Color(0, 0, 0))
	immediate.surface_add_vertex(preATipZ.global_transform.origin)
	immediate.surface_add_vertex(aTipZ.global_transform.origin)
	immediate.surface_add_vertex(bTipZ.global_transform.origin)
	immediate.surface_add_vertex(postBTipZ.global_transform.origin)
	immediate.surface_end()
