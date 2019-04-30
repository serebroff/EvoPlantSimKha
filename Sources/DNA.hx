

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


    public function new()
    {
        genes =[
            Math.PI*0.2,   // angle of new branches and leaves 0..PI/2
            90,  // branch length
            0.03,  // branch tickness  w / l
            30,  // leaf lenght
            0.4,  // leaf thickness
            0.2  // leaf frequency
        ];
	}

    private  function get_angle():Float
    {
        return genes[0];
    }
    private  function get_branch_length():Float
    {
        return genes[1];
    }

    private  function get_branch_tickness():Float
    {
        return genes[2];
    }

    private  function get_leaf_length():Float
    {
        return genes[3];
    }
    
    private  function get_leaf_tickness():Float
    {
        return genes[4];
    }
    
    private  function get_leaf_frequency():Float
    {
        return genes[5];
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





