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
    public static inline var THICKNESS = 0.1;
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
        var branchParent = branches[leafParent.parentIndex];

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

        branchParent.ChildrenIndices.push(newIndex);
       
        
        //newBranch.startPos.setFrom(branchParent.endPos);
        newBranch.startPos.setFrom(leafParent.startPos);
        //newBranch.weight = weight;
        newBranch.maxLength =  100;//dna.branch_length;// * weight;
        newBranch.length = 0;
        
        //newBranch.dir.setFrom( branchParent.dir.rotate(angle) );
        newBranch.dir.setFrom( leafParent.dir );
        newBranch.parentIndex = leafParent.parentIndex;
        newBranch.energy = 0;
        newBranch.GenerationIndex = branchParent.GenerationIndex + 1;


        TrunkCreateLeaves(newIndex);
    }

     public function TrunkCreateLeaves(BranchIndexToDivide: Int) {

        CreateNewLeaf(BranchIndexToDivide, dna.angle); 
        CreateNewLeaf(BranchIndexToDivide, - dna.angle); 
        CreateNewLeaf(BranchIndexToDivide, 0); 
    }

     public function TrunkCreateBranches(BranchIndexToDivide: Int) {
         var parendBranch: Branch = branches[BranchIndexToDivide];
         
         
         	if (parendBranch.LeavesIndices.length>0)
        {
            var i=0;

            for (i in parendBranch.LeavesIndices)
            {
                CreateNewBranch(i);
            } 
		}  
     

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

        parent.LeavesIndices.push(newIndex);
        
        newLeaf.startPos.setFrom(parent.endPos);
        newLeaf.dir.setFrom( parent.dir.rotate(angle));
        newLeaf.parentIndex = ParentBranchIndex;
        newLeaf.GenerationIndex = parent.GenerationIndex + 1;
       

    }



    public function CalculateBranches(dt:Float) {
        
        var b: Branch;
        var BranchIndex: Int = -1;
        var delta: Float =0;

        for (b in branches)
        {
            BranchIndex++;

            if (b.totalDeath) continue;

            b.Calculate(this,dt);

            if (b.dead) continue;

            b.CalculateGrowth(dt);
            
/*            if (b.length > b.maxLength *0.4) {
                TrunkCreateLeaves(BranchIndex);
            }*/

            b.CalculateEnergy(this, dt);
            
            if (b.GenerationIndex< MAX_GENERATIONS && b.ChildrenIndices.length ==0)
            if (b.length > b.maxLength)
            {
                TrunkCreateBranches(BranchIndex);
            }
            
        }

    }



    public function CalculateLeaves(dt:Float) {

        var l: Leaf;
        var delta: Float;
        for (l in leaves)
        {
            if (l.totalDeath) continue;

            l.Calculate(this,dt);
            if (l.dead) continue;
            
            delta = l.energy * dt;
            l.CalculateGrowth(dt);
            l.ConsumeEnergy(this,dt);
            l.GiveEnergyToBranch(branches[l.parentIndex], delta);        

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