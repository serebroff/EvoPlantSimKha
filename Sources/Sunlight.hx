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

    public var dir: Vec2;
	public var Frequency: Float; // per sec per pixel

    public function new() 
    {  
        dir = new Vec2(2, 1);
		Frequency = 1;
    }



}




