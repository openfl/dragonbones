package;


import openfl.display.Sprite;
#if !flixel
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.text.TextField;

import starling.core.Starling;
#else
import flixel.FlxGame;
#end


class Main extends Sprite {
	
	#if !flixel
	private var _isMoved:Bool = false;
	private var _isHorizontalMoved:Bool = false;
	private var _armatureIndex: Float = 0;
	private var _animationIndex: Float = 0;
	private var _currentArmatureScale: Float = 1;
	private var _currentAnimationScale: Float = 1;
	private var _prevArmatureScale: Float = 1;
	private var _prevAnimationScale: Float = 1;
	private var _startPoint:Point = new Point();
	#end

	public function new()
	{
		super();

		#if flixel
		// Render init.
		_flixelInit();
		#else
		// Render init.
		_flashInit();
		_starlingInit();
		
		// Add event listeners.
		this.stage.addEventListener(MouseEvent.MOUSE_UP, _mouseHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, _mouseHandler);
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, _mouseHandler);
		
		// Add infomation.
		var text:TextField = new TextField();
		text.width = this.stage.stageWidth;
		text.height = 60;
		text.x = 0;
		text.y = this.stage.stageHeight - 60;
		text.autoSize = "center";
		text.text = "Touch screen left to change armature / right to change animation.\nTouch move to scale armature and animation.";
		this.addChild(text);
		#end

	}
	
	#if flixel
	private function _flixelInit(): Void
	{
		addChild(new FlxGame(800, 600, FlixelRender));
	}
	#else
	private function _flashInit(): Void
	{
		var openFLRender: OpenFLRender = new OpenFLRender();
		this.addChild(openFLRender);
	}
	
	private function _starlingInit(): Void
	{
		var starling: Starling = new Starling(StarlingRender, this.stage);
		starling.start();
	}
	
	/** 
	 * Touch event listeners.
	 * Touch to change armature and animation.
	 * Touch move to change armature and animation scale.
	 */
	private function _mouseHandler(event: MouseEvent): Void
	{
		switch (event.type)
		{
			case MouseEvent.MOUSE_DOWN:
				if (OpenFLRender.instance != null)
				{
					_prevArmatureScale = OpenFLRender.instance.armatureDisplay.scaleX;
					_prevAnimationScale = OpenFLRender.instance.armatureDisplay.animation.timeScale;
				}
				else
				{
					_prevArmatureScale = StarlingRender.instance.armatureDisplay.scaleX;
					_prevAnimationScale = StarlingRender.instance.armatureDisplay.animation.timeScale;
				}
				_startPoint.setTo(this.stage.mouseX, this.stage.mouseY);
			
			case MouseEvent.MOUSE_UP:
				if (_isMoved)
				{
					_isMoved = false;
				}
				else
				{
					var touchRight: Bool = event.localX > stage.stageWidth * 0.5;
					
					if (OpenFLRender.instance != null)
					{
						if (OpenFLRender.instance != null && OpenFLRender.instance.dragonBonesData.armatureNames.length > 1 && !touchRight)
						{
							OpenFLRender.instance.changeArmature();
						}
						else
						{
							OpenFLRender.instance.changeAnimation();
						}
					}
					
					if (StarlingRender.instance != null)
					{
						if (StarlingRender.instance != null && StarlingRender.instance.dragonBonesData.armatureNames.length > 1 && !touchRight)
						{
							StarlingRender.instance.changeArmature();
						}
						else
						{
							StarlingRender.instance.changeAnimation();
						}
					}
				}
			
			case MouseEvent.MOUSE_MOVE:
				if (event.buttonDown)
				{
					var dX:Float = _startPoint.x - event.stageX;
					var dY:Float = _startPoint.y - event.stageY;
					
					if (!_isMoved) 
					{
						var dAX:Float = Math.abs(dX);
						var dAY:Float = Math.abs(dY);
						
						if (dAX > 5 || dAY > 5) 
						{
							_isMoved = true;
							_isHorizontalMoved = dAX > dAY;
						}
					}
					
					if (_isMoved)
					{
						if (_isHorizontalMoved) 
						{
							var currentAnimationScale:Float = Math.max((-dX / 200) + _prevAnimationScale, 0.01);
							
							if (OpenFLRender.instance != null)
							{
								OpenFLRender.instance.armatureDisplay.animation.timeScale = currentAnimationScale;
							}
							
							if (StarlingRender.instance != null)
							{
								StarlingRender.instance.armatureDisplay.animation.timeScale = currentAnimationScale;
							}
						} 
						else 
						{
							var currentArmatureScale:Float = Math.max((dY / 200) + _prevArmatureScale, 0.01);
							if (OpenFLRender.instance != null)
							{
								OpenFLRender.instance.armatureDisplay.scaleX = OpenFLRender.instance.armatureDisplay.scaleY = currentArmatureScale;
							}
							
							if (StarlingRender.instance != null)
							{
								StarlingRender.instance.armatureDisplay.scaleX = StarlingRender.instance.armatureDisplay.scaleY = currentArmatureScale;
							}
						}
					}
				}
		}
	}
	#end
}