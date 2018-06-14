//-------------------------------------------------------
// class of living creature
//-------------------------------------------------------

package;

import Branch;
import DNA;
import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;


class Creature
{
    public var NewBranchProbability = 0.9;  // per second

    var dna: DNA;


    public var pos: Vec2;

    public var branches: Array<Branch>;

    // constants
    public static inline var THICKNESS = 0.1;
    public static inline var MAX_GENERATIONS = 8;

 


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
            new Exon(-50,  50,  2), 
            new Exon( 10,  100, 1)
//            new Exon( 60,  10,  50)
            ) ,
        new Gene(
  //          new Exon(-60,  10,  50), 
            new Exon( -10,  100, 2),
            new Exon( 50,  50,  1)
            ),
        new Gene(
            //         a,   w,   l 
            new Exon(-70,  60,  2), 
            new Exon( 0,  100, 1),
            new Exon( 70,  60,  2)
            ) );      
        
        dna.NormalizeDNA();
    

        this.pos = new Vec2(System.windowWidth() * 0.5, System.windowHeight());

        var  firstBranch : Branch = new Branch();

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.length = 40;
        firstBranch.energy = 40;

        this.branches = [];
        this.branches.push(firstBranch);
   
    }


    public function TrunkDivision(ParentBranchIndex: Int) {

        var i:Int =0;
        var exon:Exon;
        var geneIndex: Int = (branches[ParentBranchIndex].GenerationIndex % dna.genes.length);

        for (exon in dna.genes[geneIndex].exons)
        {
            if (exon.weight ==0 ) { i++; continue; }
            CreateNewBranch(ParentBranchIndex, exon.angle, exon.weight, exon.length); 
            i++;
        }
    }


    public function CreateNewBranch(ParentBranchIndex: Int, angle: Float, weight: Float, length: Float) {
        var  newBranch : Branch = new Branch();
        var parent=branches[ParentBranchIndex];
        
        newBranch.startPos.setFrom(parent.endPos);
        newBranch.weight = weight;
        newBranch.NewBranchLength =  length;
        newBranch.dir = parent.dir.rotate(angle);
        newBranch.parentIndex = ParentBranchIndex;
        newBranch.GenerationIndex = parent.GenerationIndex + 1;
        newBranch.maxGenerations = MAX_GENERATIONS;
        branches.push(newBranch);

        parent.ChildrenIndices.push(branches.length-1);
    }

    public function Calculate(dt:Float) {

        var b: Branch;
        var BranchIndex: Int = 0;
        for (b in branches)
        {
            if (b.parentIndex>=0)
            {
                b.startPos.setFrom(branches[b.parentIndex].endPos);
            }

            
            if (b.energy>0) {
      
            
                if (b.ChildrenIndices.length>0)
                {
                    var i=0;
                    var delta: Float  =  b.energy *dt*3;
                    for (i in b.ChildrenIndices)
                    {
                        branches[i].energy += branches[i].weight * delta;
                    }
                    b.energy -= delta;   

                    if (b.energy>0)
                    {                   
                        b.length += dt*b.growthRate*0.5;// *b.weight;
                        b.energy -= dt*b.growthRate*0.5;
                    }
                } 
                else   {
                    b.length += dt*b.growthRate;// *b.weight;
                    b.energy -= dt*b.growthRate;
                }
            }

            b.Calculate(this,dt);
            
            if (b.GenerationIndex< MAX_GENERATIONS && b.ChildrenIndices.length ==0)
            if (b.length > b.NewBranchLength)
            {
                TrunkDivision(BranchIndex);
            }
            
            BranchIndex++;
        }
    }

    public function Draw (framebuffer:Framebuffer): Void {

        for( b in branches)
        {
            b.Draw(framebuffer);
        }
        for( b in branches)
        {
            b.DrawSkeleton(framebuffer);
        }
 
    }

}