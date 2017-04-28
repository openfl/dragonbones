package;

import openfl.geom.Point;

import dragonBones.Armature;
import dragonBones.animation.WorldClock;
import dragonBones.starling.StarlingArmatureDisplay;

import starling.display.DisplayObject;
import starling.textures.Texture;

class Bullet
{
	private var _speedX: Float = 0;
	private var _speedY: Float = 0;

	private var _armature: Armature<DisplayObject, Texture> = null;
	private var _armatureDisplay: StarlingArmatureDisplay = null;
	private var _effect: Armature<DisplayObject, Texture> = null;

	public function new(armatureName: String, effectArmatureName: String, radian: Float, speed: Float, position: Point)
	{
		_speedX = Math.cos(radian) * speed;
		_speedY = Math.sin(radian) * speed;

		_armature = Game.instance.factory.buildArmature(armatureName);
		_armatureDisplay = cast _armature.display;
		_armatureDisplay.x = position.x;
		_armatureDisplay.y = position.y;
		_armatureDisplay.rotation = radian;
		_armature.animation.play("idle");

		if (effectArmatureName != null)
		{
			_effect = Game.instance.factory.buildArmature(effectArmatureName);
			var effectDisplay: StarlingArmatureDisplay = cast _effect.display;
			effectDisplay.rotation = radian;
			effectDisplay.x = position.x;
			effectDisplay.y = position.y;
			effectDisplay.scaleX = 1 + Math.random() * 1;
			effectDisplay.scaleY = 1 + Math.random() * 0.5;
			if (Math.random() < 0.5)
			{
				effectDisplay.scaleY *= -1;
			}
			
			_effect.animation.play("idle");
			
			WorldClock.clock.add(_effect);
			Game.instance.addChild(effectDisplay);
		}

		WorldClock.clock.add(_armature);
		Game.instance.addChild(_armatureDisplay);
	}

	public function update(): Bool
	{
		_armatureDisplay.x += _speedX;
		_armatureDisplay.y += _speedY;

		if (
			_armatureDisplay.x < -100 || _armatureDisplay.x >= Game.instance.stage.stageWidth + 100 ||
			_armatureDisplay.y < -100 || _armatureDisplay.y >= Game.instance.stage.stageHeight + 100
		)
		{
			WorldClock.clock.remove(_armature);
			Game.instance.removeChild(_armatureDisplay);
			_armature.dispose();

			if (_effect != null)
			{
				WorldClock.clock.remove(_effect);
				Game.instance.removeChild(cast _effect.display);
				_effect.dispose();
			}

			return true;
		}

		return false;
	}
}