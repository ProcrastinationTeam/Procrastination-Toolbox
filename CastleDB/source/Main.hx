package;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(400, 400, PlayState));
	}
}
