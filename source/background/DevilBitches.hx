package background;

import flixel.FlxG;
import flixel.FlxSprite;

class DevilBitches extends FlxSprite {
    
    public var devilDirection:Int = 0;
    public var hasHit:Bool = false;
    public var bitchCooldown:Float = 0;
    public var speed:Float = 30;

    public function new(?isfisher:Bool = false) {
        super();
        // set up the little devils

        if (isfisher)
        {
            frames = Paths.getSparrowAtlas('bonusSongs/Fisher', 'shared');
            animation.addByPrefix('runRight', 'WalkingFish instance 1', 24, true);
            animation.addByPrefix('runLeft', 'WalkingFish from the Right instance 1', 24, true);
            animation.play('runRight');
            setGraphicSize(Std.int(width * 1));
            
            scrollFactor.set(0.91, 0.91);

            y -= 20;

            speed = 20;

            offset.set(50, 0);
        }
        else
        {
            frames = Paths.getSparrowAtlas('bonusSongs/That Annoying Bitch', 'shared');
            animation.addByPrefix('runRight', 'BoiRun instance 1', 24, true);
            animation.addByPrefix('runLeft', 'BoiRun instance 2', 24, true);
            animation.play('runRight');
            scrollFactor.set(0.7, 0.7);
        }    
    }

    public function setDirection(left:Bool) 
    {
        if (left) 
        {
            devilDirection = -1;
            animation.play('runLeft', true);
            x = FlxG.width + width * 4;
        } 
        else 
        {
            devilDirection = 1;
            animation.play('runRight', true);
            x = -width * 4;
        }
    }

    override public function update(elapsed:Float) {
        // lol
        super.update(elapsed);
        //if (this.visible)
           // trace(x);
        x += (speed * (elapsed / (1/60))) * devilDirection;
        switch (devilDirection) 
        {
            case 1:
                if (x > FlxG.width + width * 4) 
                {
                    PlayState.instance.resetDevilGroupIndex();
                    kill();
                    destroy();
                }
            case -1:
                if (x < -width * 4) 
                {
                    PlayState.instance.resetDevilGroupIndex();
                    kill();
                    destroy();
                }
        }
    }
}