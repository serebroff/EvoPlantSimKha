

typedef Vec2 = kha.math.Vector2;

class Utils {
	public static function set(vec2:kha.math.Vector2,x,y)
	{
		vec2.x=x;
		vec2.y=y;

	}
	public static function clone(vec2:kha.math.Vector2):kha.math.Vector2
	{
		var clone = new kha.math.Vector2();
		set(clone, vec2.x, vec2.y);

		return clone;
	}

	public static function lengthSquared(vec2:kha.math.Vector2):Float
	{
		return vec2.x*vec2.x + vec2.y*vec2.y;
	}

	public static function rotate(vec2:kha.math.Vector2, r:Float)
	{
		var x:Float, y:Float;
    	x = vec2.x;
    	y = vec2.y;
    	var cos:Float = Math.cos(r);
    	var sin:Float = Math.sin(r);
    	var rx:Float, ry:Float;

	      rx = cos * x - ( sin) * y;
	      ry = (sin) * x + cos * y;

        return new Vec2(rx, ry);
	}

	public static function skew(vec2:kha.math.Vector2) {
      // Returns a new vector.
    	return new Vec2(-vec2.y, vec2.x);
    }

	public static function sign(vec2:kha.math.Vector2,  p2:kha.math.Vector2,  p3: kha.math.Vector2): Float
	{
    	return (vec2.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (vec2.y - p3.y);
	}

	public static function PointInTriangle (vec2:kha.math.Vector2, v1:Vec2,  v2: Vec2, v3: Vec2):Bool
	{
    	var b1: Bool;
		var b2: Bool;
		var b3: Bool;

	    b1 = sign(vec2, v1, v2) < 0.0;
	    b2 = sign(vec2,v2, v3) < 0.0;
	    b3 = sign(vec2,v3, v1) < 0.0;

	    return ((b1 == b2) && (b2 == b3));
	}

}

