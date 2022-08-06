import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class HudIcon extends FlxSprite
{
    public var animOffsets:Map<String, Array<Dynamic>>;
    public var type:String;
    public var daZoom:Float = 1;

    public function new(x:Float, y:Float, type:String)
    {
        super(x, y);
        this.type = type;

        animOffsets = new Map<String, Array<Dynamic>>();

        offset.set(0, 0);

        switch (type)
        {
            case "attack":
                frames = Paths.getSparrowAtlas("Notmobilegameanymore", "shared");

                animation.addByPrefix("idle", "Attack instance 1", 24, false);
                animation.addByIndices('5', 'AttackNA instance 1', [0], "", 24, true);
                animation.addByIndices('4', 'AttackNA instance 1', [29], "", 24, true);
                animation.addByIndices('3', 'AttackNA instance 1', [59], "", 24, true);
                animation.addByIndices('2', 'AttackNA instance 1', [90], "", 24, true);
                animation.addByIndices('1', 'AttackNA instance 1', [119], "", 24, true);
                animation.addByPrefix('fadeBack', 'Attack Click instance 1', 24, false);

                addOffset('idle', 0, 0);
                addOffset('5', -10, 30);
                addOffset('4', -10, 30);
                addOffset('3', -10, 30);
                addOffset('2', -10, 30);
                addOffset('1', -10, 30);
                addOffset('fadeBack', -12, -8);
        
                playAnim("idle");

                setZoom(0.5);
            case "dodge":
                frames = Paths.getSparrowAtlas("Notmobilegameanymore", "shared");
                animation.addByPrefix("idle", "Dodge instance 1", 24, false);
                animation.addByPrefix("fuck", "Dodge click instance 1", 24, false);

                addOffset('idle', 0, 0);
                addOffset('fuck', -10, -10);
        
                playAnim("idle");

                setZoom(0.5);
            case "attackUT":
                loadGraphic(Paths.image('undertaleActions1', 'shared'));
                setZoom(1.5);
            case "dodgeUT":
                loadGraphic(Paths.image('undertaleActions2', 'shared'));
                setZoom(1.5);
        }

        antialiasing = FlxG.save.data.highquality && !StringTools.endsWith(type, 'UT');

        scrollFactor.set();

        alpha = 0.6;
    }

    public function useHUD()
    {
        switch (type)
        {
            case 'attack':
            {
                playAnim("fadeBack");
                animation.finishCallback = function(name)
                {
                    playAnim("idle");
                };
            }
            case 'dodge':
            {
                playAnim("fuck");
                animation.finishCallback = function(name:String)
                {
                    playAnim("idle");
                };
            }
            case 'attackUT':
                var oldColor:FlxColor = color;
                color = 0xFFFFFF00;
                new FlxTimer().start(0.3, function(timer:FlxTimer) {
                    color = oldColor;
                });
            
            case 'dodgeUT':
                var oldColor:FlxColor = color;
                color = 0xFFFFFF00;
                new FlxTimer().start(0.3, function(timer:FlxTimer) {
                    color = oldColor;
                });
        }
    }

    public function setZoom(?toChange:Float = 1):Void
    {
        daZoom = toChange;
        scale.set(toChange, toChange);
    }

    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
    {
        animation.play(AnimName, Force, Reversed, Frame);

        var daOffset = animOffsets.get(AnimName);
        if (animOffsets.exists(AnimName))
        {
            offset.set(daOffset[0] * daZoom, daOffset[1] * daZoom);
        }
        else
        {
            offset.set(0, 0);
        }
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0)
    {
        animOffsets[name] = [x, y];
    }
}