package;

//var jdffdgdfg:cdb.Data.TilesetProps;

//var tileBuilder:TileBuilder = new TileBuilder(tileSetProps, stride, total);
//var ground:Array<Int> = tileBuilder.buildGrounds(input, width);

//Data.decode(Data.levelDatas.all); // ?? cf issue

//[DB].[sheet].get([field]).[...]
//[DB].[sheet].resolve(["field"]).[...]
//[DB].[sheet].all[index].[...]

// TODO: Ajouter à castle direct celui là ?
typedef Set = {
	var x : Int;
	var y : Int;
	var w : Int;
	var h : Int;
	var t : cdb.Data.TileMode;
	var opts : cdb.Data.TileModeOptions;
}

class PlayState extends FlxState
{
	private var player 				: Player;
	private var npcSprites 			: FlxSpriteGroup			= new FlxSpriteGroup();
	private var pickupSprites 		: FlxSpriteGroup			= new FlxSpriteGroup();
	
	private var mapGround 			: FlxTilemapExt				= new FlxTilemapExt();
	private var mapObjects 			: FlxTilemapExt				= new FlxTilemapExt();
	private var mapOver 			: FlxTilemapExt				= new FlxTilemapExt();
	
	private var maps				: Array<FlxTilemapExt>		= new Array<FlxTilemapExt>();
	
	private var mapOfObjects		: Map<Int, Set> 			= new Map<Int, Set>();
	private var mapOfProps			: Map<Int, Dynamic> 		= new Map<Int, Dynamic>();
	
	override public function create():Void
	{
		super.create();
		
		// Init cdb
		var content:String = File.getContent(AssetPaths.data__cdb);
		Data.load(content);
		
		var levelData:Data.LevelDatas = Data.levelDatas.get(LevelDatasKind.FirstVillage);
		var emptyLevelData:Data.EmptyLevels = Data.emptyLevels.get(Data.EmptyLevelsKind.EmptyLevel);
		
		//traces(levelData);
		
		// Default
		// trace(emptyLevelData.id);
		// trace(emptyLevelData.height);
		// trace(emptyLevelData.width);
		// trace(emptyLevelData.props);
		// trace(emptyLevelData.tileProps);
		// trace(emptyLevelData.layers);
		
		trace(levelData.level);
		// Unique identifier (column is named "id" by default)
		
		trace(levelData.height);
		// Height (in tiles)
		
		trace(levelData.width);
		// Width (in tiles)
		
		trace(levelData.props);
		// layers : Array<{ 
		// 		l (layer) : String, (layer's name)
		//		p (props) : { 
		//						?color : Int (integer representation ?), 
		// 						?alpha : Float (between 0 and 1), 
		//						?mode : String ("ground" or "objects", assumed tiles mode otherwise) }
		// 					}
		// }>,
		// tileSize : Int (size of the map tiles, one tile is [tileSize] pixels wide)
		
		trace(levelData.tileProps);
		// TODO: 
		// Gibberish ? Each column is a new item in the list in the palette in the level editor (lots of "in the")
		// Each row ?
		
		// trace(levelData.layers);
		traceLayers(levelData);
		
		var forestTileset = levelData.props.getTileset(Data.levelDatas, "forest.png");
		trace('forestTileset stride: ${forestTileset.stride}');
		
		computeMapOfProps(forestTileset);
		computeMapOfObjects(forestTileset);
		
		processLayers(levelData);
		processObjectLayer(levelData, levelData.layers[1]);
		processNpcs(levelData.npcs);
		processPickups(levelData.pickups);
		
		add(mapGround);
		add(mapObjects);
		add(mapOver);
		add(pickupSprites);
		add(npcSprites);
		add(player);
		
		
		
		
		
		
		// Ca marche si on remplace certains upper/lower qui disparaissent
		trace(forestTileset);
		trace(forestTileset.props.length);
		trace(forestTileset.sets.length);
		var tileBuilder:TileBuilder = new TileBuilder(forestTileset, 16, 624);
		var ground:Array<Int> = tileBuilder.buildGrounds(levelData.layers[0].data.data.decode(), 50);
		trace(ground);
		
		var ground2 = [for (i in 0...(levelData.width * levelData.height)) 0];
		var number:Int = Std.int(ground.length / 3);
		for (i in 0...number) {
			var xValue = ground[3*i];
			var yValue = ground[3*i + 1];
			var idValue = ground[3 * i + 2];
			
			ground2[xValue + (yValue * levelData.width)] = idValue;
		}
		var mapObjectss:FlxTilemapExt = new FlxTilemapExt();
		mapObjectss.loadMapFromArray(ground2, levelData.width, levelData.height, AssetPaths.forest__png, 16, 16, FlxTilemapAutoTiling.OFF, 0);
		add(mapObjectss);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.anyJustPressed([Z, UP])) {
			player.y -= 16;
		}
		if (FlxG.keys.anyJustPressed([Q, LEFT])) {
			player.x -= 16;
		}
		if (FlxG.keys.anyJustPressed([S, DOWN])) {
			player.y += 16;
		}
		if (FlxG.keys.anyJustPressed([D, RIGHT])) {
			player.x += 16;
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
		
		FlxG.overlap(player, pickupSprites, playerPickup);
	}
	
