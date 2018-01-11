package;

import flash.display.BitmapData;
import flash.display3D.textures.RectangleTexture;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import openfl.geom.Point;
import openfl.display.BlendMode;
import flixel.math.FlxPoint;
import flixel.addons.display.FlxGridOverlay;
import flixel.math.FlxVector;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flash.utils.ByteArray;
import flixel.addons.util.PNGEncoder;
import openfl.geom.Rectangle;
import sys.io.File;

using flixel.util.FlxSpriteUtil;

enum CameraMode {
	SEPARATE;
	OVERLAY;
	GLOBAL;
}

class PlayState extends FlxState
{
    static inline var CAMERA_WIDTH 		: Float 	= 320;
    static inline var CAMERA_HEIGHT 	: Float 	= 180;
	
	static inline var worldWidth 		: Int 		= 10000;
	static inline var worldHeight 		: Int 		= 10000;
	
	static inline var speed 			: Float 	= 4;
	
	var redSquare 						: FlxSprite;
	var blueSquare 						: FlxSprite;

    //var maskedCamera 					: FlxCamera;
    var maskedCamera1 					: FlxCamera;
    var maskedCamera2 					: FlxCamera;
	var maskedCameraBoth				: FlxCamera;
	
    var mask 							: FlxSprite;
	
    var cameraSprite1 					: FlxSprite;
    var cameraSprite2 					: FlxSprite;
    var cameraSpriteCentered 			: FlxSprite;
	
    var cameraSpriteBoth1				: FlxSprite;
    var cameraSpriteBoth2				: FlxSprite;
	
	//var cameraBoth 					: FlxCamera;
	
	var cameraMode 						: CameraMode = SEPARATE;
	
	var centerOfPlayers 				: FlxSprite;

	var canvasHud 						: FlxSprite;
	
	var cameraScrollBoundsOffset 		: Float = CAMERA_WIDTH+1;
	
