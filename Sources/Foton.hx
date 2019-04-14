package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;
using Project;
using Plant;
using Leaf;


//------------------------------------- ------------------
// foton class 
//-------------------------------------------------------
class Foton {

        // constants
    public static inline var SPEED = 800;  // pixel / sec
    public static inline var BEAM_LENGTH = 10.0; 

    public var pos: Vec2;
    public var dir: Vec2;
    public var angle: Float;


//    public satatic var angle: Float;

    public function new() 
    {  
        pos = new Vec2(System.windowWidth() * Math.random(), System.windowHeight() * Math.random());
        dir = new Vec2(1, 1);
        dir.normalize();
        dir=dir.mult(Math.random() +1);
    }

    public function Calculate(dt:Float): Void {
        pos= pos.add(dir.mult(dt*SPEED));
        if (pos.y>System.windowHeight() || pos.x>System.windowWidth() || pos.x<0 || pos.y <0) Renew();
    }

    public function Renew(): Void {
 
        var angle:Float  = Math.PI*0.5 - Math.PI* 0.4 *  Ecosystem.instance.sun_angle; 
        dir.set(Math.cos(angle), Math.sin(angle));
        dir.normalize();

        if (Math.random()<Math.abs(dir.x)*0.6)  
        {
            this.pos.set(dir.x>0? 0 : System.windowWidth(), System.windowHeight() * Math.random());
        }
        else this.pos.set(System.windowWidth() * Math.random(), 0);
        
    }

    public function CheckCollision(plant: Plant): Bool
    {
        var b: Branch;
        var l: Leaf;
        for (l in plant.leaves)
        {
            //if (pos.PointInTriangle(l.v1,l.v2,l.v4) || pos.PointInTriangle(l.v2,l.v3,l.v4))
            if (l.dead) continue;
            if (pos.PointInTriangle(l.v2,l.v3,l.v4))
            {
                l.energy+=6;
                Renew();
                return true;
            }
        }
        return false;
    }


	public function Draw(framebuffer: Framebuffer): Void {
		var g2 = framebuffer.g2;

		//g2.color = kha.Color.Orange; //fromFloats(0.2,0.2,0.9, 0.7 );
        
        var r:Float =  0.8 * Math.abs(Ecosystem.instance.sun_angle ) ;
		g2.color = kha.Color.fromFloats( 1, 1-r, 0, 1);
		
        g2.drawLine (pos.x, pos.y , pos.x + dir.x*BEAM_LENGTH, pos.y + dir.y*BEAM_LENGTH, 2);
		//g2.fillCircle( pos.x, pos.y, 2);

	}

}




