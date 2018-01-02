package utils;
import flixel.input.keyboard.FlxKey;

class Tweaking
{
	// De la forme
	// public static inline var varName 								: varType = varValue;

	/////////////////////////////////////////////////////////////////////////////////////////////// Player
	public static inline var playerWalkingSpeed							: Float = 150;
	public static inline var playerSprite								: String = "assets/images/MisterBelly.png";

	/////////////////////////////////////////////////////////////////////////////////////////////// Bullets
	public static inline var bulletSpeed								: Int = 200;
	public static inline var bulletLifeSpan								: Float = 5;

	/////////////////////////////////////////////////////////////////////////////////////////////// Traps
	public static inline var trapBulletCooldown							: Float = 1;

	/////////////////////////////////////////////////////////////////////////////////////////////// TWEAKING PROCEDURAL GENERATION
	public static inline var roomSize									: Int  = 25;

	/////////////////////////////////////////////////////////////////////////////////////////////// Inputs (ça va bouger de fichier)

	// AZERTY
	public static inline function moveUpKeys():Array<FlxKey>
	{
		return [
			#if azerty
			FlxKey.Z,
			#else
			FlxKey.W,
			#end
			FlxKey.UP,
			FlxKey.SPACE
		];
	}
	public static inline function moveLeftKeys():Array<FlxKey>
	{
		return [
			#if azerty
			FlxKey.Q,
			#else
			FlxKey.A,
			#end
			FlxKey.LEFT
		];
	}
	public static inline function moveDownKeys():Array<FlxKey>
	{
		return [
			FlxKey.S,
			FlxKey.DOWN
		];
	}
	public static inline function moveRightKeys():Array<FlxKey>
	{
		return [
			FlxKey.D,
			FlxKey.RIGHT
		];
	}
}