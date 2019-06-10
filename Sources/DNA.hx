import js.html.AbortController;
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
	var numOrganParameterIDs = 6;
}

@:enum
abstract GeneConditionID(Int) {
	var probabilityID = 0;
	var everyNgenerationID = 1;
	var activationEnergyDensityID = 2;
}

class GeneValueLimit {
	public var min:Float;
	public var max:Float;
	public var step:Float;

	public function new(min:Float, max:Float, step:Float) {
		this.min = min;
		this.max = max;
		this.step = step;
	}
}

class GeneCondition {
	public var conditionID:GeneConditionID;
	public var value:Float;

	public function new(conditionID:GeneConditionID, value:Float) {
		this.conditionID = conditionID;
		this.value = value;
	}
}

class Gene {
	static public var organParameterLimits:Array<GeneValueLimit>;
	static public var geneConditionLimits:Array<GeneValueLimit>;

	public var organ:OrganID;
	public var organParameter:OrganParameterID;
	public var conditions:Array<GeneCondition>;
	public var value:Float;

	public function new(organ:OrganID = leaveID, organParameter:OrganParameterID = lengthID, value:Float = 0, conditions:Array<GeneCondition> = null) {
		this.organ = organ;
		this.organParameter = organParameter;

		this.value = value;
		this.conditions = conditions;
	}

	public function getCondition(conditionID:GeneConditionID):Float {
		if (conditions != null) {
			for (c in conditions) {
				if (conditionID == c.conditionID) {
					return c.value;
				}
			}
		};

		switch conditionID {
			case probabilityID:
				return 1;
			case everyNgenerationID:
				return 1;
			case activationEnergyDensityID:
				return 0;
		}
		return 0;
	}

    public function addConditions(): Gene {
 		if (conditions != null) {
             return this;
        }
        conditions = [
            new GeneCondition(probabilityID,0.5),
            new GeneCondition(everyNgenerationID,2),
            new GeneCondition(activationEnergyDensityID,0.5)
        ];
        return this;
    }

