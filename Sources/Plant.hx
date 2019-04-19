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
    public static inline var MAX_GENERATIONS = 15;

 

    public function new() 
    {

/*        dna = new DNA(
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
        
        dna.NormalizeDNA();
    
*/
        dna = new DNA();

        this.pos = new Vec2(System.windowWidth() * 0.5, System.windowHeight());
        

        var  firstBranch : Branch = new Branch();

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.length = 10;
        firstBranch.energy = 240;
        firstBranch.maxLength = dna.branch_length;

        this.branches = [];
        this.branches.push(firstBranch);

        this.leaves = [];
       // CreateNewLeaf(0,0);
   
    }



    public function TrunkDivision(BranchIndexToDivide: Int) {

  /*    var i:Int =0;
        var exon:Exon;
        var geneIndex: Int = (branches[BranchIndexToDivide].GenerationIndex % dna.genes.length);

        for (exon in dna.genes[geneIndex].exons)
        {
            if (exon.weight ==0 ) { i++; continue; }
            CreateNewBranch(BranchIndexToDivide, exon.angle, exon.weight, exon.length); 
            i++;
        }
*/
     //   CreateNewBranch(BranchIndexToDivide, dna.angle, 1, dna.branch_length);
    }


  //  public function CreateNewBranch(ParentBranchIndex: Int, angle: Float, weight: Float, length: Float) {
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
       // newBranch.weight = weight;
        newBranch.maxLength =  dna.branch_length;// * weight;
        newBranch.length = 0;
        newBranch.posOnParentBranch = leafParent.posOnParentBranch;
        //newBranch.dir.setFrom( branchParent.dir.rotate(angle) );
        newBranch.dir.setFrom( leafParent.dir );
        newBranch.parentIndex = leafParent.parentIndex;
        newBranch.energy = 10;
        newBranch.GenerationIndex = branchParent.GenerationIndex + 1;

        leafParent.parentIndex = newIndex;
        leafParent.posOnParentBranch = 0;


       // CreateNewLeaf(newIndex, angle);
    }

    //public function CreateNewLeaf(ParentBranchIndex: Int, angle: Float) {
    public function CreateNewLeaf(ParentBranchIndex: Int, leafPos: Float) {
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
        newLeaf.dir.setFrom( parent.dir.rotate((newIndex%2 == 0)? dna.angle: - dna.angle));
        newLeaf.posOnParentBranch = leafPos;
        newLeaf.parentIndex = ParentBranchIndex;
        newLeaf.GenerationIndex = parent.GenerationIndex + 1;
       

    }

    public function CalculateBranches(dt:Float) {
        
        var b: Branch;
        var BranchIndex: Int = -1;
        var delta: Float =0;
        var nLeaf: Int =0;
        var nLeaf1: Int =0;
        var leafStepOnBranch: Float = 0; 

        for (b in branches)
        {
            BranchIndex++;

            if (b.totalDeath) continue;

            b.Calculate(this,dt);

            if (b.dead) continue;

           leafStepOnBranch = b.maxLength * dna.leaf_frequency;
            nLeaf = Math.floor( b.length / leafStepOnBranch);  
            b.CalculateGrowth(dt);
            nLeaf1 = Math.floor( b.length / leafStepOnBranch);
            if (nLeaf1>nLeaf)
            {
                if (b.GenerationIndex< MAX_GENERATIONS)
                {
                    CreateNewLeaf(BranchIndex, dna.leaf_frequency * nLeaf1);
                    CreateNewLeaf(BranchIndex, dna.leaf_frequency * nLeaf1);
                }    
            }

            b.CalculateEnergy(this, dt);
            
            /*if (b.GenerationIndex< MAX_GENERATIONS && b.ChildrenIndices.length ==0)
            if (b.length > b.maxLength)
            {
                TrunkDivision(BranchIndex);
            }*/
            
        }

    }



    public function CalculateLeaves(dt:Float) {

        var l: Leaf;
        var delta: Float;
        var leafIndex: Int =-1;
        for (l in leaves)
        {
            leafIndex++;
            if (l.totalDeath) continue;

            l.Calculate(this,dt);
            if (l.dead) continue;
            
            var parentBranch: Branch = branches[l.parentIndex];
            
            l.CalculateGrowth(dt);
            l.ConsumeEnergy(this,dt);
            delta = l.energy * dt;
            l.GiveEnergyToBranch(branches[l.parentIndex], delta);  
            if (l.energy>30)// &&  parentBranch.length >= parentBranch.maxLength)      
            {
                CreateNewBranch(leafIndex);
                l.energy -= 10;
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