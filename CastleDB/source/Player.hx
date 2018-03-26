package;

class Player extends FlxSprite
{

	public var money : Float;
	
	public function new(npc:Data.LevelDatas_npcs)
	{
		var hero = Data.npcs.get(Data.NpcsKind.Hero);
		
		super(npc.x * hero.image.size, npc.y * hero.image.size);
		loadGraphic(AssetPaths.chars__png, true, hero.image.size, hero.image.size, true);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("normal", [0, 1, 2, 3], 4);
		animation.play("normal");
		
		money = 0;
	}
	
}