

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

	public static function crossProduct(vec2:kha.math.Vector2, p:kha.math.Vector2) : Float
	{
		return vec2.x * p.y - vec2.y * p.x;
		//return (vec1.x * vec2.y - vec1.y * vec2.x); //vec1.x*vec2.y –  vec1.y*vec2.x;
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

	public static function GetRayToLineSegmentIntersection(rayOrigin:Vec2, rayDirection:Vec2, point1: Vec2,  point2: Vec2): Float
    {
        var v1 : Vec2 = rayOrigin.sub( point1 );
        var v2 : Vec2 = point2.sub( point1);
        var v3: Vec2 = new Vec2(-rayDirection.y, rayDirection.x);


        var dot: Float = v2.dot( v3);
        if (Math.abs(dot) < 0.000001)
            return 0;

        var t1: Float = crossProduct( v2, v1) / dot;
        var t2: Float = v1.dot( v3) / dot;

        if (t1 >= 0.0 && (t2 >= 0.0 && t2 <= 1.0))
            return t1;

        return 0;
    }

    public static function rndsign() : Int
    {
        if (Math.random() <= 0.5) return 1;
        else return -1;
    }

}





