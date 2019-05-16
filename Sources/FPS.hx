// ----------------------------------------
// FPS counter
//----------------------------------------
import kha.Scheduler;


class FPS 
{
    var numframesPassed : Int;
    var frametimePassed : Float; 

    var TIME_TO_COUNT: Float = 0.25;

    var previousRealTime:Float;
    var realTime:Float;

    static public var dt : Float;
    
    var fps : Float;

    public function new() {
        numframesPassed =1;
        frametimePassed =0;
        realTime =0;
        fps=0;
        dt = 0;

    };

    public function Init() {
        realTime = Scheduler.realTime();
        previousRealTime = realTime;
    }

    public function getFPS()
    {
        return fps;
    }

    public function update()
    {
        previousRealTime = realTime;
        realTime = Scheduler.realTime();
        dt = realTime - previousRealTime;
        frametimePassed += dt;
        if (frametimePassed > TIME_TO_COUNT) 
        {
            fps = 1 / (frametimePassed / numframesPassed );
            frametimePassed -= TIME_TO_COUNT;
            numframesPassed = 0;
        }
        numframesPassed ++;
    }

}