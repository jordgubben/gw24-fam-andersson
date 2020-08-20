extends Control

export (float, 0, 5) var target: float = 0

func _process(delta):
	if target != $progress.value:
		var diff = self.target - $progress.value
		var change : float = diff * delta
		if abs(diff) <= $progress.step:
			$progress.value = self.target
		else:
			$progress.value += change
