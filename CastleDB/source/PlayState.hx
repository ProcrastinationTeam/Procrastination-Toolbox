package;
import cdb.Data.LayerMode;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxSprite;
import flixel.addons.display.FlxZoomCamera;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxSort;

//var jdffdgdfg:cdb.Data.TilesetProps;

//var tileBuilder = new TileBuilder(tileSetProps, stride, total);
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

typedef Goto = {
	var l : String;
	var anchor : String;
}

class PlayState extends FlxState
{
	// "Entities"
	private var player 					: Player;
	private var npcSprites 				: FlxSpriteGroup				= new FlxSpriteGroup();
	private var pickupSprites 			: FlxSpriteGroup				= new FlxSpriteGroup();
	
	// Properties of the map (tile props and object props)
	private var mapOfObjects			: Map<Int, Set> 				= new Map<Int, Set>();
	private var mapOfProps				: Map<Int, Dynamic> 			= new Map<Int, Dynamic>();
	
	// Tilemaps
	// - One for the ground
	// - A group for ground borders (TODO: merge ?)
	// - One for the objects (mostly non interactive stuff (other than maybe collisions), like trees)
	// - One for over (??)
	private var tilemapGround			: FlxTilemap					= new FlxTilemap();
	private var tilemapsGroundBorders	: FlxTypedGroup<FlxTilemap>		= new FlxTypedGroup<FlxTilemap>();
	private var tilemapObjects 			: FlxTilemapExt					= new FlxTilemapExt();
	private var tilemapOver 			: FlxTilemap					= new FlxTilemap();
	
	private var groundObjectsGroup		: FlxSpriteGroup				= new FlxSpriteGroup();
	private var objectsGroup			: FlxSpriteGroup				= new FlxSpriteGroup();
	
	private var sortableGroup			: FlxSpriteGroup				= new FlxSpriteGroup();
	
	private var changeScreenTriggers	: FlxSpriteGroup				= new FlxSpriteGroup();
	
	private var mapOfGoto				: Map<FlxSprite, Goto> 			= new Map<FlxSprite, Goto>();
	private var mapOfAnchor				: Map<String, FlxPoint> 		= new Map<String, FlxPoint>();
	
	///////////////////////////////
	// From lowest to highest priority of collision (each successive one overrides the previous behaviour if there was one)
	// 1: Ground 	(water)
	// 2. Objects 	(trees, rocks, bridges, ladders, that kind of stuff)
	// 3. Collide	(full on funky layer with invisible walls, kill zones, mob only areas, etc)
	
	// Single array to handle multiple collisions per tile, example: bridge (object) above water (ground)
	private var arrayCollisions			: Array<Array<FlxObject>>;
	private var collisionsGroup			: FlxGroup						= new FlxGroup();
	
	// TODO: https://github.com/HaxeFlixel/flixel/issues/559 ?
	// private var tilemapCollisions		: FlxTilemap					= new FlxTilemap();
	///////////////////////////////
	
	// Depending on your map, this can impact the performances quite a lot
	// (With FlxTileMap as of March 2018, as far a I know)
	private static inline var ENABLE_MULTIPLE_GROUND_BORDER_TILEMAPS 	: Bool 	= true;
	private static inline var MAX_NUMBER_OF_GROUND_BORDER_TILEMAPS 		: Int 	= 20;
	
	
	
	// BORDEL
	private var houseSprite				: FlxSprite;
	private var levelDataName			: String;
	private var levelDataKind			: Data.LevelDatasKind;
	private var levelData 				: Data.LevelDatas;
	
	private var anchor					: String;
	
	var _zoomCam:FlxZoomCamera;
	
	public function new(levelDataName:String, ?anchor:String) {
		super();
		this.levelDataName = levelDataName;
		this.anchor = anchor;
	}
	
