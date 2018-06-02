//-------------------------------------------------------
// class of living creature
//-------------------------------------------------------

package;

import kha.Framebuffer;
import kha.System;

using Utils;
using kha.graphics2.GraphicsExtension;


class Creature
{
    public static inline var VISION_DISTANCE: Int = 20;
    public static inline var BRAKING = 0.85;
    public static inline var MIN_SPEED = 0.99;
    public static inline var MAX_SPEED = 25.0;
    public static inline var INVULNERABILITY_TIME = 1000;
    public static inline var LIVE_TIME = 8000;

    public var pos: Vec2;

    // directions and velocity 
    public var  dirV:Vec2 ;
    public var velF : Float;
    public var dirAccel : Vec2;

    // parts of the body
    public var mouthR: Float;
    public var eyeR : Float;
    public var tailR : Float;

    //  basic parameters
    public var visionR : Float;
    public var mass : Float;
    public var food_counter : Float;

    public var invulnearability_timer : Float;
    public var life_timer : Float;
    public var IsNewborn : Bool;
    public var IsDead : Bool;

    function rndsign() : Int
    {
        if (Math.random() <= 0.5) return 1;
        else return -1;
    }

    public function new() 
    {
        this.pos = new Vec2(System.windowWidth() * Math.random(), System.windowHeight() * Math.random());

        // directions and velocity 
        this.dirV = new Vec2(Math.random(), Math.random());
        this.velF = Math.random() + 1;
        this.dirAccel = new Vec2(0, 0);

        if (Math.random() > 0.5) this.dirV.x *= -1;
        if (Math.random() > 0.5) this.dirV.y *= -1;
        this.dirV.normalize();

        // parts of the body
        this.mouthR = 1 + Math.random() * 1;
        this.eyeR = 1 + Math.random() * 1;
        this.tailR = 1 + Math.random() * 1;

        // calculation of basic parameters
        this.visionR = this.eyeR * VISION_DISTANCE;
        this.mass = this.mouthR + this.eyeR + this.tailR;
        this.food_counter = this.mass;

        this.invulnearability_timer = 0;
        this.life_timer = LIVE_TIME;
        this.IsNewborn = false;
        this.IsDead = false;
    }

    public function GiveBrith() : Void {
        var cs = Ecosystem.instance.creatures;
        // add empty creature to the end of an cretures array
        cs.push(new Creature());
        var newborn:Creature = cs[cs.length-1];
        newborn.pos = this.pos.clone();
        newborn.eyeR = this.eyeR + 0.5 * Math.random() * rndsign();
        newborn.mouthR = this.mouthR + 0.5 * Math.random() * rndsign();
        newborn.tailR = this.tailR + 0.5 * Math.random() * rndsign();
        newborn.invulnearability_timer = INVULNERABILITY_TIME;
        // calculation of basic parameters
        newborn.visionR = newborn.eyeR * VISION_DISTANCE;
        newborn.mass = newborn.mouthR + newborn.eyeR + newborn.tailR;
        newborn.food_counter = newborn.mass;
        newborn.velF = 0;
        newborn.IsNewborn = true;
    }

    public function BiteStranger (prey: Creature) : Void {
        this.food_counter += this.mouthR;

        prey.mouthR -= this.mouthR;
        if (prey.mouthR < 0) {
            prey.tailR += prey.mouthR;
            prey.mouthR = 0;
            if (prey.tailR < 0) {
                prey.eyeR += prey.tailR;
                prey.tailR = 0;
                if (prey.eyeR <= 0) {
                    // return back a part of negative pray mass
                    this.food_counter += prey.eyeR;
                    // delete prey from array
                    prey.IsDead = true;
                    return;
                }
            }
        }

        // prey.food_counter = 0;
        prey.invulnearability_timer = INVULNERABILITY_TIME;
        prey.velF = 0;
        prey.dirV = prey.dirV.mult(-1);


    }

    // Trying to catch some food
    public function CatchFood (food : Food, dirTo : Vec2) : Void {
        var dist = dirTo.length;

        var max_dist = this.eyeR * VISION_DISTANCE;

        // relative distance to stranger (0..1)
        var dR = (max_dist - dist) / max_dist;


        if (dist < (this.eyeR)) {  // collision?
            food.Eat();
            this.food_counter += 1;
        }

        // Calc a acceleration
        dirTo.normalize();
        dirTo = dirTo.mult(dR);
        this.dirAccel = this.dirAccel.add(dirTo);


    }


    // Behave to specified stranger
    public function Behave(stranger: Creature, dirTo : Vec2) {
        var runaway = false;
        var dist = dirTo.length;

        var max_dist = this.eyeR * VISION_DISTANCE;

        // relative distance to stranger (0..1)
        var dR = (max_dist - dist) / max_dist;
    
        // we both has no mouth - then don't care
        if (stranger.mouthR == 0 && this.mouthR == 0) return;

        // we are smaller
        if ((this.mass < stranger.mass) && dR>0.1) runaway = true;
        else if (this.mouthR < stranger.mouthR) runaway = true;

        // we have a mouth
        if ((this.mouthR > 0) && (dist < this.eyeR)   // collision?
                && (this.mouthR > stranger.mouthR)) // our mouth is bigger
                {
                this.BiteStranger(stranger);
        }
    

        // Calc a acceleration
        dirTo.normalize();
        dirTo = dirTo.mult(dR);
        if (!runaway)  this.dirAccel = this.dirAccel.add(dirTo);
        else this.dirAccel = this.dirAccel.sub(dirTo);

    }

