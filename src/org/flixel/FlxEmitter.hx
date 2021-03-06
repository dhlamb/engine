package org.flixel;

import flash.display.Bitmap;
import flash.display.BlendMode;

class FlxEmitter extends FlxTypedEmitter<FlxParticle>
{
	public function new(X:Float = 0, Y:Float = 0, Size:Int = 0)
	{
		super(X, Y, Size);
	}
}

/**
 * <code>FlxEmitter</code> is a lightweight particle emitter.
 * It can be used for one-time explosions or for
 * continuous fx like rain and fire.  <code>FlxEmitter</code>
 * is not optimized or anything; all it does is launch
 * <code>FlxParticle</code> objects out at set intervals
 * by setting their positions and velocities accordingly.
 * It is easy to use and relatively efficient,
 * relying on <code>FlxGroup</code>'s RECYCLE POWERS.
 */
class FlxTypedEmitter<T:FlxParticle> extends FlxTypedGroup<FlxParticle>
{
	/**
	 * The x position range of the emitter in world space.
	 */
	public var xPosition:Bounds<Float>;
	/**
	 * The y position range of emitter in world space.
	 */
	public var yPosition:Bounds<Float>;
	/**
	 * The x velocity range of a particle.
	 * The default value is (-100,-100).
	 */
	public var xVelocity:Bounds<Float>;
	/**
	 * The y velocity range of a particle.
	 * The default value is (100,100).
	 */
	public var yVelocity:Bounds<Float>;
	/**
	 * The X and Y drag component of particles launched from the emitter.
	 */
	public var particleDrag:FlxPoint;
	/**
	 * The minimum and maximum possible angular velocity of a particle.  The default value is (-360, 360).
	 * NOTE: rotating particles are more expensive to draw than non-rotating ones!
	 */
	public var rotation:Bounds<Float>;
	/**
	 * Sets the <code>acceleration</code> member of each particle to this value on launch.
	 */
	public var acceleration:FlxPoint;
	/**
	 * Determines whether the emitter is currently emitting particles.
	 * It is totally safe to directly toggle this.
	 */
	public var on:Bool;
	/**
	 * How often a particle is emitted (if emitter is started with Explode == false).
	 */
	public var frequency:Float;
	
	public var life:Bounds<Float>;
	
	/**
	 * Sets start scale range (when particle emits)
	 */
	public var startScale:Bounds<Float>;
	/**
	 * Sets end scale range (when particle dies)
	 */
	public var endScale:Bounds<Float>;
	
	/**
	 * Sets start alpha range (when particle emits)
	 */
	public var startAlpha:Bounds<Float>;
	
	/**
	 * Sets end alpha range (when particle emits)
	 */
	public var endAlpha:Bounds<Float>;
	
	/**
	 * Sets start red color component range (when particle emits)
	 */
	public var startRed:Bounds<Float>;
	
	/**
	 * Sets start green color component range (when particle emits)
	 */
	public var startGreen:Bounds<Float>;
	
	/**
	 * Sets start blue color component range (when particle emits)
	 */
	public var startBlue:Bounds<Float>;
	
	/**
	 * Sets end red color component range (when particle emits)
	 */
	public var endRed:Bounds<Float>;
	
	/**
	 * Sets end green color component range (when particle emits)
	 */
	public var endGreen:Bounds<Float>;
	
	/**
	 * Sets end blue color component range (when particle emits)
	 */
	public var endBlue:Bounds<Float>;
	
	/**
	 * Sets particle's blend mode. null by default.
	 * Warning: expensive on flash target
	 */
	public var blend:BlendMode;
	
	/**
	 * How much each particle should bounce.  1 = full bounce, 0 = no bounce.
	 */
	public var bounce:Float;
	/**
	 * Internal variable for tracking the class to create when generating particles.
	 */
	private var _particleClass:Class<T>;
	/**
	 * Internal helper for deciding how many particles to launch.
	 */
	private var _quantity:Int;
	/**
	 * Internal helper for the style of particle emission (all at once, or one at a time).
	 */
	private var _explode:Bool;
	/**
	 * Internal helper for deciding when to launch particles or kill them.
	 */
	private var _timer:Float = 0;
	/**
	 * Internal counter for figuring out how many particles to launch.
	 */
	private var _counter:Int;
	/**
	 * Internal point object, handy for reusing for memory mgmt purposes.
	 */
	private var _point:FlxPoint;
	/**
	 * Internal helper for automatic call the kill() method
	 */
	private var _waitForKill:Bool = false;
	
