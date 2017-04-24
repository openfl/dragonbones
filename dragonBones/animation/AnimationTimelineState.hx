package dragonBones.animation
{
import dragonBones.core.BaseObject;
import dragonBones.core.dragonBones_internal;
import dragonBones.enum.EventType;
import dragonBones.events.EventObject;
import dragonBones.events.IEventDispatcher;
import dragonBones.objects.ActionData;
import dragonBones.objects.AnimationFrameData;
import dragonBones.objects.EventData;
import dragonBones.objects.FrameData;


/**
 * @private
 */
public final class AnimationTimelineState extends TimelineState
{
	public function AnimationTimelineState()
	{
		super(this);
	}
	
	private function _onCrossFrame(frame:FrameData):Void
	{
		if (_animationState.actionEnabled)
		{
			inline var actions:Vector<ActionData> = (frame as AnimationFrameData).actions;
			l:UInt = actions.length;
			for (i in 0...l)
			{
				_armature._bufferAction(actions[i]);
			}
		}
		
		inline var eventDispatcher:IEventDispatcher = _armature.eventDispatcher;
		inline var events:Vector<EventData> = (frame as AnimationFrameData).events;
		var l = events.length;
		for (i in 0...l)
		{
			inline var eventData:EventData = events[i];
			
			var eventType:String = null;
			switch (eventData.type) 
			{
				case EventType.Frame:
					eventType = EventObject.FRAME_EVENT;
					break;
				
				case EventType.Sound:
					eventType = EventObject.SOUND_EVENT;
					break;
			}
			
			if (eventDispatcher.hasEvent(eventType) || eventData.type === EventType.Sound) 
			{
				inline var eventObject:EventObject = BaseObject.borrowObject(EventObject) as EventObject;
				eventObject.name = eventData.name;
				eventObject.frame = frame as AnimationFrameData;
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
		inline var prevState:Int = _playState;
		inline var prevPlayTimes:UInt = _currentPlayTimes;
		inline var prevTime:Float = _currentTime;
		
		if (_playState <= 0 && _setCurrentTime(passedTime)) 
		{
			inline var eventDispatcher:IEventDispatcher = _armature.eventDispatcher;
			
			if (prevState < 0 && _playState !== prevState) 
			{
				if (_animationState.displayControl != null)
				{
					_armature._sortZOrder(null);
				}
				
				if (eventDispatcher.hasEvent(EventObject.START)) 
				{
					var eventObject:EventObject = BaseObject.borrowObject(EventObject) as EventObject;
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
				inline var currentFrameIndex:UInt = Math.floor(_currentTime * _frameRate);
				inline var currentFrame:AnimationFrameData = _timelineData.frames[currentFrameIndex] as AnimationFrameData;
				if (_currentFrame !== currentFrame) 
				{
					inline var isReverse:Bool = _currentPlayTimes === prevPlayTimes && prevTime > _currentTime;
					var crossedFrame:AnimationFrameData = _currentFrame as AnimationFrameData;
					_currentFrame = currentFrame;
					
					if (crossedFrame == null) 
					{
						inline var prevFrameIndex:UInt = Math.floor(prevTime * _frameRate);
						crossedFrame = _timelineData.frames[prevFrameIndex] as AnimationFrameData;
						
						if (isReverse) 
						{
						}
						else 
						{
							if (
								prevTime <= crossedFrame.position
								// || prevPlayTimes !== _currentPlayTimes ?
							) 
							{
								crossedFrame = crossedFrame.prev as AnimationFrameData;
							}
						}
					}
					
					if (isReverse) 
					{
						while (crossedFrame !== currentFrame) 
						{
							_onCrossFrame(crossedFrame);
							crossedFrame = crossedFrame.prev as AnimationFrameData;
						}
					}
					else 
					{
						while (crossedFrame !== currentFrame) 
						{
							crossedFrame = crossedFrame.next as AnimationFrameData;
							_onCrossFrame(crossedFrame);
						}
					}
				}
			}
			else if (_keyFrameCount > 0 && !_currentFrame) 
			{
				_currentFrame = _timelineData.frames[0];
				_onCrossFrame(_currentFrame);
			}
			
			if (_currentPlayTimes !== prevPlayTimes) 
			{
				if (eventDispatcher.hasEvent(EventObject.LOOP_COMPLETE)) 
				{
					eventObject = BaseObject.borrowObject(EventObject) as EventObject;
					eventObject.animationState = _animationState;
					_armature._bufferEvent(eventObject, EventObject.LOOP_COMPLETE);
				}
				
				if (_playState > 0 && eventDispatcher.hasEvent(EventObject.COMPLETE)) 
				{
					eventObject = BaseObject.borrowObject(EventObject) as EventObject;
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
}