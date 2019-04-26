
package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Project;
using Plant;
using Leaf;


//------------------------------------- ------------------
// Beam class 
//-------------------------------------------------------
class Beam  {

       // constants
    public static inline var BEAM_ENERGY  = 300;


    public var pos1: Vec2;
    public var pos2: Vec2;
    public var dist: Float;
    public var collisionLeafIndex: Int;
    public var collisionPlantIndex: Int;

    public function new() 
    {  
        Init();
    }
    public function Init() 
    {
        pos1 = new Vec2();
		pos2 = new Vec2();
		dist = 1000;
    }

    public function CheckCollision(dt:Float)
    {
        var l: Leaf;
        var p: Plant;
        var collision: Bool = false;

        var dir: Vec2;
        var d1: Float;
        var d2: Float;
        
        dir = Sunlight.dir;
        
        var collisionLeaf: Leaf = null;

        var plantIndex: Int =0;
        var leafIndex: Int =-1;

        for (p in Ecosystem.instance.plants)
        {
            for (l in p.leaves)
            {
                leafIndex++;
                if (l.dead) continue;

                d1 = pos1.GetRayToLineSegmentIntersection(dir, l.v2,l.v3); 
                if (d1 == 0)  
                {
                    d1 = pos1.GetRayToLineSegmentIntersection(dir, l.v2,l.v4);
                }

                if (d1 != 0 ) 
                {
                
                    if (dist>d1) 
                    {
                        dist=d1;
                        pos2 = pos1.add(dir.mult(d1));
                        collision = true;
                        collisionLeaf = l;

                    }
                }
            }
            plantIndex++;    
        }

        if (collision)
        {
            collisionLeaf.ChangeEnergy(BEAM_ENERGY*FPS.dt);
        }

    }


	public function Draw(framebuffer: Framebuffer): Void {
        var g2 = framebuffer.g2;
        var r:Float =  0.1 * Math.abs(Ecosystem.instance.sun_angle ) ;
		g2.color = kha.Color.fromFloats( 1, 1-r, 0, 0.4);
        g2.drawLine(pos1.x,pos1.y,pos2.x,pos2.y,1);

	}

}




