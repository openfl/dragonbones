package dragonBones.animation;

import openfl.Vector;

import dragonBones.core.BaseObject;
import dragonBones.enums.EventType;
import dragonBones.events.EventObject;
import dragonBones.events.IEventDispatcher;
import dragonBones.objects.ActionData;
import dragonBones.objects.AnimationFrameData;
import dragonBones.objects.EventData;
import dragonBones.objects.FrameData;


/**
 * @private
 */
@:allow(dragonBones) @:final class AnimationTimelineState<TDisplay, TTexture> extends TimelineState<TDisplay, TTexture>
{
	private function new()
	{
		super();
	}
	
	private function _onCrossFrame(frame:FrameData):Void
	{
		if (_animationState.actionEnabled)
		{
			var actions:Vector<ActionData> = cast(frame, AnimationFrameData).actions;
			var l:UInt = actions.length;
			for (i in 0...l)
			{
				_armature._bufferAction(actions[i]);
			}
		}
		
		var eventDispatcher:IEventDispatcher<TDisplay, TTexture> = _armature.eventDispatcher;
		var events:Vector<EventData> = cast(frame, AnimationFrameData).events;
		var l = events.length;
		var eventData:EventData, eventType:String, eventObject:EventObject<TDisplay, TTexture>;
		for (i in 0...l)
		{
			eventData = events[i];
			
			eventType = null;
			switch (eventData.type) 
			{
				case EventType.Frame:
					eventType = EventObject.FRAME_EVENT;
				
				case EventType.Sound:
					eventType = EventObject.SOUND_EVENT;
			}
			
			if (eventDispatcher.hasEvent(eventType) || eventData.type == EventType.Sound) 
			{
				eventObject = cast BaseObject.borrowObject(EventObject);
				eventObject.name = eventData.name;
				eventObject.frame = cast frame;
				eventObject.data = eventData.data;
				eventObject.animationState = _animationState;
				
				if (eventData.bone != null) 
				{
					eventObject.bone = _armature.getBone(eventData.bone.name);
				}
				
				if (eventData.slot != null) 
				{
					eventObject.slot = _armature.getSlot(eventData.slot.name);
				}
				
				_armature._bufferEvent(eventObject, eventType);
			}
		}
	}
	
	override public function update(passedTime:Float):Void
	{
		var prevState:Int = _playState;
		var prevPlayTimes:UInt = _currentPlayTimes;
		var prevTime:Float = _currentTime;
		var eventObject:EventObject<TDisplay, TTexture>;
		
		if (_playState <= 0 && _setCurrentTime(passedTime)) 
		{
			var eventDispatcher:IEventDispatcher<TDisplay, TTexture> = _armature.eventDispatcher;
			
			if (prevState < 0 && _playState != prevState) 
			{
				if (_animationState.displayControl)
				{
					_armature._sortZOrder(null);
				}
				
				if (eventDispatcher.hasEvent(EventObject.START)) 
				{
					eventObject = cast BaseObject.borrowObject(EventObject);
					eventObject.animationState = _animationState;
					_armature._bufferEvent(eventObject, EventObject.START);
				}
			}
			
			if (prevTime < 0.0) 
			{
				return;
			}
			
			if (_keyFrameCount > 1) 
			{
				var currentFrameIndex:UInt = Math.floor(_currentTime * _frameRate);
				var currentFrame:AnimationFrameData = cast _timelineData.frames[currentFrameIndex];
				if (_currentFrame != currentFrame) 
				{
					var isReverse:Bool = _currentPlayTimes == prevPlayTimes && prevTime > _currentTime;
					var crossedFrame:AnimationFrameData = cast _currentFrame;
					_currentFrame = currentFrame;
					
					if (crossedFrame == null) 
					{
						var prevFrameIndex:UInt = Math.floor(prevTime * _frameRate);
						crossedFrame = cast _timelineData.frames[prevFrameIndex];
						
						if (isReverse) 
						{
						}
						else 
						{
							if (
								prevTime <= crossedFrame.position
								// || prevPlayTimes != _currentPlayTimes ?
							) 
							{
								crossedFrame = cast crossedFrame.prev;
							}
						}
					}
					
					if (isReverse) 
					{
						while (crossedFrame != currentFrame) 
						{
							_onCrossFrame(crossedFrame);
							crossedFrame = cast crossedFrame.prev;
						}
					}
					else 
					{
						while (crossedFrame != currentFrame) 
						{
							crossedFrame = cast crossedFrame.next;
							_onCrossFrame(crossedFrame);
						}
					}
				}
			}
			else if (_keyFrameCount > 0 && _currentFrame == null) 
			{
				_currentFrame = _timelineData.frames[0];
				_onCrossFrame(_currentFrame);
			}
			
			if (_currentPlayTimes != prevPlayTimes) 
			{
				if (eventDispatcher.hasEvent(EventObject.LOOP_COMPLETE)) 
				{
					eventObject = cast BaseObject.borrowObject(EventObject);
					eventObject.animationState = _animationState;
					_armature._bufferEvent(eventObject, EventObject.LOOP_COMPLETE);
				}
				
				if (_playState > 0 && eventDispatcher.hasEvent(EventObject.COMPLETE)) 
				{
					eventObject = cast BaseObject.borrowObject(EventObject);
					eventObject.animationState = _animationState;
					_armature._bufferEvent(eventObject, EventObject.COMPLETE);
				}
			}
		}
	}
	
	public function setCurrentTime(value:Float):Void 
	{
		_setCurrentTime(value);
		_currentFrame = null;
	}
}