    public function Vision () {
        var cs = Ecosystem.instance.creatures;
        var distance: Float = 0;
        var dirToNeibour = new Vec2(0, 0);

        this.visionR = this.eyeR * VISION_DISTANCE;
        this.visionR *= this.visionR;

        var i: Int =0;
        while  (i < cs.length) {
            if (this == cs[i]) { i++; continue ; };
        if (cs[i].invulnearability_timer > 0) { i++; continue ; };

            dirToNeibour = cs[i].pos.sub(this.pos);
            distance = dirToNeibour.lengthSquared();
            // see ya!
            if (distance < this.visionR) this.Behave(cs[i], dirToNeibour);
            i ++;
        }

        // no mouth - no food
        if (this.mouthR == 0) return;

        var ef = Ecosystem.instance.food;
        for (i in 0...Ecosystem.MAX_FOOD) {
            dirToNeibour = ef[i].pos.sub(this.pos);
            distance = dirToNeibour.lengthSquared();
            // see ya!
            if (distance < this.visionR) this.CatchFood(ef[i], dirToNeibour);

        }
        //*/
    }

    public function Calculate(dt:Float) {

        // calculation of basic parameters
        this.mass = this.mouthR + this.eyeR + this.tailR;
        this.dirV = this.dirV.mult(this.velF);

        if (this.IsDead) return;
        if (this.invulnearability_timer > 0) {
            this.invulnearability_timer -= dt;
            return;
        } else this.IsNewborn = false;


        // apply acceleration
        this.dirAccel = this.dirAccel.mult(0.04 * dt * (this.tailR * this.tailR) /
        (this.eyeR * this.eyeR + this.tailR * this.tailR + this.mouthR * this.mouthR));

        this.dirV = this.dirV.add(this.dirAccel);

        // apply hynger
        var fuel = this.dirAccel.length;
        this.food_counter -= fuel * 0.05;
        if (this.food_counter < 0) {
            this.food_counter = 0;
            // delete creture from array
            this.IsDead = true;
        }
        this.dirAccel.set(0, 0);


        // move the creature
        var v = this.dirV.mult(dt * 0.02);

        var p = this.pos.add(v);

        // Collision detection and response
        if (p.x <= 0 && v.x < 0) {
            this.dirV.x = -this.dirV.x;
            p.x = 0;
        }

        if (p.x >= System.windowWidth() && v.x > 0) {
            this.dirV.x = -this.dirV.x;
            p.x = System.windowWidth();
        }

        if (p.y <= 0 && v.y < 0) {
            p.y = 0;
            this.dirV.y = -this.dirV.y;
        }

        if (p.y >= System.windowHeight() && v.y > 0) {
            p.y = System.windowHeight();
            this.dirV.y = -this.dirV.y;
        }


        this.pos = p;


        if (this.invulnearability_timer <= 0) this.Vision();
        if (this.mouthR > 0 && (this.food_counter >= (this.mass * 2))) {
            this.GiveBrith();
            this.food_counter = this.mass;
        }

        // breaking
        this.velF = this.dirV.length;
        if (this.velF > 0) this.dirV = this.dirV.div(this.velF);

        this.velF -= BRAKING * dt * 0.01;
        if (this.velF < MIN_SPEED) this.velF = MIN_SPEED;
        else if (this.velF > MAX_SPEED) this.velF = MAX_SPEED;



    }

    public function Draw (framebuffer:Framebuffer): Void {
        var p = this.pos;
        var mouthP = this.dirV.mult(this.mouthR + this.eyeR);
        var tailP = this.dirV.mult(-this.tailR - this.eyeR);

     //   ctx.setTransform(1, 0, 0, 1,0, 0);
   //     ctx.translate(p.x, p.y);
        
		var g2 = framebuffer.g2;
		var transitColor: kha.Color = kha.Color.fromValue(0xff888888);
        if (this.IsNewborn) transitColor = kha.Color.Yellow;

        // mouth
        g2.color = kha.Color.Red;
        if (this.invulnearability_timer > 0) g2.color= transitColor;
        g2.fillCircle( pos.x + mouthP.x, pos.y + mouthP.y, this.mouthR);
    
        // eye
        g2.color = kha.Color.Blue;
        if (this.invulnearability_timer > 0) g2.color= transitColor;
        g2.fillCircle( pos.x , pos.y , this.eyeR);
 
 
        // tail
        g2.color = kha.Color.Black;
        if (this.invulnearability_timer > 0) g2.color= transitColor;
        g2.fillCircle( pos.x + tailP.x, pos.y +  tailP.y, this.tailR);
 

    }

}