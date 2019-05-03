

//-------------------------------------------------------
// class of DNA
//-------------------------------------------------------

class DNA {
    public var genes: Array<Float>;
    
    
    public var angle(get, never):Float;
    public var branch_length(get, never):Float;
    public var branch_tickness(get, never):Float;
    public var leaf_length(get, never):Float;
    public var leaf_tickness(get, never):Float;
    public var leaf_frequency(get, never):Float;

        // constants
    public static inline var LEAF_ENERGY_2_BRANCH = 1;
    public static inline var BRANCH_ENERGY_2_LEAF = 1;
    public static inline var BRANCH_ENERGY_2_BRANCH = 1;

    public static inline var LEAF_GROWTH_RATE = 1;
    public static inline var BRANCH_GROWTH_RATE = 1;

    public static inline var LEAF_ENERGY_TO_PRODUCE_BRANCH = 0.5;
    public static inline var BRANCH_ENERGY_TO_PRODUCE_LEAF = 0.5;

    public static inline var LEAF_ENERGY_TO_SHARE = 0.5;
    public static inline var BRANCH_ENERGY_TO_SHARE = 0.5;

    public static inline var LEAF_ENERGY_CONSUME = 0.1;
    public static inline var BRANCH_ENERGY_CONSUME = 0.1;

    public static inline var MAX_ENERGY_IN_LEAF = 2;
    public static inline var MAX_ENERGY_IN_BRANCH = 2;

    public static inline var MAX_GENERATIONS = 15;

    public static inline var END_OF_SEQUENCE = -10000;
    
    public var leaves_index: Int;
    public var branches_index: Int;


    public function new()
    {
        genes =[
            60,      // [0] branch length
            0.03,    // [1] branch tickness  w / l
            30,      // [2] leaf lenght
            0.3,     // [3] leaf thickness
            0.5,        // [4] leaf frequency
            END_OF_SEQUENCE,
            // leaves
            -Math.PI*0.4,   // [5] angle of new branches and leaves 0..PI/2
            Math.PI*0.4,   // [6] angle of new branches and leaves 0..PI/2
            Math.PI * 0.7,
            - Math.PI * 0.7,
            END_OF_SEQUENCE,
            -Math.PI*0.3,   // [9] angle of new branches 0..PI/2
            0.1,            // [10] probability of [5]
            Math.PI*0.3,   // [11] angle of new branches 0..PI/2
            0.1,            // [12] probability
            -Math.PI*0.1,      // [13]  angle of new branches  0..PI/2
            0.5,     // [14]  probability
            Math.PI*0.1,      // [13]  angle of new branches  0..PI/2
            0.5,     // [14]  probability
            END_OF_SEQUENCE
         
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
    
    private  function get_leaf_frequency():Float
    {
        return genes[4];
    }

    private  function get_angle():Float
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
                angles.push(genes[n]);
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

//-------------------------------------------------------
// class of DNA
//-------------------------------------------------------

class Exon {
    public var angle: Float;
    public var weight: Float;
    public var length: Float;

    public function new( a: Float, w: Float, l: Float)
    {

        angle = a;
        weight = w;
        length = l;
    }

    public function set( a: Float, w: Float, l: Float)
    {

        angle = a;
        weight = w;
        length = l;
    }
}

class Gene {
    public var exons: Array<Exon>;
    public function new( e0 : Exon, ?e1: Exon, ?e2: Exon, ?e3: Exon, ?e4: Exon   )
    {
        exons =[];
        exons.push(e0);
        if (e1 != null) exons.push(e1);
        if (e2 != null) exons.push(e2);
        if (e3 != null) exons.push(e3);
        if (e4 != null) exons.push(e4);
    }
}


class DNA2 {
    public var genes: Array<Gene>;

    public function new( g0 : Gene, ?g1: Gene, ?g2: Gene, ?g3: Gene, ?g4: Gene   )
    {
        genes =[];
        genes.push(g0);
        if (g1 != null) genes.push(g1);
        if (g2 != null) genes.push(g2);
        if (g3 != null) genes.push(g3);
        if (g4 != null) genes.push(g4);
	}

	
    public function NormalizeDNA() 
    {
        var gene : Gene;
        var exon : Exon;
        var totalWeight : Float;
        var angle : Float;

        for( gene in genes)
        {
            totalWeight = 0;
            for(exon in gene.exons)
            {
                totalWeight += exon.weight;
            }
            
            for(exon in gene.exons)
            {
                exon.weight/= totalWeight;
                exon.angle *= Math.PI / 180;
            }
        }
    }
    	
}