    override public function create():Void
    {
        super.create();
		
		var grid:FlxSprite = FlxGridOverlay.create(16, 16, worldWidth, worldHeight);
		add(grid);
		
		redSquare = new FlxSprite(0, 28);
        redSquare.makeGraphic(16, 16, FlxColor.RED);
        add(redSquare);
		
		blueSquare = new FlxSprite(0, 28);
        blueSquare.makeGraphic(16, 16, FlxColor.BLUE);
        add(blueSquare);
		
		centerOfPlayers = new FlxSprite();
		centerOfPlayers.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		add(centerOfPlayers);
		
        // this is a bit of a hack - we need this camera to be rendered so we can copy the content
        // onto the sprite, but we don't want to actually *see* it, so just move it off-screen
        //maskedCamera = new FlxCamera(20000, 0, CAMERA_SIZE, CAMERA_SIZE);
		//maskedCamera.setScrollBoundsRect(0, 0, worldWidth, worldHeight);
        //maskedCamera.bgColor = FlxColor.GRAY;
        //FlxG.cameras.add(maskedCamera);
		
		maskedCamera1 = new FlxCamera(20000, 0, CAMERA_WIDTH, CAMERA_HEIGHT);
		maskedCamera1.setScrollBoundsRect(-cameraScrollBoundsOffset, -cameraScrollBoundsOffset, worldWidth + 2*cameraScrollBoundsOffset, worldWidth + 2*cameraScrollBoundsOffset);
        maskedCamera1.bgColor = FlxColor.GRAY;
		maskedCamera1.follow(redSquare);
        FlxG.cameras.add(maskedCamera1);
		
		maskedCamera2 = new FlxCamera(20000, 0, CAMERA_WIDTH, CAMERA_HEIGHT);
		maskedCamera2.setScrollBoundsRect(-cameraScrollBoundsOffset, -cameraScrollBoundsOffset, worldWidth + 2*cameraScrollBoundsOffset, worldWidth + 2*cameraScrollBoundsOffset);
        maskedCamera2.bgColor = FlxColor.GRAY;
		maskedCamera2.follow(blueSquare);
        FlxG.cameras.add(maskedCamera2);
		
		maskedCameraBoth = new FlxCamera(20000, 0, CAMERA_WIDTH, CAMERA_HEIGHT);
		maskedCameraBoth.setScrollBoundsRect(-cameraScrollBoundsOffset, -cameraScrollBoundsOffset, worldWidth + 2*cameraScrollBoundsOffset, worldWidth + 2*cameraScrollBoundsOffset);
        maskedCameraBoth.bgColor = FlxColor.GRAY;
		maskedCameraBoth.follow(centerOfPlayers);
        FlxG.cameras.add(maskedCameraBoth);
		
		FlxCamera.defaultCameras = [maskedCamera1, maskedCamera2, maskedCameraBoth];
		
		cameraSprite1 = new FlxSprite(0, CAMERA_HEIGHT + 10);
        cameraSprite1.makeGraphic(CAMERA_WIDTH, CAMERA_HEIGHT, FlxColor.TRANSPARENT, true);
        cameraSprite1.cameras = [FlxG.camera];
		cameraSprite1.blend = BlendMode.ADD;
        add(cameraSprite1);
		
		cameraSprite2 = new FlxSprite(CAMERA_WIDTH + 10, CAMERA_HEIGHT + 10);
        cameraSprite2.makeGraphic(CAMERA_WIDTH, CAMERA_HEIGHT, FlxColor.TRANSPARENT, true);
        cameraSprite2.cameras = [FlxG.camera];
		cameraSprite2.blend = BlendMode.ADD;
        add(cameraSprite2);
		
		cameraSpriteCentered = new FlxSprite(CAMERA_WIDTH + 10 + CAMERA_WIDTH + 10, CAMERA_HEIGHT + 10);
        cameraSpriteCentered.makeGraphic(CAMERA_WIDTH, CAMERA_HEIGHT, FlxColor.TRANSPARENT, true);
        cameraSpriteCentered.cameras = [FlxG.camera];
		cameraSpriteCentered.blend = BlendMode.ADD;
        add(cameraSpriteCentered);
		
		cameraSpriteBoth1 = new FlxSprite(0, CAMERA_HEIGHT + 10 + CAMERA_HEIGHT + 10);
        cameraSpriteBoth1.makeGraphic(CAMERA_WIDTH, CAMERA_HEIGHT, FlxColor.TRANSPARENT, true);
        cameraSpriteBoth1.cameras = [FlxG.camera];
		cameraSpriteBoth1.blend = BlendMode.ADD;
        add(cameraSpriteBoth1);
		
		cameraSpriteBoth2 = new FlxSprite(0, CAMERA_HEIGHT + 10 + CAMERA_HEIGHT + 10);
        cameraSpriteBoth2.makeGraphic(CAMERA_WIDTH, CAMERA_HEIGHT, FlxColor.TRANSPARENT, true);
        cameraSpriteBoth2.cameras = [FlxG.camera];
		cameraSpriteBoth2.blend = BlendMode.ADD;
        add(cameraSpriteBoth2);
		
		//cameraBoth = new FlxCamera(0, 300, CAMERA_SIZE, CAMERA_SIZE);
		//cameraBoth.setScrollBoundsRect(0, 0, worldWidth, worldHeight);
		//cameraBoth.bgColor = FlxColor.WHITE;
		//cameraBoth.visible = false;
		//cameraBoth.follow(centerOfPlayers);
        //FlxG.cameras.add(cameraBoth);
		
		mask = new FlxSprite();
		mask.makeGraphic(CAMERA_WIDTH, CAMERA_HEIGHT, FlxColor.TRANSPARENT);
		
		var canvas = new FlxSprite(0, 0);
		canvas.makeGraphic(CAMERA_WIDTH, CAMERA_HEIGHT, FlxColor.TRANSPARENT);
		canvas.blend = BlendMode.ADD;
		//canvas.drawRect(0, 0, CAMERA_WIDTH, CAMERA_HEIGHT, FlxColor.TRANSPARENT, {thickness: 3, color: FlxColor.WHITE});
		canvas.cameras = [FlxG.camera];
		add(canvas);
		
		canvasHud = new FlxSprite();
		canvasHud.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(canvasHud);
		canvasHud.cameras = [FlxG.camera];
		
		var circle = new FlxSprite(25, 25);
		circle.makeGraphic(10, 10, FlxColor.PINK);
		add(circle);
		
		var circle = new FlxSprite(25, CAMERA_HEIGHT - 25);
		circle.makeGraphic(10, 10, FlxColor.PINK);
		add(circle);
		
		var circle = new FlxSprite(CAMERA_WIDTH - 25, 25);
		circle.makeGraphic(10, 10, FlxColor.PINK);
		add(circle);
		
		var circle = new FlxSprite(CAMERA_WIDTH - 25, CAMERA_HEIGHT - 25);
		circle.makeGraphic(10, 10, FlxColor.PINK);
		add(circle);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
		
		if (FlxG.keys.pressed.Z) {
			redSquare.y -= speed;
		} else if (FlxG.keys.pressed.S) {
			redSquare.y += speed;
		} 
		if (FlxG.keys.pressed.Q) {
			redSquare.x -= speed;
		} else if (FlxG.keys.pressed.D) {
			redSquare.x += speed;
		}
		
		if (FlxG.keys.pressed.UP) {
			blueSquare.y -= speed;
		} else if (FlxG.keys.pressed.DOWN) {
			blueSquare.y += speed;
		} 
		if (FlxG.keys.pressed.LEFT) {
			blueSquare.x -= speed;
		} else if (FlxG.keys.pressed.RIGHT) {
			blueSquare.x += speed;
		}
		
		if (FlxG.keys.justPressed.SPACE) {
			changeCameraMode();
		}
		
		centerOfPlayers.setPosition(
			(redSquare.x + (redSquare.width / 2) + blueSquare.x + (blueSquare.width / 2)) / 2, 
			(redSquare.y + (redSquare.height / 2) + blueSquare.y + (blueSquare.height / 2)) / 2 
		);
		
		
		// Ligne / vecteur du joueur 1 vers le joueur 2
		var player1ToPlayer2Vector:FlxVector = FlxVector.get(blueSquare.x - redSquare.x, blueSquare.y - redSquare.y);
		
		// Distance entre les 2 joueurs
		//distanceBetweenPlayers = player1ToPlayer2Vector.length;
		
		// https://stackoverflow.com/questions/1243614/how-do-i-calculate-the-normal-vector-of-a-line-segment
		var dx:Float = player1ToPlayer2Vector.x;
		var dy:Float = player1ToPlayer2Vector.y;
		var pointA:FlxPoint = new FlxPoint(-dy,  dx);
		var pointB:FlxPoint = new FlxPoint( dy, -dx);
		
		// Vecteur normalisé de la perpendiculaire entre les 2 joueurs
		var perpendiculaire:FlxVector = FlxVector.get(pointB.x - pointA.x, pointB.y - pointA.y).normalize();
		
		/////////////////
		var center:FlxVector = FlxVector.get(cameraSpriteBoth1.x + cameraSpriteBoth1.width / 2, cameraSpriteBoth1.y + cameraSpriteBoth1.height / 2);
		
		var intersectionUp:FlxVector = perpendiculaire.findIntersection(center, FlxVector.get(cameraSpriteBoth1.x, cameraSpriteBoth1.y), FlxVector.get(1, 0));
		var intersectionDown:FlxVector = perpendiculaire.findIntersection(center, FlxVector.get(cameraSpriteBoth1.x, cameraSpriteBoth1.y + cameraSpriteBoth1.height),  FlxVector.get(1, 0));
		
		var intersectionLeft:FlxVector = perpendiculaire.findIntersection(center, FlxVector.get(cameraSpriteBoth1.x, cameraSpriteBoth1.y),  FlxVector.get(0, 1));
		var intersectionRight:FlxVector = perpendiculaire.findIntersection(center, FlxVector.get(cameraSpriteBoth1.x + cameraSpriteBoth1.width, cameraSpriteBoth1.y),  FlxVector.get(0, 1));
		
		var screenRect:FlxRect = FlxRect.weak(cameraSpriteBoth1.x - 16, cameraSpriteBoth1.y - 16, cameraSpriteBoth1.width + 32, cameraSpriteBoth1.height + 32);
		
		canvasHud.fill(FlxColor.TRANSPARENT);
		
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
		
		//var separationLineThickness:Float = FlxMath.bound(FlxMath.lerp(1, 6, player1ToPlayer2Vector.length / 200), 1, 6);
		var separationLineThickness:Float = FlxMath.bound(FlxMath.remapToRange(player1ToPlayer2Vector.length, 100, 200, 0, 6), 0, 6);
		
		//trace(separationLineThickness);
		
		if (separationLineThickness != 0) {		
			if (intersectionLeft.inRect(screenRect) && intersectionRight.inRect(screenRect)) {
				canvasHud.drawLine(
					intersectionLeft.x, intersectionLeft.y, 
					intersectionRight.x, intersectionRight.y,
				{thickness: separationLineThickness, color:FlxColor.BLACK});
			}
			
			if (intersectionUp.inRect(screenRect) && intersectionDown.inRect(screenRect)) {
				canvasHud.drawLine(
					intersectionUp.x, intersectionUp.y, 
					intersectionDown.x, intersectionDown.y,
				{thickness: separationLineThickness, color:FlxColor.BLACK});
			}
		}
		
		// TODO: pas recalculer tout le temps
		var dxOverDy:Float = (perpendiculaire.dx / perpendiculaire.dy) / (cameraSpriteBoth1.width / cameraSpriteBoth1.height);
		
		var redPolygon:Array<FlxPoint> = [];
		var bluePolygon:Array<FlxPoint> = [];
		
		if (FlxMath.inBounds(dxOverDy, -1, 1)) {
			// -1 à 1 => rouge à gauche (ou droite)
			
			var leftPolygonPoints:Array<FlxPoint> = [
				FlxPoint.weak(0, 						0), 
				FlxPoint.weak(intersectionUp.x, 		0), 
				FlxPoint.weak(intersectionDown.x, 		cameraSpriteBoth1.height), 
				FlxPoint.weak(0, 						cameraSpriteBoth1.height)
			];
			
			var rightPolygonPoints:Array<FlxPoint> = [
				FlxPoint.weak(intersectionUp.x, 		0), 
				FlxPoint.weak(cameraSpriteBoth1.width, 	0), 
				FlxPoint.weak(cameraSpriteBoth1.width, 	cameraSpriteBoth1.height), 
				FlxPoint.weak(intersectionDown.x, 		cameraSpriteBoth1.height)
			];
			
			if (redSquare.x < blueSquare.x) {
				// rouge à gauche (coin haut gauche et bas gauche)
				redPolygon = leftPolygonPoints;
				bluePolygon = rightPolygonPoints;
			} else {
				// rouge à droite (coin haut droit et bas droite)
				redPolygon = rightPolygonPoints;
				bluePolygon = leftPolygonPoints;
			}
		} else {
			// au dessus ou en dessous => en bas (ou haut)
			
			var topPolygonPoints:Array<FlxPoint> = [
				FlxPoint.weak(0, 						0), 
				FlxPoint.weak(cameraSpriteBoth1.width, 	0), 
				FlxPoint.weak(cameraSpriteBoth1.width, 	intersectionRight.y - cameraSpriteBoth1.y), // pas propre
				FlxPoint.weak(0, 						intersectionLeft.y - cameraSpriteBoth1.y) // pas propre
			];
			
			var bottomPolygonPoints:Array<FlxPoint> = [
				FlxPoint.weak(0, 						intersectionLeft.y - cameraSpriteBoth1.y), // pas propre
				FlxPoint.weak(cameraSpriteBoth1.width, 	intersectionRight.y - cameraSpriteBoth1.y), // pas propre
				FlxPoint.weak(cameraSpriteBoth1.width, 	cameraSpriteBoth1.height), 
				FlxPoint.weak(0, 						cameraSpriteBoth1.height)
			];
			
			if (redSquare.y < blueSquare.y) {
				// rouge en haut (coin haut gauche et haut droite)
				redPolygon = topPolygonPoints;
				bluePolygon = bottomPolygonPoints;
			} else {
				// rouge en bas (coin bas gauche et bas droite)
				redPolygon = bottomPolygonPoints;
				bluePolygon = topPolygonPoints;
			}
		}
		
		//pixels.draw(maskedCamera1.canvas, null, null, null, new Rectangle(0, 0, 50, 50));
		//maskedCamera1.width += FlxG.random.int(50, 100);
		
		var minX = maskedCamera1.scroll.x < maskedCamera2.scroll.x ? maskedCamera1.scroll.x : maskedCamera2.scroll.x;
		var minY = maskedCamera1.scroll.y < maskedCamera2.scroll.y ? maskedCamera1.scroll.y : maskedCamera2.scroll.y;
		
		var maxX = maskedCamera1.scroll.x + calcViewWidth(maskedCamera1) > maskedCamera2.scroll.x + calcViewWidth(maskedCamera2) 
			? maskedCamera1.scroll.x + calcViewWidth(maskedCamera1) 
			: maskedCamera2.scroll.x + calcViewWidth(maskedCamera2);
		
		var maxY = maskedCamera1.scroll.y + calcViewHeight(maskedCamera1) > maskedCamera2.scroll.y + calcViewHeight(maskedCamera2)
			? maskedCamera1.scroll.y + calcViewHeight(maskedCamera1)
			: maskedCamera2.scroll.y + calcViewHeight(maskedCamera2);
			
		maskedCameraBoth.setSize(Std.int(Math.max(maxX - minX, CAMERA_WIDTH*2)), Std.int(Math.max(maxY - minY, CAMERA_HEIGHT*2)));
		maskedCameraBoth.follow(centerOfPlayers);
		
		
		var centerScreen:FlxPoint = FlxPoint.get(CAMERA_WIDTH / 2, CAMERA_HEIGHT / 2);
		// Calcul du centre des écrans splittés pour bien offseter le joueur pour le centrer
		// https://en.wikipedia.org/wiki/Centroid#Centroid_of_a_polygon
		var areaRedScreen:Float = 0;
		var centerRedScreenX:Float = 0;
		var centerRedScreenY:Float = 0;
		for (i in 0...4) {
			areaRedScreen += (redPolygon[i].x * redPolygon[(i + 1) % 4].y) - (redPolygon[(i + 1) % 4].x * redPolygon[i].y);
			centerRedScreenX += (redPolygon[i].x + redPolygon[(i + 1) % 4].x) * ((redPolygon[i].x * redPolygon[(i + 1) % 4].y) - (redPolygon[(i + 1) % 4].x * redPolygon[i].y));
			centerRedScreenY += (redPolygon[i].y + redPolygon[(i + 1) % 4].y) * ((redPolygon[i].x * redPolygon[(i + 1) % 4].y) - (redPolygon[(i + 1) % 4].x * redPolygon[i].y));
		}
		areaRedScreen /= 2;
		centerRedScreenX /= 6 * areaRedScreen;
		centerRedScreenY /= 6 * areaRedScreen;
		
		var centerRedScreen:FlxPoint = FlxPoint.get(centerRedScreenX, centerRedScreenY);
		
		//
		var areaBlueScreen:Float = 0;
		var centerBlueScreenX:Float = 0;
		var centerBlueScreenY:Float = 0;
		for (i in 0...4) {
			areaBlueScreen += (bluePolygon[i].x * bluePolygon[(i + 1) % 4].y) - (bluePolygon[(i + 1) % 4].x * bluePolygon[i].y);
			centerBlueScreenX += (bluePolygon[i].x + bluePolygon[(i + 1) % 4].x) * ((bluePolygon[i].x * bluePolygon[(i + 1) % 4].y) - (bluePolygon[(i + 1) % 4].x * bluePolygon[i].y));
			centerBlueScreenY += (bluePolygon[i].y + bluePolygon[(i + 1) % 4].y) * ((bluePolygon[i].x * bluePolygon[(i + 1) % 4].y) - (bluePolygon[(i + 1) % 4].x * bluePolygon[i].y));
		}
		areaBlueScreen /= 2;
		centerBlueScreenX /= 6 * areaBlueScreen;
		centerBlueScreenY /= 6 * areaBlueScreen;
		
		var centerBlueScreen:FlxPoint = FlxPoint.get(centerBlueScreenX, centerBlueScreenY);
		
		//canvasHud.drawCircle(centerRedScreen.x, centerRedScreen.y + cameraSpriteBoth1.y, 4, FlxColor.YELLOW);
		//canvasHud.drawCircle(centerBlueScreen.x, centerBlueScreen.y + cameraSpriteBoth1.y, 4, FlxColor.YELLOW);
		
		///////////////////////////////////////////////////////////////////////////// OH MY GAWH
		// both
		var spriteTemp = new FlxSprite(0, 0);
		spriteTemp.makeGraphic(maskedCameraBoth.width, maskedCameraBoth.height);
		spriteTemp.pixels.draw(maskedCameraBoth.canvas);
		
		var normalizedVector = FlxVector.get(player1ToPlayer2Vector.x, player1ToPlayer2Vector.y).normalize();
		
		
		// red
		// doit y avoir une fonction qui fait ça, du clamp
		var difX = maskedCamera1.scroll.x - maskedCameraBoth.scroll.x;
		var difY = maskedCamera1.scroll.y - maskedCameraBoth.scroll.y;
		
		var x:Int = Std.int((maskedCamera1.scroll.x < maskedCameraBoth.scroll.x ? 0 : difX) - (centerRedScreen.x - centerScreen.x));
		var y:Int = Std.int((maskedCamera1.scroll.y < maskedCameraBoth.scroll.y ? 0 : difY) - (centerRedScreen.y - centerScreen.y));
		var width:Int = Std.int(calcViewWidth(maskedCamera1));
		var height:Int = Std.int(calcViewHeight(maskedCamera1));
		var rectangle = new Rectangle(x, y, width, height);
		
		//trace(rectangle);
		
		var spriteTemp1 = new FlxSprite(0, 0);
		spriteTemp1.makeGraphic(maskedCameraBoth.width, maskedCameraBoth.height);
		spriteTemp1.pixels.draw(maskedCameraBoth.canvas);
		
		var spriteTempRed = new FlxSprite(0, 0);
		spriteTempRed.makeGraphic(width, height);
		spriteTempRed.pixels.copyPixels(spriteTemp1.pixels, rectangle, new Point());
		
		
		if (FlxG.keys.pressed.P) {
			var png:ByteArray = PNGEncoder.encode(spriteTemp.pixels);
			File.saveBytes("d:/both.png", png);
			
			var png:ByteArray = PNGEncoder.encode(spriteTempRed.pixels);
			File.saveBytes("d:/red.png", png);
			
			//var png:ByteArray = PNGEncoder.encode(spriteTempBlue.pixels);
			//File.saveBytes("d:/blue.png", png);
		}
		////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		//
		var originalPixels = mask.pixels.clone();
		
		//
		mask.drawPolygon(redPolygon, FlxColor.BLACK);
		
		// on pourra se débarasser de cameraSprite1, là c'est juste pour l'afficher 2 fois
		//cameraSprite1.pixels = spriteTempRed.pixels;
		var pixels = cameraSprite1.pixels;
		
        if (FlxG.renderBlit) {
            pixels.copyPixels(maskedCamera1.buffer, maskedCamera1.buffer.rect, new Point());
		}
        else {
            pixels.draw(maskedCamera1.canvas);
		}
		//spriteTempRed.alphaMaskFlxSprite(mask, cameraSpriteBoth1);
        spriteTempRed.alphaMaskFlxSprite(mask, cameraSpriteBoth1);
		//
		
		mask.pixels = originalPixels.clone();
		
		
		
		
		
		
		
		// on le fout ici, sinon ça écrase dans l'autre sprite apparemment
		// blue
		// doit y avoir une fonction qui fait ça, du clamp
		var difX = maskedCamera2.scroll.x - maskedCameraBoth.scroll.x;
		var difY = maskedCamera2.scroll.y - maskedCameraBoth.scroll.y;
		
		var x:Int = Std.int((maskedCamera2.scroll.x < maskedCameraBoth.scroll.x ? 0 : difX) - (centerBlueScreen.x - centerScreen.x));
		var y:Int = Std.int((maskedCamera2.scroll.y < maskedCameraBoth.scroll.y ? 0 : difY) - (centerBlueScreen.y - centerScreen.y));
		var width:Int = Std.int(calcViewWidth(maskedCamera2));
		var height:Int = Std.int(calcViewHeight(maskedCamera2));
		var rectangle = new Rectangle(x, y, width, height);
		
		//trace(rectangle);
		
		var spriteTemp2 = new FlxSprite(0, 0);
		spriteTemp2.makeGraphic(maskedCameraBoth.width, maskedCameraBoth.height);
		spriteTemp2.pixels.draw(maskedCameraBoth.canvas);
		
		
		var spriteTempBlue = new FlxSprite(0, 0);
		spriteTempBlue.makeGraphic(width, height);
		spriteTempBlue.pixels.copyPixels(spriteTemp2.pixels, rectangle, new Point());
		
		
		
		//
		mask.drawPolygon(bluePolygon, FlxColor.BLACK);
		
		//cameraSprite2.pixels = spriteTempBlue.pixels;
		var pixels = cameraSprite2.pixels;
        if (FlxG.renderBlit) {
            pixels.copyPixels(maskedCamera2.buffer, maskedCamera2.buffer.rect, new Point());
		} 
        else {
            pixels.draw(maskedCamera2.canvas);
		}
        spriteTempBlue.alphaMaskFlxSprite(mask, cameraSpriteBoth2);
		//
		
		mask.pixels = originalPixels.clone();
		
		
		//
		
		var x:Int = Std.int((calcViewWidth(maskedCameraBoth) - CAMERA_WIDTH) / 2);
		var y:Int = Std.int((calcViewHeight(maskedCameraBoth) - CAMERA_HEIGHT) / 2);
		var width:Int = CAMERA_WIDTH;
		var height:Int = CAMERA_HEIGHT;
		var rectangle = new Rectangle(x, y, width, height);
		
		//trace(player1ToPlayer2Vector.length);
		
		var spriteTemp3 = new FlxSprite(0, 0);
		spriteTemp3.makeGraphic(maskedCameraBoth.width, maskedCameraBoth.height);
		spriteTemp3.pixels.draw(maskedCameraBoth.canvas);
		
		
		var spriteTempCentered = new FlxSprite(0, 0);
		spriteTempCentered.makeGraphic(width, height);
		spriteTempCentered.pixels.copyPixels(spriteTemp3.pixels, rectangle, new Point());
		
		//trace(centerOfPlayers);
		cameraSpriteCentered.pixels = spriteTempCentered.pixels;
		
		//
		var limitBeforeSplitting:Float = 20;
		var centerCameraBoth:FlxPoint = FlxPoint.get(maskedCameraBoth.scroll.x + calcViewWidth(maskedCameraBoth) / 2, maskedCameraBoth.scroll.y + calcViewHeight(maskedCameraBoth) / 2);
		var rectangleCameraBoth:FlxRect = new FlxRect(
			centerCameraBoth.x - CAMERA_WIDTH / 2 + limitBeforeSplitting, 
			centerCameraBoth.y - CAMERA_HEIGHT / 2 + limitBeforeSplitting, 
			CAMERA_WIDTH - 2 * limitBeforeSplitting, 
			CAMERA_HEIGHT - 2 * limitBeforeSplitting);
		
		//trace(rectangleCameraBoth);
		
		if (rectangleCameraBoth.containsPoint(redSquare.getPosition()) && rectangleCameraBoth.containsPoint(blueSquare.getPosition())) {
			//trace("faut merger madame");
			cameraSpriteCentered.x = 0;
			cameraSpriteCentered.y = CAMERA_HEIGHT + 10 + CAMERA_HEIGHT + 10;
			cameraSpriteBoth1.visible = false;
			cameraSpriteBoth2.visible = false;
		} else {
			//trace("c'est le schiiiiisme");
			cameraSpriteCentered.x = CAMERA_WIDTH + 10 + CAMERA_WIDTH + 10;
			cameraSpriteCentered.y = CAMERA_HEIGHT + 10;
			cameraSpriteBoth1.visible = true;
			cameraSpriteBoth2.visible = true;
		}
    }
	
	function changeCameraMode():Void {
		switch(cameraMode) {
			case CameraMode.SEPARATE:
				cameraMode = CameraMode.OVERLAY;
			case CameraMode.OVERLAY:
				cameraMode = CameraMode.GLOBAL;
			case CameraMode.GLOBAL:
				cameraMode = CameraMode.SEPARATE;
		}
		
		switch(cameraMode) {
			case CameraMode.SEPARATE:
				cameraSprite1.visible = true;
				cameraSprite2.visible = true;
				
				cameraSprite1.x = 0;
				cameraSprite2.x = CAMERA_WIDTH + 10;
				
				//cameraBoth.visible = false;
			case CameraMode.OVERLAY:
				cameraSprite1.visible = true;
				cameraSprite2.visible = true;
				
				cameraSprite1.x = 0;
				cameraSprite2.x = 0;
				
				//cameraBoth.visible = false;
			case CameraMode.GLOBAL:
				cameraSprite1.visible = false;
				cameraSprite2.visible = false;
				
				//cameraBoth.visible = true;
		}
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