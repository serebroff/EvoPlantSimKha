//-------------------------------------------------------
// class of living plant
//-------------------------------------------------------

package;

import Branch;
import Leaf;
import DNA;
import kha.Framebuffer;
import kha.System;

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
    public static inline var MAX_GENERATIONS = 20;

 

    function rndsign() : Int
    {
        if (Math.random() <= 0.5) return 1;
        else return -1;
    }



    public function new() 
    {
        dna = new DNA(
            new Gene(
            //         a,   w,   l 
            new Exon(-50,  50,  80), 
            new Exon( 10,  150, 130)
//            new Exon( 60,  10,  50)
            ) ,
        new Gene(
//          new Exon(-60,  10,  50), 
            new Exon( -10,  100, 140),
            new Exon( 55,  50,  80)
        ),
        new Gene(
            //         a,   w,   l 
            new Exon(-70,  40,  90), 
            new Exon( 0,  100, 150),
            new Exon( 70,  40,  90)
            ) );      
        
        dna.NormalizeDNA();
    

        this.pos = new Vec2(System.windowWidth() * 0.5, System.windowHeight());

        var  firstBranch : Branch = new Branch();

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.length = 40;
        firstBranch.energy = 140;

        this.branches = [];
        this.branches.push(firstBranch);

        this.leaves = [];
       // CreateNewLeaf(0,0);
   
    }


    public function TrunkDivision(BranchIndexToDivide: Int) {

        var i:Int =0;
        var exon:Exon;
        var geneIndex: Int = (branches[BranchIndexToDivide].GenerationIndex % dna.genes.length);

/*        if (BranchIndexToDivide>0)
        {
            leaves[branches[BranchIndexToDivide].LeavesIndices[0]].dead = true;
        }*/

        for (exon in dna.genes[geneIndex].exons)
        {
            if (exon.weight ==0 ) { i++; continue; }
            CreateNewBranch(BranchIndexToDivide, exon.angle, exon.weight, exon.length); 
            i++;
        }
    }


    public function CreateNewBranch(ParentBranchIndex: Int, angle: Float, weight: Float, length: Float) {
        var  newBranch : Branch = new Branch();
        var parent=branches[ParentBranchIndex];
        
        newBranch.startPos.setFrom(parent.endPos);
        newBranch.weight = weight;
        newBranch.NewBranchLength =  length;// * weight;
        newBranch.dir = parent.dir.rotate(angle);
        newBranch.parentIndex = ParentBranchIndex;
        newBranch.GenerationIndex = parent.GenerationIndex + 1;
        newBranch.maxGenerations = MAX_GENERATIONS;
        branches.push(newBranch);

        parent.ChildrenIndices.push(branches.length-1);
        CreateNewLeaf(branches.length-1, angle);
    }

    public function CreateNewLeaf(ParentBranchIndex: Int, angle: Float) {
        var  newLeaf : Leaf = new Leaf();
        var parent=branches[ParentBranchIndex];
        
        newLeaf.startPos.setFrom(parent.endPos);
        newLeaf.dir = parent.dir.rotate(angle);
        newLeaf.parentIndex = ParentBranchIndex;
        newLeaf.GenerationIndex = parent.GenerationIndex + 1;

        leaves.push(newLeaf);

        parent.LeavesIndices.push(leaves.length-1);
    }

    public function CalculateBranches(dt:Float) {
        var b: Branch;
        var BranchIndex: Int = 0;
        var delta: Float =0;

        for (b in branches)
        {
            b.CalculateGrowth(dt);
            b.CalculateEnergy(this, dt);
            b.Calculate(this,dt);
            
            if (b.GenerationIndex< MAX_GENERATIONS && b.ChildrenIndices.length ==0)
            if (b.length > b.NewBranchLength)
            {
                TrunkDivision(BranchIndex);
            }
            
            BranchIndex++;
        }

    }



    public function CalculateLeaves(dt:Float) {

        var l: Leaf;
        var delta: Float;
        for (l in leaves)
        {
            if (!l.dead) 
            {
                delta = l.energy * dt;
                l.CalculateGrowth(dt);
                l.ConsumeEnergy(dt);
                l.GiveEnergyToBranch(branches[l.parentIndex], delta);
            }
            l.Calculate(this,dt);
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