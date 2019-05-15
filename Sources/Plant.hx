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
    public var seeds: Array<Seed>;

    public var pos: Vec2;

    public function new() 
    {
        dna = new DNA();
        dna.Init();

        pos = new Vec2(0,0);

        firstBranch = new Branch(this);

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.endPos.set(0, -1);
        firstBranch.maxLength = dna.branch_length;
        firstBranch.energy = 2000;
        firstBranch.parentPlant = this;


        branches = [];
        branches.push(firstBranch);

        leaves = [];
        seeds = [];
        
      /*  CreateNewLeaf(firstBranch, dna.angle); 
        CreateNewLeaf(firstBranch, - dna.angle); 
        CreateNewLeaf(firstBranch, 0); */
    
   
    }

 
    public function CreateNewBranch(branchParent: Branch, angle:Float =0) 
    {
        var  newBranch : Branch = null; // new Branch();
        
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
       
        
        newBranch.startPos.setFrom(branchParent.startPos);
        newBranch.maxLength = dna.branch_length;
        newBranch.dir.setFrom( branchParent.dir.rotate(angle) );
        newBranch.parentBranch = branchParent;

        newBranch.GenerationIndex = branchParent.GenerationIndex + 1;

    }

    public function CreateNewSeed(parent: Branch, angle: Float) {

        var  newSeed : Seed = null; 
        var deadReplace:Bool = false;

        for (s in seeds)
        {
            if (s.totalDeath) {
                newSeed = s;
                newSeed.Init();
                deadReplace = true;
                break;
            }
        }  

        if (!deadReplace)
        {
            newSeed = new Seed(this);
            seeds.push(newSeed);
        }

        parent.SeedsIndices.push(newSeed);
        newSeed.startPos.setFrom(parent.endPos);
        newSeed.dir.setFrom( parent.dir.rotate(angle));
        newSeed.maxLength=dna.leaf_length;
        newSeed.parentBranch = parent;
        newSeed.GenerationIndex = parent.GenerationIndex + 1;

    }

    public function CreateNewLeaf(parent: Branch, angle: Float, posOnBranch: Float = 1) {

        var  newLeaf : Leaf = null; 

      
        var deadReplace:Bool = false;

        for (l in leaves)
        {
            if (l.totalDeath) {
                newLeaf = l;
                newLeaf.Init();
                deadReplace = true;
                break;
            }
        }  

        if (!deadReplace)
        {
            newLeaf = new Leaf(this);
            leaves.push(newLeaf);
        }

        parent.LeavesIndices.push(newLeaf);
        newLeaf.posOnBranch = posOnBranch;
        newLeaf.startPos.setFrom(parent.endPos);
        newLeaf.dir.setFrom( parent.dir.rotate(angle));
        newLeaf.maxLength=dna.leaf_length;
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

        for( s in seeds)
        {
            s.Draw(framebuffer);
           // l.DrawSkeleton(framebuffer);
        }
    }

}