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

    var dna: DNA;

    public var branches: Array<Branch>;
    public var leaves: Array<Leaf>;

    public var pos: Vec2;



    // constants
    public static inline var LEAF_ENERGY_2_BRANCH = 2.0;
    public static inline var BRANCH_ENERGY_2_LEAF = 1.0;
    public static inline var BRANCH_ENERGY_2_BRANCH = 1.0;

    public static inline var LEAF_ENERGY_TO_PRODUCE_BRANCH = 1.0;
    public static inline var BRANCH_ENERGY_TO_PRODUCE_LEAF = 2.0;

    public static inline var LEAF_ENERGY_TO_SHARE = 0.1;
    public static inline var BRANCH_ENERGY_TO_SHARE = 0.6;

    public static inline var LEAF_ENERGY_CONSUME = 0.03;
    public static inline var BRANCH_ENERGY_CONSUME = 0.03;

    public static inline var MAX_ENERGY_IN_LEAF = 2;
    public static inline var MAX_ENERGY_IN_BRANCH = 2;

    public static inline var MAX_GENERATIONS = 15;



 

    public function new() 
    {
         dna = new DNA();
       /* dna = new DNA(
            new Gene(
            //         a,   w,   l 
            new Exon(-40,  50,  40), //, 
            new Exon( 0,  50, 40) //,
         //   new Exon( 30,  20,  10)
            ) 
            ,
        new Gene(
          new Exon(40,  50,  40), 
//            new Exon( -30,  50, 80),
            new Exon( 0,  50, 40)
        )
       ,
        new Gene(
            //         a,   w,   l 
            new Exon(-40,  50,  40), 
            new Exon( 0,  50, 40),
            new Exon( 40,  50,  40)
            ) );      
        
        dna.NormalizeDNA();*/
    

        this.pos = new Vec2(System.windowWidth() * 0.5, System.windowHeight());

        var  firstBranch : Branch = new Branch();

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.length = 20;
        firstBranch.energy = 140;

        this.branches = [];
        this.branches.push(firstBranch);

        this.leaves = [];
        TrunkCreateLeaves(0);
    
   
    }




    public function CreateNewBranch(ParentLeafIndex: Int) 
    {
        var  newBranch : Branch = null; // new Branch();
        
        var leafParent = leaves[ParentLeafIndex];
        var branchParent = leafParent.parentBranch;

         var deadReplace:Bool = false;
        var newIndex: Int =0;

        for (b in branches)
        {
            if (b.totalDeath) {
                newBranch = b;
                newBranch.Init();
                deadReplace = true;
                break;
            }
            newIndex++;
        }  

        if (!deadReplace)
        {
            newBranch = new Branch();
            branches.push(newBranch);
        }

        branchParent.ChildrenIndices.push(newBranch);
       
        
        //newBranch.startPos.setFrom(branchParent.endPos);
        newBranch.startPos.setFrom(leafParent.startPos);
        //newBranch.weight = weight;
        newBranch.maxLength = dna.branch_length;
        newBranch.length = 0;
        newBranch.Thikness = dna.branch_tickness;
        
        //newBranch.dir.setFrom( branchParent.dir.rotate(angle) );
        newBranch.dir.setFrom( leafParent.dir );
        newBranch.parentBranch = leafParent.parentBranch;
        newBranch.energy = 0;
        newBranch.GenerationIndex = branchParent.GenerationIndex + 1;



    }

     public function TrunkCreateLeaves(BranchIndexToDivide: Int) {

        CreateNewLeaf(BranchIndexToDivide, dna.angle); 
        CreateNewLeaf(BranchIndexToDivide, - dna.angle); 
        CreateNewLeaf(BranchIndexToDivide, 0); 
    }



    public function CreateNewLeaf(ParentBranchIndex: Int, angle: Float) {

        var  newLeaf : Leaf = null; // = new Leaf();
        var parent=branches[ParentBranchIndex];
      
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
            newLeaf = new Leaf();
            leaves.push(newLeaf);
        }

        parent.LeavesIndices.push(newLeaf);
        
        newLeaf.startPos.setFrom(parent.endPos);
        newLeaf.dir.setFrom( parent.dir.rotate(angle));
        newLeaf.maxLength=dna.leaf_length;
        newLeaf.Thikness = dna.leaf_tickness;
        newLeaf.parentBranch = parent;
        newLeaf.GenerationIndex = parent.GenerationIndex + 1;
       

    }



    public function CalculateBranches(dt:Float) {
        
        var b: Branch;
        var BranchIndex: Int = -1;
        var delta: Float =0;
        var energyDensity: Float;

        for (b in branches)
        {
            BranchIndex++;

            if (b.totalDeath) continue;

            b.Calculate(this,dt);

            if (b.dead) continue;

            b.CalculateGrowth(dt);
            

            b.CalculateEnergy(this, dt);
            
            if (b.length < b.maxLength * 0.1 ) continue;
            if (b.LeavesIndices.length == 3) continue;

            energyDensity = b.energy / b.square;
            if (energyDensity> BRANCH_ENERGY_TO_PRODUCE_LEAF)  
            {
                
                CreateNewLeaf(BranchIndex, dna.angle * (-1 + 2* Math.random()));
            }
            
        }

    }



    public function CalculateLeaves(dt:Float) {

        var l: Leaf;
        var delta: Float;
        var energyDensity: Float; 
        var index: Int = -1;
        var square : Float;
        for (l in leaves)
        {
            index++;
            if (l.totalDeath) continue;

            l.Calculate(this,dt);
            if (l.dead) continue;
            
            delta = l.energy * dt;
            l.CalculateGrowth(dt);
            l.ConsumeEnergy(this,dt);
            
            energyDensity = l.energy / l.square;
            if (energyDensity< LEAF_ENERGY_TO_SHARE) continue;

            l.GiveEnergyToBranch(l.parentBranch, LEAF_ENERGY_2_BRANCH * delta);      


            if (l.length< l.maxLength*0.5 || l.hasProducedBranch) continue;
            energyDensity = l.energy / l.square;
            
            if (energyDensity> LEAF_ENERGY_TO_PRODUCE_BRANCH)  
            {
                l.hasProducedBranch = true;
                CreateNewBranch(index);
            }

        }

    }

    public function RemoveDead()
    {
        if (leaves.length!=0 && leaves[leaves.length-1].totalDeath) {
            leaves.splice(leaves.length-1,1 );
        }
    }

    public function Calculate(dt:Float) {
        CalculateBranches(dt);
        CalculateLeaves(dt);
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