package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class DeadState extends FlxState
{
    var titleText:FlxText;
    var deadText:FlxText;
    var scoreText:FlxText;

    override public function create():Void
    {
        super.create();
        
        titleText = new FlxText(0, FlxG.height/3, FlxG.width, "Whopsieee...");
        titleText.setFormat(null, 64, FlxColor.WHITE, "center");
        add(titleText);
        
        // Skoru göster
        scoreText = new FlxText(0, FlxG.height/2, FlxG.width, "Score: " + PlayState.lastScore);
        scoreText.setFormat(null, 32, FlxColor.YELLOW, "center");
        add(scoreText);

        deadText = new FlxText(0, FlxG.height * 2/3, FlxG.width, "You Died! Restart? (Space,Z)");
        deadText.setFormat(null, 16, FlxColor.WHITE, "center");
        add(deadText);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (FlxG.keys.anyJustPressed([SPACE, Z]))
        {
            FlxG.sound.play("assets/sounds/select.mp3", 1.0, false);
            FlxG.switchState(new PlayState());
        }
    }
}