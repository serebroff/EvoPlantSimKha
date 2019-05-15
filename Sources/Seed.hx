import kha.Framebuffer;
import kha.System;

using kha.graphics2.GraphicsExtension;

//-------------------------------------------------------
// class of seed
//-------------------------------------------------------


class Seed extends Leaf {
	var newDNA: DNA;
	
	public override function Draw (framebuffer:Framebuffer): Void 
	{
		if (deathtime> Leaf.DEATH_TIME) return;

		var a: Float = 1 - disapperTime / Leaf.DISAPPEAR_TIME;
		if (a<0) a=0;

		var g2 = framebuffer.g2;
		var c: Float = energyDensity / DNA.MAX_ENERGY_IN_LEAF;
		var r: Float = 0;
		if (c<0) c= 0;
		if (c>1) c =1;

		g2.color = kha.Color.fromFloats(c, 0, 0, a);
	//	if (dead) g2.color = kha.Color.fromFloats(0.1, 0.1, 0, 1);

		g2.fillTriangle(v2.x,v2.y, v3.x,v3.y, v4.x,v4.y);

	}

}
