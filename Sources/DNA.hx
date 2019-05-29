

import haxe.io.Float32Array;
//-------------------------------------------------------
// class of Gene 
//-------------------------------------------------------

class Exon {
    public var id: Float;
    public var length: Float;
    public var thickness: Float;
    public var angle: Float;
    public function new(i: Float, l:Float, t: Float, a: Float) {
        id = i;
        length=l;
        thickness = t;
        angle = a;
    }
}

class Gene {
   
    var probability: Float;
    var everyNgeneration: Float;
    var activationEnergyDensity: Float;

    public var exons: Array<Exon>;

    public function new(e: Array<Exon>,  p: Float = 1, n: Float = 1, a:Float = 0)
    {
        exons= e;
        probability= p;
        everyNgeneration = n;
        activationEnergyDensity= a;
    }
}


//-------------------------------------------------------
// Sets limits of gene values for DNA class
//-------------------------------------------------------
class ProtoDNA {
    public var genelimits: Array<Float>;
    function new()
    {
        genelimits =[

            10, 100,     // [0] branch length
            0.01, 0.1,    // [1] branch thickness  w / l
            10, 100,     // [2] leaf lenght
            0.01, 0.5,    // [3] leaf thickness
            5, 40,        // [4] seed length
            0.2, 0.7,        // [5] seed thickness
            1,1,        // [6] branch start growth position [0,1] on branch
            1, 20,       // [7] number of leaves
            0, 10,         // [8] generation to blossom
            //END_OF_SEQUENCE,
            // leaves
            Math.PI*0.1, Math.PI*0.5,  // [6] angle of new leaves 
            //END_OF_SEQUENCE,
            -Math.PI*0.2,      // [13]  angle of new branches  0..PI/2
            0.5,     // [14]  probability
            Math.PI*0.2,      // [13]  angle of new branches  0..PI/2
            0.5,     // [14]  probability   
            0,  
            1.0,
//            END_OF_SEQUENCE
         
        ];
    }
}

//-------------------------------------------------------
// class of DNA
//-------------------------------------------------------

class DNA {
    public var genes: Array<Float>;

    public var megagenes: Array<Gene>;
    
    public var branch_length(get, never):Float;
    public var branch_thickness(get, never):Float;
    public var leaf_length(get, never):Float;
    public var leaf_thickness(get, never):Float;
    public var seed_length(get, never):Float;
    public var seed_thickness(get, never):Float;
    public var branch_growth_pos(get, never):Float;
    public var leaves_number(get, never):Float;
    public var generation2blossom(get, never):Float;

        // constants
    public static inline var LEAF_ENERGY_2_BRANCH = 1;
    public static inline var BRANCH_ENERGY_2_LEAF = 1;
    public static inline var BRANCH_ENERGY_2_BRANCH = 1;
    public static inline var BRANCH_ENERGY_2_SEED = 1;

    public static inline var LEAF_GROWTH_RATE = 1;
    public static inline var BRANCH_GROWTH_RATE = 1;

    public static inline var BRANCH_ENERGY_TO_PRODUCE_BRANCH = 1.0;
    public static inline var BRANCH_ENERGY_TO_PRODUCE_LEAF = 1.0;

    public static inline var LEAF_ENERGY_TO_SHARE = 0.0;
    public static inline var BRANCH_ENERGY_TO_SHARE_WITH_CHILD = 1.0;
    public static inline var BRANCH_ENERGY_TO_SHARE_WITH_PARENT = 0.0;

    public static inline var LEAF_ENERGY_CONSUME = 0.2;
    public static inline var BRANCH_ENERGY_CONSUME = 0.2;
    public static inline var SEED_ENERGY_CONSUME = 0.2;
    public static inline var SEED_ENERGY_2_CONSERVATE = 1;
    public static inline var MAX_CONSERVATED_ENERGY = 10;

    public static inline var MAX_ENERGY_DENSITY = 3;
   // public static inline var MAX_ENERGY_DENSITY = 3;

    public static inline var BRANCH_ANGLE_DEVIATION = 0.1;

