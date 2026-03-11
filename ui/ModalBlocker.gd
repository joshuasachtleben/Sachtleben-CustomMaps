extends "res://systems/input/InputProcessor.gd"

func handleStart():
	pass

func buttonEvent(event) -> bool:
	if justPressed(event, "ui_cancel") or justPressed(event, "escape"):
		var p = get_parent()
		if p and p.has_method("_on_cancel"):
			p._on_cancel()
	return true

func stick_move(event) -> bool:
	return true
