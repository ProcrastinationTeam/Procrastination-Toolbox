package hud;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;

class Hud extends FlxTypedGroup<FlxSprite>
{
	public var _width			: Int = 720;
	public var _height			: Int = 720;
	private var _player 		: Player;

	public var _testSprite		: FlxSprite;
	public var _miniMap			: FlxSprite;
	public var _playerInfos		: FlxSprite;

	public function new(player:Player)
	{
		super();

		_player = player;

		var x:Int = 20000;

		// Pour fixer la cam
		_testSprite = new FlxSprite(x + 0, 0).makeGraphic(_width, _height, FlxColor.TRANSPARENT);
		//_testSprite.setPosition(x, 32);
		add(_testSprite);
		
		_playerInfos = new FlxSprite(x + 32, 32).makeGraphic(64, 32, FlxColor.BLUE);
		add(_playerInfos);
		
		_miniMap = new FlxSprite(x + 720 - 32 - 64, 32).makeGraphic(64, 64, FlxColor.BLUE);
		_miniMap.alpha = 0.3;
		add(_miniMap);
	}
}