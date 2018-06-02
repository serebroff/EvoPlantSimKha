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
    public var NewBranchProbability = 0.15;  // per second
    public var NumOfNewBrenches :Int = 2;
    public var NumOfNewBrenchesVariation :Int = 0;
    public var NewBranchAngle :Float = Math.PI * 0.3;
    public var NewBranchAngleVariation :Float = Math.PI * 0.3;

    

    public var pos: Vec2;

    public static var TrunckThickness: Float = 0.1;

    public var branches: Array<Branch>;

    // constants
    public static inline var THICKNESS = 0.1;
    public static inline var GROWTH_RATE = 0.1;  // Percent per second
    public static inline var NEW_BRANCH_CREATION_INTERVAL = 0.2;  // sec

 


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
        firstBranch.lenght = 60;

        this.branches = [];
        this.branches.push(firstBranch);

   
    }

    public function TrunkDivision(ParentBranchIndex: Int) {
        var n: Int = NumOfNewBrenches + Std.random(NumOfNewBrenchesVariation);
        var DivisionAngle: Float = NewBranchAngle + Math.random()*NewBranchAngleVariation;
        var angle: Float = - DivisionAngle / 2; 
        var angleStep: Float = DivisionAngle / (n-1);
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
        branches.push(newBranch);
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

            b.lenght += b.lenght*dt*GROWTH_RATE;
            b.Calculate(dt);

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
                    }
                }
            }
            
            BranchIndex++;
        }

 

    }

    public function Draw (framebuffer:Framebuffer): Void {
        var p = this.pos;

        for( b in branches)
        {
            b.Draw(framebuffer);
        }

 
    }

}