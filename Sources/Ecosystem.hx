//-------------------------------------------------------
// Base class of living space for plants
//-------------------------------------------------------
class Ecosystem 
{
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

    public var sunlight : Sunlight;

    public var plants(default, null): Array<Plant>;

    static public var branches: Array<Branch>;
    static public var leaves: Array<Leaf>;
    static public var seeds: Array<Seed>;

    private function new() {
        ecosystem_time =0;
        
        sunlight = new Sunlight();

        branches = [];
        leaves = [];
        seeds = [];

         plants = [new Plant()];

    }


   public function Calculate(dt: Float): Void {
        
        sunlight.Calculate(dt);

        for (p in plants) {
            p.Calculate(dt);
        }

        sunlight.CheckCollision(dt);

        ecosystem_time += dt;

    }

    public function Render(framebuffer:kha.Framebuffer) {


        /*for (plant in plants)
        {
            plant.Draw(framebuffer);
        }*/

        for( b in Ecosystem.branches)
        {
            b.Draw(framebuffer);
        }
        
        for( l in Ecosystem.leaves)
        {
            l.Draw(framebuffer);
        }

        for( s in Ecosystem.seeds)
        {
            s.Draw(framebuffer);
        }

        sunlight.Draw(framebuffer);
        
    }
}