    public static inline var MAX_GENERATIONS = 15;

    public static inline var END_OF_GENE = -1000;
    public static inline var END_OF_SEQUENCE = -10000;
    
    public var leaves_index: Int;
    public var branches_index: Int;


    public function Init()
    {
         genes =[

            80,      // [0] branch length
            0.03,    // [1] branch thickness  w / l
            30,      // [2] leaf lenght
            0.2,     // [3] leaf thickness
            20,         // [4] seed length
            0.5,        // [5] seed thickness
            1,        // [6] branch start growth position [0,1] on branch
            5,        // [7] number of leaves
            2,          // [8] generation to blossom
            END_OF_SEQUENCE,
            // leaves
            Math.PI*0.4,   // [6] angle of new branches and leaves 0..PI/2
        //    Math.PI * 0.7,
            END_OF_SEQUENCE,
   /*        -Math.PI*0.3,   // [9] angle of new branches 0..PI/2
            0.5,            // [10] probability of [5]
            Math.PI*0.3,   // [11] angle of new branches 0..PI/2
            0.5,            // [12] probability
     */      -Math.PI*0.2,      // [13]  angle of new branches  0..PI/2
            0.5,     // [14]  probability
            Math.PI*0.2,      // [13]  angle of new branches  0..PI/2
            0.5,     // [14]  probability   
            0,  
            1.0,
            END_OF_SEQUENCE
         
        ];
        
         megagenes = [

            new Gene([ new Exon(0,100,0.01,0)]),      // [0] branch length
            new Gene([ new Exon(1,30,0.3,0.3)]),       // [2] leaf lenght
            null
        ];

        SetIndices();

    }

    public function SetIndices()
    {





        var i: Int =0;

        while(genes[i]>END_OF_SEQUENCE) i++;
        i++;
        leaves_index=i;

        while(genes[i]>END_OF_SEQUENCE) i++;
        i++;
        branches_index = i;
           
    }

    
    public function new()
    {
        genes = [];
        leaves_index = 0;
        branches_index = 0;
	}
 
    private  function get_branch_length():Float
    {
        return genes[0];
    }

    private  function get_branch_thickness():Float
    {
        return genes[1];
    }

    private  function get_leaf_length():Float
    {
        return genes[2];
    }
    
    private  function get_leaf_thickness():Float
    {
        return genes[3];
    }
    private  function get_seed_length(): Float
    {
        return genes[4];
    }
    private  function get_seed_thickness():Float
    {
        return genes[5];
    }

    private  function get_branch_growth_pos():Float
    {
        return genes[6];
    }

    private  function get_leaves_number(): Float
    {
        return genes[7];
    }
    private  function get_generation2blossom(): Float 
    {
        return genes[8];
    }

    public function getBranches() 
    {
        var angles: Array<Float>;
        angles = new Array<Float>();

        var n:Int = branches_index;
        while (genes[n]>END_OF_SEQUENCE)
        {
            if (Math.random() < genes[n+1])
            {
                angles.push(genes[n] + (2*Math.random()-1)*BRANCH_ANGLE_DEVIATION);
            }
            n+=2;    
        }
        return angles;
    }

    public function getLeaves() 
    {
        var angles: Array<Float>;
        angles = new Array<Float>();
        var n:Int = leaves_index;
        while (genes[n]>END_OF_SEQUENCE)
        {
            angles.push(genes[n]);
            n++;    
        }
  
        return angles;
    }
	
    public  function duplicate() : DNA
    {
        var newDNA : DNA;
        newDNA = new DNA();
        newDNA.genes = genes.copy();
        var genes: Array<Float> = newDNA.genes;
        var i: Int =0;
        while (i < genes.length)
        {
            if (genes[i]==END_OF_SEQUENCE || genes[i]==END_OF_GENE) {
                i++;
                continue;
            }
            var r: Float = Math.random();
            if (r < 0.33) {
                genes[i] *= 0.8;    
            } else if (r < 0.66) {
                genes[i] *=1.2;
            } 
            
            i++;
        }
        newDNA.SetIndices();
        return newDNA;
    }
    	
}








