
import haxe.macro.Type.MethodKind;

using Utils;

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

    static public var plants(default, null): Array<Plant>;

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

    public static function AddNewPlant(pos: Vec2, dna: DNA, energy: Float): Void {
        plants.push( new Plant(pos, dna, energy));
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

        for( b in branches)
        {
            if (b.totalDeath) continue;
            b.Draw(framebuffer);
        }
        
        for( l in leaves)
        {
            if (l.totalDeath) continue;
            l.Draw(framebuffer);
        }

        for( s in seeds)
        {
            if (s.totalDeath) continue;
            s.Draw(framebuffer);
        }

        sunlight.Draw(framebuffer);
        
    }
}

