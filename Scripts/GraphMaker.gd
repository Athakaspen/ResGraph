extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ArrowConnections := {
	"Arrow1": ["Node1", "Node2", 0, "allowed"],
	"Arrow2": ["Node2", "Node3", 0, "request"],
	"Arrow3": ["Node3", "Node4", 0, "allowed"],
	"Arrow4": ["Node4", "Node5", 0, "request"],
	"Arrow5": ["Node5", "Node1", 0, "request"],
	"Arrow6": ["Node1", "Node3", 0, "allocation"],
	"Arrow7": ["Node2", "Node4", 0, "request"],
	"Arrow8": ["Node3", "Node5", 0, "allowed"],
	"Arrow9": ["Node4", "Node1", 0, "request"],
   "Arrow10": ["Node5", "Node2", -10, "request"],
   "Arrow11": ["Node5", "Node2", 10, "request"],
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for arrowName in ArrowConnections:
		get_node("Arrows/"+arrowName).p1 = get_node("Nodes/"+ArrowConnections[arrowName][0]).global_position
		get_node("Arrows/"+arrowName).p2 = get_node("Nodes/"+ArrowConnections[arrowName][1]).global_position
		get_node("Arrows/"+arrowName).offset = ArrowConnections[arrowName][2]
		get_node("Arrows/"+arrowName).mode = ArrowConnections[arrowName][3]