	public function clone():Gene {
		var limit:GeneValueLimit;
		var newGene:Gene = new Gene(organ, organParameter, value, null);
		var r:Float = Math.random();

		limit = organParameterLimits[cast(organParameter, Int)];

		if (r < 0.33) {
			newGene.value += limit.step;
			if (newGene.value > limit.max) {
				newGene.value = limit.max;
			}
		} else if (r < 0.66) {
			newGene.value -= limit.step;
			if (newGene.value < limit.min) {
				newGene.value = limit.min;
			}
		}

		if (conditions != null) {
            newGene.conditions = [];
			for (c in conditions) {
				limit = geneConditionLimits[cast(c.conditionID, Int)];
				r = Math.random();
				var newCondidtion:GeneCondition = new GeneCondition(c.conditionID, c.value);
				if (r < 0.33) {
					newCondidtion.value += limit.step;
					if (newCondidtion.value > limit.max) {
						newCondidtion.value = limit.max;
					}
				} else if (r < 0.66) {
					newCondidtion.value -= limit.step;
					if (newCondidtion.value < limit.min) {
						newCondidtion.value = limit.min;
					}
				}
				newGene.conditions.push(newCondidtion);
			}
		}

		return newGene;
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
	
	public static inline var LEAF_ENERGY_CONSUME = 0.3;
	public static inline var BRANCH_ENERGY_CONSUME = 0.3;
	public static inline var SEED_ENERGY_CONSUME = 0.3;

	public static inline var SEED_ENERGY_2_CONSERVATE = 1;
	public static inline var MAX_CONSERVATED_ENERGY = 5;
	
	public static inline var MAX_LEAF_ENERGY_DENSITY = 3;
	public static inline var MAX_BRANCH_ENERGY_DENSITY = 3;
	public static inline var MAX_SEED_ENERGY_DENSITY = 3;



	public static inline var BRANCH_ANGLE_DEVIATION = 0.1;

	// static public var organParameterLimits:Array<GeneValueLimit>;
	public function Init() {
		Gene.organParameterLimits = [
			new GeneValueLimit(5, 160, 5), // length
			new GeneValueLimit(0.03, 0.6, 0.01), // thickness
			new GeneValueLimit(-Math.PI * 0.8, Math.PI * 0.8, Math.PI * 0.05), // angle
			new GeneValueLimit(1, 15, 1), // leaves_numberID
			new GeneValueLimit(1, 10, 1), // generation2blossomID
			new GeneValueLimit(0.1, 1, 0.05), // start_growth_posID
		];

		Gene.geneConditionLimits = [
			new GeneValueLimit(0, 1, 0.05), // probabilityID
			new GeneValueLimit(1, 10, 0.25), // everyNgenerationID
			new GeneValueLimit(0, 1, 0.05) // activationEnergyDensityID
		];

        //var firstGenes: Array<Gene>;
		genes = [

			new Gene(branchID, lengthID, 80), //
			new Gene(branchID, thicknessID, 0.03), //
			new Gene(branchID, start_growth_posID, 1), //
			new Gene(branchID, leaves_numberID, 5), //
			new Gene(branchID, generation2blossomID, 2), //
			new Gene(branchID, angleID, 0), //
			new Gene(branchID, angleID, -Math.PI * 0.2, [new GeneCondition(probabilityID, 0.5)]), //
			new Gene(branchID, angleID, Math.PI * 0.2, [new GeneCondition(probabilityID, 0.5)]), //

			new Gene(leaveID, lengthID, 30), //
			new Gene(leaveID, thicknessID, 0.2), //
			new Gene(leaveID, angleID, Math.PI * 0.4), //

			new Gene(seedID, lengthID, 20), //
			new Gene(seedID, thicknessID, 0.5), //
			new Gene(seedID, angleID, 0),

		];

        /*
        genes = [];
        for (g in firstGenes)
        {
            
            genes.push(g);
            genes.push(g.clone().addConditions());
        } */
	}

	public function new() {
		genes = [];
	}

    public function getGeneValue(organ:OrganID, param:OrganParameterID, branch:Branch = null):Float {
    
        var values: Array<Float> ;
        
        values = getGeneValues(organ,param,branch);
        if (values.length >0)
        {
            return values[Math.floor(Math.random() * values.length)];
        }

		return -1;
    }

	public function getGeneValues(organ:OrganID, param:OrganParameterID, branch:Branch = null): Array<Float> {
		var generation:Int = 0;
		var energyDensity:Float = 1;

        var values: Array<Float> = [];

		if (branch != null) {
			generation = branch.GenerationIndex;
			energyDensity = branch.energyDensity / branch.MAX_ENERGY_DENSITY;
		}

		for (g in genes) {
			if (g.organ == organ && g.organParameter == param) {
				if (generation % g.getCondition(everyNgenerationID) == 0) {
					if (energyDensity >= g.getCondition(activationEnergyDensityID)) {
                       if (Math.random() <= g.getCondition(probabilityID)) {
                            values.push(g.value);
                       }
					}
				}
			}
		}

		return values;
	}

	public function getAngles(organ:OrganID, branch:Branch = null):Array<Float> {
		var angles:Array<Float>; 
        angles = getGeneValues(organ, angleID, branch);
        var i:Int =0;
        while (i < angles.length)
        {
            angles[i] += (2 * Math.random() - 1) * BRANCH_ANGLE_DEVIATION;
            i++;
        }
        return angles;
/*
		var generation:Int = 0;
		var energyDensity:Float = 1;
		if (branch != null) {
			generation = branch.GenerationIndex;
			energyDensity = branch.energyDensity / MAX_ENERGY_DENSITY;
		}

		for (g in genes) {
			if (g.organ == organ && g.organParameter == angleID) {
				if (generation % g.getCondition(everyNgenerationID) == 0) {
					if (energyDensity >= g.getCondition(activationEnergyDensityID)) {
						if (Math.random() <= g.getCondition(probabilityID)) {
							angles.push(g.value + (2 * Math.random() - 1) * BRANCH_ANGLE_DEVIATION);
						}
					}
				}
			}
		}
		return angles;  */
	}

	public function duplicate():DNA {
		var newDNA:DNA;
		// var newGene: Gene;
		newDNA = new DNA();
		// newDNA.genes = this.genes.copy();
		var limit:GeneValueLimit;
		var value:Float;

		for (g in genes) {
			/*var r:Float = Math.random();
				limit = Gene.organParameterLimits[cast(g.organParameter, Int)];
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
			}*/
			newDNA.genes.push(g.clone()); // new Gene(g.organ, g.organParameter, value, g.probability, g.everyNgeneration, g.activationEnergyDensity));
 		}

		return newDNA;
	}
}