	/**
	 * Creates a new <code>FlxEmitter</code> object at a specific position.
	 * Does NOT automatically generate or attach particles!
	 * @param	X		The X position of the emitter.
	 * @param	Y		The Y position of the emitter.
	 * @param	Size	Optional, specifies a maximum capacity for this emitter.
	 */
	public function new(X:Float = 0, Y:Float = 0, Size:Int = 0)
	{
		super(Size);
		
		xPosition = new Bounds<Float>(X, 0);
		yPosition = new Bounds<Float>(Y, 0);
		xVelocity = new Bounds<Float>( -100, 100);
		yVelocity = new Bounds<Float>( -100, 100);
		rotation = new Bounds<Float>( -360, 360);
		startScale = new Bounds<Float>(1, 1);
		endScale = new Bounds<Float>(1, 1);
		startAlpha = new Bounds<Float>(1.0, 1.0);
		endAlpha = new Bounds<Float>(1.0, 1.0);
		startRed = new Bounds<Float>(1.0, 1.0);
		startGreen = new Bounds<Float>(1.0, 1.0);
		startBlue = new Bounds<Float>(1.0, 1.0);
		endRed = new Bounds<Float>(1.0, 1.0);
		endGreen = new Bounds<Float>(1.0, 1.0);
		endBlue = new Bounds<Float>(1.0, 1.0);
		blend = null;
		acceleration = new FlxPoint(0, 0);
		_particleClass = cast FlxParticle;
		particleDrag = new FlxPoint();
		frequency = 0.1;
		life = new Bounds<Float>(3, 3);
		bounce = 0;
		_quantity = 0;
		_counter = 0;
		_explode = true;
		on = false;
		exists = false;
		_point = new FlxPoint();
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		xPosition = null;
		yPosition = null;
		xVelocity = null;
		yVelocity = null;
		rotation = null;
		startScale = null;
		endScale = null;
		startAlpha = null;
		endAlpha = null;
		startRed = null;
		startGreen = null;
		startBlue = null;
		endRed = null;
		endGreen = null;
		endBlue = null;
		blend = null;
		acceleration = null;
		
		particleDrag = null;
		_particleClass = null;
		_point = null;
		super.destroy();
	}
	
	/**
	 * This function generates a new array of particle sprites to attach to the emitter.
	 * @param	Graphics		If you opted to not pre-configure an array of FlxParticle objects, you can simply pass in a particle image or sprite sheet.
	 * @param	Quantity		The number of particles to generate when using the "create from image" option.
	 * @param	BakedRotations	How many frames of baked rotation to use (boosts performance).  Set to zero to not use baked rotations.
	 * @param	Multiple		Whether the image in the Graphics param is a single particle or a bunch of particles (if it's a bunch, they need to be square!).
	 * @param	Collide			Whether the particles should be flagged as not 'dead' (non-colliding particles are higher performance).  0 means no collisions, 0-1 controls scale of particle's bounding box.
	 * @return	This FlxEmitter instance (nice for chaining stuff together, if you're into that).
	 */
	public function makeParticles(Graphics:Dynamic, Quantity:Int = 50, BakedRotations:Int = 16, Multiple:Bool = false, Collide:Float = 0.8):FlxTypedEmitter<T>
	{
		maxSize = Quantity;
		var totalFrames:Int = 1;
		if (Multiple)
		{ 
			var sprite:FlxSprite = new FlxSprite();
			sprite.loadGraphic(Graphics, true);
			totalFrames = sprite.frames;
			sprite.destroy();
		}
		
		var randomFrame:Int;
		var particle:FlxParticle;
		var i:Int = 0;
		while (i < Quantity)
		{
			particle = Type.createInstance(_particleClass, []);
			if (Multiple)
			{
				randomFrame = Std.int(FlxG.random() * totalFrames); 
				if (BakedRotations > 0)
				{
					#if flash
					particle.loadRotatedGraphic(Graphics, BakedRotations, randomFrame);
					#else
					particle.loadGraphic(Graphics, true);
					particle.frame = randomFrame;
					#end
				}
				else
				{
					particle.loadGraphic(Graphics, true);
					particle.frame = randomFrame;
				}
			}
			else
			{
				if (BakedRotations > 0)
				{
					#if flash
					particle.loadRotatedGraphic(Graphics, BakedRotations);
					#else
					particle.loadGraphic(Graphics);
					#end
				}
				else
				{
					particle.loadGraphic(Graphics);
				}
			}
			if(Collide > 0)
			{
				particle.width *= Collide;
				particle.height *= Collide;
				particle.centerOffsets();
			}
			else
			{
				particle.allowCollisions = FlxObject.NONE;
			}
			particle.exists = false;
			add(particle);
			i++;
		}
		return this;
	}
	
