package ;


// import openfl.display.Sprite;
// import gtoolbox.KeyboardKeys;
import nape.callbacks.*;

import fluidity2.*;

import nape.geom.Vec2;

import evsm.FState;

import gtoolbox.KeyboardKeys;
import gtoolbox.Input;

class MonsterScene extends GameScene {

    var bobCounter = 0.0;

    var sceneOptions = {
        width: 400,
        height: 300,
        gravity: .3
    }

    var numSoldiers:Int = 0;
    var maxSoldiers:Int = 200;
    var player:GameObject;
       
    public function new () {

        super (new Vec2(0,0));

        var states = new StringBin<FState<GameObject,GameEvent>>(function(name:String)
            {
                return new FState<GameObject,GameEvent>(name);
            });

        var blankType = new ObjectType();
        var playerType = new ObjectType();
        var enemyType = new ObjectType();
        var enemyAttackType = new ObjectType();


        var collider:Collider = Circle(0,0,80);
        var headOptions = {
            image: "assets/head.png",
            height: 130,
            jumpStrength: -10,
            collider:collider,
            z: 3
        };

        collider = None;
        var rightArmOptions = {
            image: "assets/rightarm.png",
            restingPosition: new Vec2(-40,70),
            bobHeight:10,
            bobSpeed: 2,
            followSpeed: 1/6,
            type:blankType,
            collider:collider,
            z: 10
        };

        var leftArmOptions = {
            image: "assets/leftarm.png",
            restingPosition: new Vec2(30,70),
            bobHeight:10,
            bobSpeed: 3,
            followSpeed: 1/6,
            type:blankType,
            collider:collider,
            z: -5
        };

        collider = Circle(0,-5,70);
        var bodyOptions = {
            image: "assets/body.png",
            restingPosition: new Vec2(-10,60),
            bobHeight:10,
            bobSpeed: 4,
            followSpeed: 1/2,
            type:playerType,
            collider:collider,
            z: -3
        };

        input
            .registerAxis(KeyboardKeys.LEFT,KeyboardKeys.RIGHT,'x')
            .registerAxis(KeyboardKeys.UP,KeyboardKeys.DOWN,'y')
            .registerInput(KeyboardKeys.Z,'jump')
        ;

        addGenerator("player",function()
            {
                player = (new GameObject())
                    .setGraphic(Image(headOptions.image))
                    .setScale(1/4)
                    .setState(states.get('playerNormalAir'))
                    .addType(playerType)
                    .setZ(headOptions.z)
                    .setCollider(headOptions.collider)
                    .setAttribute('randomColor',false)
                    .setAttribute('drawColorR',1.2)
                    .setAttribute('drawColorG',0)
                    .setAttribute('drawColorB',0)
                    .setAttribute('drawColorA',1)
                ;

                input                    
                    .registerFunction(Input.ONKEYDOWN,'jump', function()
                        {
                            player.processEvent(new GameEvent("jump"));
                        })
                ;

                generate("part",[rightArmOptions])
                    .setAttribute('randomColor',false)
                    .setAttribute('drawColorR',1.2)
                    .setAttribute('drawColorG',0)
                    .setAttribute('drawColorB',0)
                    .setAttribute('drawColorA',1)
                ;
                generate("part",[bodyOptions])
                    .setAttribute('randomColor',false)
                    .setAttribute('drawColorR',1.2)
                    .setAttribute('drawColorG',0)
                    .setAttribute('drawColorB',0)
                    .setAttribute('drawColorA',1)
                ;
                generate("part",[leftArmOptions])
                    .setAttribute('randomColor',false)
                    .setAttribute('drawColorR',1.2)
                    .setAttribute('drawColorG',0)
                    .setAttribute('drawColorB',0)
                    .setAttribute('drawColorA',1)
                ;

                return player;
            });

        addGenerator("part",function(args:Array<Dynamic>)
            {
                return (new GameObject())
                    .setGraphic(Image(args[0].image))
                    .setScale(1/4)
                    .setState(states.get('restingBob'))
                    .setAttribute('restingPosition',args[0].restingPosition)
                    .setAttribute('bobHeight',args[0].bobHeight)
                    .setAttribute('bobSpeed',args[0].bobSpeed)
                    .setAttribute('followSpeed',args[0].followSpeed)
                    .addType(args[0].type)
                    .setCollider(args[0].collider)
                    .setZ(args[0].z)
                ;
            });


        addGenerator("groundTile",function(args:Array<Dynamic>)
            {
                return (new GameObject())
                    .setGraphic(Image("assets/groundtile.png"))
                    .setState(states.get('loopingBackground'))
                    .setAttribute('width',12)
                    .addType(blankType)
                    .setX(args[0])
                    .setY(sceneOptions.height/2 - 33)
                    .setZ(-10)
                ;
            });

        addGenerator("building",function(args:Array<Dynamic>)
            {
                return (new GameObject())
                    .setGraphic(Image(args[7]))
                    .setState(states.get('background'))
                    .addType(blankType)
                    .setScale(1/2)
                    .setX(args[0])
                    .setY(args[1])
                    .setZ(-110 - args[2])
                    .setAttribute('drawColorR',args[3])
                    .setAttribute('drawColorG',args[4])
                    .setAttribute('drawColorB',args[5])
                    .setAttribute('drawColorA',args[6])
                ;
            });

        addGenerator("skyBackground",function(args:Array<Dynamic>)
            {
                return (new GameObject())
                    .setGraphic(Image("assets/skybg.png"))
                    .setState(states.get('background'))
                    .setAttribute('width',800)
                    .addType(blankType)
                    .setX(args[0])
                    .setZ(-200)
                ;
            });

        addGenerator("soldier",function()
            {
                var pos = Math.random()*30;
                numSoldiers++;

                var side = 1;
                if(Math.random() > .5)
                {
                    side = -1;
                }
                return (new GameObject())
                    .setPosition(new Vec2(player.position.x + side*(sceneOptions.width/2 + 5 + Math.random()*100),sceneOptions.height/2 - 20 - pos))
                    .setGraphic(SpriteSheet("assets/soldier-runcycle.png", 16,14, [0,1,2,3],5, true))
                    .setState(states.get('soldierNormal'))
                    .addType(enemyType)
                    .setAttribute('shotCounter',0)
                    .setZ(-pos/100)
                ;
            });

        addGenerator("bullet",function()
            {
                return (new GameObject())
                    .setGraphic(Image("assets/bullet.png"))
                    .setZ(100)
                    .addType(enemyAttackType)
                    .setCollider(Circle(0,0,1))
                    .setState(states.get('bulletNormal'))
                ;
            });

        states.get('bulletNormal')
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.position.y < -sceneOptions.height/2 - 3 || obj.position.x < player.position.x - sceneOptions.width*3/2 || obj.position.x > player.position.x + sceneOptions.width*3/2)
                    {
                        delete(obj);
                    }
                })
        ;

        states.get('background')
            .setStart(function(obj:GameObject)
                {
                    obj.setAttribute('startPosition',obj.position);
                })
            .setUpdate(function(obj:GameObject)
                {
                    var startPosition:Vec2 = obj.getAttribute('startPosition');
                    obj.position = (camera.add(startPosition));
                })
        ;

        states.get('loopingBackground')
            .setUpdate(function(obj:GameObject)
                {
                    while(obj.position.x + obj.getAttribute('width')*3/2 < camera.x - sceneOptions.width/2)
                    {
                        obj.translateX(sceneOptions.width - (sceneOptions.width%obj.getAttribute('width')) + obj.getAttribute('width')*3);
                    }
                    while(obj.position.x > camera.x - obj.getAttribute('width')*3/2 - sceneOptions.width/2 + sceneOptions.width - (sceneOptions.width%obj.getAttribute('width')) + obj.getAttribute('width')*3)
                    {
                        obj.translateX(-(sceneOptions.width - (sceneOptions.width%obj.getAttribute('width')) + obj.getAttribute('width')*3));
                    }
                })
        ;

        states.get('playerVulnerable')
            .onEvent('hit',function(obj:GameObject,event:GameEvent)
                {
                    // trace('')
                    delete(event.collision.obj2);
                })
        ;

        states.get('playerHeadControl')
            .setUpdate(function(obj:GameObject)
                {
                    obj.setAngularVel((input.getAxis('y')*30 - obj.angle)/10);
                })
        ;

        states.get('playerNormalAir')
            .addParent(states.get('playerVulnerable'))
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.position.y > sceneOptions.height/2 - headOptions.height)
                    {
                        obj
                            // .setY(sceneOptions.height/2 - headOptions.height)
                            // .setVelocityY(0)
                            .setState(states.get('playerNormalGround'))
                        ;
                    }

                    obj.velocity.setxy(
                        input.getAxis('x') * 5,
                        obj.velocity.y + sceneOptions.gravity);

                    if(input.getAxis('x') < 0)
                    {
                        obj.flip = true;
                    }
                    if(input.getAxis('x') > 0)
                    {
                        obj.flip = false;
                    }
                })
            .addParent(states.get('playerHeadControl'))
        ;

        states.get('playerNormalGround')
            .addParent(states.get('playerVulnerable'))
            .setUpdate(function(obj:GameObject)
                {
                    // obj.angle += .2;
                    obj.velocity.setxy(
                        input.getAxis('x') * 5,
                        ((sceneOptions.height/2 - headOptions.height) - obj.position.y)/10);
                    if(input.getAxis('x') < 0)
                    {
                        obj.flip = true;
                    }
                    if(input.getAxis('x') > 0)
                    {
                        obj.flip = false;
                    }
                })
            .addParent(states.get('playerHeadControl'))
            .addTransition(states.get('playerJump'),'jump')
        ;

        states.get('playerJump')
            .setStart(function(obj:GameObject)
                {
                    obj
                        .setY(sceneOptions.height/2 - headOptions.height - 1)
                        .setVelocityY(headOptions.jumpStrength)
                        .setState(states.get('playerNormalAir'))
                    ;
                })
        ;

        states.get('restingBob')
            .addParent(states.get('playerVulnerable'))
            .setUpdate(function(obj:GameObject)
                {
                    var flip = 1;
                    if(player.flip)
                    {
                        obj.flip = true;
                        flip = -1;
                    }
                    else
                    {
                        obj.flip = false;
                    }

                    var restingPosition:Vec2 = obj.getAttribute('restingPosition');
                    var bobSpeed:Float = obj.getAttribute('bobSpeed');
                    var bobHeight:Float = obj.getAttribute('bobHeight');
                    var followSpeed:Float = obj.getAttribute('followSpeed');

                    var targetPosition = player.position.copy();
                    targetPosition.x += flip*(restingPosition.x);
                    targetPosition.y += (restingPosition.y + Math.sin(bobCounter*bobSpeed)*bobHeight);
                    
                    var velocity:Vec2 = targetPosition.sub(obj.position);

                    if(velocity.length != 0)
                    {
                        velocity.length *= followSpeed;
                    }

                    obj.setVelocity(velocity);

                })
        ;

        states.get('soldierScreen')
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.position.x < player.position.x - sceneOptions.width/2 - 110)
                    {
                        delete(obj);
                        numSoldiers -= 1;
                    }
                    if(obj.position.x > player.position.x + sceneOptions.width/2 + 110)
                    {
                        delete(obj);
                        numSoldiers -= 1;
                    }
                    obj.setAttribute('shotCounter',obj.getAttribute('shotCounter') - 1);
                })
        ;

        var shootFunc = function(obj:GameObject){
                    if(obj.getAttribute('shotCounter') <= 0)
                    {
                        obj.setAttribute('shotCounter',200);
                        generate('bullet')
                            .setVelocity(player.position.sub(obj.position).add(new Vec2(0,Math.random()*100 - 50)).unit().mul(3))
                            .setPosition(obj.position)
                        ;
                    }
                };

        states.get('soldierNormal')
            .addParent(states.get('soldierScreen'))
            .setStart(function(obj:GameObject)
                {
                    obj.setAttribute('distanceDifference',Math.random()*Math.random()*150);
                })
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.position.x < player.position.x)
                    {
                        obj.flip = true;
                        if(obj.position.x < player.position.x - 100 - obj.getAttribute('distanceDifference'))
                        {
                            obj.setVelocityX(1);
                        }
                        else if(Math.abs(player.position.x - 100 - obj.getAttribute('distanceDifference') - obj.position.x) <= 1)
                        {
                            obj
                                .setX(player.position.x - 100 - obj.getAttribute('distanceDifference'))
                                .setState(states.get('soldierStand'))
                            ;
                        }
                        else
                        {
                            obj.setVelocityX(-1);
                            shootFunc(obj);
                        }
                    }
                    else
                    {
                        obj.flip = false;
                        if(obj.position.x > player.position.x + 100 + obj.getAttribute('distanceDifference'))
                        {
                            obj.setVelocityX(-1);
                        }
                        else if(Math.abs(obj.position.x - player.position.x - 100 - obj.getAttribute('distanceDifference')) <= 1)
                        {
                            obj
                                .setX(player.position.x + 100 + obj.getAttribute('distanceDifference'))
                                .setState(states.get('soldierStand'))
                            ;
                        }
                        else
                        {
                            obj.setVelocityX(1);
                            shootFunc(obj);
                        }
                    }
                })
        ;

        states.get('soldierStand')
            .addParent(states.get('soldierScreen'))
            .setStart(function(obj:GameObject)
                {
                    obj
                        .setVelocityX(0)
                        .setGraphic(Image('assets/soldier-stand.png'))
                    ;
                })
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.getAttribute('shotCounter') <= 0)
                    {
                        obj.setAttribute('shotCounter',200);
                        generate('bullet')
                            .setVelocity(player.position.sub(obj.position).add(new Vec2(0,Math.random()*100 - 20)).unit().mul(3))
                            .setPosition(obj.position)
                        ;
                    }
                    if(!(obj.position.x == player.position.x - 100 - obj.getAttribute('distanceDifference') || obj.position.x == player.position.x + 100 + obj.getAttribute('distanceDifference')))
                    {
                        obj.setState(states.get('soldierNormal'));
                    }
                })
        ;


        addInteractionStartListener('hit',playerType,enemyAttackType);
    }


    public override function onStart()
    {
        generate('player');

        generate('skyBackground',[-sceneOptions.width/2]);
        generate('skyBackground',[sceneOptions.width/2]);
        for(i in 0...(Math.floor(sceneOptions.width/12) + 3))
        {
            generate('groundTile',[i*12 + 6 - sceneOptions.width/2]);
        }

        for(i in 0...8)
        {
            generate('building',[Math.random()*sceneOptions.width - sceneOptions.width/2, sceneOptions.height/2 - 70 + Math.random()*50,0, .6,.6,.6,1, "assets/building" + (Math.floor(Math.random()*4) + 1) + ".png"]);
        }
        for(i in 0...8)
        {
            generate('building',[Math.random()*sceneOptions.width - sceneOptions.width/2, sceneOptions.height/2 - 100 + Math.random()*50,1, .4,.4,.4,1, "assets/building" + (Math.floor(Math.random()*4) + 1) + ".png"]);
        }
        for(i in 0...8)
        {
            generate('building',[Math.random()*sceneOptions.width - sceneOptions.width/2, sceneOptions.height/2 - 120 + Math.random()*50,2, .3,.3,.3,1, "assets/building" + (Math.floor(Math.random()*4) + 1) + ".png"]);
        }
    }

    public override function onUpdate()
    {
        bobCounter += .01;
        if(numSoldiers < maxSoldiers)
        {
            generate('soldier');
            generate('soldier');
            generate('soldier');
            generate('soldier');
        }

        camera.x += (player.position.x - camera.x)/2;
    }
}