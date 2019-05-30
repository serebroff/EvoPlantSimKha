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

    public function new(pos: Vec2 = null, newDNA: DNA = null, energy: Float = 150) 
    {
        if (newDNA != null) {
            dna = newDNA;
        } 
        else {
            dna = new DNA();
            dna.Init();
        }

        firstBranch = CreateNewBranch();
        //firstBranch = new Branch(this);

        if (pos != null ) {
            firstBranch.startPos.set(pos.x, pos.y);
        }
        else {
            firstBranch.startPos.set(0, 0);
        }

    }
    


 
    public function CreateNewBranch(branchParent: Branch = null, angle:Float =0) : Branch
    {
        var  newBranch : Branch = null; // new Branch();
        
        var deadReplace:Bool = false;

        for (b in Ecosystem.branches)
        {
            if (b.totalDeath) {
                newBranch = b;
                if (newBranch.parentBranch!=null && !newBranch.parentBranch.totalDeath) {
                    newBranch.parentBranch.ChildrenIndices.remove(newBranch);
                }
                newBranch.Init();
                deadReplace = true;
                break;
            }
        }  

        if (!deadReplace)
        {
            newBranch = new Branch();
            Ecosystem.branches.push(newBranch);
        }

        newBranch.maxLength = dna.getGeneValue(branchID, lengthID, branchParent); //branch_length;
        newBranch.thickness = dna.getGeneValue(branchID, thicknessID, branchParent);  //branch_thickness;
        newBranch.branch_growth_pos = dna.getGeneValue(branchID, start_growth_posID, branchParent);
	    newBranch.leaves_number = dna.getGeneValue(branchID, leaves_numberID, branchParent);
	    newBranch.generation2blossom = dna.getGeneValue(branchID, generation2blossomID, branchParent);

        newBranch.parentPlant = this;

        if (branchParent!=null) {
            branchParent.ChildrenIndices.push(newBranch);
            newBranch.startPos.setFrom(branchParent.startPos);
            newBranch.dir.setFrom( branchParent.dir.rotate(angle) );
            newBranch.parentBranch = branchParent;
            newBranch.GenerationIndex = branchParent.GenerationIndex + 1;
        }
        newBranch.CalculateVertices();
       
        return newBranch;

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
            newSeed = new Seed();
            Ecosystem.seeds.push(newSeed);
        }

        newSeed.parentPlant = this; 
        newSeed.newDNA = dna.duplicate();
        newSeed.maxLength=dna.getGeneValue(seedID, lengthID, parent);
        newSeed.thickness = dna.getGeneValue(seedID, thicknessID, parent);

        parent.SeedsIndices.push(newSeed);
        newSeed.startPos.setFrom(parent.endPos);
        newSeed.dir.setFrom( parent.dir.rotate(angle));
        newSeed.parentBranch = parent;
        newSeed.CalculateVertices();

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
            newLeaf = new Leaf();
            Ecosystem.leaves.push(newLeaf);
        }

        newLeaf.parentPlant = this;
        newLeaf.maxLength= dna.getGeneValue(leaveID, lengthID, parent);
        newLeaf.thickness = dna.getGeneValue(leaveID, thicknessID, parent);

        parent.LeavesIndices.push(newLeaf);
        newLeaf.posOnBranch = posOnBranch;
        newLeaf.startPos.setFrom(parent.endPos);
        newLeaf.dir.setFrom( parent.dir.rotate(angle));
        newLeaf.parentBranch = parent;
        newLeaf.CalculateVertices();

        newLeaf.GenerationIndex = parent.GenerationIndex + 1;
       

    }


    public function Calculate(dt:Float) {

        if (firstBranch == null) {
            return;
        }

        firstBranch.Calculate(dt);

        if (firstBranch.totalDeath) {
            firstBranch = null;
        }

    }

    public function Draw (framebuffer:Framebuffer): Void {

    }

}