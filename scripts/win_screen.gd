extends Control


func play_win(team_one_win : bool):
	show()
	MusicController.slow_down()
	if team_one_win:
		$ColorRect2/Header1.text = "ECLIPSO !! ECLIPSO !! ECLIPSO !! ECLIPSO !! ECLIPSO !! ECLIPSO !! "
		$Title.text = "ECLIPSO"
	
	else:
		$ColorRect2/Header1.text = "LUNAIRE !! LUNAIRE !! LUNAIRE !! LUNAIRE !! LUNAIRE !! LUNAIRE !! "
		$Title.text = "LUNAIRE"
	
	$AnimationPlayer.play("in")
	$Title/Ttile2.text = $Title.text
	$ColorRect/Header2.text = $ColorRect2/Header1.text  
	await Util.wait(0.75)
	SFX.play("eclipso_win" if team_one_win else "lunaire_win")
	await $AnimationPlayer.animation_finished
	hide()
