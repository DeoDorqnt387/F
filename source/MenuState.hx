package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxColor;


class MenuState extends FlxState
{
    var titleText:FlxText;
    var startText:FlxText;

    override public function create():Void
    {
        super.create();

        titleText = new FlxText(0, FlxG.height/3, FlxG.width, "Fish Escape");
        titleText.setFormat(null, 64, FlxColor.WHITE, "center");
        add(titleText);

        startText = new FlxText(0, FlxG.height * 2/3, FlxG.width, "Press 'Space' or 'Z' to start");
        startText.setFormat(null, 16, FlxColor.WHITE, "center");
        add(startText);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.anyJustPressed([SPACE, Z]))
        {
            FlxG.sound.playMusic("assets/sounds/select.mp3", 1.0, true);
            FlxTween.tween(startText.scale, {x: 1.2, y: 1.2}, 0.2, {
                onComplete: function(tween:FlxTween) {
                    FlxG.switchState(new PlayState());
                }
            });
        }
    }
}