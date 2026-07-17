@abstract
extends Resource
class_name Voice

@export var min_delay: float = 0.3
@export var volume: float = -24

@abstract
func stream_for(char: String) -> AudioStream
