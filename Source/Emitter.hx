package ;
import openfl.geom.Point;

class Emitter
{
	public var position:Point;
	public var enabled:Bool = false;
    public var id:Int;

	public function new(id:Int){
        this.id = id;
		this.position = new Point();
	}
	public function setPosition(x:Float, y:Float):Void{
		this.position.x = x; this.position.y = y;
	}

}