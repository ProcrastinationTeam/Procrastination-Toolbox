package;

import Data;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import openfl.Assets;
import typedefs.Goto;

class PlayState extends FlxState {
	
	private var levelDataName			: String;
	private var anchor					: String;
	
	private var level					: CdbLevel;
	
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
		//var content:String = File.getContent(AssetPaths.data__cdb);
		var content:String = Assets.getText(AssetPaths.data__cdb);
		Data.load(content);
		
		//levelData = Data.levelDatas.resolve(levelDataName);
		
		level = new CdbLevel(levelDataName, anchor);
		
		//////////////////////////////////////// Add all the layers in the right order
		// First "simple" ground tiles
		add(level.tilemapGround);
		
		// Then borders (autotiling)
		add(level.tilemapsGroundBorders);	
		
		// Then "ground objects" (alway under the rest)
		add(level.groundObjectsGroup);
		
		//////// Then "sortable" items (player, npcs, pickups, etc) so we can manipulate the draw order
		// objects (mostly non interactive doodads like trees, rocks, etc)
		add(level.sortableGroup);
		////////
		
		// Then "over objects" (alway above the rest)
		add(level.overObjectsGroup);
		
		// Then the over layer (top of trees and cliffs ?)
		add(level.tilemapOver);
		
		// Then, trigger zones
		add(level.changeScreenTriggers);
		
		// Adding the collisions group
		add(level.collisionsGroup);
		
		// Camera setup
		FlxG.camera.follow(level.player, FlxCameraFollowStyle.LOCKON, 0.5);
		FlxG.camera.snapToTarget();
		
		level.tilemapGround.follow(FlxG.camera, 0, true);
		
		FlxG.camera.fade(FlxColor.BLACK, 0.2, true);
	}
	
	override public function update(elapsed:Float):Void {
		// Mandatory
		super.update(elapsed);
		
		// Sort objects by their y value
		level.sortableGroup.sort(sortByY, FlxSort.DESCENDING);
		
		// Collisions handling
		FlxG.overlap(level.player, level.pickupSprites, PlayerPickup);
		
		FlxG.collide(level.player, level.npcSprites);
		FlxG.collide(level.player, level.collisionsGroup);
		FlxG.collide(level.player, level.objectsGroup);
		FlxG.collide(level.player, level.groundObjectsGroup);
		FlxG.collide(level.player, level.overObjectsGroup);
		
		FlxG.overlap(level.player, level.changeScreenTriggers, ChangeScreenTriggerCallback);
		
		// Debug
		#if debug
		if(FlxG.keys.pressed.SHIFT) {
			FlxG.camera.zoom += FlxG.mouse.wheel / 20.;
		}
		
		if (FlxG.keys.justPressed.ONE) {
			if (FlxG.keys.pressed.SHIFT) {
				level.tilemapsGroundBorders.visible = !level.tilemapsGroundBorders.visible;
			} else {
				level.tilemapGround.visible = !level.tilemapGround.visible;
			}
		}
		if (FlxG.keys.justPressed.TWO) {
			level.tilemapObjects.visible = !level.tilemapObjects.visible;
		}
		if (FlxG.keys.justPressed.THREE) {
			level.tilemapOver.visible = !level.tilemapOver.visible;
		}
		#end
	}
	
	private function ChangeScreenTriggerCallback(player:Player, triggerSprite:FlxSprite) {
		var goto:Goto = level.mapOfGoto.get(triggerSprite);
		
		FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() {
			FlxG.switchState(new PlayState(goto.l, goto.anchor));
		});
	}
	
	private function PlayerPickup(player:Player, pickup:Pickup):Void
	{
		if (player.alive && player.exists && pickup.alive && pickup.exists)
		{
			pickup.kill();
			player.money += pickup.money;
			trace(player.money);
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
}