	override public function create():Void
	{
		super.create();
		
		if (levelDataName == null) {
			levelDataName = "FirstVillage";
		}
		
		// Init cdb
		var content:String = File.getContent(AssetPaths.data__cdb);
		Data.load(content);
		
		levelData = Data.levelDatas.resolve(levelDataName);
		
		//traces(levelData);
		
		// Default
		// trace(levelData.id);
		// trace(levelData.height);
		// trace(levelData.width);
		// trace(levelData.props);
		// trace(levelData.tileProps);
		// trace(levelData.layers);
		
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
		
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// TODO: More generic
		//
		var forestTileset = levelData.props.getTileset(Data.levelDatas, "forest.png");
		
		computeMapOfProps(forestTileset);
		computeMapOfObjects(forestTileset);
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		// Process layers (ground and borders, objects, tiles)
		processLayers(levelData);
		
		// Process npcs (and player)
		processNpcs(levelData.npcs);
		
		// Process pickups
		processPickups(levelData.pickups);
		
		// Process triggers
		processTriggerZones(levelData.triggers);
		
		//////////////////////////////////////// Add all the layers in the right order
		// First "simple" ground tiles
		add(tilemapGround);
		
		// Then borders (autotiling)
		add(tilemapsGroundBorders);	
		
		// Then "ground objects" (alway under the rest)
		add(groundObjectsGroup);
		
		//////// Then "sortable" items (player, npcs, pickups, etc) so we can manipulate the draw order
		// objects (mostly non interactive doodads like trees, rocks, etc)
		for (item in objectsGroup) {
			sortableGroup.add(item);
		}
		// pickups (custom layer)
		for (item in pickupSprites) {
			sortableGroup.add(item);
		}
		// npcs
		for (item in npcSprites) {
			sortableGroup.add(item);
		}
		// player
		sortableGroup.add(player);
		
		add(sortableGroup);
		////////
		
		// Then the over layer (top of trees and cliffs ?)
		add(tilemapOver);
		
		// Then, trigger zones
		add(changeScreenTriggers);
		
		// Adding the collisions group
		// TODO: move ? 
		for (y in 0...levelData.height) {
			for (x in 0...levelData.width) {
				if (arrayCollisions[y][x] != null) {
					collisionsGroup.add(arrayCollisions[y][x]);
				}
			}
		}
		add(collisionsGroup);
		
		// Camera setup
		FlxG.camera.follow(player, FlxCameraFollowStyle.LOCKON, 0.5);
		FlxG.camera.snapToTarget();
		FlxG.camera.bgColor = FlxColor.BLACK;
		
		tilemapGround.follow(FlxG.camera, 0, true);
		
		// TODO: Move ?
		// Place the player
		if (anchor != null) {
			var newPosition = mapOfAnchor.get(anchor);
			player.reset(newPosition.x * levelData.props.tileSize, newPosition.y * levelData.props.tileSize);
			FlxG.camera.snapToTarget();
		}
	}
	
	/**
	* Comparateur perso pour trier les sprites par Y croissant (en tenant compte de leur hauteur)
	* @param	Order
	* @param	Obj1
	* @param	Obj2
	* @return
	*/
	public static function sortByY(Order:Int, Obj1:FlxObject, Obj2:FlxObject):Int {
		return Obj1.y + Obj1.height < Obj2.y + Obj2.height ? -Order : Order;
	}

	override public function update(elapsed:Float):Void {
		// Mandatory
		super.update(elapsed);
		
		// Sort objects by their y value
		sortableGroup.sort(sortByY, FlxSort.DESCENDING);
		
		// Collisions handling
		FlxG.overlap(player, pickupSprites, playerPickup);
		
		FlxG.collide(player, npcSprites);
		FlxG.collide(player, collisionsGroup);
		FlxG.collide(player, objectsGroup);
		FlxG.collide(player, groundObjectsGroup);
		
		//FlxG.overlap(player, houseSprite, HouseEnter);
		FlxG.overlap(player, changeScreenTriggers, ChangeScreenTriggerCallback);
		
		// Debug
		#if debug
		if(FlxG.keys.pressed.SHIFT) {
			FlxG.camera.zoom += FlxG.mouse.wheel / 20.;
		}
		
		if (FlxG.keys.justPressed.ONE) {
			if (FlxG.keys.pressed.SHIFT) {
				tilemapsGroundBorders.visible = !tilemapsGroundBorders.visible;
			} else {
				tilemapGround.visible = !tilemapGround.visible;
			}
		}
		if (FlxG.keys.justPressed.TWO) {
			tilemapObjects.visible = !tilemapObjects.visible;
		}
		if (FlxG.keys.justPressed.THREE) {
			tilemapOver.visible = !tilemapOver.visible;
		}
		#end
	}
	
