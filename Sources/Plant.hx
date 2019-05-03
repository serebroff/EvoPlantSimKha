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

    public function new() 
    {
        dna = new DNA();

        pos = new Vec2(0,0);

        firstBranch = new Branch(this);

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.endPos.set(0, -100);
        firstBranch.length = 100;
        firstBranch.energy = 540;
        firstBranch.parentPlant = this;


        branches = [];
        branches.push(firstBranch);

        leaves = [];
        
        CreateNewLeaf(firstBranch, dna.angle); 
        CreateNewLeaf(firstBranch, - dna.angle); 
        CreateNewLeaf(firstBranch, 0); 
    
   
    }

    public function CreateNewBranch(leafParent: Leaf, angle:Float =0) 
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
       // newBranch.dir.setFrom( leafParent.dir.rotate(angle) );
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


    public function Calculate(dt:Float) {
        firstBranch.Calculate(dt);
/*        CalculateLeaves(dt);
        CalculateBranches(dt);*/

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