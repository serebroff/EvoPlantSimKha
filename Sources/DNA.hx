import haxe.io.Float32Array;

//-------------------------------------------------------
// class of Gene
//-------------------------------------------------------
@:enum
abstract OrganID(Int) {
	var leaveID = 0;
	var branchID = 1;
	var seedID = 2;
}

@:enum
abstract OrganParameterID(Int) {
	var lengthID = 0;
	var thicknessID = 1;
	var angleID = 2;
	var leaves_numberID = 3;
	var generation2blossomID = 4;
	var start_growth_posID = 5;
}

class Exon {
	public var id:OrganID;
	public var length:Float;
	public var thickness:Float;
	public var angle:Float;

	public function new(i:OrganID, l:Float, t:Float, a:Float) {
		id = i;
		length = l;
		thickness = t;
		angle = a;
	}
}

class Gene {
	public var organ:OrganID;
	public var organParameter:OrganParameterID;
	public var probability:Float;
	public var everyNgeneration:Float;
	public var activationEnergyDensity:Float;
	public var value:Float;

	public function new(organ:OrganID, organParameter:OrganParameterID, value:Float, p:Float = 1, n:Float = 1, a:Float = 0) {
		this.organ = organ;
		this.organParameter = organParameter;
		this.value = value;
		this.probability = p;
		this.everyNgeneration = n;
		this.activationEnergyDensity = a;
	}
}

//-------------------------------------------------------
// class of DNA
//-------------------------------------------------------
class DNA {
	public var genes:Array<Gene>;

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


	public function Init() {


		genes = [

			new Gene(branchID, lengthID, 80),  //
            new Gene(branchID, thicknessID, 0.03), //
            new Gene(branchID, start_growth_posID, 1), //
			new Gene(branchID, leaves_numberID, 5), //
            new Gene(branchID, generation2blossomID, 2), //
            new Gene(branchID, angleID, 0), //
			
            new Gene(branchID, angleID, -Math.PI * 0.2, 0.5), new Gene(branchID, angleID, Math.PI * 0.2, 0.5), new Gene(leaveID, lengthID, 30),

			new Gene(leaveID, thicknessID, 0.2), new Gene(leaveID, angleID, Math.PI * 0.4), 
            
            new Gene(seedID, lengthID, 20), new Gene(seedID, thicknessID, 0.5), new Gene(seedID, angleID, 0),

		];

	}


	public function new() {
		genes = [];
	}

	public function getGeneValue(organ:OrganID, param:OrganParameterID, branch:Branch = null):Float {
		for (g in genes) {
			if (g.organ == organ && g.organParameter == param) {
				return g.value;
			}
		}
		return -1;
	}

	public function getAngles(organ:OrganID, branch:Branch):Array<Float> {
		var angles:Array<Float> = new Array<Float>();
		for (g in genes) {
			if (g.organ == organ && g.organParameter == angleID) {
				if (Math.random() < g.probability) {
					angles.push(g.value + (2 * Math.random() - 1) * BRANCH_ANGLE_DEVIATION);
				}
			}
		}
		return angles;
	}



	public function duplicate():DNA {
		var newDNA:DNA;
		newDNA = new DNA();
		newDNA.genes = genes.copy();
/*		var genes:Array<Float> = newDNA.genes;
		var i:Int = 0;
		while (i < genes.length) {
			if (genes[i] == END_OF_SEQUENCE || genes[i] == END_OF_GENE) {
				i++;
				continue;
			}
			var r:Float = Math.random();
			if (r < 0.33) {
				genes[i] *= 0.8;
			} else if (r < 0.66) {
				genes[i] *= 1.2;
			}

			i++;
		}
		newDNA.SetIndices();

        newDNA.megagenes = megagenes.copy();*/
		return newDNA;
	}
}
