


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

}

typedef Vec2 = kha.math.Vector2;