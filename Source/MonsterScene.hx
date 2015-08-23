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
    var leftArm:GameObject;
    var rightArm:GameObject;
    var body:GameObject;
       
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
        var playerAttackType = new ObjectType();


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
            restingPosition: new Vec2(30,60),
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
            z: -.2
        };

        input
            .registerAxis(KeyboardKeys.LEFT,KeyboardKeys.RIGHT,'x')
            .registerAxis(KeyboardKeys.UP,KeyboardKeys.DOWN,'y')
            .registerInput(KeyboardKeys.Z,'jump')
            .registerInput(KeyboardKeys.X,'attack')
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
                    .registerFunction(Input.ONKEYDOWN,'attack', function()
                        {
                            player.processEvent(new GameEvent("attack"));
                        })
                ;

                rightArm = generate("part",[rightArmOptions])
                    .setAttribute('randomColor',false)
                    .setAttribute('drawColorR',1.2)
                    .setAttribute('drawColorG',0)
                    .setAttribute('drawColorB',0)
                    .setAttribute('drawColorA',1)
                ;
                body = generate("part",[bodyOptions])
                    .setAttribute('randomColor',false)
                    .setAttribute('drawColorR',1.2)
                    .setAttribute('drawColorG',0)
                    .setAttribute('drawColorB',0)
                    .setAttribute('drawColorA',1)
                ;
                leftArm = generate("part",[leftArmOptions])
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
                    .setCollider(Circle(0,0,1))
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

        addGenerator('playerAttackHitbox',function(args:Array<Dynamic>)
            {
                return (new GameObject())
                    .setAttribute('followObject',args[0])
                    .addType(playerAttackType)
                    .setState(states.get('playerAttackHitbox'))
                ;
            });

        states.get('playerAttackHitbox')
            .setUpdate(function(obj:GameObject)
                {
                    obj.setPosition(obj.getAttribute('followObject').position);
                })
        ;

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
                    var flip = 1;
                    if(obj.flip)
                    {
                        flip = -1;
                    }
                    obj.setAngularVel((input.getAxis('y')*30*flip - obj.angle)/10);
                })
        ;

        states.get('playerNormal')
            .setUpdate(function(obj:GameObject)
                {
                    obj.setVelocityX(input.getAxis('x') * 5);
                    if(input.getAxis('x') < 0)
                    {
                        obj.flip = true;
                    }
                    if(input.getAxis('x') > 0)
                    {
                        obj.flip = false;
                    }
                    bobCounter += .01;    
                })
        ;

        states.get('playerNormalAir')
            .addParent(states.get('playerVulnerable'))
            .addParent(states.get('playerNormal'))
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

                    obj.setVelocityY(obj.velocity.y + sceneOptions.gravity);

                })
            .addParent(states.get('playerHeadControl'))
        ;

        states.get('playerNormalGround')
            .addParent(states.get('playerNormal'))
            .addParent(states.get('playerVulnerable'))
            .setUpdate(function(obj:GameObject)
                {
                    obj.setVelocityY(((sceneOptions.height/2 - headOptions.height) - obj.position.y)/10);
                })
            .addParent(states.get('playerHeadControl'))
            .addTransition(states.get('playerJump'),'jump')
            .addTransition(states.get('playerAttackGround'),'attack')
        ;

        states.get('playerAttackGround')
            .setStart(function(obj)
                {
                    var leftArmEvent = new GameEvent('attack');
                    leftArmEvent
                        .setAttribute('move',true)
                        .setAttribute('position',new Vec2(100,30 + 60*input.getAxis('y')))
                        .setAttribute('vel',15.0)
                        .setAttribute('duration',20)
                        .setAttribute('type',playerAttackType)
                    ;
                    leftArm.processEvent(leftArmEvent);

                    var otherEvent = new GameEvent('attack');
                    otherEvent
                        .setAttribute('move',false)
                        .setAttribute('duration',20)
                        .setAttribute('type',blankType)
                    ;

                    obj.setAttribute('timer',20);
                        obj.setVelocity(new Vec2(0,0));
                    // rightArm.processEvent(otherEvent);
                    // body.processEvent(otherEvent);
                })
            .setUpdate(function(obj)
                {
                    obj.setAttribute('timer',obj.getAttribute('timer') - 1);
                    if(obj.getAttribute('timer') <= 0)
                    {
                        obj.setState(states.get('playerNormalGround'));
                    }
                })
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
            .setStart(function(obj:GameObject)
                {
                    obj.addType(blankType);
                })
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
            .addTransition(states.get('partAttack'),'attack')
        ;

        states.get('partAttack')
            .setStart(function(obj:GameObject,event:GameEvent)
                {
                    obj.setAttribute('timer',event.getAttribute('duration'));
                    obj.setAttribute('move',false);
                    if(event.getAttribute('move'))
                    {
                        obj.setAttribute('move',true);

                        obj.setAttribute('targetPosition',event.getAttribute('position'));
                        obj.setAttribute('velocity',event.getAttribute('vel'));
                    }
                    else
                    {
                        obj.setVelocity(new Vec2(0,0));
                    }
                    if(event.getAttribute('type') == playerAttackType)
                    {
                        obj.setAttribute('hasHitbox',true);
                        obj.setAttribute('hitbox',generate('playerAttackHitbox',[obj])
                                                    .setCollider(Circle(0,0,20)));
                    }
                    // obj.addType(event.getAttribute('type'));
                })
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.getAttribute('move'))
                    {
                        var flip = 1;
                        if(obj.flip)
                        {
                            flip = -1;
                        }

                        var targetPosition:Vec2 = obj.getAttribute('targetPosition').copy();
                        targetPosition.x *= flip;
                        targetPosition.addeq(player.position);
                        if(Vec2.distance(targetPosition,obj.position) < obj.getAttribute('velocity'))
                        {
                            obj.setPosition(targetPosition);
                            obj.setVelocity(new Vec2(0,0));
                        }
                        else
                        {
                            var vel = targetPosition.sub(obj.position).unit().mul(obj.getAttribute('velocity'));
                            

                            obj.setVelocity(vel);
                        }
                    }

                    obj.setAttribute('timer',obj.getAttribute('timer') - 1);
                    if(obj.getAttribute('timer') <= 0)
                    {
                        obj.setState(states.get('restingBob'));
                    }

                })
            .setEnd(function(obj:GameObject)
                {
                    if(obj.getAttribute('hasHitbox'))
                    {
                        var hitbox:GameObject = obj.getAttribute('hitbox');
                        delete(hitbox);
                        obj.setAttribute('hitbox',null);
                    }
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
                    if(obj.position.y > sceneOptions.height/2 + 10)
                    {
                        delete(obj);
                        // numSoldiers -= 1;
                    }
                    obj.setAttribute('shotCounter',obj.getAttribute('shotCounter') - 1);
                })
            .addTransition(states.get('soldierHit'),'hit')
        ;

        states.get('soldierHitGravity')
            .setUpdate(function(obj:GameObject)
                {
                    obj.setVelocityY(obj.velocity.y += sceneOptions.gravity);
                    if(obj.velocity.x < 0)
                    {
                        obj.flip = true;
                    }
                    if(obj.velocity.y >= 0)
                    {
                        obj.setGraphic(SpriteSheet("assets/soldier-hit-down.png", 14,15, [0,1],1, true));
                    }
                })
        ;

        states.get('soldierHit')
            .addParent(states.get('soldierHitGravity'))
            .setStart(function(obj:GameObject)
                {
                    if(obj.getAttribute('removed') == null)
                    {
                        obj.setAttribute('removed',true);
                        numSoldiers -=1;
                    }
                    obj.setGraphic(SpriteSheet("assets/soldier-hit-up.png", 14,15, [0,1],1, true));
                    obj.setVelocityY(-10);
                    obj.setAttribute('timer',20);
                })
            .setUpdate(function(obj:GameObject)
                {
                    obj.setAttribute('timer',obj.getAttribute('timer') - 1);
                    if(obj.getAttribute('timer') <= 0)
                    {
                        obj.setState(states.get('soldierFlying'));
                    }
                })
        ;

        states.get('soldierFlying')
            .addParent(states.get('soldierHitGravity'))
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.position.y + obj.velocity.y >= sceneOptions.height/2 - 20 + obj.z*100)
                    {
                        // obj.position.y = sceneOptions.height/2 - 20 + obj.z*100;
                        obj.setState(states.get('soldierGround'));
                    }
                })
            .addTransition(states.get('soldierHit'),'hit')
        ;

        states.get('soldierGround')
            .setStart(function(obj:GameObject)
                {
                    obj.setAttribute('timer',100)
                        .setAttribute('drawColorR',1)
                        .setAttribute('drawColorG',1)
                        .setAttribute('drawColorB',1)
                        .setAttribute('drawColorA',1)
                    ;
                    obj.setGraphic(Image("assets/soldier-dead.png"));
                    obj.setVelocity(new Vec2(0,0));
                })
            .setUpdate(function(obj:GameObject)
                {
                    obj
                        .setAttribute('timer',obj.getAttribute('timer') - 1)
                        // .setAttribute('drawColorA',obj.getAttribute('timer')/100)
                        .setAttribute('drawColorR',obj.getAttribute('timer')/100)
                        .setAttribute('drawColorG',obj.getAttribute('timer')/100)
                        .setAttribute('drawColorB',obj.getAttribute('timer')/100)
                    ;
                    if(obj.getAttribute('timer') <= 0)
                    {
                        delete(obj);
                    }
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
                    obj
                        .setAttribute('distanceDifference',Math.random()*Math.random()*150)
                        .setGraphic(SpriteSheet("assets/soldier-runcycle.png", 16,14, [0,1,2,3],5, true))
                    ;
                })
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.position.x < player.position.x + obj.z*130)
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
                        obj.setState(states.get('soldierNormal'));
                    }
                    if(!(obj.position.x == player.position.x - 100 - obj.getAttribute('distanceDifference') || obj.position.x == player.position.x + 100 + obj.getAttribute('distanceDifference')))
                    {
                        obj.setState(states.get('soldierNormal'));
                    }
                })
        ;


        addInteractionStartListener('hit',playerType,enemyAttackType);
        addInteractionStartListener('hit',enemyType,playerAttackType);
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
        if(numSoldiers < maxSoldiers)
        {
            generate('soldier');
            generate('soldier');
            generate('soldier');
            generate('soldier');
        }

        camera.x += (player.position.x - camera.x)/3.5;
        // camera.y += (player.position.y - camera.y - 60)/12;
    }
}