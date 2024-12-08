# This script is an autoload, that can be accessed from any other script!

extends Node

@onready var jump_sfx = $JumpSfx
@onready var coin_pickup_sfx = $CoinPickup
@onready var death_sfx = $DeathSfx
@onready var respawn_sfx = $RespawnSfxMUTED
@onready var level_complete_sfx = $LevelCompleteSfx
@onready var level_music = $LevelMusic

func _ready() -> void:
	var allDemonsOfHell = [jump_sfx,coin_pickup_sfx,death_sfx, respawn_sfx, level_complete_sfx, level_music]
	for AudioPlayer in allDemonsOfHell:
		AudioPlayer.volume_db = -80 # BE SILENT
		# we might need to adjust the music if my first carnal need is to disable it after adding
