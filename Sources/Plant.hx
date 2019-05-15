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

    public var pos: Vec2;

    public function new(newDNA: DNA = null, energy: Float = 2000) 
    {
        if (newDNA != null) {
            dna = newDNA;
        } 
        else {
            dna = new DNA();
            dna.Init();
        }

        pos = new Vec2(0,0);

        firstBranch = new Branch(this);

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.endPos.set(0, -1);
        firstBranch.maxLength = dna.branch_length;
        firstBranch.thickness = dna.branch_thickness;
        firstBranch.energy = energy;
        firstBranch.parentPlant = this;

        Ecosystem.branches.push(firstBranch);
    }
    
/*    public function new(newDNA: DNA, energy: Float) 
    {
        dna = newDNA;

        pos = new Vec2(0,0);

        firstBranch = new Branch(this);

        firstBranch.startPos.set(pos.x, pos.y);
        firstBranch.endPos.set(0, -1);
        firstBranch.maxLength = dna.branch_length;
        firstBranch.thickness = dna.branch_thickness;
        firstBranch.energy = energy;
        firstBranch.parentPlant = this;

        Ecosystem.branches.push(firstBranch);
    }  */

 
    public function CreateNewBranch(branchParent: Branch, angle:Float =0) 
    {
        var  newBranch : Branch = null; // new Branch();
        
        var deadReplace:Bool = false;

        for (b in Ecosystem.branches)
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
            Ecosystem.branches.push(newBranch);
        }

        branchParent.ChildrenIndices.push(newBranch);
       
        
        newBranch.startPos.setFrom(branchParent.startPos);
        newBranch.maxLength = dna.branch_length;
        newBranch.thickness = dna.branch_thickness;
        newBranch.dir.setFrom( branchParent.dir.rotate(angle) );
        newBranch.parentBranch = branchParent;

        newBranch.GenerationIndex = branchParent.GenerationIndex + 1;

    }

    public function CreateNewSeed(parent: Branch, angle: Float) {

        var  newSeed : Seed = null; 
        var deadReplace:Bool = false;

        for (s in Ecosystem.seeds)
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
            Ecosystem.seeds.push(newSeed);
        }

        parent.SeedsIndices.push(newSeed);
        newSeed.startPos.setFrom(parent.endPos);
        newSeed.dir.setFrom( parent.dir.rotate(angle));
        newSeed.maxLength=dna.seed_length;
        newSeed.thickness = dna.seed_thickness;
        newSeed.parentBranch = parent;
        newSeed.GenerationIndex = parent.GenerationIndex + 1;

    }

    public function CreateNewLeaf(parent: Branch, angle: Float, posOnBranch: Float = 1) {

        var  newLeaf : Leaf = null; 

      
        var deadReplace:Bool = false;

        for (l in Ecosystem.leaves)
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
            Ecosystem.leaves.push(newLeaf);
        }

        parent.LeavesIndices.push(newLeaf);
        newLeaf.posOnBranch = posOnBranch;
        newLeaf.startPos.setFrom(parent.endPos);
        newLeaf.dir.setFrom( parent.dir.rotate(angle));
        newLeaf.maxLength=dna.leaf_length;
        newLeaf.thickness = dna.leaf_thickness;
        newLeaf.parentBranch = parent;
        newLeaf.GenerationIndex = parent.GenerationIndex + 1;
       

    }


    public function Calculate(dt:Float) {

        firstBranch.Calculate(dt);

    }

    public function Draw (framebuffer:Framebuffer): Void {

    }

}