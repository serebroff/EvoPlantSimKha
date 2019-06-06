

//-------------------------------------------------------
// Wind class
//-------------------------------------------------------
class Wind {
	public inline static var MAX_WIND_POWER = 0.2;
	public var windpower_x: Float;
	public var time: Float;

	public function new()
	{
		windpower_x =0;
		time =0;
	}
	public function Calculate()
	{
		time+=FPS.dt;
		windpower_x = Math.sin(time) * MAX_WIND_POWER;
	}
}