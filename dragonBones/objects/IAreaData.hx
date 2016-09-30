package dragonBones.objects;

interface IAreaData
{
    public var name(get, set):String;
	public function get_name():String;
	public function set_name(name:String):String;
	public function dispose():Void;
}
