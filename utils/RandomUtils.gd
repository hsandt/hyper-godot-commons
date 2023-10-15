class_name RandomUtils
## Util static functions for random operations


## Return a random float in [0; 1)
static func exclusive_randf() -> float:
		# up to 15 decimals under zero, 0.999... is not 1.0 yet
		return min(randf(), 0.999999999999999)