	/**
	 * Called automatically by the game loop, decides when to launch particles and when to "die".
	 */
	override public function update():Void
	{
		if (on)
		{
			if (_explode)
			{
				on = false;
				_waitForKill = true;
				var i:Int = 0;
				var l:Int = _quantity;
				if ((l <= 0) || (l > length))
				{
					l = length;
				}
				while(i < l)
				{
					emitParticle();
					i++;
				}
				_quantity = 0;
			}
			else
			{
				// Spawn a particle per frame
				if (frequency <= 0)
				{
					emitParticle();
					if((_quantity > 0) && (++_counter >= _quantity))
					{
						on = false;
						_waitForKill = true;
						_quantity = 0;
					}
				}
				else
				{
					_timer += FlxG.elapsed;
					while (_timer > frequency)
					{
						_timer -= frequency;
						emitParticle();
						if ((_quantity > 0) && (++_counter >= _quantity))
						{
							on = false;
							_waitForKill = true;
							_quantity = 0;
						}
					}
				}
			}
		}
		else if (_waitForKill)
		{
			_timer += FlxG.elapsed;
			if ((life.max > 0) && (_timer > life.max))
			{
				kill();
				return;
			}
		}
		
		super.update();
	}
	
	/**
	 * Call this function to turn off all the particles and the emitter.
	 */
	override public function kill():Void
	{
		on = false;
		_waitForKill = false;
		super.kill();
	}
	
	/**
	 * Call this function to start emitting particles.
	 * @param	Explode		Whether the particles should all burst out at once.
	 * @param	Lifespan	How long each particle lives once emitted. 0 = forever.
	 * @param	Frequency	Ignored if Explode is set to true. Frequency is how often to emit a particle. 0 = never emit, 0.1 = 1 particle every 0.1 seconds, 5 = 1 particle every 5 seconds.
	 * @param	Quantity	How many particles to launch. 0 = "all of the particles".
	 * @param	LifespanRange	Max amount to add to the particle's lifespan. Leave it to default (zero), if you want to make particle "live" forever (plus you should set Lifespan parameter to zero too).
	 */
	public function start(Explode:Bool = true, Lifespan:Float = 0, Frequency:Float = 0.1, Quantity:Int = 0, LifespanRange:Float = 0):Void
	{
		revive();
		visible = true;
		on = true;
		
		_explode = Explode;
		life.min = Lifespan;
		life.max = Lifespan + Math.abs(LifespanRange);
		frequency = Frequency;
		_quantity += Quantity;
		
		_counter = 0;
		_timer = 0;
		
		_waitForKill = false;
	}
	
