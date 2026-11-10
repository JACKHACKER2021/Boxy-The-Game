## Ukládání hry – pamatuje si poslední checkpoint (i po vypnutí hry).
class_name SaveGame

const PATH := "user://save.cfg"

static func save_checkpoint(level: String, pos: Vector2) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "level", level)
	cfg.set_value("game", "checkpoint", pos)
	cfg.save(PATH)

static func has_checkpoint() -> bool:
	var cfg := ConfigFile.new()
	return cfg.load(PATH) == OK and cfg.has_section_key("game", "checkpoint")

static func load_checkpoint(level: String) -> Variant:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK or cfg.get_value("game", "level", "") != level:
		return null
	return cfg.get_value("game", "checkpoint", null)

static func clear() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
