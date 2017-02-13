package;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.ui.Keyboard;
import openfl.ui.Mouse;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import openfl.display.FPS;
import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.geom.Rectangle;
import openfl.geom.Point;

import openfl.Assets;
import openfl.media.Sound;

import lime.ui.Joystick;
import lime.ui.JoystickHatPosition;

class Main extends Sprite {
	
	private var tilemap:Tilemap;
	private var tileset:Tileset;
	private var screen:Sprite;
	private var particles:Array<Particle>;
	private var inited:Bool = false;
	private var emitters:Array<Emitter>;
	private var emitterMap:Map<Int, Emitter>;
	private var particleTypes:Array<Int>;
	private var mouseEmitterIndex:Int =0;
	private var heat:Int;
	private var showMouse:Bool = true;
	
	private var joysticks:Array<Joystick>;

	public function new () 
	{	
		super ();	
		init();
	}

	private function init() 
	{
		if (inited) return;
		inited = true;

		particles = new Array<Particle>();
		particleTypes = [];
		emitters = [];
		
		joysticks = [];
		Joystick.onConnect.add (joystick_onConnect);

		// screen = new Sprite();
		// addChild(screen);
		
		var bgbitmap = new Bitmap (Assets.getBitmapData ("assets/bg.png"));
		bgbitmap.x = (stage.stageWidth - bgbitmap.width) / 2;
		bgbitmap.y = (stage.stageHeight - bgbitmap.height) / 2;
	
		var openflBitmap = new Bitmap (Assets.getBitmapData ("assets/openfl.png"));
		openflBitmap.x = (stage.stageWidth - openflBitmap.width) / 2;
		openflBitmap.y = (stage.stageHeight - openflBitmap.height) / 2;

		//var particle:BitmapData = new BitmapData(8, 8, false, 0xcc33ff);
		tileset = new Tileset (Assets.getBitmapData ("assets/sheet.png"));
		particleTypes.push(tileset.addRect (new Rectangle(0,0,48,48))  );
		particleTypes.push(tileset.addRect (new Rectangle(48,0,48,48)) );
		particleTypes.push(tileset.addRect (new Rectangle(96,0,48,48)) );
		particleTypes.push(tileset.addRect (new Rectangle(144,0,48,48)));
		particleTypes.push(tileset.addRect (new Rectangle(0,48,48,48)) );
		particleTypes.push(tileset.addRect (new Rectangle(48,48,48,48)));
		particleTypes.push(tileset.addRect (new Rectangle(96,48,48,48)));
		
		for( i in 0...particleTypes.length)
		{
			var e = new Emitter(i);
			e.setPosition(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight *0.5);
			emitters.push(e);
		}

		tilemap = new Tilemap (stage.stageWidth, stage.stageHeight, tileset);

		addChild (bgbitmap);
		addChild (tilemap);
		addChild (openflBitmap);

		stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
		stage.addEventListener (KeyboardEvent.KEY_DOWN, stage_onKeyDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBegin);
		stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEnd);
		stage.addEventListener(TouchEvent.TOUCH_MOVE, stage_touchMove);
		//Mouse.hide();
	}	

	private function addParticle (e:Emitter):Void 
	{	
		var newParticle = new Particle (e.id);
		newParticle.originX = 24;
		newParticle.originY = 24;
		newParticle.x = e.position.x ;
		newParticle.y = e.position.y ;
		newParticle.acc_x = 0;
		newParticle.acc_y = 0.95;
		newParticle.vel_x = Math.random() * 12 - 6;
		newParticle.vel_y = -12.6 + Math.random() * 5;
		particles.push (newParticle);
		tilemap.addTile (newParticle);
	}

	public function stage_onEnterFrame(e:Event) 
	{	
		for(e in emitters)
		{
			if(e.enabled)
			{
				addParticle(e);
			}
		}

		// render
		for (particle in particles) 
		{
			if (particle.x > stage.stageWidth || particle.x < 0 ) 
			{
				particles.remove(particle);
				tilemap.removeTile(particle);
			} else 
			{
				particle.x += particle.vel_x;
				particle.y += particle.vel_y;
				particle.rotation += particle.rotationSpeed;
				particle.vel_x += particle.acc_x;
				particle.vel_y += particle.acc_y;
				if (particle.y > stage.stageHeight - 16) 
				{
					particle.y = stage.stageHeight -16 ;
					particle.vel_y *= -Math.random()*0.7;

					if( Math.abs(particle.vel_y) < .1  )
					{
						particles.remove(particle);
						tilemap.removeTile(particle);
					}
				}
			}
		}
	}

	private function toggleMouse():Void
	{
		showMouse = !showMouse;
		if(showMouse)
		{
			Mouse.show();
		}else
		{
			Mouse.hide();
		}
	}

	private function stage_touchBegin(event:TouchEvent)
	{
		Mouse.hide();
		var tid:Int = event.touchPointID%emitters.length;
		emitters[tid].setPosition(event.stageX, event.stageY);
		emitters[tid].enabled = true;
		
	}

	private function stage_touchEnd(event:TouchEvent)
	{
		var tid:Int  = event.touchPointID%emitters.length;
		emitters[tid].enabled = false;
	}	

	private function stage_touchMove(event:TouchEvent)
	{
		var tid:Int  = event.touchPointID%emitters.length;
		emitters[tid].setPosition(event.stageX, event.stageY);
	}

	private function stage_mouseDown(event:MouseEvent):Void
	{
		mouseEmitterIndex++;
		if(mouseEmitterIndex > emitters.length-1){
			mouseEmitterIndex = 0;
		}
		emitters[mouseEmitterIndex].enabled = true;
	}

	private function stage_mouseUp(event:MouseEvent):Void
	{
		emitters[mouseEmitterIndex].enabled = false;
	}

	private function stage_mouseMove(event:MouseEvent):Void
	{
		Mouse.show();
		emitters[mouseEmitterIndex].setPosition(event.stageX, event.stageY);
	}

	private function stage_onKeyDown (event:KeyboardEvent):Void
	{	
		switch (event.keyCode) 
		{
			case Keyboard.ESCAPE, Keyboard.F4: 
				openfl.system.System.exit(0);

			case Keyboard.M:
				toggleMouse();
		}
	}

	public function joystick_onConnect (joystick:Joystick):Void 
	{
		joystick.onAxisMove.add (joystick_onAxisMove.bind (joystick));
		joystick.onButtonDown.add (joystick_onButtonDown.bind (joystick));
		joystick.onButtonUp.add (joystick_onButtonUp.bind (joystick));
		joystick.onDisconnect.add (joystick_onDisconnect.bind (joystick));
		joystick.onHatMove.add (joystick_onHatMove.bind (joystick));
		
		joysticks.push (joystick);	
	}
	
	public function joystick_onDisconnect (joystick:Joystick):Void 
	{	
		joysticks.remove (joystick);
	}

	public function joystick_onAxisMove (joystick:Joystick, axis:Int, value:Float):Void
	{
		//trace("axis: " + axis + " -> " + value);
	}
	
	public function joystick_onButtonDown (joystick:Joystick, button:Int):Void
	{	
		if(button < emitters.length)
		{
			emitters[button].setPosition(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight * 0.5);
			emitters[button].enabled =true;
		}
	}
	
	public function joystick_onButtonUp (joystick:Joystick, button:Int):Void 
	{
		if(button < emitters.length)
		{
			emitters[button].enabled =false;
		}
	}
	
	public function joystick_onHatMove (joystick:Joystick, hat:Int, position:JoystickHatPosition):Void 
	{
		//updateJoystickVisual (joystick.id, "hat", hat, position);	
	}
	
}