	/**
	 * This function can be used both internally and externally to emit the next particle.
	 */
	public function emitParticle():Void
	{
		var particle:FlxParticle = recycle(cast _particleClass);
		particle.elasticity = bounce;
		
		particle.reset(x - (Std.int(particle.width) >> 1) + FlxG.random() * width, y - (Std.int(particle.height) >> 1) + FlxG.random() * height);
		particle.visible = true;
		
		if (life.min != life.max)
		{
			particle.lifespan = particle.maxLifespan = life.min + FlxG.random() * (life.max - life.min);
		}
		else
		{
			particle.lifespan = particle.maxLifespan = life.min;
		}
		
		if (startAlpha.min != startAlpha.max)
		{
			particle.startAlpha = startAlpha.min + FlxG.random() * (startAlpha.max - startAlpha.min);
		}
		else
		{
			particle.startAlpha = startAlpha.min;
		}
		particle.alpha = particle.startAlpha;
		
		var particleEndAlpha:Float = endAlpha.min;
		if (endAlpha.min != endAlpha.max)
		{
			particleEndAlpha = endAlpha.min + FlxG.random() * (endAlpha.max - endAlpha.min);
		}
		
		if (particleEndAlpha != particle.startAlpha)
		{
			particle.useFading = true;
			particle.rangeAlpha = particleEndAlpha - particle.startAlpha;
		}
		else
		{
			particle.useFading = false;
			particle.rangeAlpha = 0;
		}
		// particle color settings
		var startRedComp:Float = particle.startRed = startRed.min;
		var startGreenComp:Float = particle.startGreen = startGreen.min;
		var startBlueComp:Float = particle.startBlue = startBlue.min;
		
		var endRedComp:Float = endRed.min;
		var endGreenComp:Float = endGreen.min;
		var endBlueComp:Float = endBlue.min;
		
		if (startRed.min != startRed.max)
		{
			particle.startRed = startRedComp = startRed.min + FlxG.random() * (startRed.max - startRed.min);
		}
		if (startGreen.min != startGreen.max)
		{
			particle.startGreen = startGreenComp = startGreen.min + FlxG.random() * (startGreen.max - startGreen.min);
		}
		if (startBlue.min != startBlue.max)
		{
			particle.startBlue = startBlueComp = startBlue.min + FlxG.random() * (startBlue.max - startBlue.min);
		}
		
		if (endRed.min != endRed.max)
		{
			endRedComp = endRed.min + FlxG.random() * (endRed.max - endRed.min);
		}
		
		if (endGreen.min != endGreen.max)
		{
			endGreenComp = endGreen.min + FlxG.random() * (endGreen.max - endGreen.min);
		}
		
		if (endBlue.min != endBlue.max)
		{
			endBlueComp = endBlue.min + FlxG.random() * (endBlue.max - endBlue.min);
		}
		
		particle.rangeRed = endRedComp - startRedComp;
		particle.rangeGreen = endGreenComp - startGreenComp;
		particle.rangeBlue = endBlueComp - startBlueComp;
		
		particle.useColoring = false;
		if (particle.rangeRed != 0 || particle.rangeGreen != 0 || particle.rangeBlue != 0)
		{
			particle.useColoring = true;
		}
		// end of particle color settings
		if (startScale.min != startScale.max)
		{
			particle.startScale = startScale.min + FlxG.random() * (startScale.max - startScale.min);
		}
		else
		{
			particle.startScale = startScale.min;
		}
		particle.scale.x = particle.scale.y = particle.startScale;
		
		var particleEndScale:Float = endScale.min;
		if (endScale.min != endScale.max)
		{
			particleEndScale = endScale.min + Std.int(FlxG.random() * (endScale.max - endScale.min));
		}
		
		if (particleEndScale != particle.startScale)
		{
			particle.useScaling = true;
			particle.rangeScale = particleEndScale - particle.startScale;
		}
		else
		{
			particle.useScaling = false;
			particle.rangeScale = 0;
		}
		
		particle.blend = blend;
		
		if (xVelocity.min != xVelocity.max)
		{
			particle.velocity.x = xVelocity.min + FlxG.random() * (xVelocity.max - xVelocity.min);
		}
		else
		{
			particle.velocity.x = xVelocity.min;
		}
		if (yVelocity.min != yVelocity.max)
		{
			particle.velocity.y = yVelocity.min + FlxG.random() * (yVelocity.max - yVelocity.min);
		}
		else
		{
			particle.velocity.y = yVelocity.min;
		}
		particle.acceleration.make(acceleration.x, acceleration.y);
		
		if (rotation.min != rotation.max)
		{
			particle.angularVelocity = rotation.min + FlxG.random() * (rotation.max - rotation.min);
		}
		else
		{
			particle.angularVelocity = rotation.min;
		}
		if (particle.angularVelocity != 0)
		{
			particle.angle = FlxG.random() * 360 - 180;
		}
		
		particle.drag.make(particleDrag.x, particleDrag.y);
		particle.onEmit();
	}
	
