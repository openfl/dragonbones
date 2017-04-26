package;

import openfl.geom.Point;

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.starling.StarlingArmatureDisplay;

class Bullet
{
	private var _speedX: Float = 0;
	private var _speedY: Float = 0;

	private var _armature: Armature = null;
	private var _armatureDisplay: StarlingArmatureDisplay = null;

	public function new(armatureName: String, radian: Float, speed: Float, position: Point)
	{
		_speedX = Math.cos(radian) * speed;
		_speedY = Math.sin(radian) * speed;

		_armature = Game.instance.factory.buildArmature(armatureName);
		_armatureDisplay = cast _armature.display;
		_armatureDisplay.x = position.x;
		_armatureDisplay.y = position.y;
		_armatureDisplay.rotation = radian;
		_armature.animation.play("idle");
		
		WorldClock.clock.add(_armature);
		Game.instance.addChild(_armatureDisplay);
	}

	public function update(): Bool
	{
		_speedY += Game.G;
		
		_armatureDisplay.x += _speedX;
		_armatureDisplay.y += _speedY;
		_armatureDisplay.rotation = Math.atan2(_speedY, _speedX);

		if (
			_armatureDisplay.x < -100 || _armatureDisplay.x >= Game.instance.stage.stageWidth + 100 ||
			_armatureDisplay.y < -100 || _armatureDisplay.y >= Game.instance.stage.stageHeight + 100
		)
		{
			WorldClock.clock.remove(_armature);
			Game.instance.removeChild(_armatureDisplay);
			_armature.dispose();

			return true;
		}

		return false;
	}
}