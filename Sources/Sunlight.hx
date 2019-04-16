package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Plant;
using Leaf;



//------------------------------------- ------------------
// Sunlight class 
//-------------------------------------------------------
class Sunlight {

    public static inline var RADIUS = 1700;
    public static inline var NUM_BEAMS = 50;
    public static var BEAM_DISTANCE = 30;
    public static var BEAM_LENGTH = 2700; 

    public var dir: Vec2;
    public var pos: Vec2;
    public var ar_beam_pos1: haxe.ds.Vector<Vec2>;
    public var ar_beam_pos2: haxe.ds.Vector<Vec2>;
    public var ar_beam_dist: haxe.ds.Vector<Float>;
    public var center: Vec2;
    public var angle : Float;
    public var radius : Float;
    public var beam_delta : Float;


	public var Frequency: Float; // per sec per pixel

    public function new() 
    {  
        dir = new Vec2(2, 1);
		Frequency = 1;
        angle = 0;
        radius = RADIUS;
        beam_delta =0;

        ar_beam_pos1 =  new haxe.ds.Vector<Vec2> (NUM_BEAMS);
        ar_beam_pos2 =  new haxe.ds.Vector<Vec2> (NUM_BEAMS);
        ar_beam_dist = new haxe.ds.Vector<Float> (NUM_BEAMS);// [for (i in 0...NUM_BEAMS) 0];
      
        center = new Vec2(System.windowWidth() * 0.5 , System.windowHeight());
    }

    public function Calculate(dt:Float) 
    {
        angle  = - Math.PI*0.5 - Math.PI* 0.4 *  Ecosystem.instance.sun_angle; 
        dir.set(-Math.cos(angle), -Math.sin(angle));

        beam_delta += dt *20 ;
        if (beam_delta> BEAM_DISTANCE)
        {
            beam_delta -= BEAM_DISTANCE; 
        }

        pos = center.add(dir.mult(-radius) );
        var perpendicular : Vec2;
        perpendicular = dir.rotate(Math.PI*0.5);
        var v: Vec2 = new Vec2();
        var i:  Int = 0 ; 

        while (i < NUM_BEAMS)
        {
            v = pos.add(perpendicular.mult(beam_delta + BEAM_DISTANCE*( i - Math.floor(NUM_BEAMS/2))));

            ar_beam_pos1[i] = v;
            
            ar_beam_pos2[i] = v.add(dir.mult(BEAM_LENGTH));
            ar_beam_dist[i] = BEAM_LENGTH;
            i++;

        }
        
    }

    public function CheckCollision(plant: Plant): Bool
    {
        var b: Branch;
        var l: Leaf;
        var ray: Vec2 = new Vec2();
        var d1, d2: Float;
        var collision: Bool = false;

        var i:  Int = 0 ; 

        while (i < NUM_BEAMS)
        {
            ray = ar_beam_pos1[i];
            

            for (l in plant.leaves)
            {
                if (l.dead) continue;

                d1 = ray.GetRayToLineSegmentIntersection(dir, l.v2,l.v3); 
                d2 = ray.GetRayToLineSegmentIntersection(dir, l.v2,l.v4);

                if (d1>0 || d2>0) 
                {
                    if (d1==0 || d1<d2) d1 = d2;

                
                    if (ar_beam_dist[i]>d1) 
                    {
                        ar_beam_dist[i]=d1;
                        ar_beam_pos2[i] = ar_beam_pos1[i].add(dir.mult(d1));
                        l.energy+=6;
                        collision = true;
                    }
                }
            }    
            i++;
        }
        return collision;
    }

      public function Draw (framebuffer:Framebuffer): Void {
        var g2 = framebuffer.g2;
		g2.color = kha.Color.fromFloats(0,0,0,0.5);
		g2.drawLine(center.x,center.y,pos.x,pos.y,2);
        
        var r:Float =  0.8 * Math.abs(Ecosystem.instance.sun_angle ) ;
		g2.color = kha.Color.fromFloats( 1, 1-r, 0, 0.4);
        
        var v1:Vec2 = new Vec2();
        var v2:Vec2 = new Vec2();
        var i:  Int = 0;

        while (i < NUM_BEAMS)
        {
            v1 = ar_beam_pos1[i] ;
            v2 = ar_beam_pos2[i] ;
            g2.drawLine(v1.x,v1.y,v2.x,v2.y,2);
            i++;
        }

      }


}




