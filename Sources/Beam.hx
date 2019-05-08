
package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Project;
using Plant;
using Leaf;

class IntersectionWithLeaf {
    public var pos: Vec2;
    public var distance: Float;
    public var leaf: Leaf;
    public var power: Float;
    public function new(p: Vec2, d: Float, l: Leaf) 
    {
        pos = p;
        distance = d;
        leaf = l;
        power =1;
    }

}

//------------------------------------- ------------------
// Beam class 
//-------------------------------------------------------
class Beam  {

       // constants
    public static inline var BEAM_ENERGY  = 200;
    public static inline var LOSS_OF_EVERGY_IN_LEAF  = 0.3;


    public var pos1: Vec2;
    public var pos2: Vec2;
    public var intercections_with_leaf: Array<IntersectionWithLeaf>;
    public var dist: Float;


    public function new() 
    {  
        Init();
        intercections_with_leaf = new Array<IntersectionWithLeaf>();
    }
    public function Init() 
    {
        pos1 = new Vec2();
		pos2 = new Vec2();
		dist = 1000;
        intercections_with_leaf = [];
    }

    public function CheckCollision(dt:Float)
    {
        var l: Leaf;
        var p: Plant;
        var collision: Bool = false;
        var intersection: IntersectionWithLeaf;

        var dir: Vec2;
        var d1: Float;
        var d2: Float;
        
        dir = Sunlight.dir;
        
        var collisionLeaf: Leaf = null;
        
        intercections_with_leaf = [];
        

        for (p in Ecosystem.instance.plants)
        {
            for (l in p.leaves)
            {
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
                        intercections_with_leaf.push(
                            new IntersectionWithLeaf( pos1.add(dir.mult(d1)), d1, l )
                            );

                        /*dist=d1;
                        pos2.setFrom( pos1.add(dir.mult(d1)) );
                        collision = true;
                        collisionLeaf = l;*/

                    }
                }
            }
        }

        if (intercections_with_leaf.length !=0)
        {
            intercections_with_leaf.sort(
                function(a, b) {
                    return Math.ceil(a.distance - b.distance);
                }
                );

            var power: Float = 1;
            for (i in intercections_with_leaf)  {
               i.leaf.AddEnergy(power * BEAM_ENERGY*FPS.dt); 
               power *= LOSS_OF_EVERGY_IN_LEAF;
               i.power = power;
            }  
        }

    /*    if (collision)
        {
            collisionLeaf.AddEnergy(BEAM_ENERGY*FPS.dt);
        }*/

    }


	public function Draw(framebuffer: Framebuffer): Void 
    {
        var g2 = framebuffer.g2;
        var r:Float =  1 - 0.1 * Math.abs(Sunlight.sun_angle ) ;
        var alpha: Float = 0.6;

		g2.color = kha.Color.fromFloats( 1, r, 0, alpha);
        
        if (intercections_with_leaf.length != 0)
        {
            var i: Int=0;
            g2.drawLine(pos1.x,pos1.y,intercections_with_leaf[i].pos.x, intercections_with_leaf[i].pos.y ,2);
            while (i < intercections_with_leaf.length -1)
            {
                g2.color = kha.Color.fromFloats( 1, r, 0, alpha * intercections_with_leaf[i].power);
                g2.drawLine(intercections_with_leaf[i].pos.x,intercections_with_leaf[i].pos.y,
                    intercections_with_leaf[i+1].pos.x, intercections_with_leaf[i +1].pos.y ,1);
                    i++;
            }

            g2.color = kha.Color.fromFloats( 1, r, 0, alpha * intercections_with_leaf[i].power);
            g2.drawLine(intercections_with_leaf[i].pos.x, intercections_with_leaf[i].pos.y,pos2.x,pos2.y, 1);
            
        }
        else 
        {
            g2.drawLine(pos1.x,pos1.y,pos2.x,pos2.y,2);
        }

	}

}




