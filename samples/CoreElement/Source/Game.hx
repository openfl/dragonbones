package;

import haxe.Json;

import openfl.Assets;
import openfl.Vector;

import dragonBones.animation.WorldClock;
import dragonBones.starling.StarlingFactory;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.EnterFrameEvent;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;

class Game extends Sprite
{
	public static inline var GROUND: Int = 500;
	public static inline var G: Float = 0.6;
	public static var instance: Game = null;

	// Global factory
	public var factory: StarlingFactory = new StarlingFactory();

	private var _left: Bool = false;
	private var _right: Bool = false;
	private var _player: Mecha = null;
	private var _bullets: Vector<Bullet> = new Vector<Bullet>();

	public function new()
	{
		super();
		instance = this;
		this.addEventListener(Event.ADDED_TO_STAGE, _addToStageHandler);
	}

	public function addBullet(bullet: Bullet): Void
	{
		_bullets.push(bullet);
	}

	private function _addToStageHandler(event: Event): Void
	{
		factory.parseDragonBonesData(
			Json.parse(Assets.getText("assets/CoreElement.json"))
		);
		factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/CoreElement_texture_1.json")),
			Assets.getBitmapData("assets/CoreElement_texture_1.png")
		);

		this.addEventListener(EnterFrameEvent.ENTER_FRAME, _enterFrameHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, _keyHandler);
		this.stage.addEventListener(TouchEvent.TOUCH, _mouseHandler);

		_player = new Mecha();
		
		var text: TextField = new TextField(800, 60, "Press W/A/S/D to move. Press Q/E/SPACE to switch weapens.\nMouse Move to aim. Click to fire.");
		text.x = 0;
		text.y = this.stage.stageHeight - 60;
		text.autoSize = "center";
		this.addChild(text);
	}

	private function _keyHandler(event: KeyboardEvent): Void
	{
		var isDown:Bool = event.type == KeyboardEvent.KEY_DOWN;
		switch (event.keyCode)
		{
			case 37, 65:
				_left = isDown;
				_updateMove(-1);

			case 39, 68:
				_right = isDown;
				_updateMove(1);

			case 38, 87:
				if (isDown)
				{
					_player.jump();
				}

			case 83, 40:
				_player.squat(isDown);

			case 81:
				if (isDown)
				{
					_player.switchWeaponR();
				}

			case 69:
				if (isDown)
				{
					_player.switchWeaponL();
				}

			case 32:
				if (isDown)
				{
					_player.switchWeaponR();
					_player.switchWeaponL();
				}
		}
	}

	private function _mouseHandler(event: TouchEvent): Void
	{
		var touch: Touch = event.getTouch(this.stage);
		if (touch != null)
		{
			_player.aim(touch.getLocation(this.stage));

			if (touch.phase == TouchPhase.BEGAN)
			{
				_player.attack(true);
			}
			else if (touch.phase == TouchPhase.ENDED)
			{
				_player.attack(false);
			}
		}
	}

	private function _enterFrameHandler(event: EnterFrameEvent): Void
	{
		_player.update();
		
		var i: Int = _bullets.length;
		while (i-- != 0)
		{
			var bullet: Bullet = _bullets[i];
			if (bullet.update())
			{
				_bullets.splice(i, 1);
			}
		}

		WorldClock.instance.advanceTime(-1);
	}

	private function _updateMove(dir: Int): Void
	{
		if (_left && _right)
		{
			_player.move(dir);
		}
		else if (_left)
		{
			_player.move(-1);
		}
		else if (_right)
		{
			_player.move(1);
		}
		else
		{
			_player.move(0);
		}
	}
}