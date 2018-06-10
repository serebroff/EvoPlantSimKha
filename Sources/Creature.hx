//-------------------------------------------------------
// class of living creature
//-------------------------------------------------------

package;

import Branch;
import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;

class Creature
{
    public var NewBranchProbability = 0.25;  // per second

    public var NumOfNewBrenches :Int = 2;
    public var NumOfNewBrenchesVariation :Int = 1;
    public var NewBranchAngle :Float = Math.PI * 0.2;
    public var NewBranchAngleVariation :Float = Math.PI * 0.3;

//    public var growthRate = 0.1;  // Percent per second
    

    public var pos: Vec2;

    public static var TrunckThickness: Float = 0.1;

    public var branches: Array<Branch>;

    // constants
    public static inline var THICKNESS = 0.1;
    public static inline var NEW_BRANCH_CREATION_INTERVAL = 0.2;  // sec
    public static inline var MAX_GENERATIONS = 8;

 


    function rndsign() : Int
    {
        if (Math.random() <= 0.5) return 1;
        else return -1;
    }

    public function new() 
    {
        this.pos = new Vec2(System.windowWidth() * 0.5, System.windowHeight());

        var  firstBranch : Branch = new Branch();

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.lenght = 40;

        this.branches = [];
        this.branches.push(firstBranch);

   
    }

    public function TrunkDivision(ParentBranchIndex: Int) {
       
        var n: Int = NumOfNewBrenches + Std.random(NumOfNewBrenchesVariation);
        var DivisionAngle: Float = NewBranchAngle + Math.random()*NewBranchAngleVariation;
        var angle: Float = - DivisionAngle / 2; 
        var angleStep: Float =0;

        if (n==1) {
            angle=0;
        }
        else angleStep = DivisionAngle / (n-1);

        var i:Int =0;

        do 
        {
            CreateNewBranch(ParentBranchIndex, angle);  
            angle += angleStep;
            i++;
        }
        while (i<n);
    }

    public function CreateNewBranch(ParentBranchIndex: Int, angle: Float) {
        var  newBranch : Branch = new Branch();
        var parent=branches[ParentBranchIndex];
        
        newBranch.startPos.setFrom(parent.endPos);
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

            b.lenght += dt*b.growthRate*100;
            //b.growthPotential -= dt*10;

            b.Calculate(this,dt);

            if (b.GenerationIndex< MAX_GENERATIONS)
            if (b.timeToNewBranch >= 0)
            {
                 b.timeToNewBranch += dt;

                if (b.timeToNewBranch> NEW_BRANCH_CREATION_INTERVAL)
                 {
                    b.timeToNewBranch-=NEW_BRANCH_CREATION_INTERVAL;
                    if (Math.random()<= (NewBranchProbability* NEW_BRANCH_CREATION_INTERVAL) ) 
                    {
                        TrunkDivision(BranchIndex);
                        b.timeToNewBranch = -1;
                        b.growthRate*=0.5;
                    }
                }
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