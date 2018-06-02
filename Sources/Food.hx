package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;


//------------------------------------- ------------------
// food class 
//-------------------------------------------------------
class Food {

    public var pos: Vec2;

    public function new() 
    {  
        this.pos = new Vec2(System.windowWidth() * Math.random(), System.windowHeight() * Math.random());
    }

    public function Calculate(): Void {
    }

    public function Eat(): Void {
        this.pos.set(System.windowWidth() * Math.random(), System.windowHeight() * Math.random());
    }


	public function Draw(framebuffer: Framebuffer): Void {
		var g2 = framebuffer.g2;
		
		g2.color = kha.Color.Red;
		
		g2.fillCircle( pos.x, pos.y, 1);

	}

}




