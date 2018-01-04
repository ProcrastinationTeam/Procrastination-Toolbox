package;

import flash.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.FlxPointer;
import flixel.math.FlxRect;
import flixel.math.FlxVector;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxGradient;
import flixel.math.FlxPoint;
import openfl.display.DisplayObject;
import openfl.display.LineScaleMode;
import openfl.geom.Rectangle;
import sys.io.File;
import openfl.utils.ByteArray;
import flixel.addons.util.PNGEncoder;
import flash.filters.BitmapFilter;
import flixel.math.FlxMath;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	var playerSpriteSize : Int = 16;
	
	var player1Sprite : FlxSprite;
	var player2Sprite : FlxSprite;
	
	var camera1 : FlxCamera;
	var camera2 : FlxCamera;
	var cameraBoth : FlxCamera;
	var cameraHud : FlxCamera;
	var cameraDebug : FlxCamera;
	
	var camera1Mask : FlxCamera;
	var camera2Mask : FlxCamera;
	
	var speed : Float = 4;
	
	var displayScreen : Int = 0;
	
	var canvas : FlxSprite;
	var canvasHud : FlxSprite;
	
	var minX : Float = -100000;
	var minY : Float = -100000;
	var maxX : Float =  100000;
	var maxY : Float =  100000;
	
	var distanceBetweenPlayers : Float;
	var maxDistanceBetweenPlayers : Float = 216;
	
	var centerOfPlayers : FlxSprite;
	
	var player1Zone : FlxSprite;
	var player1ZoneMask : FlxSprite;
	var player1ZoneFinal : FlxSprite;
	
	var player2Zone : FlxSprite;
	var player2ZoneMask : FlxSprite;
	var player2ZoneFinal : FlxSprite;
	
	var spriteTemp : FlxSprite = new FlxSprite();
	var spriteTempMask : FlxSprite = new FlxSprite();
	var spriteTempOutput : FlxSprite = new FlxSprite();
	
	override public function create():Void
	{
		super.create();
		
		var gradient:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.RED, FlxColor.YELLOW, FlxColor.PINK, FlxColor.GREEN], 16, 112, true);
		var grid:FlxSprite = FlxGridOverlay.overlay(gradient, 16, 16, FlxG.width, FlxG.height);
		add(grid);
		
		canvas = new FlxSprite();
		canvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(canvas);
		
		canvasHud = new FlxSprite();
		canvasHud.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(canvasHud);
		
		player1Sprite = new FlxSprite(50);
		player1Sprite.makeGraphic(playerSpriteSize, playerSpriteSize, FlxColor.RED);
		player1Sprite.screenCenter(FlxAxes.Y);
		add(player1Sprite);
		
		var halfWidth:Int = Std.int(FlxG.width / 2);
		var zoom:Int = 3;
		
		camera1 = new FlxCamera(0, 0, Std.int(FlxG.width / (2 * zoom)), Std.int(FlxG.height / zoom), zoom);
		camera1.setScrollBoundsRect(0, 0, FlxG.width, FlxG.height);
		camera1.follow(player1Sprite);
		FlxG.cameras.add(camera1);
		
		/////////////////////////////////////////////////////////////////////////////////////////
		
		player2Sprite = new FlxSprite(FlxG.width - 50 - playerSpriteSize);
		player2Sprite.makeGraphic(playerSpriteSize, playerSpriteSize, FlxColor.BLUE);
		player2Sprite.screenCenter(FlxAxes.Y);
		add(player2Sprite);
		
		camera2 = new FlxCamera(halfWidth, 0, Std.int(FlxG.width / (2 * zoom)), Std.int(FlxG.height / zoom), zoom);
		camera2.setScrollBoundsRect(0, 0, FlxG.width, FlxG.height);
		camera2.follow(player2Sprite);
		FlxG.cameras.add(camera2);
		
		cameraHud = new FlxCamera();
		cameraHud.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(cameraHud);
		
		cameraDebug = new FlxCamera(-Std.int(FlxG.width / 4), -Std.int(FlxG.height / 4), FlxG.width * 2, FlxG.height * 2, 0.5);
		cameraDebug.setScrollBoundsRect(0, 0, FlxG.width * 2, FlxG.height * 2);
		cameraDebug.follow(grid);
		cameraDebug.visible = false;
		FlxG.cameras.add(cameraDebug);
		
		centerOfPlayers = new FlxSprite();
		centerOfPlayers.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		add(centerOfPlayers);
		
		cameraBoth = new FlxCamera(0, 0, Std.int(FlxG.width / zoom), Std.int(FlxG.height / zoom), zoom);
		cameraBoth.setScrollBoundsRect(0, 0, FlxG.width, FlxG.height);
		cameraBoth.follow(centerOfPlayers);
		cameraBoth.visible = false;
		FlxG.cameras.add(cameraBoth);
		
		//var player1Zone : FlxSprite;
		//var player1ZoneMask : FlxSprite;
		//var player1ZoneFinal : FlxSprite;
		//
		//var player2Zone : FlxSprite;
		//var player2ZoneMask : FlxSprite;
		//var player2ZoneFinal : FlxSprite;
		
		camera1Mask = new FlxCamera();
		camera1Mask.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera1Mask);
		
		player1Zone = new FlxSprite();
		player1Zone.makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
		player1Zone.cameras = [camera1Mask];
		
		player1ZoneMask = new FlxSprite();
		player1ZoneMask.makeGraphic(FlxG.width, FlxG.height - 1, FlxColor.TRANSPARENT); // TODO: Sans le -1 ça marche pas -_-
		player1ZoneMask.cameras = [camera1Mask];
		
		player1ZoneFinal = new FlxSprite();
		player1ZoneFinal.cameras = [camera1Mask];
		add(player1ZoneFinal);
		
		// 
		camera2Mask = new FlxCamera();
		camera2Mask.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camera2Mask);
		
		player2Zone = new FlxSprite();
		player2Zone.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLUE);
		player2Zone.cameras = [camera2Mask];
		
		player2ZoneMask = new FlxSprite();
		player2ZoneMask.makeGraphic(FlxG.width, FlxG.height - 1, FlxColor.TRANSPARENT); // TODO: Sans le -1 ça marche pas -_-
		player2ZoneMask.cameras = [camera2Mask];
		
		player2ZoneFinal = new FlxSprite();
		player2ZoneFinal.cameras = [camera2Mask];
		add(player2ZoneFinal);
		
		//spriteTempOutput.cameras = [cameraHud];
		//spriteTemp.makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
		//spriteTempMask.makeGraphic(FlxG.width, FlxG.height-1, FlxColor.TRANSPARENT);
		//add(spriteTempOutput);
		
		// MVP : https://groups.google.com/forum/#!topic/haxeflixel/GIE-Als5Soc
		// Pour, par défaut, afficher les sprites sur les caméras player1, player2 et worldmap quoi
		FlxCamera.defaultCameras = [camera1, camera2, cameraDebug, cameraBoth];
		
		// Pour qu'il n'y ait que la cameraHud qui affiche la ligne (à faire pour tous les élements du hud quoi)
		//verticalSplitScreenSeparator.cameras = [cameraHud];
		//canvas.cameras = [cameraDebug];
		canvasHud.cameras = [cameraHud];
	}
		
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		//trace(FlxG.renderBlit, FlxG.renderTile, FlxG.renderMethod);
		//trace(camera1.canvas);
		
		if (FlxG.keys.pressed.Z) {
			player1Sprite.y -= speed;
		} else if (FlxG.keys.pressed.S) {
			player1Sprite.y += speed;
		} 
		if (FlxG.keys.pressed.Q) {
			player1Sprite.x -= speed;
		} else if (FlxG.keys.pressed.D) {
			player1Sprite.x += speed;
		}
		
		if (FlxG.keys.pressed.UP) {
			player2Sprite.y -= speed;
		} else if (FlxG.keys.pressed.DOWN) {
			player2Sprite.y += speed;
		} 
		if (FlxG.keys.pressed.LEFT) {
			player2Sprite.x -= speed;
		} else if (FlxG.keys.pressed.RIGHT) {
			player2Sprite.x += speed;
		}
		
		if (FlxG.keys.justPressed.SPACE) {
			displayScreen = (displayScreen + 1) % 3;
			if (displayScreen == 0) {
				camera1.visible = true;
				camera2.visible = true;
				
				cameraBoth.visible = false;
				
				cameraDebug.visible = false;
				
				cameraHud.visible = true;
			} else if (displayScreen == 1) {
				camera1.visible = false;
				camera2.visible = false;
				
				cameraBoth.visible = true;
				
				cameraDebug.visible = false;
				
				cameraHud.visible = true;
			} else {
				camera1.visible = false;
				camera2.visible = false;
				
				cameraBoth.visible = false;
				
				cameraDebug.visible = true;
				
				cameraHud.visible = false;
			}
		}
		
		
			//if (distanceBetweenPlayers < maxDistanceBetweenPlayers) {
				//// 1
				//camera1.visible = false;
				//camera2.visible = false;
				//
				//cameraBoth.visible = true;
				//
				//cameraDebug.visible = false;
				//
				//cameraHud.visible = true;
			//} else {
				//// 0
				//camera1.visible = true;
				//camera2.visible = true;
				//
				//cameraBoth.visible = false;
				//
				//cameraDebug.visible = false;
				//
				//cameraHud.visible = true;
			//}
		
		var rectangleCameraBoth:FlxRect = new FlxRect(cameraBoth.scroll.x, cameraBoth.scroll.y, calcViewWidth(cameraBoth), calcViewHeight(cameraBoth));
		
		if (displayScreen == 0 || displayScreen == 1) {
			// TODO: meilleure condition serait de faire en fonction de la distance du sprite au bord le plus proche de l'écran
			if (rectangleCameraBoth.containsPoint(player1Sprite.getPosition()) && rectangleCameraBoth.containsPoint(player2Sprite.getPosition())) {
				displayScreen = 1;
				
				camera1.visible = false;
				camera2.visible = false;
				
				cameraBoth.visible = true;
				
				cameraDebug.visible = false;
				
				cameraHud.visible = true;
			} else {
				displayScreen = 0;
				
				camera1.visible = true;
				camera2.visible = true;
				
				cameraBoth.visible = false;
				
				cameraDebug.visible = false;
				
				cameraHud.visible = true;
			}
		}
		
		camera1.zoom += FlxG.mouse.wheel / 10;
		camera2.zoom += FlxG.mouse.wheel / 10;
		//cameraDebug.zoom += FlxG.mouse.wheel / 10;
		
		canvas.fill(FlxColor.TRANSPARENT);
		canvasHud.fill(FlxColor.TRANSPARENT);
		
		var lineStyle:LineStyle = { color: FlxColor.PURPLE, thickness: 2 };
		
		// Ligne reliant les 2 joueurs
		canvas.drawLine(
			player1Sprite.x + playerSpriteSize / 2, player1Sprite.y + playerSpriteSize / 2, 
			player2Sprite.x + playerSpriteSize / 2, player2Sprite.y + playerSpriteSize / 2, 
			lineStyle);
			
		// Détermination de la taille du rectangle contenant les 2 joueurs
		// TODO: imposer une taille minimale
		minX = camera1.scroll.x < camera2.scroll.x ? camera1.scroll.x : camera2.scroll.x;
		minY = camera1.scroll.y < camera2.scroll.y ? camera1.scroll.y : camera2.scroll.y;
		
		maxX = camera1.scroll.x + calcViewWidth(camera1) > camera2.scroll.x + calcViewWidth(camera2) 
			? camera1.scroll.x + calcViewWidth(camera1) 
			: camera2.scroll.x + calcViewWidth(camera2);
				
		maxY = camera1.scroll.y + calcViewHeight(camera1) > camera2.scroll.y + calcViewHeight(camera2)
			? camera1.scroll.y + calcViewHeight(camera1)
			: camera2.scroll.y + calcViewHeight(camera2);
			
		// Box de vision autour des 2 joueurs
		canvas.drawRect(minX, minY, maxX - minX, maxY - minY, FlxColor.TRANSPARENT, lineStyle);
		
		// Box de visions autour de chacun des joueurs
		canvas.drawRect(camera1.scroll.x, camera1.scroll.y, calcViewWidth(camera1), calcViewHeight(camera1), FlxColor.TRANSPARENT, lineStyle);
		canvas.drawRect(camera2.scroll.x, camera2.scroll.y, calcViewWidth(camera2), calcViewHeight(camera2), FlxColor.TRANSPARENT, lineStyle);
		
		// Box de vision de la cameraBoth
		canvas.drawRect(cameraBoth.scroll.x, cameraBoth.scroll.y, calcViewWidth(cameraBoth), calcViewHeight(cameraBoth), FlxColor.TRANSPARENT, { color: FlxColor.GREEN, thickness: 3 });
		
		// Ligne / vecteur du joueur 1 vers le joueur 2
		var player1ToPlayer2Vector:FlxVector = FlxVector.get(player2Sprite.x - player1Sprite.x, player2Sprite.y - player1Sprite.y);
		
		// Distance entre les 2 joueurs
		distanceBetweenPlayers = player1ToPlayer2Vector.length;
		
		// https://stackoverflow.com/questions/1243614/how-do-i-calculate-the-normal-vector-of-a-line-segment
		var dx:Float = player1ToPlayer2Vector.x;
		var dy:Float = player1ToPlayer2Vector.y;
		var pointA:FlxPoint = new FlxPoint(-dy,  dx);
		var pointB:FlxPoint = new FlxPoint( dy, -dx);
		
		// Vecteur normalisé de la perpendiculaire entre les 2 joueurs
		var perpendiculaire:FlxVector = FlxVector.get(pointB.x - pointA.x, pointB.y - pointA.y).normalize();
		
		// Milieu du vecteur entre les 2 joueurs
		centerOfPlayers.setPosition(
			//player1Sprite.x + (playerSpriteSize / 2) + (player1ToPlayer2Vector.x / 2), 
			//player1Sprite.y + (playerSpriteSize / 2) + (player1ToPlayer2Vector.y / 2)
			(player1Sprite.x + player2Sprite.x) / 2 + playerSpriteSize/2, 
			(player1Sprite.y + player2Sprite.y) / 2 + playerSpriteSize/2 
		);
		
		// Perpendiculaire du trait entre les 2 joueurs
		canvas.drawLine(
			centerOfPlayers.x - perpendiculaire.x*3000, centerOfPlayers.y - perpendiculaire.y*3000,
			centerOfPlayers.x + perpendiculaire.x*3000, centerOfPlayers.y + perpendiculaire.y*3000,
			lineStyle);
			
		// Point au milieu des joueurs
		canvas.drawCircle(centerOfPlayers.x, centerOfPlayers.y, 4, FlxColor.MAGENTA);
		
		// Cercles autour des joueurs
		//canvas.drawCircle(player1Sprite.x + playerSpriteSize / 2, player1Sprite.y + playerSpriteSize / 2, 50, FlxColor.TRANSPARENT, lineStyle);
		//canvas.drawCircle(player2Sprite.x + playerSpriteSize / 2, player2Sprite.y + playerSpriteSize / 2, 50, FlxColor.TRANSPARENT, lineStyle);
		
		// Longueur du trait (FlxG.width parce que c'est la plus grande distance possible, ou pas, c'est la diagonale, mais bref)
		// TODO: enlever ces new partout
		var lineLength:Float = FlxG.width;
		
		// Ligne de séparation à la perpendiculaire du vecteur entre les 2
		canvasHud.drawLine(
			FlxG.width/2 - perpendiculaire.x*lineLength, FlxG.height/2 - perpendiculaire.y*lineLength,
			FlxG.width/2 + perpendiculaire.x*lineLength, FlxG.height/2 + perpendiculaire.y*lineLength,
			{color: FlxColor.WHITE, thickness: 8});
			
		// Ligne de séparation verticale entre les 2 caméras
		canvasHud.drawLine(FlxG.width / 2, 0, FlxG.width / 2, FlxG.height, {color: FlxColor.WHITE, thickness: 8});
		
		//camera2.flashSprite.mask = new DisplayObject();
		//canvas.drawPolygon([], FlxColor.fromRGB(255, 255, 0, 127));
		
		//camera1.buffer.setPixel(20, 20, 20);
		//var spriteTest = new FlxSprite();
		
		//camera1MaskSprite.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		//camera1MaskSprite.drawPolygon([FlxPoint.get(0, 0), FlxPoint.get(300, 0), FlxPoint.get(500, 200), FlxPoint.get(0, 200)], FlxColor.CYAN);
		//camera1MaskSprite.cameras = [cameraHud];
		//var newCameraBuffer:FlxSprite = new FlxSprite();
		//camera1MaskSprite.cameras = [cameraHud];
		//FlxSpriteUtil.alphaMask(newCameraBuffer, camera1.buffer, camera1MaskSprite.pixels);
		//camera1.buffer = newCameraBuffer.pixels;
		
		//FlxG.renderBlit;
		
		//if (FlxG.keys.justPressed.P) {
			//var png:ByteArray = PNGEncoder.encode(camera1MaskSprite.pixels);
			//File.saveBytes("D:/test.png", png);
			//
			//var png:ByteArray = PNGEncoder.encode(camera1.screen.pixels);
			//var png:ByteArray = PNGEncoder.encode(camera1.screen.framePixels);
			//trace(camera1.screen); // null
			//trace(camera1.buffer); // null
			//trace(camera1.flashSprite); 
			//trace(camera1.canvas.graphics); 
		//}
		
		/////////////////
		var intersectionUp:FlxVector = perpendiculaire.findIntersection(FlxVector.get(FlxG.width/2, FlxG.height/2), FlxVector.get(0, 0), FlxVector.get(FlxG.width, 0));
		var intersectionDown:FlxVector = perpendiculaire.findIntersection(FlxVector.get(FlxG.width/2, FlxG.height/2), FlxVector.get(0, FlxG.height),  FlxVector.get(FlxG.width, 0));
		
		var intersectionLeft:FlxVector = perpendiculaire.findIntersection(FlxVector.get(FlxG.width/2, FlxG.height/2), FlxVector.get(0, 0),  FlxVector.get(0, FlxG.height));
		var intersectionRight:FlxVector = perpendiculaire.findIntersection(FlxVector.get(FlxG.width/2, FlxG.height/2), FlxVector.get(FlxG.width, 0),  FlxVector.get(0, FlxG.height));
		
		// On déborde un peu pour éviter qu'à cause des imprécisions (x à -0.05 par exemple), ça ne s'affiche pas tout le temps
		var screenRect:FlxRect = FlxRect.weak(-16, -16, FlxG.width + 32, FlxG.height + 32);
		
		if (intersectionUp.inRect(screenRect)) {
			canvasHud.drawCircle(intersectionUp.x, intersectionUp.y, 10, FlxColor.CYAN);
		}
		if (intersectionDown.inRect(screenRect)) {
			canvasHud.drawCircle(intersectionDown.x, intersectionDown.y, 10, FlxColor.CYAN);
		}
		
		if (intersectionLeft.inRect(screenRect)) {
			canvasHud.drawCircle(intersectionLeft.x, intersectionLeft.y, 10, FlxColor.CYAN);
		}
		if (intersectionRight.inRect(screenRect)) {
			canvasHud.drawCircle(intersectionRight.x, intersectionRight.y, 10, FlxColor.CYAN);
		}
		
		// TODO: pas recalculer tout le temps
		var dxOverDy:Float = (perpendiculaire.dx / perpendiculaire.dy) / (FlxG.width / FlxG.height);
		
		player1ZoneMask.fill(FlxColor.TRANSPARENT);
		player2ZoneMask.fill(FlxColor.TRANSPARENT);
		
		// TODO: faire un math.abs ? plus opti ?
		// TODO: vu que ça inverse d'un côté à l'autre, y'a moyen de factoriser
		if (FlxMath.inBounds(dxOverDy, -1, 1)) {
			// -1 à 1 => rouge à gauche (ou droite)
			
			var leftPolygonPoints:Array<FlxPoint> = [
				FlxPoint.weak(0, 0), 
				FlxPoint.weak(intersectionUp.x, 0), 
				FlxPoint.weak(intersectionDown.x, FlxG.height), 
				FlxPoint.weak(0, FlxG.height)
			];
			
			var rightPolygonPoints:Array<FlxPoint> = [
				FlxPoint.weak(intersectionUp.x, 0), 
				FlxPoint.weak(FlxG.width, 0), 
				FlxPoint.weak(FlxG.width, FlxG.height), 
				FlxPoint.weak(intersectionDown.x, FlxG.height)
			];
			
			if (player1Sprite.x < player2Sprite.x) {
				// rouge à gauche (coin haut gauche et bas gauche)
				
				player1ZoneMask.drawPolygon(leftPolygonPoints, FlxColor.BLACK);
				//player2ZoneMask.drawPolygon(rightPolygonPoints, FlxColor.BLACK);
			} else {
				// rouge à droite (coin haut droit et bas droite)
				
				player1ZoneMask.drawPolygon(rightPolygonPoints, FlxColor.BLACK);
				//player2ZoneMask.drawPolygon(leftPolygonPoints, FlxColor.BLACK);
			}
		} else {
			// au dessus ou en dessous => en bas (ou haut)
			
			var topPolygonPoints:Array<FlxPoint> = [
				FlxPoint.weak(0, 0), 
				FlxPoint.weak(FlxG.width, 0), 
				FlxPoint.weak(FlxG.width, intersectionRight.y), 
				FlxPoint.weak(0, intersectionLeft.y)
			];
			
			var bottomPolygonPoints:Array<FlxPoint> = [
				FlxPoint.weak(0, intersectionLeft.y), 
				FlxPoint.weak(FlxG.width, intersectionRight.y), 
				FlxPoint.weak(FlxG.width, FlxG.height), 
				FlxPoint.weak(0, FlxG.height)
			];
			
			if (player1Sprite.y < player2Sprite.y) {
				// rouge en haut (coin haut gauche et haut droite)
				
				player1ZoneMask.drawPolygon(topPolygonPoints, FlxColor.BLACK);
				//player2ZoneMask.drawPolygon(bottomPolygonPoints, FlxColor.BLACK);
			} else {
				// rouge en bas (coin bas gauche et bas droite)
				
				player1ZoneMask.drawPolygon(bottomPolygonPoints, FlxColor.BLACK);
				//player2ZoneMask.drawPolygon(topPolygonPoints, FlxColor.BLACK);
			}
		}
		
		//FlxSpriteUtil.alphaMaskFlxSprite(player1Zone, player1ZoneMask, player1ZoneFinal);
		//player1ZoneFinal.alpha = 0.3;
		
		//add(player1ZoneMask);
		
		//FlxSpriteUtil.alphaMaskFlxSprite(player2Zone, player2ZoneMask, player2ZoneFinal);
		//player2ZoneFinal.alpha = 0.3;
		
		//add(player2ZoneMask);
		
		// https://groups.google.com/forum/#!topic/haxeflixel/JX45NAgT49k
		// http://coinflipstudios.com/devblog/?p=421 ?
		
		// OK
		//spriteTempOutput.cameras = [cameraHud];
		//
		//spriteTemp.makeGraphic(1000, 1000, FlxColor.RED);
		//
		//spriteTempMask.makeGraphic(1000, 1000, FlxColor.TRANSPARENT);
		//spriteTempMask.fill(FlxColor.TRANSPARENT);
		//spriteTempMask.drawPolygon([FlxPoint.weak(0, 0), FlxPoint.weak(intersectionUp.x, 0), FlxPoint.weak(intersectionDown.x, FlxG.height), FlxPoint.weak(0, FlxG.height)], FlxColor.BLACK);
		//
		//FlxSpriteUtil.alphaMaskFlxSprite(spriteTemp, spriteTempMask, spriteTempOutput);
		//
		//spriteTempOutput.alpha = 0.3;
	}
	
	function calcViewWidth(camera:FlxCamera):Float
	{
		var viewOffsetX = 0.5 * camera.width * (camera.scaleX - camera.initialZoom) / camera.scaleX;
		//var viewOffsetWidth = camera.width - viewOffsetX;
		return camera.width - 2 * viewOffsetX;
	}
	
	function calcViewHeight(camera:FlxCamera):Float
	{
		var viewOffsetY = 0.5 * camera.height * (camera.scaleY - camera.initialZoom) / camera.scaleY;
		//viewOffsetHeight = height - viewOffsetY;
		return camera.height - 2 * viewOffsetY;
	}
}
