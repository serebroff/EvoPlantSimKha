
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
    static public var numLiveLeaves: Int;
    static public var numLiveSeeds: Int;
    static public var numLiveBranches: Int;
    static public var numLivePlants: Int;

    public var sunlight : Sunlight;

    static public var plants(default, null): Array<Plant>;

    static public var branches: Array<Branch>;
    static public var leaves: Array<Leaf>;
    static public var seeds: Array<Seed>;

    private function new() {
        ecosystem_time =0;
        numLiveLeaves = 0;
        numLiveSeeds = 0;
        numLiveBranches = 0;
        numLivePlants = 0;
        
        sunlight = new Sunlight();

        branches = [];
        leaves = [];
        seeds = [];

        plants = [new Plant()];

    }

    public static function AddNewPlant(pos: Vec2, dna: DNA, energy: Float): Void {
        var newPlant: Plant = null;
        var replaceDead : Bool = false;
        
        for (p in plants){
            if (p.firstBranch == null) {
                newPlant = p;
                replaceDead = true;
                break;
            }
        }
        
        if (!replaceDead) {
            newPlant = new Plant(pos, dna, energy);
            plants.push(newPlant);
        }
        else {
            newPlant.firstBranch = newPlant.CreateNewBranch();
            newPlant.firstBranch.startPos.setFrom(pos);
            newPlant.firstBranch.energy = energy;
            newPlant.dna = dna;
        }
        
    }

    public function Calculate(dt: Float): Void {
        
        sunlight.Calculate(dt);
        
        sunlight.CheckCollision(dt);

        numLivePlants =0;
        for (p in plants) {
            if (p.firstBranch==null) {
                continue;
            }
            numLivePlants++;
            p.Calculate(dt);
        }


        numLiveLeaves=0;
        for( l in leaves)
        {
            if (l.totalDeath) continue;
            numLiveLeaves++;
            if (l.dead) { 
                l.CalculateDeath();
            }
        }

        numLiveSeeds =0;
        for( s in seeds)
        {
            if (s.totalDeath) {
                continue;
            }
            numLiveSeeds++;
            if ( s.dead)  {
                s.CalculateDeath();
            }
        }

        numLiveBranches=0;
        for( b in branches)
        {
            if (b.totalDeath) {
                continue;
            }
            numLiveBranches++;
            if ( b.deathtime>0) {
                b.CalculateDeath();
            }
        } 

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

