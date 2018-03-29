package;

import flixel.math.FlxPoint;
import flixel.util.FlxTimer;

class Player extends FlxSprite
{
	public var money : Float;
	private var timeSinceLastMoved : Float;
	private var isAnimating : Bool;

	private var _isSprinting : Bool;
	
	public function new(npc:Data.LevelDatas_npcs)
	{
		var heroData = Data.npcs.get(Data.NpcsKind.Hero);
		//var npcsTileset:cdb.Data.TilesetProps = Data.levelDatas.get(LevelDatasKind.FirstVillage).props.getTileset(Data.levelDatas, heroData.image.file);
		
		super(npc.x * heroData.image.size, npc.y * heroData.image.size);
		
		// TODO: re use AssetPaths ?
		loadGraphic("assets/" + heroData.image.file, true, heroData.image.size, heroData.image.size, true);
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.LEFT, true, false);

		for(anim in heroData.animations) {
			animation.add(anim.name, [for(frame in anim.frames) frame.frame.x + frame.frame.y*heroData.image.size], anim.frameRate);
		}
		// TODO: get anim name from the data?
		animation.play("idle");
		
		drag.x = drag.y = 1600;
		
		setSize(8, 6);
		offset.set(4, 10);

		money = 0;
		timeSinceLastMoved = 0;
		isAnimating = false;
		_isSprinting = false;
	}

	override public function update(elapsed:Float):Void {
		movement(elapsed);

		super.update(elapsed);
	}

	/**
	 * Gestion des mouvements et sprint
	 */
	private function movement(elapsed:Float):Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		
		_up = FlxG.keys.anyPressed([UP, Z]);
		_down = FlxG.keys.anyPressed([DOWN, S]);
		_left = FlxG.keys.anyPressed([LEFT, Q]);
		_right = FlxG.keys.anyPressed([RIGHT, D]);
				
		_isSprinting = FlxG.keys.pressed.SPACE;

		if (_up && _down)
		{
			_up = _down = false;
		}

		if (_left && _right)
		{
			_left = _right = false;
		}

		if (_up || _down || _left || _right)
		{
			var _ma:Float = 0;
			timeSinceLastMoved = 0;

			if (_up)
			{
				_ma = -90;
				if (_left) {
					_ma -= 45;
				}
				else if (_right) {
					_ma += 45;
				}
			}
			else if (_down)
			{
				_ma = 90;
				if (_left) {
					_ma += 45;
				}
				else if (_right) {
					_ma -= 45;
				}
			}
			else if (_left)
			{
				_ma = 180;
				facing = FlxObject.LEFT;
			}
			else if (_right)
			{
				_ma = 0;
				facing = FlxObject.RIGHT;
			}
			
			if (_left)
			{
				facing = FlxObject.LEFT;
			}
			else if (_right)
			{
				facing = FlxObject.RIGHT;
			}
			
			var velocityX: Float = 0;

			velocityX = _isSprinting ? 250 : 75;
			
			velocity.set(velocityX, 0);
			velocity.rotate(FlxPoint.weak(0, 0), _ma);
			// if (!_isOnHisPhone && !_isInCallWithMom)
			// {
				
			// 	if ((velocity.x != 0 || velocity.y != 0) /*&& touching == FlxObject.NONE*/)
			// 	{
			if (_isSprinting)
			{
				animation.play("run");
			}
			else
			{
				animation.play("walk");
			}
			// 	}
			// }
		}
		else
		{
			timeSinceLastMoved += elapsed;

			if(timeSinceLastMoved >= 2) {
				if(FlxG.random.bool(95)) {
					animation.play("text");
				} else {
					animation.play("call");
				}
				isAnimating = true;
				var timer:FlxTimer = new FlxTimer();
				timer.start(2, function(timer:FlxTimer) {
					isAnimating = false;
				});
				timeSinceLastMoved = - (2 + 5);
			} else {
				if(!isAnimating) {
					animation.play("idle", true);
				}
			}
		}
	}
}