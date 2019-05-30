
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

    static public var sunlight : Sunlight;

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

        plants = []; //new Plant()];
        seeds = [];
        
        var newSeed = new Seed();
        seeds.push(newSeed);
        
        var dna = new DNA();
        dna.Init();
        newSeed.newDNA = dna;
        newSeed.maxLength=dna.getGeneValue(seedID, lengthID);
        newSeed.length = newSeed.maxLength;
        newSeed.energy = 100;
        newSeed.thickness = dna.getGeneValue( seedID, thicknessID);
        newSeed.dead = true;
        newSeed.startPos.set(0,-100);
        newSeed.dir.set(0,-1);
        newSeed.CalculateVertices();
        newSeed.conservatedEnergy = DNA.MAX_CONSERVATED_ENERGY * newSeed.square;
    
    }

    public static function AddNewPlant(parentSeed: Seed): Plant {
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
            newPlant = new Plant(parentSeed.startPos, parentSeed.newDNA, parentSeed.conservatedEnergy);
            plants.push(newPlant);
        }
        else {
            newPlant.firstBranch = newPlant.CreateNewBranch();
            newPlant.firstBranch.startPos.setFrom(parentSeed.startPos);
            newPlant.firstBranch.energy = parentSeed.conservatedEnergy;
            newPlant.dna = parentSeed.newDNA;
        }
        return newPlant;
        
    }

    public function Calculate(dt: Float): Void {
        
        sunlight.Calculate(dt);
        
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

        //sunlight.CheckCollision(dt);
        sunlight.AddEnergyToHitedLeaves();

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

