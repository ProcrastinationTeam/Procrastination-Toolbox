package;

import flixel.addons.editors.tiled.TiledTileSet;
import structs.Hitbox;
import haxe.xml.Fast;
import openfl.Assets;

class EncapsulateTilesetHitboxes
{
	public static var instance(default, null)		: EncapsulateTilesetHitboxes = new EncapsulateTilesetHitboxes();

	public var _tileSet								: TiledTileSet;
	public var _hitboxesMap							: Map<Int, Array<Hitbox>>;
	
	private var _isInit								: Bool = false;

	// Constructeur privé pour singletoniser
	private function new()
	{
		instance = this;
		
		// TODO: tweaker
		//var tilesetSource = new Fast(Xml.parse(Assets.getText("assets/tiled/tileset.tsx")));
		//_tileSet = new TiledTileSet(tilesetSource, "assets/tiled/");
		
		_hitboxesMap = new Map<Int, Array<Hitbox>>();
	}
	
	// TODO: moche
	public function init(tileSet:TiledTileSet):Void {
		
		// déjà init, on fait rien
		if (_isInit) {
			return;
		}
		
		// premier appel, on instancie
		//if (instance == null) {
			//instance = new EncapsulateTilesetHitboxes();
		//}
		
		_tileSet = tileSet;
		
		var tilesetSource:Fast = new Fast(Xml.parse(Assets.getText("assets/tiled/tileset.tsx")));
		extractHitboxes(tilesetSource);
		
		_isInit = true;
		
		//trace("ouech");
	}
	
	private function extractHitboxes(tilesetSource:Fast):Void
	{
		var nodes:List<Fast> = tilesetSource.node.tileset.nodes.tile;
		for (tileNode in nodes)
		{
			var id:Int = Std.parseInt(tileNode.att.id);
			var hitboxes:List<Fast> = tileNode.node.objectgroup.nodes.object;
			for (hitbox in hitboxes)
			{
				var x:Int = Std.parseInt(hitbox.att.x);
				var y:Int = Std.parseInt(hitbox.att.y);
				var width:Int = Std.parseInt(hitbox.att.width);
				var height:Int = Std.parseInt(hitbox.att.height);
				if (_hitboxesMap.get(id) == null)
				{
					_hitboxesMap.set(id, new Array<Hitbox>());
				}
				_hitboxesMap.get(id).push({x : x, y : y, width : width, height : height});
			}
		}
	}
}