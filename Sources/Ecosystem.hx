//-------------------------------------------------------
// Base class of living space for plants
//-------------------------------------------------------
class Ecosystem 
{
    public static inline var MAX_CREATURES: Int = 1;

    public static inline var MAX_FOOD: Int = 500;

    public static var instance(get, null):Ecosystem;

    private static var _instance:Ecosystem;

    private static function get_instance():Ecosystem
    {
        if (_instance == null)
        {
            _instance = new Ecosystem();
        }

        return _instance;
    }

    static public var ecosystem_time: Float;

    public var foton: Array<Foton>;
    public var sunlight : Sunlight;

    public var plants(default, null): Array<Plant>;

    private function new() {
        ecosystem_time =0;
        
        sunlight = new Sunlight();

         this.plants = [for (i in 0...MAX_CREATURES) new Plant()];
        this.foton = [for (i in 0...MAX_FOOD) new Foton()];


    }


   public function Calculate(dt: Float): Void {
        
        sunlight.Calculate(dt);

        for (plant in this.plants) {
            plant.Calculate(dt);
        }


        sunlight.CheckCollision(dt);



        ecosystem_time += dt;

    }

    public function Render(framebuffer:kha.Framebuffer) {


        for (plant in plants)
        {
            plant.Draw(framebuffer);
        }

        sunlight.Draw(framebuffer);
        
    }
}

