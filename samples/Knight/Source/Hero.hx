package;

import openfl.geom.Point;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.animation.WorldClock;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;

import starling.events.Event;

class Hero
{
	private static inline var MAX_WEAPON_LEVEL: UInt = 3;
	private static inline var JUMP_SPEED: Float = -15;
	private static inline var MOVE_SPEED: Float = 4;
	private static var WEAPON_LIST: Array<String> = ["sword", "pike", "axe", "bow"];

	private var _isJumping: Bool = false;
	private var _isAttacking: Bool = false;
	private var _hitCount: UInt = 0;
	private var _weaponIndex: Int = 0;
	private var _weaponName: String; //= WEAPON_LIST[_weaponIndex];
	private var _weaponsLevel: Array<Int> = [0, 0, 0, 0];
	private var _faceDir: Int = 1;
	private var _moveDir: Int = 0;
	private var _speedX: Float = 0;
	private var _speedY: Float = 0;

	private var _armature: Armature = null;
	private var _armatureDisplay: StarlingArmatureDisplay = null;
	private var _armArmature: Armature = null;

	public function new()
	{
		_weaponName = WEAPON_LIST[_weaponIndex];
		
		_armature = Game.instance.factory.buildArmature("knight");
		_armatureDisplay = cast _armature.display;
		_armatureDisplay.x = 400;
		_armatureDisplay.y = Game.GROUND;
		_armatureDisplay.scaleX = _armatureDisplay.scaleY = 1;

		_armArmature = _armature.getSlot("armOutside").childArmature;
		_armArmature.eventDispatcher.addEvent(EventObject.COMPLETE, _armEventHandler);
		_armArmature.eventDispatcher.addEvent(EventObject.FRAME_EVENT, _armEventHandler);

		_updateAnimation();

		WorldClock.clock.add(_armature);
		Game.instance.addChild(_armatureDisplay);
	}

	public function update(): Void
	{
		_updatePosition();
	}

	public function move(dir: Int): Void
	{
		if (_moveDir == dir)
		{
			return;
		}

		_moveDir = dir;
		if (_moveDir != 0)
		{
			if (_faceDir != _moveDir)
			{
				_faceDir = _moveDir;
				_armatureDisplay.scaleX *= -1;
			}
		}

		_updateAnimation();
	}

	public function jump(): Void
	{
		if (_isJumping)
		{
			return;
		}

		_isJumping = true;
		_speedY = JUMP_SPEED;
		_armature.animation.fadeIn("jump");
	}
	
	public function attack():Void
	{
		if(_isAttacking)
		{
			return;
		}
		
		_isAttacking = true;
		var animationName: String = "attack_" + _weaponName + "_" + (_hitCount + 1);
		_armArmature.animation.fadeIn(animationName);
	}

	public function switchWeapon(): Void
	{
		_isAttacking = false;
		_hitCount = 0;
		
		_weaponIndex++;
		if (_weaponIndex >= WEAPON_LIST.length)
		{
			_weaponIndex = 0;
		}

		_weaponName = WEAPON_LIST[_weaponIndex];

		_armArmature.animation.fadeIn("ready_" + _weaponName);
	}

	public function upgradeWeapon(dir: Int): Void
	{
		var weaponLevel: Int = _weaponsLevel[_weaponIndex] + dir;
		weaponLevel %= MAX_WEAPON_LEVEL;
		if (weaponLevel < 0)
		{
			weaponLevel = MAX_WEAPON_LEVEL + weaponLevel;
		}
		
		_weaponsLevel[_weaponIndex] = weaponLevel;
		
		// Replace display.
		if (_weaponName == "bow")
		{
			_armArmature.getSlot("bow").childArmature = Game.instance.factory.buildArmature("knightFolder/" + _weaponName + "_" + (weaponLevel + 1));
		}
		else
		{
			Game.instance.factory.replaceSlotDisplay(
				null, "weapons", "weapon", 
				"knightFolder/" + _weaponName + "_" + (weaponLevel + 1), 
				_armArmature.getSlot("weapon")
			);
		}
	}
	
	private static var _localPoint: Point = new Point();
	private static var _globalPoint: Point = new Point();
	
	private function _armEventHandler(event: Event): Void
	{
		var eventObject: EventObject = event.data;
		switch (event.type)
		{
			case EventObject.COMPLETE:
				_isAttacking = false;
				_hitCount = 0;
				var animationName: String = "ready_" + _weaponName;
				_armArmature.animation.fadeIn(animationName);

			case EventObject.FRAME_EVENT:
				if(eventObject.name == "ready")
				{
					_isAttacking = false;
					_hitCount++;
				}
				else if (eventObject.name == "fire")
				{
					var firePointBone: Bone = eventObject.armature.getBone("bow");

					_localPoint.x = firePointBone.global.x;
					_localPoint.y = firePointBone.global.y;

					(eventObject.armature.display:StarlingArmatureDisplay).localToGlobal(_localPoint, _globalPoint);
					
					var radian:Float = 0;
					if(_faceDir > 0)
					{
						radian = firePointBone.global.rotation + (eventObject.armature.display:StarlingArmatureDisplay).rotation;
					}
					else
					{
						radian = Math.PI - (firePointBone.global.rotation + (eventObject.armature.display:StarlingArmatureDisplay).rotation);
					}
					
					switch (_weaponsLevel[_weaponIndex])
					{
						case 0:
							_fire(_globalPoint, radian);
						
						case 1:
							_fire(_globalPoint, radian + 3 / 180 * Math.PI);
							_fire(_globalPoint, radian - 3 / 180 * Math.PI);
						
						case 2:
							_fire(_globalPoint, radian + 6 / 180 * Math.PI);
							_fire(_globalPoint, radian);
							_fire(_globalPoint, radian - 6 / 180 * Math.PI);
					}
				}
		}
	}

	private function _fire(firePoint: Point, radian:Float): Void
	{
		var bullet: Bullet = new Bullet("arrow", radian, 20, firePoint);
		Game.instance.addBullet(bullet);
	}

	private function _updateAnimation(): Void
	{
		if (_isJumping)
		{
			return;
		}

		if (_moveDir == 0)
		{
			_speedX = 0;
			_armature.animation.fadeIn("stand");
		}
		else
		{
			_speedX = MOVE_SPEED * _moveDir;
			_armature.animation.fadeIn("run");
		}
	}

	private function _updatePosition(): Void
	{
		if (_speedX != 0)
		{
			_armatureDisplay.x += _speedX;
			if (_armatureDisplay.x < 0)
			{
				_armatureDisplay.x = 0;
			}
			else if (_armatureDisplay.x > Game.instance.stage.stageWidth)
			{
				_armatureDisplay.x = Game.instance.stage.stageWidth;
			}
		}

		if (_speedY != 0)
		{
			if (_speedY < 0 && _speedY + Game.G >= 0)
			{
				_armature.animation.fadeIn("fall");
			}
			
			_speedY += Game.G;

			_armatureDisplay.y += _speedY;
			if (_armatureDisplay.y > Game.GROUND)
			{
				_armatureDisplay.y = Game.GROUND;
				_isJumping = false;
				_speedY = 0;
				_speedX = 0;
				_updateAnimation();
			}
		}
	}
}