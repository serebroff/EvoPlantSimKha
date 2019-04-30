//-------------------------------------------------------
// class of living plant
//-------------------------------------------------------

package;

import Branch;
import Leaf;
import DNA;
import kha.Framebuffer;
import kha.System;

using Project;
using Utils;
using kha.graphics2.GraphicsExtension;


class Plant
{

    public var dna: DNA;

    public var firstBranch: Branch;

    public var branches: Array<Branch>;
    public var leaves: Array<Leaf>;

    public var pos: Vec2;



    // constants
    public static inline var LEAF_ENERGY_2_BRANCH = 1;
    public static inline var BRANCH_ENERGY_2_LEAF = 1;
    public static inline var BRANCH_ENERGY_2_BRANCH = 1;

    public static inline var LEAF_ENERGY_TO_PRODUCE_BRANCH = 0.6;
    public static inline var BRANCH_ENERGY_TO_PRODUCE_LEAF = 0.6;

    public static inline var LEAF_ENERGY_TO_SHARE = 0.0;
    public static inline var BRANCH_ENERGY_TO_SHARE = 0.0;

    public static inline var LEAF_ENERGY_CONSUME = 0.1;
    public static inline var BRANCH_ENERGY_CONSUME = 0.1;

    public static inline var MAX_ENERGY_IN_LEAF = 2;
    public static inline var MAX_ENERGY_IN_BRANCH = 2;

    public static inline var MAX_GENERATIONS = 15;



 

    public function new() 
    {
        dna = new DNA();

        pos = new Vec2(System.windowWidth() * 0.5, System.windowHeight());

        firstBranch = new Branch(this);

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.endPos.set(0, -100);
        firstBranch.length = 100;
        firstBranch.energy = 340;
        firstBranch.parentPlant = this;


        branches = [];
        branches.push(firstBranch);

        leaves = [];
        
        CreateNewLeaf(firstBranch, dna.angle); 
        CreateNewLeaf(firstBranch, - dna.angle); 
        CreateNewLeaf(firstBranch, 0); 
    
   
    }




    public function CreateNewBranch(leafParent: Leaf) 
    {
        var  newBranch : Branch = null; // new Branch();
        
        var branchParent = leafParent.parentBranch;

        var deadReplace:Bool = false;

        for (b in branches)
        {
            if (b.totalDeath) {
                newBranch = b;
                newBranch.Init();
                deadReplace = true;
                break;
            }
        }  

        if (!deadReplace)
        {
            newBranch = new Branch(this);
            branches.push(newBranch);
        }

        branchParent.ChildrenIndices.push(newBranch);
       
        
        //newBranch.startPos.setFrom(branchParent.endPos);
        newBranch.startPos.setFrom(leafParent.startPos);
        newBranch.maxLength = dna.branch_length;
        //newBranch.length = 0;
       // newBranch.Thikness = dna.branch_tickness;
        
        //newBranch.dir.setFrom( branchParent.dir.rotate(angle) );
        newBranch.dir.setFrom( leafParent.dir );
        newBranch.parentBranch = leafParent.parentBranch;
        //newBranch.energy = 0;
        newBranch.GenerationIndex = branchParent.GenerationIndex + 1;



    }



    public function CreateNewLeaf(parent: Branch, angle: Float) {

        var  newLeaf : Leaf = null; 

      
        var deadReplace:Bool = false;
        var newIndex: Int =0;

        for (l in leaves)
        {
            if (l.totalDeath) {
                newLeaf = l;
                newLeaf.Init();
                deadReplace = true;
                break;
            }
            newIndex++;
        }  

        if (!deadReplace)
        {
            newLeaf = new Leaf(this);
            leaves.push(newLeaf);
        }

        parent.LeavesIndices.push(newLeaf);
        
        newLeaf.startPos.setFrom(parent.endPos);
        newLeaf.dir.setFrom( parent.dir.rotate(angle));
        newLeaf.maxLength=dna.leaf_length;
       // newLeaf.energy= 20;
       // newLeaf.Thikness = dna.leaf_tickness;
        newLeaf.parentBranch = parent;
        newLeaf.GenerationIndex = parent.GenerationIndex + 1;
       

    }



    public function CalculateBranches(dt:Float) {
        
        var b: Branch;
        var delta: Float =0;
        var energyDensity: Float;

        for (b in branches)
        {
            if (b.totalDeath) continue;

            if (!b.dead) {

                if ((b.length > b.maxLength * 0.1 ) && (b.LeavesIndices.length < 2))
                {
                    if (b.energyDensity> BRANCH_ENERGY_TO_PRODUCE_LEAF)  
                    {
                
                        CreateNewLeaf(b, dna.angle ); //*Utils.rndsign()); // (-1 + 2* Math.random()));
                        CreateNewLeaf(b, -dna.angle );
                       // CreateNewLeaf(b, 0 );
                    }
                }
                b.CalculateGrowth(dt);
                b.ExchangeEnergyWithParent();
		        b.ConsumeEnergy(dt);
            }

            b.Calculate(dt);
            


            
        }

    }



    public function CalculateLeaves(dt:Float) {

        var l: Leaf;
        var delta: Float;
        var energyDensity: Float; 
        var square : Float;
        for (l in leaves)
        {
            if (l.totalDeath) continue;
            if (!l.dead) {

                if (l.length> l.maxLength*0.5 && !l.hasProducedBranch) {
                    if (l.energyDensity> LEAF_ENERGY_TO_PRODUCE_BRANCH)  
                    {
                        l.hasProducedBranch = true;
                        CreateNewBranch(l);
                    }
                }
                l.CalculateGrowth(dt);
                l.ExchangeEnergyWithParent();
                l.ConsumeEnergy(dt);
            }
            l.Calculate(dt);

        }

    }


    public function Calculate(dt:Float) {
        CalculateLeaves(dt);
        CalculateBranches(dt);

    }

    public function Draw (framebuffer:Framebuffer): Void {

        for( b in branches)
        {
            b.Draw(framebuffer);
        }
   /*     for( b in branches)
        {
            b.DrawSkeleton(framebuffer);
        }*/
        
        for( l in leaves)
        {
            l.Draw(framebuffer);
           // l.DrawSkeleton(framebuffer);
        }

    }

}