	/**
	 * A more compact way of setting the width and height of the emitter.
	 * @param	Width	The desired width of the emitter (particles are spawned randomly within these dimensions).
	 * @param	Height	The desired height of the emitter.
	 */
	public function setSize(Width:Int, Height:Int):Void
	{
		width = Width;
		height = Height;
	}
	
	/**
	 * A more compact way of setting the X velocity range of the emitter.
	 * @param	Min		The minimum value for this range.
	 * @param	Max		The maximum value for this range.
	 */
	public function setXSpeed(Min:Float = 0, Max:Float = 0):Void
	{
		if (Max < Min)
			Max = Min;
		
		xVelocity.min = Min;
		xVelocity.max = Max;
	}
	
	/**
	 * A more compact way of setting the Y velocity range of the emitter.
	 * @param	Min		The minimum value for this range.
	 * @param	Max		The maximum value for this range.
	 */
	public function setYSpeed(Min:Float = 0, Max:Float = 0):Void
	{
		if (Max < Min)
			Max = Min;
			
		yVelocity.min = Min;
		yVelocity.max = Max;
	}
	
	/**
	 * A more compact way of setting the angular velocity constraints of the emitter.
	 * @param	Min		The minimum value for this range.
	 * @param	Max		The maximum value for this range.
	 */
	public function setRotation(Min:Float = 0, Max:Float = 0):Void
	{
		if (Max < Min)
			Max = Min;
		
		rotation.min = Min;
		rotation.max = Max;
	}
	
	/**
	 * A more compact way of setting the scale constraints of the emitter.
	 * @param	startMin	The minimum value for particle scale at the start (emission).
	 * @param	startMax	The maximum value for particle scale at the start (emission).
	 * @param	endMin		The minimum value for particle scale at the end (death).
	 * @param	endMax		The maximum value for particle scale at the end (death).
	 */
	public function setScale(startMin:Float = 1, startMax:Float = 1, endMin:Float = 1, endMax:Float = 1):Void
	{
		if (startMax < startMin)	
			startMax = startMin;
		
		if (endMax < endMin)		
			endMax = endMin;
		
		startScale.min = startMin;
		startScale.max = startMax;
		endScale.min = endMin;
		endScale.max = endMax;
	}
	
	/**
	 * A more compact way of setting the alpha constraints of the emitter.
	 * @param	startMin	The minimum value for particle alpha at the start (emission).
	 * @param	startMax	The maximum value for particle alpha at the start (emission).
	 * @param	endMin		The minimum value for particle alpha at the end (death).
	 * @param	endMax		The maximum value for particle alpha at the end (death).
	 */
	public function setAlpha(startMin:Float = 1.0, startMax:Float = 1.0, endMin:Float = 1.0, endMax:Float = 1.0):Void
	{
		if (startMin < 0)
			startMin = 0;
		
		if (startMax < startMin)
			startMax = startMin;
		
		if (endMin < 0)
			endMin = 0;
		
		if (endMax < endMin)
			endMax = endMin;
		
		startAlpha.min = startMin;
		startAlpha.max = startMax;
		endAlpha.min = endMin;
		endAlpha.max = endMax;
	}
	
	/**
	 * A more compact way of setting the color constraints of the emitter.
	 * But it's not so flexible as setting values of each color bounds objects.
	 * @param	start		The start particles color at the start (emission).
	 * @param	endMin		The end particles color at the end (death).
	 */
	public function setColor(start:Int = 0xffffff, end:Int = 0xffffff):Void
	{
		start &= 0xffffff;
		end &= 0xffffff;
		
		var startRedComp:Float = (start >> 16 & 0xFF) / 255;
		var startGreenComp:Float = (start >> 8 & 0xFF) / 255;
		var startBlueComp:Float = (start & 0xFF) / 255;
		
		var endRedComp:Float = (end >> 16 & 0xFF) / 255;
		var endGreenComp:Float = (end >> 8 & 0xFF) / 255;
		var endBlueComp:Float = (end & 0xFF) / 255;
		
		startRed.min = startRed.max = startRedComp;
		startGreen.min = startGreen.max = startGreenComp;
		startBlue.min = startBlue.max = startBlueComp;
		
		endRed.min = endRed.max = endRedComp;
		endGreen.min = endGreen.max = endGreenComp;
		endBlue.min = endBlue.max = endBlueComp;
	}
	
