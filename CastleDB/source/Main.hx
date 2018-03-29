package;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(50*16, 50*16, PlayState));
	}
}
