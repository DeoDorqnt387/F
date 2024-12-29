package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
    public static var lastScore:Int = 0;
    var player:FlxSprite;
    var obstacles:FlxTypedGroup<Obstacle>;
    var dragging:Obstacle;
    var random:FlxRandom;
    var spawnTimer:Float = 0;
    var spawnInterval:Float = 2;

    var score:Int = 0;
    var scoreText:FlxText;
    var hungerTimer:Float = 0;
    var maxHungerTime:Float = 20;
    var hungerBar:FlxSprite;
    var foodItem:FlxSprite;
    var foodCooldown:Float = 0;
    var foodCooldownMax:Float = 5;
    var canUseFoodItem:Bool = true;

    /*############################
    # Player Random Movement Var #*/    
    var playerSize:Float = 1.0;
    var moveTimer:Float = 0;
    var moveInterval:Float = 5;
    var isMoving:Bool = false;
    var moveDirection:String = "";
    var difficulty:Float = 1.0;
    var difficultyTimer:Float = 0;
    var difficultyInterval:Float = 10;

    override public function create()
    {   
        super.create();

        random = new FlxRandom();

        player = new FlxSprite();
        player.loadGraphic("assets/images/player.png");
        player.setPosition(100, FlxG.height / 2);
        player.scale.set(3,3);
        add(player);

        scoreText = new FlxText(10, 10, 200, "Score: 0");
        scoreText.setFormat(null, 16, FlxColor.WHITE);
        add(scoreText);

        hungerBar = new FlxSprite(10, FlxG.height - 30);
        hungerBar.makeGraphic(100, 20, FlxColor.GREEN);
        add(hungerBar);

        foodItem = new FlxSprite(10, FlxG.height - 60);
        foodItem.loadGraphic("assets/images/y.png");
        foodItem.scale.set(4, 4);
        add(foodItem);

        obstacles = new FlxTypedGroup<Obstacle>();
        add(obstacles);
    
        FlxG.sound.playMusic("assets/music/bgm.mp3", 1.0, true);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        updateTimers(elapsed);
    
        spawnTimer += elapsed;
        if (spawnTimer >= spawnInterval) {
            spawnObstacle();
            spawnTimer = 0;
        }
    
        if (FlxG.overlap(player, foodItem) && canUseFoodItem) {
            useFoodItem();
            growPlayer();
        }
    
        obstacles.forEach(function(obstacle:Obstacle) {
            if (obstacle.x < -obstacle.width) {
                obstacles.remove(obstacle, true);
                obstacle.destroy();
            }
        });
    
        handleFoodAndDragging();
        checkCollisions();
        updatePlayerMovement(elapsed);
        timer(elapsed);
    }
    function timer(elapsed){
        difficultyTimer += elapsed;
        if (difficultyTimer >= difficultyInterval) {
            difficulty += 0.2;
            spawnInterval = Math.max(0.5, 2 - (difficulty * 0.2));
            difficultyTimer = 0;
        }
    }
    function spawnObstacle() {
        var obstacleTypes = ["net", "bait2", "fish", "bait"];
        var randomType = obstacleTypes[random.int(0, obstacleTypes.length - 1)];
        
        for (i in 0...Math.floor(difficulty)) {
            var obstacle = new Obstacle(
                FlxG.width + (i * 50),
                random.float(0, FlxG.height - 50),
                randomType
            );
            obstacles.add(obstacle);
        }
    }

    function updateTimers(elapsed:Float)
    {
        hungerTimer += elapsed;
        var hungerRatio = 1 - (hungerTimer / maxHungerTime);
        hungerBar.scale.x = Math.max(0, hungerRatio);
        
        if (hungerTimer >= maxHungerTime) {
            gameOver();
        }

        if (!canUseFoodItem) {
            foodCooldown += elapsed;
            if (foodCooldown >= foodCooldownMax) {
                canUseFoodItem = true;
                foodCooldown = 0;
                foodItem.alpha = 1;
            }
        }
    }

    function handleFoodAndDragging()
    {
        if (FlxG.mouse.justPressed) {
            if (canUseFoodItem && FlxG.mouse.overlaps(foodItem)) {
                dragging = null;
                useFoodItem();
            } else {
                obstacles.forEach(function(obstacle:Obstacle) {
                    if (FlxG.mouse.overlaps(obstacle)) {
                        dragging = obstacle;
                        return;
                    }
                });
            }
        }

        if (FlxG.mouse.pressed && dragging != null) {
            var targetY = FlxG.mouse.y - (dragging.height / 2);
            dragging.y += (targetY - dragging.y) / dragging.weight;
        }

        if (FlxG.mouse.justReleased) {
            dragging = null;
        }
    }

    function useFoodItem()
    {
        if (canUseFoodItem) {
            canUseFoodItem = false;
            foodItem.alpha = 0.5;
            
            FlxG.sound.play("assets/sounds/y.wav", 1.0, false);

            hungerTimer = 0;
            hungerBar.scale.x = 1;
            increaseScore(10);
        }
    }

    function checkCollisions()
    {
        obstacles.forEach(function(obstacle:Obstacle) {
            if (FlxG.overlap(player, obstacle)) {
                FlxG.switchState(new DeadState());
            }
        });
    }

    function increaseScore(amount:Int)
    {
        score += amount;
        scoreText.text = "Score: " + score;

        FlxTween.tween(scoreText.scale, {x: 1.5, y: 1.5}, 0.4, {
            onComplete: function(tween:FlxTween) {
                FlxTween.tween(scoreText.scale, {x: 1, y: 1}, 0.4);
            }
        });
    }

    function gameOver()
    {
        PlayState.lastScore = score;
        FlxG.switchState(new DeadState());
    }

    function updatePlayerMovement(elapsed:Float) {
        moveTimer += elapsed;
        
        if (moveTimer >= moveInterval) {
            startRandomMovement();
            moveTimer = 0;
            moveInterval = random.float(3, 6);
        }
        
        if (isMoving) {
            switch (moveDirection) {
                case "up":
                    player.y -= 2;
                    player.angle = -15;
                case "down":
                    player.y += 2;
                    player.angle = 15;
            }
            
            player.y = FlxMath.bound(player.y, 0, FlxG.height - player.height);
            player.x = FlxMath.bound(player.x, 0, FlxG.width - player.width);
        } else {
            player.angle = 0;
        }
    }

    function startRandomMovement() {
        isMoving = true;
        var directions = ["up", "down"];
        moveDirection = directions[random.int(0, directions.length - 1)];
        
        new FlxTimer().start(2, function(_) {
            isMoving = false;
        });
    }
    
    function growPlayer() {
        playerSize += 0.8;
        player.scale.set(playerSize, playerSize);
    }
}

