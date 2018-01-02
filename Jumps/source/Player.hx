package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import utils.Tweaking;
import flixel.math.FlxPoint;

class Player extends FlxSprite
{
	
	var jumping 		: Bool = false;
	var doubleJumped 	: Bool = false;
	
	var fsm 			: FlxFSM<FlxSprite>;
	
	public function new(?X:Float=0, ?Y:Float=0)
	{
		super(X, Y);

		loadGraphic(Tweaking.playerSprite, true, 16, 16);
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.LEFT, true, false);

		animation.add("idle", [0], 10, true);
		animation.add("walk", [0, 1, 2, 1], 6, true);
		animation.add("run", [4, 3], 6, true);
		animation.add("text", [5, 6], 6, true);
		animation.add("call", [7, 8], 6, true);

		//drag.x = drag.y = 1600;
		
		maxVelocity.x = 600;
		maxVelocity.y = 2000;
		
		drag.x = maxVelocity.x * 8;
		acceleration.y = 3000;

		scale = new FlxPoint(3, 3);
		updateHitbox();
		
		fsm = new FlxFSM<FlxSprite>(this);
		fsm.transitions
			.add(Idle, Jump, Conditions.jump)
			.start(Idle);
	}

	override public function update(elapsed:Float):Void
	{
		movement();
		//fsm.update(elapsed);
		super.update(elapsed);
	}
	
	/**
	 * Gestion des mouvements
	 */
	private function movement():Void
	{
		// https://www.youtube.com/watch?v=hG9SzQxaCm8
		// dernière partie (euler, interpolation) déjà implémentée par flixel
		// le double saut avec saut paramètrable est pas très cool avec cette façon (ou alors faut beaucoup tweaker peut être)
		
		var moveUp:Bool = FlxG.keys.anyPressed(Tweaking.moveUpKeys());
		var moveUpJustPressed:Bool = FlxG.keys.anyJustPressed(Tweaking.moveUpKeys());
		//var moveDown:Bool = FlxG.keys.anyPressed([Tweaking.moveDown]);
		var moveLeft:Bool = FlxG.keys.anyPressed(Tweaking.moveLeftKeys());
		var moveRight:Bool = FlxG.keys.anyPressed(Tweaking.moveRightKeys());
		
		// Durée avant hauteur max
		// th = xh / vx
		
		// Impulsion y
		// v0 = 2 * h * vx / xh
		
		// Gravité
		// g = -2 * h * vx² / xh²
		
		var h : Float = 150;
		var xh : Float = 150;
		//var vx : Float = velocity.x;
		var vx : Float = maxVelocity.x;
		
		// th = xh / vx => 
		
		var v0 : Float = (2 * h * vx) / xh;
		var v1 : Float = 1 * v0;
		
		var g : Float = ( -2 * h * vx * vx) / (xh * xh);
		
		if (velocity.y < 0) {
			// phase ascendante
			// trace('up');
			// bon g
			if (moveUp) {
				// on maintient la touche de saut, c'est bien
				// vérifier qu'on a pas lâché à un moment quand même
			} else {
				// on maintient pas, plus gros g
				g *= 4;
			}
		} else if(velocity.y > 0) {
			// phase descendante
			// trace('down');
			// changer g
			g *= 1.2;
			// éventuellement, baisser temporairement l'acceleration max
			//maxVelocity.y = 20;
		} else {
			// Apex ou idle
		}
		
		//trace(g);
		acceleration.y = -g;		
		
		if (moveLeft)
		{
			acceleration.x = -maxVelocity.x * 6;
			facing = FlxObject.LEFT;
		}
		if (moveRight)
		{
			acceleration.x = maxVelocity.x * 6;
			facing = FlxObject.RIGHT;
		}
		if (moveUpJustPressed && isTouching(FlxObject.FLOOR))
		{
			//velocity.y = -maxVelocity.y / 2;
			velocity.y = -v0;
			jumping = true;
		}
		
		if (moveUpJustPressed && !isTouching(FlxObject.FLOOR) && !doubleJumped) {
			velocity.y = -v1;
			doubleJumped = true;
			//trace('bonjour');
		}
		
		if (isTouching(FlxObject.FLOOR)) {
			jumping = false;
			doubleJumped = false;
		}
		
		//trace(velocity.y);
		
		//
		//if (isTouching(FlxObject.FLOOR)) {
			//maxVelocity.y = 2000;
		//}
		
		if (velocity.x != 0)
		{
			animation.play("walk");
		}
		else
		{
			animation.play("idle");
		}
	}
}

class Conditions {
	public static function jump(Owner:FlxSprite):Bool {
		return FlxG.keys.anyJustPressed(Tweaking.moveUpKeys()) && Owner.isTouching(FlxObject.FLOOR);
	}
}

// Idle ou marche
class Idle extends FlxFSMState<FlxSprite> {
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void {
		owner.animation.play('idle');
	}
	
	override public function update(elapsed:Float, owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void {
		
	}
}

// Saut (phase ascendante ? sans le double ?)
class Jump extends FlxFSMState<FlxSprite> {
	override public function enter(owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void {
		//owner.animation.play("jumping");
	}
	
	override public function update(elapsed:Float, owner:FlxSprite, fsm:FlxFSM<FlxSprite>):Void {
		//
	}
}