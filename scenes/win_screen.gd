extends Node2D

func _ready() -> void:
	MusicController.slow_down()
	if Global.winner == Global.Team.Light:
		SFX.play("eclipso_win")
		$ColorRect2/Header1.text = "ECLIPSO !! ECLIPSO !! ECLIPSO !! ECLIPSO !! ECLIPSO !! ECLIPSO !! "
		$Title.text = "ECLIPSO"
	
	else:
		SFX.play("lunaire_win")
		$ColorRect2/Header1.text = "LUNAIRE !! LUNAIRE !! LUNAIRE !! LUNAIRE !! LUNAIRE !! LUNAIRE !! "
		$Title.text = "LUNAIRE"
	$Title/Ttile2.text = $Title.text
	$ColorRect/Header2.text = $ColorRect2/Header1.text  
