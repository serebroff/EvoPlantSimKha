//-------------------------------------------------------
// Base class of living space for creatures
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

    public var food: Array<Food>;

    public var creatures(default, null): Array<Creature>;

    private function new() {
         this.creatures = [for (i in 0...MAX_CREATURES) new Creature()];
        this.food = [for (i in 0...MAX_FOOD) new Food()];


    }


   public function Calculate(dt: Float): Void {
        
        for (creature in this.creatures) {
            creature.Calculate(dt);
        }
        for (f in food) {
            f.Calculate(dt);
        }

    }

    public function Render(framebuffer:kha.Framebuffer) {

//        ctx.setTransform(1, 0, 0, 1, 0, 0);
        for (f in food)
        {
                f.Draw(framebuffer);
        }

        for (creature in creatures)
        {
                creature.Draw(framebuffer);
        }
        
    }
}

