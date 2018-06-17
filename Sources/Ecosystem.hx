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

    public var foton: Array<Foton>;

    public var plants(default, null): Array<Plant>;

    private function new() {
         this.plants = [for (i in 0...MAX_CREATURES) new Plant()];
        this.foton = [for (i in 0...MAX_FOOD) new Foton()];


    }


   public function Calculate(dt: Float): Void {
        
        for (plant in this.plants) {
            plant.Calculate(dt);
        }
        for (f in foton) {
            f.Calculate(dt);
        }

         for (f in foton) {
            for (plant in this.plants)
            {
                f.CheckCollision(plant);
            }
        }


    }

    public function Render(framebuffer:kha.Framebuffer) {

//        ctx.setTransform(1, 0, 0, 1, 0, 0);
        for (f in foton)
        {
            f.Draw(framebuffer);
        }

        for (plant in plants)
        {
            plant.Draw(framebuffer);
        }
        
    }
}

