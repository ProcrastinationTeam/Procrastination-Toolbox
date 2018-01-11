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
		canvas.drawRect(0, 0, CAMERA_WIDTH, CAMERA_HEIGHT, FlxColor.TRANSPARENT, {thickness: 3, color: FlxColor.WHITE});
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
			(redSquare.x + blueSquare.x) / 2, 
			(redSquare.y + blueSquare.y) / 2 
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
		
		//canvasHud.drawLine(
			//cameraSpriteBoth1.x + centerOfPlayers.x - perpendiculaire.x*3000, cameraSpriteBoth1.y + centerOfPlayers.y - perpendiculaire.y*3000,
			//cameraSpriteBoth1.x + centerOfPlayers.x + perpendiculaire.x*3000, cameraSpriteBoth1.y + centerOfPlayers.y + perpendiculaire.y*3000,
		//{thickness: 2, color:FlxColor.BLACK});
		
		canvasHud.drawLine(
			intersectionLeft.x, intersectionLeft.y, 
			intersectionRight.x, intersectionRight.y,
		{thickness: 2, color:FlxColor.BLACK});
		
		canvasHud.drawLine(
			intersectionUp.x, intersectionUp.y, 
			intersectionDown.x, intersectionDown.y,
		{thickness: 2, color:FlxColor.BLACK});
		
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
				//drawCameras(leftPolygonPoints, rightPolygonPoints);
			} else {
				// rouge à droite (coin haut droit et bas droite)
				redPolygon = rightPolygonPoints;
				bluePolygon = leftPolygonPoints;
				//drawCameras(rightPolygonPoints, leftPolygonPoints);
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
			
			//trace(topPolygonPoints);
			
			if (redSquare.y < blueSquare.y) {
				// rouge en haut (coin haut gauche et haut droite)
				redPolygon = topPolygonPoints;
				bluePolygon = bottomPolygonPoints;
				//drawCameras(topPolygonPoints, bottomPolygonPoints);
			} else {
				// rouge en bas (coin bas gauche et bas droite)
				redPolygon = bottomPolygonPoints;
				bluePolygon = topPolygonPoints;
				//drawCameras(bottomPolygonPoints, topPolygonPoints);
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
		
		//trace(maskedCameraBoth.width, maskedCameraBoth.height);
		
		
		///////////////////////////////////////////////////////////////////////////// OH MY GAWH
		// both
		var spriteTemp = new FlxSprite(0, 0);
		spriteTemp.makeGraphic(maskedCameraBoth.width, maskedCameraBoth.height);
		spriteTemp.pixels.draw(maskedCameraBoth.canvas);
		
		var normalizedVector = player1ToPlayer2Vector.normalize();
		
		
		// red
		// doit y avoir une fonction qui fait ça, du clamp
		var difX = maskedCamera1.scroll.x - maskedCameraBoth.scroll.x;
		var difY = maskedCamera1.scroll.y - maskedCameraBoth.scroll.y;
		
		var x:Int = Std.int((maskedCamera1.scroll.x < maskedCameraBoth.scroll.x ? 0 : difX) + 50 * normalizedVector.x);
		var y:Int = Std.int((maskedCamera1.scroll.y < maskedCameraBoth.scroll.y ? 0 : difY) + 50 * normalizedVector.y);
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
            //pixels.copyPixels(maskedCamera1.buffer, maskedCamera1.buffer.rect, new Point());
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
		
		var x:Int = Std.int((maskedCamera2.scroll.x < maskedCameraBoth.scroll.x ? 0 : difX) - 50 * normalizedVector.x);
		var y:Int = Std.int((maskedCamera2.scroll.y < maskedCameraBoth.scroll.y ? 0 : difY) - 50 * normalizedVector.y);
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