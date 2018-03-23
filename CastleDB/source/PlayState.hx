package;

import flixel.FlxSprite;
import flixel.FlxState;
import Data;
import flixel.group.FlxSpriteGroup;
import flixel.tile.FlxTilemap;
import sys.io.File;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.tile.FlxTilemapExt;

class PlayState extends FlxState
{
	private var heroSprite : FlxSprite;
	private var npcSprites : FlxSpriteGroup;
	
	private var mapGround : FlxTilemapExt;
	private var mapObjects : FlxTilemapExt;
	private var mapOver : FlxTilemapExt;
	
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
		
		//[DB].[sheet].get([field]).[...]
		//[DB].[sheet].resolve(["field"]).[...]
		//[DB].[sheet].all[index].[...]
		
		var levelData:Data.LevelDatas = Data.levelDatas.get(LevelDatasKind.FirstVillage);
		
		//levelData.props.getLayer("ground").alpha
		//levelData.props.tileSize
		var forestTileset = levelData.props.getTileset(Data.levelDatas, "forest.png");
		trace(forestTileset.stride);
		//for (prop in forestTileset.props) {
			//trace(prop);
		//}
		//trace(forestTileset.props.length);
		//trace(forestTileset.sets.length);
		
		// TODO: trouver un moyen de pas mettre Dynamic
		var mapOfObjects:Map<Int, Dynamic> = new Map<Int, Dynamic>();
		for (set in forestTileset.sets) {
			//trace(set);
			switch(set.t) {
				case object:
					var potentialId = (set.y * forestTileset.stride) + set.x;
					if (potentialId == 240) {
						trace(set);
					}
					mapOfObjects[potentialId] = set;
				case border:
					//
				case group:
					//
				case ground:
					//
				default:
					trace('unknown type :' + set);
			}
		}
		
		mapGround = new FlxTilemapExt();
		var groundLayer = levelData.layers[0];
		mapGround.loadMapFromArray(groundLayer.data.data.decode(), levelData.width, levelData.height, AssetPaths.forest__png, groundLayer.data.size, groundLayer.data.size, FlxTilemapAutoTiling.OFF, 1);
		
		mapObjects = new FlxTilemapExt();
		var objectsLayer = levelData.layers[1];
		var objectsDataMap = [for (i in 0...(levelData.width * levelData.height)) 0];
		trace(objectsDataMap);
		
		// TODO: le faire pour d'autres si on détecte le 65535
		// TODO: supporter la superposition
		var objectsArray:Array<Int> = objectsLayer.data.data.decode();
		
		// On enlève le 65535
		objectsArray.shift();
		var numberOfObjects:Int = Std.int(objectsArray.length / 3);
		var specialTiles:Array<FlxTileSpecial> = new Array<FlxTileSpecial>();
		for (i in 0...numberOfObjects) {
			var xValue = objectsArray[3*i];
			var yValue = objectsArray[3*i + 1];
			var idValue = objectsArray[3*i + 2];
			
			// TODO: prendre en compte que ça peut être un float
			// ((xValue & ((1 << 15) - 1)) => ou binaire entre 0111 111 et la valeur, pour ne pas tenir compte du bit de poids fort qui sert de flag
			// / 16 parce que c'est en pixel et qu'on veut en tile
			var x:Int = Std.int((xValue & ((1 << 15) - 1)) / 16); // TODO: groundLayer.data.size ?
			var y:Int = Std.int((yValue & ((1 << 15) - 1)) / 16); // TODO: groundLayer.data.size ?
			var id:Int = idValue & ((1 << 15) - 1); // TODO: +1 ?
			
			var rotate90:Bool = xValue | (1 << 15) == 1 << 15;
			var rotate180:Bool = yValue | (1 << 15) == 1 << 15;
			var flip:Bool = idValue | (1 << 15) == 1 << 15;
			
			var rotate:Int = (rotate90 ? 1 : 0) + (rotate180 ? 2 : 0);
			
			// TEMP
			//objectsArray[3*i] = x;
			//objectsArray[3*i + 1] = y;
			//objectsArray[3 * i + 2] = id;
			//objectsDataMap[x + y * levelData.width] = id;
			
			// TODO: prendre en compte rotation/flip
			var set:Dynamic = mapOfObjects[id];
			if (set != null) {
				for (dy in 0...set.h) {
					for (dx in 0...set.w) {
						var tempX:Int = x + dx;
						var tempY:Int = y + dy;
						var tempId:Int = id + dx + (16 * dy);
						objectsDataMap[tempX + (tempY * levelData.width)] = tempId;
					}
				}
			}
			// TEMP
			
			if (rotate != 0 || flip) {
				var x = new FlxTileSpecial(id, flip, false, rotate);
				specialTiles.push(x);
			}
			
		}
		trace(objectsDataMap);
		mapObjects.loadMapFromArray(objectsDataMap, levelData.width, levelData.height, AssetPaths.forest__png, objectsLayer.data.size, objectsLayer.data.size, FlxTilemapAutoTiling.OFF, 0);
		mapObjects.setSpecialTiles(specialTiles);
		
		mapOver = new FlxTilemapExt();
		var overLayer = levelData.layers[2];
		mapOver.loadMapFromArray(overLayer.data.data.decode(), levelData.width, levelData.height, AssetPaths.forest__png, overLayer.data.size, overLayer.data.size, FlxTilemapAutoTiling.OFF, 1);
		
		for (layer in levelData.layers) {
			trace("name : " + layer.name);
			trace("file : " + layer.data.file);
			trace("size : " + layer.data.size);
			trace("stride : " + layer.data.stride);
			trace("data : " + layer.data.data.decode());
			trace("");
		}
		
		npcSprites = new FlxSpriteGroup();	
		
		for (npc in levelData.npcs) {
			switch(npc.kind.id) {
				case Data.NpcsKind.Hero:
					var hero = Data.npcs.get(Data.NpcsKind.Hero);
					heroSprite = new FlxSprite(npc.x * hero.image.size, npc.y * hero.image.size);
					heroSprite.loadGraphic(AssetPaths.chars__png, true, hero.image.size, hero.image.size, true);
					heroSprite.setFacingFlip(FlxObject.LEFT, false, false);
					heroSprite.setFacingFlip(FlxObject.RIGHT, true, false);
					heroSprite.animation.add("normal", [0, 1, 2, 3], 4);
					heroSprite.animation.play("normal");
				case Data.NpcsKind.Finrod:
					var finrod = Data.npcs.get(Data.NpcsKind.Finrod);
					var finrodSprite = new FlxSprite(npc.x * finrod.image.size, npc.y * finrod.image.size);
					finrodSprite.x -= finrod.image.size / 2;
					finrodSprite.y -= finrod.image.size;
					finrodSprite.loadGraphic(AssetPaths.chars__png, true, finrod.image.size * finrod.image.width, finrod.image.size * finrod.image.height);
					finrodSprite.animation.add("normal", [2], 1);
					finrodSprite.animation.play("normal");
					npcSprites.add(finrodSprite);
			}
		}
		
		add(mapGround);
		add(mapObjects);
		add(mapOver);
		add(heroSprite);
		add(npcSprites);
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
		
		if (FlxG.keys.justPressed.ONE) {
			mapGround.visible = !mapGround.visible;
		}
		if (FlxG.keys.justPressed.TWO) {
			mapObjects.visible = !mapObjects.visible;
		}
		if (FlxG.keys.justPressed.THREE) {
			mapOver.visible = !mapOver.visible;
		}
	}
}
