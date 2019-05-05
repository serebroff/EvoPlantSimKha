

//-------------------------------------------------------
// class of Gene 
//-------------------------------------------------------

class Gene {
   
    var probability: Float;
    var symmetry: Bool;
    var activationEnergyDensity: Float;

    public var exons: Array<Float>;

    public function new(e: Array<Float>,  p: Float = 1, s: Bool = false, a:Float = 0)
    {
        exons=e;
        probability=p;
        symmetry = s;
        activationEnergyDensity=0;
    }
}

//-------------------------------------------------------
// class of DNA
//-------------------------------------------------------

class DNA {
    public var genes: Array<Float>;

    public var megagenes: Array<Gene>;
    
    public var branch_length(get, never):Float;
    public var branch_tickness(get, never):Float;
    public var leaf_length(get, never):Float;
    public var leaf_tickness(get, never):Float;
    public var leaf_growth_pos(get, never):Float;
    public var branch_growth_pos(get, never):Float;

        // constants
    public static inline var LEAF_ENERGY_2_BRANCH = 1;
    public static inline var BRANCH_ENERGY_2_LEAF = 1;
    public static inline var BRANCH_ENERGY_2_BRANCH = 1;

    public static inline var LEAF_GROWTH_RATE = 1;
    public static inline var BRANCH_GROWTH_RATE = 1;

    public static inline var LEAF_ENERGY_TO_PRODUCE_BRANCH = 1.0;
    public static inline var BRANCH_ENERGY_TO_PRODUCE_LEAF = 1.0;

    public static inline var LEAF_ENERGY_TO_SHARE = 0.0;
    public static inline var BRANCH_ENERGY_TO_SHARE_WITH_CHILD = 1.0;
    public static inline var BRANCH_ENERGY_TO_SHARE_WITH_PARENT = 0.0;

    public static inline var LEAF_ENERGY_CONSUME = 0.1;
    public static inline var BRANCH_ENERGY_CONSUME = 0.1;

    public static inline var MAX_ENERGY_IN_LEAF = 2;
    public static inline var MAX_ENERGY_IN_BRANCH = 2;

    public static inline var BRANCH_ANGLE_DEVIATION = 0.1;

    public static inline var MAX_GENERATIONS = 15;

    public static inline var END_OF_GENE = -1000;
    public static inline var END_OF_SEQUENCE = -10000;
    
    public var leaves_index: Int;
    public var branches_index: Int;


    public function new()
    {
        genes =[

            20,      // [0] branch length
            0.02,    // [1] branch tickness  w / l
            40,      // [2] leaf lenght
            0.2,     // [3] leaf thickness
            0.3,        // [4] leaf start growth position [0,1] on branch
            0.5,        // [5] branch start growth position [0,1] on branch
            END_OF_SEQUENCE,
            // leaves
            Math.PI*0.4,   // [6] angle of new branches and leaves 0..PI/2
       //     Math.PI * 0.7,
            END_OF_SEQUENCE,
   /*        -Math.PI*0.3,   // [9] angle of new branches 0..PI/2
            0.5,            // [10] probability of [5]
            Math.PI*0.3,   // [11] angle of new branches 0..PI/2
            0.5,            // [12] probability
     /*       -Math.PI*0.1,      // [13]  angle of new branches  0..PI/2
            0.2,     // [14]  probability
            Math.PI*0.1,      // [13]  angle of new branches  0..PI/2
            0.2,     // [14]  probability  */ 
            0,
            1.0,
            END_OF_SEQUENCE
         
        ];

        megagenes = [

            new Gene( [60]),      // [0] branch length
            new Gene([0.01] ),    // [1] branch tickness  w / l
            new Gene( [30 ]),      // [2] leaf lenght
            new Gene( [0.3 ]),     // [3] leaf thickness
            new Gene( [0.5 ]),        // [4] leaf start growth position [0,1] on branch
            new Gene([0.5]),        // [5] branch start growth position [0,1] on branch
            null,
            // leaves
            new Gene( [Math.PI*0.4, Math.PI * 0.7]),   // [6] angle of new branches and leaves 0..PI/2
            null,
            new Gene( [-Math.PI*0.3, Math.PI*0.3 ], 0.1),  // [9] angle of new branches 0..PI/2
            new Gene( [0], 1 ),
            
            null
         
        ];


        var i: Int =0;
        leaves_index = 0;
        while(genes[i]>END_OF_SEQUENCE) i++;
        i++;
        leaves_index=i;

        while(genes[i]>END_OF_SEQUENCE) i++;
        i++;
        branches_index = i;


	}

 
    private  function get_branch_length():Float
    {
        return genes[0];
    }

    private  function get_branch_tickness():Float
    {
        return genes[1];
    }

    private  function get_leaf_length():Float
    {
        return genes[2];
    }
    
    private  function get_leaf_tickness():Float
    {
        return genes[3];
    }
    
    private  function get_leaf_growth_pos():Float
    {
        return genes[4];
    }

    private  function get_branch_growth_pos():Float
    {
        return genes[5];
    }

    public function getBranches(energy) 
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

    public function getLeaves(energy) 
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
	
    public  function dupblicateDNA() 
    {

    }
    	
}








