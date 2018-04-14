package;

import openfl.geom.Point;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.animation.AnimationState;
import dragonBones.animation.AnimationFadeOutMode;
import dragonBones.animation.WorldClock;
import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;

import starling.events.Event;

class Mecha
{
	private static inline var NORMAL_ANIMATION_GROUP: String = "normal";
	private static inline var AIM_ANIMATION_GROUP: String = "aim";
	private static inline var ATTACK_ANIMATION_GROUP: String = "attack";
	private static inline var JUMP_SPEED: Float = 20;
	private static inline var NORMALIZE_MOVE_SPEED: Float = 3.6;
	private static inline var MAX_MOVE_SPEED_FRONT: Float = NORMALIZE_MOVE_SPEED * 1.4;
	private static inline var MAX_MOVE_SPEED_BACK: Float = NORMALIZE_MOVE_SPEED * 1.0;
	private static var WEAPON_R_LIST: Array<String> = ["weapon_1502b_r", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d", "weapon_1005e"];
	private static var WEAPON_L_LIST: Array<String> = ["weapon_1502b_l", "weapon_1005", "weapon_1005b", "weapon_1005c", "weapon_1005d"];

	private var _isJumpingA: Bool = false;
	private var _isJumpingB: Bool = false;
	private var _isSquating: Bool = false;
	private var _isAttackingA: Bool = false;
	private var _isAttackingB: Bool = false;
	private var _weaponRIndex: Int = 0;
	private var _weaponLIndex: Int = 0;
	private var _faceDir: Int = 1;
	private var _aimDir: Int = 0;
	private var _moveDir: Int = 0;
	private var _aimRadian: Float = 0;
	private var _speedX: Float = 0;
	private var _speedY: Float = 0;
	private var _armature: Armature = null;
	private var _armatureDisplay: StarlingArmatureDisplay = null;
	private var _weaponR: Armature = null;
	private var _weaponL: Armature = null;
	private var _aimState: AnimationState = null;
	private var _walkState: AnimationState = null;
	private var _attackState: AnimationState = null;
	private var _target: Point = new Point();

	public function new()
	{
		_armature = Game.instance.factory.buildArmature("mecha_1502b");
		_armatureDisplay = cast _armature.display;
		_armatureDisplay.x = 400;
		_armatureDisplay.y = Game.GROUND;
		_armatureDisplay.scaleX = _armatureDisplay.scaleY = 1;
		_armature.eventDispatcher.addEvent(EventObject.FADE_IN_COMPLETE, _animationEventHandler);
		_armature.eventDispatcher.addEvent(EventObject.FADE_OUT_COMPLETE, _animationEventHandler);

		// Mecha effects only controled by normalAnimation.
		_armature.getSlot("effects_1").displayController = NORMAL_ANIMATION_GROUP;
		_armature.getSlot("effects_2").displayController = NORMAL_ANIMATION_GROUP;

		// Get weapon childArmature.
		_weaponR = _armature.getSlot("weapon_r").childArmature;
		_weaponL = _armature.getSlot("weapon_l").childArmature;
		_weaponR.eventDispatcher.addEvent(EventObject.FRAME_EVENT, _frameEventHandler);
		_weaponL.eventDispatcher.addEvent(EventObject.FRAME_EVENT, _frameEventHandler);

		_updateAnimation();

		WorldClock.clock.add(_armature);
		Game.instance.addChild(_armatureDisplay);
	}

	public function update(): Void
	{
		_updatePosition();
		_updateAim();
		_updateAttack();
	}

	public function move(dir: Int): Void
	{
		if (_moveDir == dir)
		{
			return;
		}

		_moveDir = dir;
		_updateAnimation();
	}

	public function jump(): Void
	{
		if (_isJumpingA)
		{
			return;
		}

		_isJumpingA = true;
		_armature.animation.fadeIn("jump_1", -1, -1, 0, NORMAL_ANIMATION_GROUP);
		_walkState = null;
	}

	public function squat(isSquating: Bool): Void
	{
		if (_isSquating == isSquating)
		{
			return;
		}

		_isSquating = isSquating;
		_updateAnimation();
	}

	public function attack(isAttacking: Bool): Void
	{
		if (_isAttackingA == isAttacking)
		{
			return;
		}

		_isAttackingA = isAttacking;
	}

	public function switchWeaponR(): Void
	{
		_weaponRIndex++;
		if (_weaponRIndex >= WEAPON_R_LIST.length)
		{
			_weaponRIndex = 0;
		}

		_weaponR.eventDispatcher.removeEvent(EventObject.FRAME_EVENT, _frameEventHandler);

		var weaponName: String = WEAPON_R_LIST[_weaponRIndex];
		_weaponR = Game.instance.factory.buildArmature(weaponName);
		_armature.getSlot("weapon_r").childArmature = _weaponR;
		_weaponR.eventDispatcher.addEvent(EventObject.FRAME_EVENT, _frameEventHandler);
	}

	public function switchWeaponL(): Void
	{
		_weaponLIndex++;
		if (_weaponLIndex >= WEAPON_L_LIST.length)
		{
			_weaponLIndex = 0;
		}

		_weaponL.eventDispatcher.removeEvent(EventObject.FRAME_EVENT, _frameEventHandler);

		var weaponName: String = WEAPON_L_LIST[_weaponLIndex];
		_weaponL = Game.instance.factory.buildArmature(weaponName);
		_armature.getSlot("weapon_l").childArmature = _weaponL;
		_weaponL.eventDispatcher.addEvent(EventObject.FRAME_EVENT, _frameEventHandler);
	}

	public function aim(target: Point): Void
	{
		if (_aimDir == 0)
		{
			_aimDir = 10;
		}

		_target.copyFrom(target);
	}

	private function _animationEventHandler(event: Event): Void
	{
		var eventObject: EventObject = event.data;
		switch (event.type)
		{
			case EventObject.FADE_IN_COMPLETE:
				if (eventObject.animationState.name == "jump_1")
				{
					_isJumpingB = true;
					_speedY = -JUMP_SPEED;
					_armature.animation.fadeIn("jump_2", -1, -1, 0, NORMAL_ANIMATION_GROUP);
				}
				else if (eventObject.animationState.name == "jump_4")
				{
					_updateAnimation();
				}

			case EventObject.FADE_OUT_COMPLETE:
				if (eventObject.animationState.name == "attack_01")
				{
					_isAttackingB = false;
					_attackState = null;
				}
		}
	}

	private static var _localPoint: Point = new Point();
	private static var _globalPoint: Point = new Point();

	private function _frameEventHandler(event: Event): Void
	{
		var eventObject: EventObject = event.data;
		if (eventObject.name == "onFire")
		{
			var firePointBone: Bone = eventObject.armature.getBone("firePoint");

			_localPoint.x = firePointBone.global.x;
			_localPoint.y = firePointBone.global.y;

			cast(eventObject.armature.display, StarlingArmatureDisplay).localToGlobal(_localPoint, _globalPoint);

			_fire(_globalPoint);
		}
	}

	private function _fire(firePoint: Point): Void
	{
		firePoint.x += Math.random() * 2 - 1;
		firePoint.y += Math.random() * 2 - 1;

		var radian: Float = _faceDir < 0 ? Math.PI - _aimRadian : _aimRadian;
		var bullet: Bullet = new Bullet("bullet_01", "fireEffect_01", radian + Math.random() * 0.02 - 0.01, 40, firePoint);

		Game.instance.addBullet(bullet);
	}

	private function _updateAnimation(): Void
	{
		if (_isJumpingA)
		{
			return;
		}

		if (_isSquating)
		{
			_speedX = 0;
			_armature.animation.fadeIn("squat", -1, -1, 0, NORMAL_ANIMATION_GROUP);
			_walkState = null;
			return;
		}

		if (_moveDir == 0)
		{
			_speedX = 0;
			_armature.animation.fadeIn("idle", -1, -1, 0, NORMAL_ANIMATION_GROUP);
			_walkState = null;
		}
		else
		{
			if (_walkState == null)
			{
				_walkState = _armature.animation.fadeIn("walk", -1, -1, 0, NORMAL_ANIMATION_GROUP);
			}

			if (_moveDir * _faceDir > 0)
			{
				_walkState.timeScale = MAX_MOVE_SPEED_FRONT / NORMALIZE_MOVE_SPEED;
			}
			else
			{
				_walkState.timeScale = -MAX_MOVE_SPEED_BACK / NORMALIZE_MOVE_SPEED;
			}

			if (_moveDir * _faceDir > 0)
			{
				_speedX = MAX_MOVE_SPEED_FRONT * _faceDir;
			}
			else
			{
				_speedX = -MAX_MOVE_SPEED_BACK * _faceDir;
			}
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
			if (_speedY < 5 && _speedY + Game.G >= 5)
			{
				_armature.animation.fadeIn("jump_3", -1, -1, 0, NORMAL_ANIMATION_GROUP);
			}

			_speedY += Game.G;

			_armatureDisplay.y += _speedY;
			if (_armatureDisplay.y > Game.GROUND)
			{
				_armatureDisplay.y = Game.GROUND;
				_isJumpingA = false;
				_isJumpingB = false;
				_speedY = 0;
				_speedX = 0;
				_armature.animation.fadeIn("jump_4", -1, -1, 0, NORMAL_ANIMATION_GROUP);
				if (_isSquating || _moveDir != 0)
				{
					_updateAnimation();
				}
			}
		}
	}

	private function _updateAim(): Void
	{
		if (_aimDir == 0)
		{
			return;
		}

		_faceDir = _target.x > _armatureDisplay.x ? 1 : -1;
		if (_armatureDisplay.scaleX * _faceDir < 0)
		{
			_armatureDisplay.scaleX *= -1;
			if (_moveDir != 0)
			{
				_updateAnimation();
			}
		}

		var aimOffsetY: Float = _armature.getBone("chest").global.y;

		if (_faceDir > 0)
		{
			_aimRadian = Math.atan2(_target.y - _armatureDisplay.y - aimOffsetY, _target.x - _armatureDisplay.x);
		}
		else
		{
			_aimRadian = Math.PI - Math.atan2(_target.y - _armatureDisplay.y - aimOffsetY, _target.x - _armatureDisplay.x);
			if (_aimRadian > Math.PI)
			{
				_aimRadian -= Math.PI * 2;
			}
		}

		var aimDir: Int = 0;
		if (_aimRadian > 0)
		{
			aimDir = -1;
		}
		else
		{
			aimDir = 1;
		}

		if (_aimDir != aimDir)
		{
			_aimDir = aimDir;

			// Animation Mixing.
			if (_aimDir >= 0)
			{
				_aimState = _armature.animation.fadeIn(
					"aimUp", 0, 1,
					0, AIM_ANIMATION_GROUP, AnimationFadeOutMode.SameGroup
				);
			}
			else
			{
				_aimState = _armature.animation.fadeIn(
					"aimDown", 0, 1,
					0, AIM_ANIMATION_GROUP, AnimationFadeOutMode.SameGroup
				);
			}

			// Add bone Mask.
			//_aimState.addBoneMask("pelvis");
		}

		_aimState.weight = Math.abs(_aimRadian / Math.PI * 2);

		//_armature.invalidUpdate("pelvis"); // Only Update bone Mask.
		_armature.invalidUpdate();
	}

	private function _updateAttack(): Void
	{
		if (!_isAttackingA || _isAttackingB)
		{
			return;
		}

		_isAttackingB = true;

		//Animation Mixing.
		_attackState = _armature.animation.fadeIn(
			"attack_01", -1, -1,
			0, ATTACK_ANIMATION_GROUP, AnimationFadeOutMode.SameGroup
		);

		_attackState.autoFadeOutTime = @:privateAccess _attackState.fadeTotalTime;
		_attackState.addBoneMask("pelvis");
	}
}