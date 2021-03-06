package;

import Data;
import flixel.FlxSprite;

class Pickup extends FlxSprite
{
	public var money : Float;
	
	public function new(pickup:Data.LevelDatas_pickups)
	{
		var pickupData = Data.pickups.get(pickup.kindId);
		var pickupsTileset:cdb.Data.TilesetProps = Data.levelDatas.get(LevelDatasKind.FirstVillage).props.getTileset(Data.levelDatas, pickupData.image.file);
		
		super(pickup.x * pickupData.image.size, pickup.y * pickupData.image.size);
		
		// TODO: re use AssetPaths ?
		loadGraphic("assets/" + pickupData.image.file, true, pickupData.image.size, pickupData.image.size);
		animation.frameIndex = pickupData.image.x + pickupData.image.y * pickupsTileset.stride;
		
		money = pickupData.money;
	}
}