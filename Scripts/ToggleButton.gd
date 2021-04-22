extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_ToggleButton_pressed():
	match($"/root/Graph".mode):
		"build_normal", "build_arrow":
			$"/root/Graph".switch_to_sim()
			text = "Build"
		"simulate":
			$"/root/Graph".switch_to_build()
			text = "Simulate"
