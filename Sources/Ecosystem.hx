//-------------------------------------------------------
// Base class of living space for creatures
//-------------------------------------------------------
class Ecosystem 
{
    public static inline var MAX_CREATURES: Int = 1000;

    public static inline var MAX_FOOD: Int = 1000;

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
        
       // var i = creatures.length - 1;

        var i:Int=0, j:Int=0;
        while (j < creatures.length) {
            while (this.creatures[j].IsDead && j < creatures.length) j++;
            if (j>i) this.creatures[i] = this.creatures[j];
             i++;
             j++;
        }
        creatures.splice(i, j-i);

/*        while (i >= 0) {
            if (this.creatures[i].IsDead) {
                this.creatures.splice(i, 1);
            }
            i--;
        }
        */

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

