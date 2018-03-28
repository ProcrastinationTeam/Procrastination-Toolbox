import sys.io.File;

import openfl.display.Sprite;

import cdb.Data.TileMode;
import cdb.Lz4Reader;
import cdb.Module;
import cdb.TileBuilder;
import cdb.Types.ArrayRead;
import cdb.Types.Layer;
import cdb.Types.LevelPropsAccess;
import cdb.Types.TileLayer;
import cdb.Types.TileLayerData;
import cdb.Types.TilePos;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxSpriteGroup;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;

import Data;