	//private function HouseEnter(player:Player, house:FlxSprite) {
		//FlxG.camera.fade(FlxColor.BLACK, 0.3, false, function() {
			//if (levelDataKind == FirstVillage) {
				//FlxG.switchState(new PlayState(Data.LevelDatasKind.House));
			//} else {
				//FlxG.switchState(new PlayState(Data.LevelDatasKind.FirstVillage));
			//}
			//FlxG.camera.fade(FlxColor.BLACK, 0.3, true);
		//});
	//}
	
	private function ChangeScreenTriggerCallback(player:Player, triggerSprite:FlxSprite) {
		var goto:Goto = mapOfGoto.get(triggerSprite);
		
		FlxG.camera.fade(FlxColor.BLACK, 0.3, false, function() {
			FlxG.switchState(new PlayState(goto.l, goto.anchor));
			FlxG.camera.fade(FlxColor.BLACK, 0.3, true);
		});
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
	
	// the first tile id is 1
	private function computeMapOfProps(tileset:cdb.Data.TilesetProps): Void {
		for (i in 0...tileset.props.length) {
			var prop:Dynamic = tileset.props[i];
			if (prop != null) {
				mapOfProps[i + 1] = prop;
			}
		}
		
		//for (key in mapOfProps.keys()) {
			//trace('[prop] $key => ${mapOfProps[key]}');
		//}
	}
	
	// the first tile id is 0
	private function computeMapOfObjects(tileset:cdb.Data.TilesetProps): Void {
		for (set in tileset.sets) {
			switch(set.t) {
				case object:
					var tileId = (set.y * tileset.stride) + set.x;
					mapOfObjects[tileId] = set;
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
		
		//for (key in mapOfObjects.keys()) {
			//trace('[object] $key => ${mapOfObjects[key]}');
		//}
	}
	
	private function processLayers(levelData:Data.LevelDatas):Void {
		for (layer in levelData.layers) {
			
			// Process the layer depending on the layer mode
			var mode:LayerMode = levelData.props.getLayer(layer.name).mode;
			switch(mode) {
				case LayerMode.Ground:
					trace('${layer.name}: Ground');
					processGroundLayer(layer, levelData);
				case LayerMode.Objects:
					trace('${layer.name}: Objects');
					processObjectLayer(layer, levelData);
				case LayerMode.Tiles:
					trace('${layer.name}: Tiles');
					// Never reached ? Tiles by default
					//processTileLayer(layer, levelData, tilemapOver); // TODO: just in case
				default:
					trace('${layer.name}: Default, probably Tiles');
					// TODO: Make generic
					processTileLayer(layer, levelData, tilemapOver);
			}
		}
	}
	
	private function processTileLayer(tileLayer: Data.LevelDatas_layers, levelData:Data.LevelDatas, tilemap:FlxTilemap):Void {
		tilemap.loadMapFromArray(tileLayer.data.data.decode(), levelData.width, levelData.height, "assets/" + tileLayer.data.file, tileLayer.data.size, tileLayer.data.size, FlxTilemapAutoTiling.OFF, 1);
	}
	
	private function processGroundLayer(groundLayer: Data.LevelDatas_layers, levelData:Data.LevelDatas):Void {
		// Simple ground
		processTileLayer(groundLayer, levelData, tilemapGround);
		
		// Borders
		var tileset = levelData.props.getTileset(Data.levelDatas, groundLayer.data.file);
		
		// TODO:
		// total argument seems useless, 624 in cdb (???), works for any value
		// at the end, groundMap.length = max(483, total+1)
		// (total number of tiles ? last tile id ?
		
		// /!\ This tileBuilder doesn't work the same as the Flixel one, it blends different tiles together /!\ 
		// There is not always a single tile per coordinate
		// (Comments in git/cdb/TileBuilder.hx laptop)
		
		var tileBuilder = new TileBuilder(tileset, groundLayer.data.stride, 0);
		var groundMapArray:Array<Int> = tileBuilder.buildGrounds(groundLayer.data.data.decode(), levelData.width);
		
		// TODO: array comprehension like above ?
		var groundBordersMapsData = new Array<Array<Int>>();
		
		// TODO: perfs
		// Create 4 tilemaps by default, more on the fly if needed
		for (i in 0...(ENABLE_MULTIPLE_GROUND_BORDER_TILEMAPS ? 4 : 1)) {
			var tempArray:Array<Int> = [for (i in 0...(levelData.width * levelData.height)) 0];
			groundBordersMapsData.push(tempArray);
		}
		
		var number:Int = Std.int(groundMapArray.length / 3);
		for (i in 0...number) {
			var x = groundMapArray[3*i];
			var y = groundMapArray[3*i + 1];
			var id = groundMapArray[3 * i + 2];
			
			var position = x + (y * levelData.width);
			
			// To check if the tile has been added
			var added = false;
			
			for (tempArray in groundBordersMapsData) {
				if (tempArray[position] == 0) {
					tempArray[position] = id;
					added = true;
					break;
				}
			}
			
			if (ENABLE_MULTIPLE_GROUND_BORDER_TILEMAPS && groundBordersMapsData.length < MAX_NUMBER_OF_GROUND_BORDER_TILEMAPS) {
				// If all the current tilemaps already contain something in the specified location, create a new one
				if (!added) {
					var tempArray:Array<Int> = [for (i in 0...(levelData.width * levelData.height)) 0];
					tempArray[position] = id;
					groundBordersMapsData.push(tempArray);
				}
			}
		}
		
		for (i in 0...groundBordersMapsData.length) {
			var groundBordersMapData:Array<Int> = groundBordersMapsData[i];
			var tilemapGroundBorders = new FlxTilemap();
			tilemapGroundBorders.loadMapFromArray(groundBordersMapData, levelData.width, levelData.height, "assets/" + groundLayer.data.file, groundLayer.data.size, groundLayer.data.size);			
			tilemapsGroundBorders.add(tilemapGroundBorders);
		}
		
		// TODO: move initialization ?
		arrayCollisions = [for (y in 0...levelData.height) [for (x in 0...levelData.width) null]];
		
		// Collisions
		for (y in 0...levelData.height) {
			for (x in 0...levelData.width) {
				var tileId:Int = tilemapGround.getTile(x, y);
				var prop:Dynamic = mapOfProps[tileId];
				if (prop != null && prop.collide != null && prop.collide == Full) {
					var groundCollisionObject = new FlxObject(x * groundLayer.data.size, y * groundLayer.data.size);
					groundCollisionObject.immovable = true;
					groundCollisionObject.allowCollisions = FlxObject.ANY;
					groundCollisionObject.setSize(groundLayer.data.size, groundLayer.data.size);
					groundCollisionObject.active = false;
					groundCollisionObject.moves = false;
					//groundCollisionObject.exists = false; // trop violent
					
					arrayCollisions[y][x] = groundCollisionObject;
				}
			}
		}
	}
	
	private function processObjectLayer(objectsLayer: Data.LevelDatas_layers, levelData:Data.LevelDatas):Void {
		var objectsDataMap:Array<Int> = [for (i in 0...(levelData.width * levelData.height)) 0];
		
		var tileset = levelData.props.getTileset(Data.levelDatas, objectsLayer.data.file);
		
		// TODO: supporter la superposition
		var objectsArray:Array<Int> = objectsLayer.data.data.decode();
		
		// Removing the leading 0xFFFF value
		objectsArray.shift();
		
		// Since there are 3 fields per objects (x, y, id), there are length/3 objects
		var numberOfObjects:Int = Std.int(objectsArray.length / 3);
		
		// TODO:
		// For rotated/flipped/animated tiles
		//var specialTiles:Array<FlxTileSpecial> = new Array<FlxTileSpecial>();
		
		for (i in 0...numberOfObjects) {
			var xValue = objectsArray[3*i];
			var yValue = objectsArray[3*i + 1];
			var idValue = objectsArray[3*i + 2];
			
			// TODO: x and y can actually be Floats
			// This just extracts the actual value (in pixel, not tile), ignoring the optional higher bit
			var x:Int = Std.int((xValue & ((1 << 15) - 1)) / objectsLayer.data.size);
			var y:Int = Std.int((yValue & ((1 << 15) - 1)) / objectsLayer.data.size);
			var id:Int = idValue & ((1 << 15) - 1);
			
			// These just check if the higher bit is set
			// TODO: Optimize ?
			// +90° rotation flag is encoded into the higher bit
			var rotate90:Bool = (xValue | (1 << 15)) == 1 << 15;
			
			// +180° rotation flag is encoded into the higher bit
			var rotate180:Bool = (yValue | (1 << 15)) == 1 << 15;
			
			// Horizontal flip flag is encoded into the higher bit
			var flip:Bool = (idValue | (1 << 15)) == 1 << 15;
			
			// Final rotation
			var rotation:Int = (rotate90 ? 1 : 0) + (rotate180 ? 2 : 0);
			
			// Sets all the tiles of the object (if width > 1 || height > 1)
			var set:Set = mapOfObjects[id];
			if (set != null) {
				for (dy in 0...set.h) {
					for (dx in 0...set.w) {
						var tempX:Int = x + dx;
						var tempY:Int = y + dy;
						var tempId:Int = id + dx + (tileset.stride * dy);
						objectsDataMap[tempX + (tempY * levelData.width)] = tempId;
					}
				}
			} else {
				// TODO:
			}
			
			// TODO: Take rotation/flip/animation in account
			//if (rotation != 0 || flip) {
				//var specialTile = new FlxTileSpecial(id, flip, false, rotation);
				//specialTiles.push(specialTile);
			//}
		}
		 //trace(objectsDataMap);
		tilemapObjects.loadMapFromArray(objectsDataMap, levelData.width, levelData.height, "assets/" + objectsLayer.data.file, objectsLayer.data.size, objectsLayer.data.size, FlxTilemapAutoTiling.OFF, 0);
		//tilemapObjects.setSpecialTiles(specialTiles);
		
		for (y in 0...levelData.height) {
			for (x in 0...levelData.width) {
				
				var tileId:Int = tilemapObjects.getTile(x, y);
				
				// 0 means there is no tile, so we skip
				if (tileId == 0) {
					continue;
				}
				
				// Increment because the tilesheet is 1-based
				tileId++;
				
				var prop:Dynamic = mapOfProps[tileId];
				
				var objectSprite:FlxSprite = tilemapObjects.tileToSprite(x, y, 0, function(tileProperty:FlxTileProperties) {
					var sprite = new FlxSprite(x * objectsLayer.data.size, y * objectsLayer.data.size);
					sprite.frame = tileProperty.graphic.frame;
					sprite.immovable = true;
					sprite.allowCollisions = FlxObject.NONE;
					sprite.active = false;
					sprite.moves = false;
					sprite.setSize(objectsLayer.data.size, objectsLayer.data.size);
					
					return sprite;
				});
				
				if (prop == null || prop.hideHero == null || prop.hideHero == 0) {
					groundObjectsGroup.add(objectSprite);
				} else {
					objectsGroup.add(objectSprite);
				}
				
				if (prop != null && prop.collide != null) {
					
					objectSprite.allowCollisions = FlxObject.ANY;
					
					// If there already was a collision information for this coordinate, we discard it
					// Object collision overrides ground collisions (ex: bridge)
					arrayCollisions[y][x] = null;
					
					switch(prop.collide) {
						case Full:
							// Default
							
						case Small:
							// USE RESET
							// If you just set x and y, "last" is not updated and fucks up collisions
							
							var offsetX = objectsLayer.data.size / 4;
							var offsetY = objectsLayer.data.size / 4;
							var sizeX = objectsLayer.data.size / 2;
							var sizeY = objectsLayer.data.size / 2;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case No:
							//trace(prop);
							objectSprite.allowCollisions = FlxObject.NONE;
							
						case Top:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Right:
							var offsetX = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Bottom:
							var offsetX = 0;
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Left:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case HalfTop:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 2;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case HalfBottom:
							var offsetX = 0;
							var offsetY = objectsLayer.data.size / 2;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 2;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case HalfLeft:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 2;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case HalfRight:
							var offsetX = objectsLayer.data.size / 2;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 2;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Vertical:
							var offsetX = objectsLayer.data.size / 3;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case Horizontal:
							var offsetX = 0;
							var offsetY = objectsLayer.data.size / 3;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case SmallTR:
							var offsetX = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case SmallBR:
							var offsetX = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case SmallBL:
							var offsetX = 0;
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case SmallTL:
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size / 4;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
						case CornerTR:
							// TODO: horrible
							var tempSprite = new FlxSprite(objectSprite.x, objectSprite.y);
							tempSprite.makeGraphic(objectsLayer.data.size, objectsLayer.data.size, FlxColor.TRANSPARENT);
							tempSprite.immovable = true;
							tempSprite.allowCollisions = FlxObject.ANY;
							tempSprite.active = false;
							tempSprite.moves = false;
							
							// TOP
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
							// RIGHT
							var offsetX2 = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY2 = 0;
							var sizeX2 = objectsLayer.data.size / 4;
							var sizeY2 = objectsLayer.data.size;
							
							tempSprite.reset(tempSprite.x + offsetX2, tempSprite.y + offsetY2);
							tempSprite.setSize(sizeX2, sizeY2);
							tempSprite.offset.set(offsetX2, offsetY2);
							
							objectsGroup.add(tempSprite);
							
						case CornerBR:
							// TODO: horrible
							var tempSprite = new FlxSprite(objectSprite.x, objectSprite.y);
							tempSprite.makeGraphic(objectsLayer.data.size, objectsLayer.data.size, FlxColor.TRANSPARENT);
							tempSprite.immovable = true;
							tempSprite.allowCollisions = FlxObject.ANY;
							tempSprite.active = false;
							tempSprite.moves = false;
							
							// BOTTOM
							var offsetX = 0;
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
							// RIGHT
							var offsetX2 = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var offsetY2 = 0;
							var sizeX2 = objectsLayer.data.size / 4;
							var sizeY2 = objectsLayer.data.size;
							
							tempSprite.reset(tempSprite.x + offsetX2, tempSprite.y + offsetY2);
							tempSprite.setSize(sizeX2, sizeY2);
							tempSprite.offset.set(offsetX2, offsetY2);
							
							objectsGroup.add(tempSprite);
							
						case CornerBL:
							// TODO: horrible
							var tempSprite = new FlxSprite(objectSprite.x, objectSprite.y);
							tempSprite.makeGraphic(objectsLayer.data.size, objectsLayer.data.size, FlxColor.TRANSPARENT);
							tempSprite.immovable = true;
							tempSprite.allowCollisions = FlxObject.ANY;
							tempSprite.active = false;
							tempSprite.moves = false;
							
							// BOTTOM
							var offsetX = 0;
							var offsetY = objectsLayer.data.size - (objectsLayer.data.size / 4);
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
							// LEFT
							var offsetX2 = 0;
							var offsetY2 = 0;
							var sizeX2 = objectsLayer.data.size / 4;
							var sizeY2 = objectsLayer.data.size;
							
							tempSprite.reset(tempSprite.x + offsetX2, tempSprite.y + offsetY2);
							tempSprite.setSize(sizeX2, sizeY2);
							tempSprite.offset.set(offsetX2, offsetY2);
							
							objectsGroup.add(tempSprite);
							
						case CornerTL:
							// TODO: horrible
							var tempSprite = new FlxSprite(objectSprite.x, objectSprite.y);
							tempSprite.makeGraphic(objectsLayer.data.size, objectsLayer.data.size, FlxColor.TRANSPARENT);
							tempSprite.immovable = true;
							tempSprite.allowCollisions = FlxObject.ANY;
							tempSprite.active = false;
							tempSprite.moves = false;
							
							// TOP
							var offsetX = 0;
							var offsetY = 0;
							var sizeX = objectsLayer.data.size;
							var sizeY = objectsLayer.data.size / 4;
							
							objectSprite.reset(objectSprite.x + offsetX, objectSprite.y + offsetY);
							objectSprite.setSize(sizeX, sizeY);
							objectSprite.offset.set(offsetX, offsetY);
							
							// LEFT
							var offsetX2 = 0;
							var offsetY2 = 0;
							var sizeX2 = objectsLayer.data.size / 4;
							var sizeY2 = objectsLayer.data.size;
							
							tempSprite.reset(tempSprite.x + offsetX2, tempSprite.y + offsetY2);
							tempSprite.setSize(sizeX2, sizeY2);
							tempSprite.offset.set(offsetX2, offsetY2);
							
							objectsGroup.add(tempSprite);
							
						// TODO: One is WALL (LEFT | RIGHT), the other is TOP | DOWN, but I don't know yet which is which
						case Ladder:
							objectSprite.allowCollisions = FlxObject.LEFT | FlxObject.RIGHT; // ie FlxObject.WALL
							
						case VLadder:
							objectSprite.allowCollisions = FlxObject.UP | FlxObject.DOWN;
							
						default: 
							objectSprite.allowCollisions = FlxObject.NONE;
							//trace('($x, $y) : $tileId => $prop');
					}
				} else {
					// No object with collision at this position
					//trace('($x, $y)');
				}
			}
		}
	}
	
	private function processNpcs(npcs:ArrayRead < Data.LevelDatas_npcs > ):Void {
		for (npc in npcs) {
			switch(npc.kindId) {
				case NpcsKind.Hero:			
					player = new Player(npc);
					
				case NpcsKind.Finrod:
					var finrod = Data.npcs.get(Data.NpcsKind.Finrod);
					var finrodSprite = new FlxSprite(npc.x * levelData.props.tileSize, npc.y * levelData.props.tileSize);
					finrodSprite.immovable = true;
					finrodSprite.x -= finrod.image.size / 2;
					finrodSprite.y -= finrod.image.size;
					finrodSprite.loadGraphic("assets/" + finrod.image.file, true, finrod.image.size * finrod.image.width, finrod.image.size * finrod.image.height, false);
					finrodSprite.animation.frameIndex = 2;
					
					for(anim in finrod.animations) {
						finrodSprite.animation.add(anim.name, [for(frame in anim.frames) frame.frame.x + frame.frame.y * finrod.image.width], anim.frameRate);
					}
					finrodSprite.animation.play("idle");
					
					npcSprites.add(finrodSprite);
			}
		}
	}
	
	private function processPickups(pickups:ArrayRead < Data.LevelDatas_pickups > ):Void {
		for (pickup in pickups) {
			var pickupSprite = new Pickup(pickup);
			pickupSprites.add(pickupSprite);
		}
	}
	
	private function processTriggerZones(triggers:ArrayRead < Data.LevelDatas_triggers > ):Void {
		for (trigger in triggers) {
			switch(trigger.action) {
				case Data.Action.Anchor(id):
					// Spawn point
					trace('Anchor - id: [$id]');
					
					mapOfAnchor.set(id, new FlxPoint(trigger.x, trigger.y));
					
				case Data.Action.Goto(l, anchor):
					// Departure point
					trace('Goto - l: [$l] - anchor: [$anchor]');
					
					var sprite = new FlxSprite(trigger.x * levelData.props.tileSize, trigger.y * levelData.props.tileSize);
					sprite.setSize(levelData.props.tileSize * trigger.width, levelData.props.tileSize * trigger.height);
					sprite.makeGraphic(levelData.props.tileSize * trigger.width, levelData.props.tileSize * trigger.height, FlxColor.TRANSPARENT);
					sprite.immovable = true;
					sprite.active = false;
					sprite.moves = false;
					//sprite.allowCollisions = FlxObject.NONE;
					
					var goto:Goto = {l: l, anchor: anchor};
					
					changeScreenTriggers.add(sprite);
					mapOfGoto.set(sprite, goto);
					
				case Data.Action.ScrollStop:
					// Osef (scrollbounds ?)
			}
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
			// Int, width (in tiles) of the tilesheet
			
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