	private function playerPickup(player:Player, pickup:Pickup):Void
	{
		if (player.alive && player.exists && pickup.alive && pickup.exists)
		{
			pickup.kill();
			player.money += pickup.money;
			trace(player.money);
		}
	}
	
	private function processNpcs(npcs:ArrayRead < Data.LevelDatas_npcs > ):Void {
		for (npc in npcs) {
			switch(npc.kindId) {
				case NpcsKind.Hero:			
					player = new Player(npc);
					
				case NpcsKind.Finrod:
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
	}
	
	private function processPickups(pickups:ArrayRead < Data.LevelDatas_pickups > ):Void {
		for (pickup in pickups) {
			var pickupSprite:Pickup = new Pickup(pickup);
			pickupSprites.add(pickupSprite);
		}
	}
	
	private function processLayers(levelData:Data.LevelDatas):Void {
		for (layer in levelData.layers) {
			// Soit décoder et regarder le premier élément si c'est 0xFFFF, soit regarder dans levelData.props.l == layer.name => si p.mode && p.mode == "object"
			
		}
		var groundLayer = levelData.layers[0];
		mapGround.loadMapFromArray(groundLayer.data.data.decode(), levelData.width, levelData.height, AssetPaths.forest__png, groundLayer.data.size, groundLayer.data.size, FlxTilemapAutoTiling.OFF, 1);
		
		var overLayer = levelData.layers[2];
		mapOver.loadMapFromArray(overLayer.data.data.decode(), levelData.width, levelData.height, AssetPaths.forest__png, overLayer.data.size, overLayer.data.size, FlxTilemapAutoTiling.OFF, 1);
	}
	
	private function processObjectLayer(levelData:Data.LevelDatas, layer: Data.LevelDatas_layers ):Void {
		var objectsLayer = layer;
		var objectsDataMap = [for (i in 0...(levelData.width * levelData.height)) 0];
		
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
			var set:Set = mapOfObjects[id];
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
				var xx = new FlxTileSpecial(id, flip, false, rotate);
				specialTiles.push(xx);
			}
		}
		trace(objectsDataMap);
		mapObjects.loadMapFromArray(objectsDataMap, levelData.width, levelData.height, AssetPaths.forest__png, objectsLayer.data.size, objectsLayer.data.size, FlxTilemapAutoTiling.OFF, 0);
		mapObjects.setSpecialTiles(specialTiles);
	}
	
	private function computeMapOfObjects(tileset:cdb.Data.TilesetProps): Void {
		for (set in tileset.sets) {
			trace(set);
			switch(set.t) {
				case object:
					var computedId = (set.y * tileset.stride) + set.x;
					mapOfObjects[computedId] = set;
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
	}
	
	private function computeMapOfProps(tileset:cdb.Data.TilesetProps): Void {
		for (i in 0...tileset.props.length) {
			var prop:Dynamic = tileset.props[i];
			if (prop != null) {
				mapOfProps[i] = prop;
			}
		}
		for (key in mapOfProps.keys()) {
			trace('$key => ${mapOfProps[key]}');
		}
	}
	
	private function traceLayers(levelData:Data.LevelDatas):Void {
		// List of layers in the "layers" column
		for (layer in levelData.layers) {
			trace("name : " + layer.name);
			// String, name of the layer
			
			trace("blending: " + layer.blending);
			// Enumeration (Add, Multiply, Erase) ?
			
			trace("file : " + layer.data.file);
			// String, name of the tileset file
			
			trace("size : " + layer.data.size);
			// Int, size of the tiles in the tileset
			
			trace("stride : " + layer.data.stride);
			// Int, width (in tiles) of the tilesheet (ISSUE: have to select file twice for it to be correct)
			
			trace("data : " + layer.data.data.decode());
			// Array<Int>
			// either width x height with tile id as a value (ground/tile)
			// or 0xFFFF (65535) to indicate object array, then numberOfObjects x 3 (x, y, top left id)
			
			trace("");
		}
	}
	
	private function traces(levelData:Data.LevelDatas):Void {
		trace("items : ");
		for (item in Data.items.all) {
			trace(item);
		}
		trace("npcs : ");
		for (npc in Data.npcs.all) {
			trace(npc);
		}
		trace("collides :");
		for (collide in Data.collides.all) {
			trace(collide);
		}
		
		//trace(Data.ItemsKind);
		trace(Data.items.get(Data.ItemsKind.Sword));
		trace(Data.items.resolve("Sword"));
		
		// Ok
		trace(Data.items.resolve("Guinea Pig", true));
		
		// Would crash because there is no "Guinea Pig" object (sadly)
		//trace(Data.items.resolve("Guinea Pig", false));
		
		//trace(forestTileset.props.length);
		//trace(forestTileset.sets.length);
		
		//Data.collides.all
		//Data.levelDatas.get().collide.
		//var ertert:Layer<Collides>;
		
		//trace("sets:");
		//trace(levelData.collide.decode());
		
		//levelData.props.getLayer("ground").alpha
		//levelData.props.tileSize
		
		//var something:cdb.Data.SOME_TYPE;
	}
}
