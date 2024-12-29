package;

import flixel.FlxG;
import flixel.FlxSprite;

class Obstacle extends FlxSprite {
    public var speed:Float;
    public var weight:Float;
    public var obstacleType:String;
    
    public function new(X:Float, Y:Float, type:String) {
        super(X, Y);
        
        obstacleType = type;
        
        switch(type) {
            case "net":
                speed = 100;
                weight = 35;
                var fishingLineGraphic = loadGraphic("assets/images/fishingnet.png");
                fishingLineGraphic.scale.set(3, 3);
            case "fish":
                speed = 155;
                weight = 90;
                var enemyFish = loadGraphic("assets/images/enemyfish.png", true);
                enemyFish.animation.add("idle", [0,1,2,3,4,5,6,7,8], 8, true);
                enemyFish.animation.play("idle");
                enemyFish.scale.set(3,3);
            case "bait":
                speed = 95;
                weight = 50;
                var y = loadGraphic("assets/images/bait.png");
                y.scale.set(3.5,3.5);
            case "bait2":
                speed=105;
                weight=35;
                var t = loadGraphic("assets/images/y.png");
                t.scale.set(3.5,3.5);
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        x -= speed * elapsed;
    }
}