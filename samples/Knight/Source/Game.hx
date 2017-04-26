package;

import haxe.Json;

import openfl.Assets;
import openfl.Vector;

import dragonBones.animation.WorldClock;
import dragonBones.events.EventObject;
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
	private var _player: Hero = null;
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
			Json.parse(Assets.getText("assets/Knight.json"))
		);
		factory.parseTextureAtlasData(
			Json.parse(Assets.getText("assets/Knight_texture_1.json")),
			Assets.getBitmapData("assets/Knight_texture_1.png")
		);

		_player = new Hero();
		
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, _enterFrameHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyHandler);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, _keyHandler);
		this.stage.addEventListener(TouchEvent.TOUCH, _mouseHandler);

		var text: TextField = new TextField(800, 60, "Press W/A/S/D to move. Press SPACE to switch weapen. Press Q/E to upgrade weapen.\nClick to attack.");
		text.x = 0;
		text.y = this.stage.stageHeight - 60;
		text.autoSize = "center";
		this.addChild(text);
	}

	private function _enterFrameHandler(event: EnterFrameEvent): Void
	{
		_player.update();
		
		var i: Int = _bullets.length;
		while (i-- > 0)
		{
			var bullet: Bullet = _bullets[i];
			if (bullet.update())
			{
				_bullets.splice(i, 1);
			}
		}

		WorldClock.instance.advanceTime(0.015);
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

			case 81:
				if (isDown)
				{
					_player.upgradeWeapon(-1);
				}

			case 69:
				if (isDown)
				{
					_player.upgradeWeapon(1);
				}

			case 32:
				if (isDown)
				{
					_player.switchWeapon();
				}
		}
	}

	private function _mouseHandler(event: TouchEvent): Void
	{
		var touch: Touch = event.getTouch(this.stage);
		if (touch != null)
		{
			if (touch.phase == TouchPhase.BEGAN)
			{
				_player.attack();
			}
		}
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