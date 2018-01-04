package;

import flixel.tweens.FlxTween;
import flash.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.geom.Point;
import openfl.display.BlendMode;
import flixel.math.FlxPoint;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
    static inline var CAMERA_SIZE = 200;

    var maskedCamera:FlxCamera;
	
	var maskedCamera1:FlxCamera;
    //var maskedCamera3:FlxCamera;
    //var maskedCamera4:FlxCamera;
	
    var cameraSprite:FlxSprite;
    var cameraSprite2:FlxSprite;
    var cameraSprite3:FlxSprite;
    var cameraSprite4:FlxSprite;
	
    //var mask:FlxSprite;
    //var mask2:FlxSprite;
    var mask3:FlxSprite;
    //var mask4:FlxSprite;
	
	var cameraBoth:FlxSprite;
	
	var speed : Float = 4;
	
	var redSquare:FlxSprite;
	var blueSquare:FlxSprite;

    override public function create():Void
    {
        super.create();
		
        maskedCamera = new FlxCamera(0, 0, CAMERA_SIZE, CAMERA_SIZE);
        maskedCamera.bgColor = FlxColor.GRAY;
        FlxG.cameras.add(maskedCamera);
		
		maskedCamera1 = new FlxCamera(500, 0, 100, 100);
		maskedCamera1.setScrollBoundsRect(0, 0, CAMERA_SIZE, CAMERA_SIZE);
        maskedCamera1.bgColor = FlxColor.GRAY;
		//maskedCamera1.visible = false;
        FlxG.cameras.add(maskedCamera1);
		
        // this is a bit of a hack - we need this camera to be rendered so we can copy the content
        // onto the sprite, but we don't want to actually *see* it, so just move it off-screen
        //maskedCamera.x = ;
		
		//maskedCamera3 = new FlxCamera(0, 0, CAMERA_SIZE, CAMERA_SIZE);
        //maskedCamera3.bgColor = FlxColor.YELLOW;
        //maskedCamera3.x = FlxG.width;
        //FlxG.cameras.add(maskedCamera3);
		
		// AAAAAAAAAAAAAAAAAH
		//maskedCamera4 = new FlxCamera(0, 0, CAMERA_SIZE, CAMERA_SIZE);
		////maskedCamera4.scroll.x = 125;
        //maskedCamera4.bgColor = FlxColor.GREEN;
        //maskedCamera4.x = FlxG.width;
        //FlxG.cameras.add(maskedCamera4);
		
        //cameraSprite = new FlxSprite();
        //cameraSprite.makeGraphic(CAMERA_SIZE, CAMERA_SIZE, FlxColor.WHITE, true);
        //cameraSprite.y = 100;
        //cameraSprite.cameras = [FlxG.camera];
        //add(cameraSprite);
		//
        //cameraSprite2 = new FlxSprite();
        //cameraSprite2.makeGraphic(CAMERA_SIZE, CAMERA_SIZE, FlxColor.WHITE, true);
        //cameraSprite2.y = 200;
        //cameraSprite2.cameras = [FlxG.camera];
        //add(cameraSprite2);
		
		FlxG.camera.zoom = 2;
		
		cameraSprite3 = new FlxSprite(400, 300);
        cameraSprite3.makeGraphic(CAMERA_SIZE, CAMERA_SIZE, FlxColor.TRANSPARENT, true);
        //cameraSprite3.y = 400;
        cameraSprite3.cameras = [FlxG.camera];
		cameraSprite3.blend = BlendMode.ADD;
        add(cameraSprite3);
		
		cameraSprite4 = new FlxSprite(600, 300);
        cameraSprite4.makeGraphic(CAMERA_SIZE, CAMERA_SIZE, FlxColor.TRANSPARENT, true);
        cameraSprite4.cameras = [FlxG.camera];
		cameraSprite4.blend = BlendMode.ADD;
        add(cameraSprite4);
		
		cameraBoth = new FlxSprite(150, 600);
        cameraBoth.makeGraphic(CAMERA_SIZE, CAMERA_SIZE, FlxColor.TRANSPARENT, true);
        cameraBoth.cameras = [FlxG.camera];
		//cameraBoth.blend = BlendMode.ADD;
        add(cameraBoth);
		
        //mask = new FlxSprite(FlxGraphic.fromClass(GraphicLogo));
		
        //mask2 = new FlxSprite();
		//mask2.makeGraphic(CAMERA_SIZE, CAMERA_SIZE, FlxColor.TRANSPARENT);
		//mask2.drawCircle(CAMERA_SIZE / 2, CAMERA_SIZE / 2, 35, FlxColor.BLACK);
		
		mask3 = new FlxSprite();
		mask3.makeGraphic(CAMERA_SIZE, CAMERA_SIZE, FlxColor.TRANSPARENT);
		//mask3.drawRect(0, 0, 75, 75, FlxColor.BLACK);
		//mask3.drawPolygon([FlxPoint.get(0, 0), FlxPoint.get(50, 0), FlxPoint.get(75, 50), FlxPoint.get(0, 50)], FlxColor.BLACK);
		//mask3.cameras = [maskedCamera3];
		
		//mask4 = new FlxSprite();
		//mask4.makeGraphic(CAMERA_SIZE, CAMERA_SIZE, FlxColor.TRANSPARENT);
		//mask4.drawRect(125, 0, 75, 75, FlxColor.BLACK);
		//mask4.cameras = [maskedCamera4];
		
        redSquare = new FlxSprite(0, 25);
        redSquare.makeGraphic(16, 16, FlxColor.RED);
        //redSquare.cameras = [maskedCamera];
        add(redSquare);
        //FlxTween.tween(redSquare, {x: 150}, 0.75, {type: FlxTween.PINGPONG});
		
		blueSquare = new FlxSprite(125, 25);
        blueSquare.makeGraphic(16, 16, FlxColor.BLUE);
        //blueSquare.cameras = [maskedCamera];
        add(blueSquare);
		
		var canvas = new FlxSprite(0, 0);
		canvas.makeGraphic(CAMERA_SIZE, CAMERA_SIZE, FlxColor.TRANSPARENT);
		////canvas.drawCircle(25, 15, 10, FlxColor.PINK);
		////canvas.drawCircle(25, 100, 10, FlxColor.PINK);
		////canvas.drawCircle(CAMERA_SIZE - 25, 100, 10, FlxColor.PINK);
		////canvas.drawCircle(CAMERA_SIZE - 25, 15, 10, FlxColor.PINK);
		canvas.blend = BlendMode.ADD;
		canvas.drawRect(0, 0, CAMERA_SIZE, CAMERA_SIZE, FlxColor.TRANSPARENT, {thickness: 3, color: FlxColor.WHITE});
		add(canvas);
		
		var circle = new FlxSprite(25, 25);
		circle.makeGraphic(10, 10, FlxColor.PINK);
		add(circle);
		
		var circle = new FlxSprite(25, CAMERA_SIZE - 25);
		circle.makeGraphic(10, 10, FlxColor.PINK);
		add(circle);
		
		var circle = new FlxSprite(CAMERA_SIZE - 25, 25);
		circle.makeGraphic(10, 10, FlxColor.PINK);
		add(circle);
		
		var circle = new FlxSprite(CAMERA_SIZE - 25, CAMERA_SIZE - 25);
		circle.makeGraphic(10, 10, FlxColor.PINK);
		add(circle);
		
		//FlxCamera.defaultCameras = [maskedCamera];
		//maskedCamera.x = FlxG.width;
		
		maskedCamera1.follow(redSquare);
		//FlxG.camera.follow(redSquare);
		//FlxG.camera.setScrollBoundsRect(0, 0, CAMERA_SIZE, CAMERA_SIZE);
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
		
        //var pixels = cameraSprite.pixels;
        //if (FlxG.renderBlit)
            //pixels.copyPixels(maskedCamera.buffer, maskedCamera.buffer.rect, new Point());
        //else
            //pixels.draw(maskedCamera.canvas);
		//
        //cameraSprite.alphaMaskFlxSprite(mask, cameraSprite);
		
		//var pixels = cameraSprite2.pixels;
        //if (FlxG.renderBlit)
            //pixels.copyPixels(maskedCamera.buffer, maskedCamera.buffer.rect, new Point());
        //else
            //pixels.draw(maskedCamera.canvas);
		//
        //cameraSprite2.alphaMaskFlxSprite(mask2, cameraSprite2);
		
		//
		var originalPixels3 = mask3.pixels.clone();
		//var originalPixels4 = mask4.pixels.clone();
		
		//mask3.drawRect(0, 0, 75, 75, FlxColor.BLACK);
		//mask3.drawPolygon([FlxPoint.get(0, 0), FlxPoint.get(50, 0), FlxPoint.get(75, 50), FlxPoint.get(0, 50)], FlxColor.BLACK);
		//mask3.drawPolygon([FlxPoint.get(0, 0), FlxPoint.get(CAMERA_SIZE, CAMERA_SIZE), FlxPoint.get(0, CAMERA_SIZE)], FlxColor.BLACK);
		
		mask3.drawPolygon([
			FlxPoint.get(redSquare.x - 32, redSquare.y - 32), 
			FlxPoint.get(redSquare.x + redSquare.width + 32, redSquare.y - 32), 
			FlxPoint.get(redSquare.x + redSquare.width + 32, redSquare.y + redSquare.height + 32), 
			FlxPoint.get(redSquare.x - 32, redSquare.y + redSquare.height + 32)
		], FlxColor.BLACK);
		
		var pixels = cameraSprite3.pixels;
        if (FlxG.renderBlit)
            pixels.copyPixels(maskedCamera.buffer, maskedCamera.buffer.rect, new Point());
        else
            pixels.draw(maskedCamera.canvas);
        cameraSprite3.alphaMaskFlxSprite(mask3, cameraSprite3);
        //cameraBoth.alphaMaskFlxSprite(mask3, cameraSprite3);
		
		mask3.pixels = originalPixels3.clone();
		//mask4.pixels = originalPixels4.clone();
		
		//mask4.drawRect(125, 0, 75, 75, FlxColor.BLACK);
		mask3.drawPolygon([
			FlxPoint.get(blueSquare.x - 32, blueSquare.y - 32), 
			FlxPoint.get(blueSquare.x + blueSquare.width + 32, blueSquare.y - 32), 
			FlxPoint.get(blueSquare.x + blueSquare.width + 32, blueSquare.y + blueSquare.height + 32), 
			FlxPoint.get(blueSquare.x - 32, blueSquare.y + blueSquare.height + 32)
		], FlxColor.BLACK);
		
		var pixels = cameraSprite4.pixels;
        if (FlxG.renderBlit)
            pixels.copyPixels(maskedCamera.buffer, maskedCamera.buffer.rect, new Point());
        else
            pixels.draw(maskedCamera.canvas);
        cameraSprite4.alphaMaskFlxSprite(mask3, cameraSprite4);
        //cameraBoth.alphaMaskFlxSprite(mask4, cameraSprite4);
		
		mask3.pixels = originalPixels3;
		//mask4.pixels = originalPixels4;
    }
}