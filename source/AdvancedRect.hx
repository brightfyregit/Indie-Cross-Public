package;

import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;


class AdvancedRect extends FlxRect
{


    public function getTheRotatedBounds(degrees:Float, ?origin:FlxPoint, ?newRect:FlxRect):FlxRect
        {
            if (origin == null)
                origin = FlxPoint.weak(0, 0);
            
            if (newRect == null)
                newRect = FlxRect.get();
            
            degrees = degrees % 360;
            if (degrees == 0)
            {
                origin.putWeak();
                return newRect.set(x, y, width, height);
            }
            
            if (degrees < 0)
                degrees += 360;
            
            var radians = FlxAngle.TO_RAD * degrees;
            var cos = Math.cos(radians);
            var sin = Math.sin(radians);
            
            var left = -origin.x;
            var top = -origin.y;
            var right = -origin.x + width;
            var bottom = -origin.y + height;
            if (degrees < 90)
            {
                newRect.x = x + origin.x + cos * left - sin * bottom;
                newRect.y = y + origin.y + sin * left + cos * top;
            }
            else if (degrees < 180)
            {
                newRect.x = x + origin.x + cos * right - sin * bottom;
                newRect.y = y + origin.y + sin * left  + cos * bottom;
            }
            else if (degrees < 270)
            {
                newRect.x = x + origin.x + cos * right - sin * top;
                newRect.y = y + origin.y + sin * right + cos * bottom;
            }
            else
            {
                newRect.x = x + origin.x + cos * left - sin * top;
                newRect.y = y + origin.y + sin * right + cos * top;
            }
            // temp var, in case input rect is the output rect
            var newHeight = Math.abs(cos * height) + Math.abs(sin * width );
            newRect.width = Math.abs(cos * width ) + Math.abs(sin * height);
            newRect.height = newHeight;
            
            origin.putWeak();
            return newRect;
        }

}