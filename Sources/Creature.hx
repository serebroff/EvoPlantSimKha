//-------------------------------------------------------
// class of living creature
//-------------------------------------------------------

package;

import Branch;
import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;

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



class Creature
{
    public var NewBranchProbability = 0.9;  // per second

    var DNA: Array<Gene>;

    public var NewBranchLength = 40;  // in pixels
    public var NewBranchLengthVariation = 0;


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

        DNA = [];
        var gene:Gene;
        DNA.push( new Gene(
            new Exon(-60,  30,  20), 
            new Exon( 5,  100, 50),
            new Exon( 60,  30,  20)
            ) );
        DNA.push( new Gene(
            new Exon(-5,  50,  60)
            //new Exon( 30,  0,  40)
            ) );
      
        NormalizeDNA();
    

        this.pos = new Vec2(System.windowWidth() * 0.5, System.windowHeight());

        var  firstBranch : Branch = new Branch();

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.length = 40;
        firstBranch.energy = 40;

        this.branches = [];
        this.branches.push(firstBranch);
   
    }

    public function NormalizeDNA() 
    {
        var gene : Gene;
        var exon : Exon;
        var totalWeight : Float;
        var angle : Float;
        for( gene in DNA)
        {
            totalWeight = 0;
            for(exon in gene.exons)
            {
                totalWeight += exon.weight;
                exon.angle *= Math.PI / 180;
            }
            totalWeight /= gene.exons.length;
        }
    }

    public function TrunkDivision(ParentBranchIndex: Int) {

        var i:Int =0;
        var exon:Exon;
        var geneIndex: Int = (branches[ParentBranchIndex].GenerationIndex % DNA.length);

        for (exon in DNA[geneIndex].exons)
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
                    var delta: Float  =  b.energy *dt;
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
            if (b.length > b.NewBranchLength)// * b.weight)
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