package;

import flixel.FlxSprite;
import flixel.FlxState;
import Data;
import flixel.tile.FlxTilemap;
import sys.io.File;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;

class PlayState extends FlxState
{
	private var heroSprite : FlxSprite;
	
	override public function create():Void
	{
		super.create();
		
		var content:String = File.getContent(AssetPaths.data__cdb);
		Data.load(content);
		
		trace("items : ");
		for (item in Data.items.all) {
			trace(item);
		}
		trace("npcs : ");
		for (npc in Data.npcs.all) {
			trace(npc);
		}
		//trace("collides :");
		//for (collide in Data.collides.all) {
			//trace(collide);
		//}
		
		var levelData:Data.LevelDatas = Data.levelDatas.get(LevelDatasKind.FirstVillage);
		
		var heroImage = Data.npcs.get(NpcsKind.Hero).image;
		heroSprite = new FlxSprite(levelData.npcs[0].x * heroImage.size, levelData.npcs[0].y * heroImage.size);
		heroSprite.loadGraphic(AssetPaths.chars__png, true, heroImage.size, heroImage.size, true);
		heroSprite.setFacingFlip(FlxObject.LEFT, false, false);
		heroSprite.setFacingFlip(FlxObject.RIGHT, true, false);
		heroSprite.animation.add("normal", [0, 8, 12], 4);
		heroSprite.animation.play("normal");
		
		var mapGround = new FlxTilemap();
		var groundLayer = levelData.layers[0];
		mapGround.loadMapFromArray(groundLayer.data.data.decode(), levelData.width, levelData.height, AssetPaths.forest__png, groundLayer.data.size, groundLayer.data.size, FlxTilemapAutoTiling.AUTO);
		
		var mapObjects = new FlxTilemap();
		var objectsLayer = levelData.layers[1];
		mapObjects.loadMapFromArray(objectsLayer.data.data.decode(), levelData.width, levelData.height, AssetPaths.forest__png, objectsLayer.data.size, objectsLayer.data.size, FlxTilemapAutoTiling.AUTO);
		
		
		var mapOver = new FlxTilemap();
		var overLayer = levelData.layers[2];
		mapOver.loadMapFromArray(overLayer.data.data.decode(), levelData.width, levelData.height, AssetPaths.forest__png, overLayer.data.size, overLayer.data.size, FlxTilemapAutoTiling.AUTO);
		
		//for (layer in levelData.layers) {
			//trace("name : " + layer.name);
			//trace("file : " + layer.data.file);
			//trace("size : " + layer.data.size);
			//trace("stride : " + layer.data.stride);
			//trace("data : " + layer.data.data.decode());
			//trace("");
		//}
		
		add(mapGround);
		add(mapObjects);
		add(mapOver);
		add(heroSprite);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.anyJustPressed([Z, UP])) {
			heroSprite.y -= 16;
		}
		if (FlxG.keys.anyJustPressed([Q, LEFT])) {
			heroSprite.x -= 16;
		}
		if (FlxG.keys.anyJustPressed([S, DOWN])) {
			heroSprite.y += 16;
		}
		if (FlxG.keys.anyJustPressed([D, RIGHT])) {
			heroSprite.x += 16;
		}
	}
}
