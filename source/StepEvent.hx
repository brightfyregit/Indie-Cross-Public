class StepEvent 
{
    public var step:Int = 0;
    public var callback:Void->Void;

    public function new(daStep:Int = 0, daCallback:Void->Void = null)
    {
        // /trace(daStep);
        step = daStep;
        callback = daCallback;
    }
}