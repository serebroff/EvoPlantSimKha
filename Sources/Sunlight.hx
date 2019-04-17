package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Plant;
using Leaf;
using Beam;



//------------------------------------- ------------------
// Sunlight class 
//-------------------------------------------------------
class Sunlight {

    public static inline var RADIUS = 1700;
    public static inline var NUM_BEAMS = 50;
    public static var BEAM_DISTANCE = 30;
    public static var BEAM_LENGTH = 2700; 

    public static var dir: Vec2;
    public var pos: Vec2;
    public var ar_beams: Array<Beam>;
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
        
        ar_beams =  [for (i in 0...NUM_BEAMS) new Beam()];
      
        center = new Vec2(System.windowWidth() * 0.5 , System.windowHeight());
    }

    public function Calculate(dt:Float) 
    {
        angle  = - Math.PI*0.5 - Math.PI* 0.2 *  Ecosystem.instance.sun_angle; 
        dir.set(-Math.cos(angle), -Math.sin(angle));

        /*beam_delta += dt *20 ;
        if (beam_delta> BEAM_DISTANCE)
        {
            beam_delta -= BEAM_DISTANCE; 
        }*/

        pos = center.add(dir.mult(-radius) );
        var perpendicular : Vec2;
        perpendicular = dir.rotate(Math.PI*0.5);
        var v: Vec2 = new Vec2();
        var i:  Int = 0 ; 

        while (i < NUM_BEAMS)
        {
            v = pos.add(perpendicular.mult(beam_delta + BEAM_DISTANCE*( i - Math.floor(NUM_BEAMS/2))));


            ar_beams[i].pos1 = v;
            ar_beams[i].pos2 = v.add(dir.mult(BEAM_LENGTH));
            ar_beams[i].dist = BEAM_LENGTH;

            i++;

        }
        
    }


    public function CheckCollision()
    {
        for (b in ar_beams)
        {
            b.CheckCollision();
        }


    }

      public function Draw (framebuffer:Framebuffer): Void 
      {
        var g2 = framebuffer.g2;
		g2.color = kha.Color.fromFloats(0,0,0,0.5);
		g2.drawLine(center.x,center.y,pos.x,pos.y,2);


         for (b in ar_beams)
        {
            b.Draw(framebuffer);
        }


      }


}




