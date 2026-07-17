extends Voice
class_name VoiceMap

@export var sounds: Dictionary[String, AudioStream] = {}
@export var polyphony: int = 3

@export var silent_chars: String = " !,.?\"\'() "

func stream_for(char: String) -> AudioStream:
	char = char.to_lower()
	return sounds.get(char) if char in sounds else null
