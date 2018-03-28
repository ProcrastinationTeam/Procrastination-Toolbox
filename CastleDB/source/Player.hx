package;

class Player extends FlxSprite
{
	public var money : Float;
	
	public function new(npc:Data.LevelDatas_npcs)
	{
		var heroData = Data.npcs.get(Data.NpcsKind.Hero);
		//var npcsTileset:cdb.Data.TilesetProps = Data.levelDatas.get(LevelDatasKind.FirstVillage).props.getTileset(Data.levelDatas, heroData.image.file);
		
		super(npc.x * heroData.image.size, npc.y * heroData.image.size);
		
		// TODO: re use AssetPaths ?
		loadGraphic("assets/" + heroData.image.file, true, heroData.image.size, heroData.image.size, true);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("normal", [0, 1, 2, 3], 4);
		animation.play("normal");
		
		money = 0;
	}
}