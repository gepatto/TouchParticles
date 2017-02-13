package ;
import openfl.display.Tile;

class Particle extends Tile {
    
	public var vel_x:Float;
	public var vel_y:Float;
	public var acc_x:Float;
	public var acc_y:Float;
    public var rotationSpeed:Float;
	
    public function new (tileID:Int = 0) {
        super (tileID);
        this.scaleX = Math.random();
        this.scaleY = this.scaleX;
        this.rotationSpeed = Math.random()*10;
    }
}