	/**
	 * Change the emitter's midpoint to match the midpoint of a <code>FlxObject</code>.
	 * @param	Object		The <code>FlxObject</code> that you want to sync up with.
	 */
	public function at(Object:FlxObject):Void
	{
		Object.getMidpoint(_point);
		x = _point.x - (Std.int(width) >> 1);
		y = _point.y - (Std.int(height) >> 1);
	}
	
	/**
	 * Set your own particle class type here. The custom class must extend <code>FlxParticle</code>.
	 * Default is <code>FlxParticle</code>.
	 */
	public var particleClass(get_particleClass, set_particleClass):Class<T>;
	
	private function get_particleClass():Class<T> 
	{
		return _particleClass;
	}
	
	private function set_particleClass(value:Class<T>):Class<T> 
	{
		return _particleClass = value;
	}
	
	/**
	 * The width of the emitter.  Particles can be randomly generated from anywhere within this box.
	 */
	public var width(get_width, set_width):Float;
	
	private function get_width():Float
	{
		return xPosition.max;
	}
	
	private function set_width(value:Float):Float
	{
		xPosition.max = value;
		return value;
	}
	
	/**
	 * The height of the emitter.  Particles can be randomly generated from anywhere within this box.
	 */
	public var height(get_height, set_height):Float;
	
	private function get_height():Float
	{
		return yPosition.max;
	}
	
	private function set_height(value:Float):Float
	{
		yPosition.max = value;
		return value;
	}
	
	public var x(get_x, set_x):Float;
	
	private function get_x():Float
	{
		return xPosition.min;
	}
	
	private function set_x(value:Float):Float
	{
		xPosition.min = value;
		return value;
	}
	
	public var y(get_y, set_y):Float;
	
	private function get_y():Float
	{
		return yPosition.min;
	}
	
	private function set_y(value:Float):Float
	{
		yPosition.min = value;
		return value;
	}
	
	/**
	 * Sets the <code>acceleration.y</code> member of each particle to this value on launch.
	 */
	public var gravity(get_gravity, set_gravity):Float;
	
	private function get_gravity():Float
	{
		return acceleration.y;
	}
	
	private function set_gravity(value:Float):Float
	{
		acceleration.y = value;
		return value;
	}
	
	/**
	 * The minimum possible angular velocity of a particle. The default value is -360.
	 * NOTE: rotating particles are more expensive to draw than non-rotating ones!
	 */
	public var minRotation(get_minRotation, set_minRotation):Float;
	
	private function get_minRotation():Float
	{
		return rotation.min;
	}
	
	private function set_minRotation(value:Float):Float
	{
		rotation.min = value;
		return value;
	}
	
	/**
	 * The maximum possible angular velocity of a particle. The default value is 360.
	 * NOTE: rotating particles are more expensive to draw than non-rotating ones!
	 */
	public var maxRotation(get_maxRotation, set_maxRotation):Float;
	
	private function get_maxRotation():Float
	{
		return rotation.max;
	}
	
	private function set_maxRotation(value:Float):Float
	{
		rotation.max = value;
		return value;
	}
	
	/**
	 * How long each particle lives once it is emitted.
	 * Set lifespan to 'zero' for particles to live forever.
	 */
	public var lifespan(get_lifespan, set_lifespan):Float;
	
	private function get_lifespan():Float
	{
		return life.min;
	}
	
	private function set_lifespan(value:Float):Float
	{
		var dl:Float = life.max - life.min;
		life.min = value;
		life.max = value + dl;
		return value;
	}
}

/**
 * Helper object for holding bounds of different variables
 */
class Bounds<T>
{
	public var min:T;
	public var max:T;

	public function new(min:T, max:Null<T> = null)
	{
		this.min = min;
		this.max = max == null ? min : max;
	}
}