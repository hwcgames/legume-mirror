extends Voice
class_name VoiceList

@export var sounds: Array[AudioStream] = []
@export var polyphony: int = 3

@export var silent_chars: String = " !,.?\"\'() "

func stream_for(char: String) -> AudioStream:
	if silent_chars.contains(char):
		return null
	return sounds[randi_range(0, len(sounds)-1)]
