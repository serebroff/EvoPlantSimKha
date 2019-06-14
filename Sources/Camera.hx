import kha.Framebuffer;
using Utils;

class Camera {
	static var matrix: Matrix3;
	static var x: Float;
	static var y: Float;
	static public var zoom: Float;
	public static function Init()
	{
		matrix = Matrix3.identity();
		x = 0; 
		y = 0;
		zoom = 1;
	}
	public static function load(fb:Framebuffer)
	{
		matrix.setFrom(Matrix3.identity());
		matrix.setFrom(matrix.multmat(Matrix3.translation(x,y)));
		matrix.setFrom(matrix.multmat(Matrix3.scale(zoom,zoom)));
		fb.g2.transformation.setFrom(fb.g2.transformation.multmat(matrix));
	}

	public static function identity()
	{
		matrix.setFrom(Matrix3.identity());
	}

	public static function translate(xx: Float, yy: Float)
	{
		x += xx; 
		y += yy;
		if (y<0) y=0;
		if (y> Sunlight.BEAM_LENGTH * 0.3 ) {
			y = Sunlight.BEAM_LENGTH * 0.3;
		}
		var xlim: Float = 0.3 * Sunlight.NUM_BEAMS *Sunlight.BEAM_DISTANCE;
		if (x< -xlim) x = -xlim;
		if (x> xlim) x = xlim;

	}
	public static function scale(x: Float)
	{
		zoom *= x;
		 if (zoom< 0.8) zoom = 0.8;
		 if (zoom> 2.5) zoom = 2.5;
	}
}