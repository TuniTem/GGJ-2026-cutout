extends Node2D

func _ready() -> void:
	if Global.winner == Global.Team.Light:
		SFX.play("eclipso_win")
		$ColorRect2/Header1.text = "ECLIPSO !! ECLIPSO !! ECLIPSO !! ECLIPSO !! ECLIPSO !! ECLIPSO !! "
		$Title.text = "ECLIPSO"
		$SWAP.hide()
	else:
		SFX.play("lunaire_win")
		$ColorRect2/Header1.text = "LUNAIRE !! LUNAIRE !! LUNAIRE !! LUNAIRE !! LUNAIRE !! LUNAIRE !! "
		$Title.text = "LUNAIRE"
		$SWAP.show()
	$Title/Ttile2.text = $Title.text
	$ColorRect/Header2.text = $ColorRect2/Header1.text  
