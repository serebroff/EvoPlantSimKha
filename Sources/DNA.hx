import haxe.io.Float32Array;

//-------------------------------------------------------
// class of Gene
//-------------------------------------------------------
@:enum
abstract OrganID(Int) {
	var leaveID = 0;
	var branchID = 1;
	var seedID = 2;
	var numOrganIDs = 3;
}

@:enum
abstract OrganParameterID(Int) {
	var lengthID = 0;
	var thicknessID = 1;
	var angleID = 2;
	var leaves_numberID = 3;
	var generation2blossomID = 4;
	var start_growth_posID = 5;
	var numOrganParameterIDs = 6;
}

class OrganParameterLimit {
	public var min:Float;
	public var max:Float;
	public var step:Float;

	public function new(min:Float, max:Float, step:Float) {
		this.min = min;
		this.max = max;
		this.step = step;
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
	public static inline var BRANCH_ANGLE_DEVIATION = 0.1;
	public static inline var MAX_GENERATIONS = 15;
	public static inline var END_OF_GENE = -1000;
	public static inline var END_OF_SEQUENCE = -10000;
	
    static public var organParameterLimits:Array<OrganParameterLimit>;

	public function Init() {
		organParameterLimits = [
			new OrganParameterLimit(5, 200, 5), // length
			new OrganParameterLimit(0.01, 0.6, 0.01), // thickness
			new OrganParameterLimit(-Math.PI * 0.8, Math.PI * 0.8, Math.PI * 0.1), // angle
			new OrganParameterLimit(1, 15, 1), // leaves_numberID
			new OrganParameterLimit(1, 10, 1), // generation2blossomID
			new OrganParameterLimit(0.1, 1, 0.05), // start_growth_posID
		];

		genes = [

			new Gene(branchID, lengthID, 80), //
			new Gene(branchID, thicknessID, 0.03), //
			new Gene(branchID, start_growth_posID, 1), //
			new Gene(branchID, leaves_numberID, 5), //
			new Gene(branchID, generation2blossomID, 2), //
			new Gene(branchID, angleID, 0), //
			new Gene(branchID, angleID, -Math.PI * 0.2, 0.5), //
			new Gene(branchID, angleID, Math.PI * 0.2, 0.5), //

			new Gene(leaveID, lengthID, 30), //
			new Gene(leaveID, thicknessID, 0.2), //
			new Gene(leaveID, angleID, Math.PI * 0.4), //

			new Gene(seedID, lengthID, 20), //
			new Gene(seedID, thicknessID, 0.5), //
			new Gene(seedID, angleID, 0),

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
		// var newGene: Gene;
		newDNA = new DNA();
		//newDNA.genes = this.genes.copy();
        var limit: OrganParameterLimit;
        var value: Float;

		for (g in genes) {
			var r:Float = Math.random();
            limit = organParameterLimits[cast (g.organParameter, Int)];
            value = g.value;
			if (r < 0.33) {
				value += limit.step;
				if (value > limit.max) {
					value = limit.max;
				}
			} else if (r < 0.66) {
				value -= limit.step;
				if (value < limit.min) {
					value = limit.min;
				}
			}
            newDNA.genes.push(new Gene(g.organ, g.organParameter, value, g.probability, g.everyNgeneration, g.activationEnergyDensity));
		}

		return newDNA;
	}
}
