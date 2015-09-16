package ;


// import openfl.display.Sprite;
// import gtoolbox.KeyboardKeys;
import fluidity.*;

import fluidity.input.KeyboardKeys;
import fluidity.Input;

import fluidity.utils.Vec2;
import fluidity.utils.StringBin;

class MonsterScene extends GameScene {

    var bobCounter = 0.0;

    var sceneOptions = {
        width: 400,
        height: 300,
        gravity: .3
    }

    var numSoldiers:Int = 0;
    var maxSoldiers:Int = 100;
    var player:GameObject;
    var leftArm:GameObject;
    var rightArm:GameObject;
    var body:GameObject;

    var health:Float = 1;
    var damagePerHit:Float = .003;
    var healPerHit:Float = .001;

    var stopFollow = false;

    var zoomCounter = 0;

    public var finished:Bool = false;
    public var helpSpawned:Bool = false;

    public static var score:Int = 0;

    public var instructionsShown:Bool = false;
    public var scrolledDown:Bool = false;

    var followX = 0.0;
    var followY = 0.0;

    var kbInfo = {vel:0,angle:0,dmg:.1,red:false};
       
    public function new () {

        super (new Vec2(0,0));

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
            z: 100
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

        addGenerator("name",function()
            {
                return (new GameObject())
                    .setGraphic(Image('assets/madeby.png'))
                    .setPosition(new Vec2(-120,140))
                    .setState(states.get('blank'))
                    .addType(blankType)
                    .setZ(-100)
                ;
            });

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

                    // player.processEvent(new GameEvent("jump"));

                input
                    .registerObjectOnKeyDown("jump",player,"jump")
                    .registerObjectOnKeyDown("attack",player,"attack")
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
                var jesus = (new GameObject());
                    jesus.setGraphic(Image(args[0].image));
                    jesus.setScale(1/4);
                    jesus.setState(states.get('restingBob'));
                    jesus.setAttribute('restingPosition',args[0].restingPosition);
                    jesus.setAttribute('bobHeight',args[0].bobHeight);
                    jesus.setAttribute('bobSpeed',args[0].bobSpeed);
                    jesus.setAttribute('followSpeed',args[0].followSpeed);

                jesus
                    .addType(args[0].type)
                ;

                return jesus
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

        addGenerator("instructionSign",function()
            {
                instructionsShown = true;
                return (new GameObject())
                    .setGraphic(Image("assets/instructions.png"))
                    .setState(states.get('instructionSign'))
                    .addType(blankType)
                    .setPosition(new Vec2(100,0))
                    .setZ(-100)
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

        addGenerator('help',function()
            {
                helpSpawned = true;
                return (new GameObject())
                    .setGraphic(Image("assets/help" + Math.floor(Math.random()*5) + ".png"))
                    .addType(blankType)
                    .setState(states.get('helpState'))
                    .setPosition(new Vec2(camera.x,camera.y - 400))
                    .setZ(100)
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

        states.get('helpState')
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.position.y < camera.y)
                    {
                        obj.translateY(10);
                    }
                    else
                    {
                        scrolledDown = true;
                    }
                })
        ;

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
                    health -= damagePerHit;
                    if(health <= 0)
                    {
                        player.setState(states.get('partDead'));
                        leftArm.setState(states.get('partDead'));
                        rightArm.setState(states.get('partDead'));
                        body.setState(states.get('partDead'));
                        stopFollow = true;
                    }
                    delete(event.collision.obj2);
                })
        ;

        states.get('playerBlue')
            .setUpdate(function(obj:GameObject)
                {
                    player
                        .setAttribute('drawColorB',health*1)
                        .setAttribute('drawColorR',0)
                        .setAttribute('drawColorG',0)
                        .setAttribute('drawColorA',1)
                    ;
                    leftArm
                        .setAttribute('drawColorB',health*1)
                        .setAttribute('drawColorR',0)
                        .setAttribute('drawColorG',0)
                        .setAttribute('drawColorA',1)
                    ;
                    rightArm
                        .setAttribute('drawColorB',health*1)
                        .setAttribute('drawColorR',0)
                        .setAttribute('drawColorG',0)
                        .setAttribute('drawColorA',1)
                    ;
                    body
                        .setAttribute('drawColorB',health*1)
                        .setAttribute('drawColorR',0)
                        .setAttribute('drawColorG',0)
                        .setAttribute('drawColorA',1)
                    ;
                })
        ;

        states.get('playerRed')
            .setUpdate(function(obj:GameObject)
                {
                    if(kbInfo.red)
                    {
                        player
                            .setAttribute('drawColorR',health*1)
                            .setAttribute('drawColorB',0)
                            .setAttribute('drawColorG',0)
                            .setAttribute('drawColorA',1)
                        ;
                        leftArm
                            .setAttribute('drawColorR',health*1)
                            .setAttribute('drawColorB',0)
                            .setAttribute('drawColorG',0)
                            .setAttribute('drawColorA',1)
                        ;
                        rightArm
                            .setAttribute('drawColorR',health*1)
                            .setAttribute('drawColorB',0)
                            .setAttribute('drawColorG',0)
                            .setAttribute('drawColorA',1)
                        ;
                        body
                            .setAttribute('drawColorR',health*1)
                            .setAttribute('drawColorB',0)
                            .setAttribute('drawColorG',0)
                            .setAttribute('drawColorA',1)
                        ;
                    }
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
                    obj.setAngle((input.getAxis('y')*30*flip - obj.angle)/10 + obj.angle);
                })
            // .setStop(function(obj:GameObject)
            //     {
            //         obj.setAngularVel(0);
            //     })
        ;

        states.get('playerNormal')
            .setUpdate(function(obj:GameObject)
                {
                    obj.setVelocityX(input.getAxis('x') * 4);
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
            .addParent(states.get('playerBlue'))
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
            .addTransition(states.get('playerAttackAir'),'attack')
        ;

        states.get('playerNormalGround')
            .addParent(states.get('playerNormal'))
            .addParent(states.get('playerBlue'))
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
            .addParent(states.get('playerRed'))
            .setStart(function(obj)
                {
                    var flip = 1;
                    if(obj.flip)
                    {
                        flip = -1;
                    }
                    if(input.getAxis('y') > 0)
                    {
                        var leftArmEvent = new GameEvent('attack');
                        leftArmEvent
                            .setAttribute('move',true)
                            .setAttribute('chargePosition',new Vec2(120,100))
                            .setAttribute('position',new Vec2(80,50))
                            .setAttribute('vel',15.0)
                            .setAttribute('angle',(-10))
                            .setAttribute('chargeDuration',5)
                            .setAttribute('duration',5)
                            .setAttribute('type',playerAttackType)
                        ;
                        obj.setAttribute('timer',10);
                        leftArm.processEvent(leftArmEvent);
                        kbInfo = {angle:-90,vel:10,dmg:.1,red:false};
                    }
                    else if(input.getAxis('y') < 0)
                    {
                        var leftArmEvent = new GameEvent('attack');
                        leftArmEvent
                            .setAttribute('move',true)
                            .setAttribute('chargePosition',new Vec2(80,-20))
                            .setAttribute('position',new Vec2(20,-80))
                            .setAttribute('vel',15.0)
                            .setAttribute('angle',(45*input.getAxis('y') - 10))
                            .setAttribute('chargeDuration',5)
                            .setAttribute('duration',10)
                            .setAttribute('type',playerAttackType)
                        ;
                        obj.setAttribute('timer',15);
                        leftArm.processEvent(leftArmEvent);
                        kbInfo = {angle:-90 - 20*flip,vel:10,dmg:.1,red:false};
                    }
                    else if(input.getAxis('x') == 0)
                    {
                        var leftArmEvent = new GameEvent('attack');
                        leftArmEvent
                            .setAttribute('move',true)
                            .setAttribute('chargePosition',new Vec2(40,-40))
                            .setAttribute('position',new Vec2(50,50))
                            .setAttribute('vel',15.0)
                            .setAttribute('angle',(-30))
                            .setAttribute('chargeDuration',5)
                            .setAttribute('duration',10)
                            .setAttribute('type',playerAttackType)
                        ;
                        obj.setAttribute('timer',15);
                        rightArm.processEvent(leftArmEvent);
                        kbInfo = {angle:90 - 20*flip,vel:7,dmg:.1,red:false};
                    }
                    else
                    {
                        var leftArmEvent = new GameEvent('attack');
                        leftArmEvent
                            .setAttribute('move',true)
                            .setAttribute('chargePosition',new Vec2(-10,30))
                            .setAttribute('position',new Vec2(100,30))
                            .setAttribute('vel',15.0)
                            .setAttribute('angle',(-10))
                            .setAttribute('chargeDuration',5)
                            .setAttribute('duration',20)
                            .setAttribute('type',playerAttackType)
                        ;
                        obj.setAttribute('timer',25);
                        leftArm.processEvent(leftArmEvent);
                        kbInfo = {angle:-90 + 70*flip,vel:10,dmg:1,red:true};
                    }

                    obj.setVelocity(new Vec2(0,0));
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

        states.get('playerAttackAir')
            .addParent(states.get('playerRed'))
            .setStart(function(obj)
                {
                    var flip = 1;
                    if(obj.flip)
                    {
                        flip = -1;
                    }
                    var rightArmEvent = new GameEvent('attack');

                    if(input.getAxis('y') < 0)
                    {
                        rightArmEvent
                            .setAttribute('move',true)
                            .setAttribute('chargePosition',new Vec2(50,10))
                            .setAttribute('position',new Vec2(-50,-90))
                            .setAttribute('vel',30.0)
                            .setAttribute('angle',-90)
                            .setAttribute('chargeDuration',10)
                            .setAttribute('duration',10)
                            .setAttribute('type',playerAttackType)
                        ;
                        kbInfo = {angle:-90 - 20*flip,vel:8,dmg:.1,red:false};
                        obj.setAttribute('timer',20);
                        rightArm.processEvent(rightArmEvent);
                    }
                    else if(input.getAxis('y') > 0)
                    {
                        rightArmEvent
                            .setAttribute('move',true)
                            .setAttribute('chargePosition',new Vec2(0,30))
                            .setAttribute('position',new Vec2(10,150))
                            .setAttribute('vel',30.0)
                            .setAttribute('angle',(0))
                            .setAttribute('chargeDuration',20)
                            .setAttribute('duration',10)
                            .setAttribute('type',playerAttackType)
                        ;
                        kbInfo = {angle:90 - 5*flip,vel:20,dmg:1,red:true};
                        obj.setAttribute('timer',30);
                        body.processEvent(rightArmEvent);
                    }
                    else if(input.getAxis('x') == 0)
                    {
                        rightArmEvent
                            .setAttribute('move',true)
                            .setAttribute('chargePosition',new Vec2(0,80))
                            .setAttribute('position',new Vec2(50,-50))
                            .setAttribute('vel',30.0)
                            .setAttribute('angle',(-20))
                            .setAttribute('chargeDuration',3)
                            .setAttribute('duration',7)
                            .setAttribute('type',playerAttackType)
                        ;
                        kbInfo = {angle:-90 + 18*flip,vel:7,dmg:.01,red:false};
                        obj.setAttribute('timer',10);
                        rightArm.processEvent(rightArmEvent);
                    }
                    else
                    {
                        rightArmEvent
                            .setAttribute('move',true)
                            .setAttribute('chargePosition',new Vec2(-5,40))
                            .setAttribute('position',new Vec2(100,30))
                            .setAttribute('vel',35.0)
                            .setAttribute('angle',(-90))
                            .setAttribute('chargeDuration',15)
                            .setAttribute('duration',15)
                            .setAttribute('type',playerAttackType)
                        ;
                        kbInfo = {angle:-90 + 90*flip,vel:20,dmg:.6,red:true};
                        obj.setAttribute('timer',30);
                        body.processEvent(rightArmEvent);
                    }

                    // if(input.getAxis('x') == 0)
                    // {
                    // }
                    // else
                    // {                               aorisetnaoiresntoairesntoarufntoayuwfhtoyauwhftoyauwhftoyauwnfotyauwnft
                    //     rightArmEvent
                    //         .setAttribute('position',new Vec2(130,30))
                    //         .setAttribute('vel',15.0)
                    //         .setAttribute('duration',10)
                    //         .setAttribute('kbAngle',90)
                    //     ;
                    //     var chargeEvent = new GameEvent('charge')
                    //     rightArm.setState('chargeAttack',);
                    // }

                        obj.setVelocity(new Vec2(0,0));
                })
            .setUpdate(function(obj)
                {
                    obj.setAttribute('timer',obj.getAttribute('timer') - 1);
                    if(obj.getAttribute('timer') <= 0)
                    {
                        obj.setState(states.get('playerNormalAir'));
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
                    if(body != null)
                    {
                        body.addType(playerType);
                    }
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
                    obj.setAngle((-obj.angle)/7 + obj.angle);

                })
            .addTransition(states.get('partCharge'),'attack')
        ;

        states.get('partDead')
            .setStart(function(obj:GameObject)
                {
                    obj.setAttribute('targetY',sceneOptions.height/2 - 20 - 50*Math.random());
                })
            .setUpdate(function(obj:GameObject)
                {
                    obj.setVelocityX(obj.velocity.x*.9);
                    if(obj.getAttribute('targetY') - obj.position.y <= obj.velocity.y)
                    {
                        obj.position.addeq(obj.velocity);
                        obj.setVelocity(new Vec2(0,0));
                    }
                    else
                    {
                        obj.setVelocityY(obj.velocity.y + sceneOptions.gravity);
                    }
                })
        ;

        states.get('partCharge')
            .setStart(function(obj:GameObject,event:GameEvent)
                {
                    obj.setAttribute('timer',event.getAttribute('chargeDuration'));
                    obj.setAttribute('attackEvent',event);
                })
            .setUpdate(function(obj:GameObject)
                {
                    var flip = 1;
                    var targetPosition:Vec2 = obj.getAttribute('attackEvent').getAttribute('chargePosition');
                    targetPosition = targetPosition.copy();
                    if(obj.flip)
                    {
                        targetPosition.x *= -1;
                        flip = -1;
                    }
                    targetPosition.x += player.position.x;
                    targetPosition.y += player.position.y;
                    
                    var velocity:Vec2 = targetPosition.sub(obj.position);

                    if(velocity.length != 0)
                    {
                        velocity.length = velocity.length/4;
                    }

                    obj.setVelocity(velocity);
                    obj.setAttribute('timer',obj.getAttribute('timer') - 1);
                    if(obj.getAttribute('timer') <= 0)
                    {
                        var ev:GameEvent = obj.getAttribute('attackEvent');
                        obj.processEvent(ev);
                    }
                    obj.setAngle((obj.getAttribute('attackEvent').getAttribute('angle')*flip - obj.angle)/3 + obj.angle);
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
                        obj
                        .setAttribute('hitbox',generate('playerAttackHitbox',[obj])
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
            .setStart(function(obj:GameObject,e:GameEvent)
                {
                    if(obj.getAttribute('removed') == null)
                    {
                        obj.setAttribute('removed',true);
                        numSoldiers -=1;
                        score += 1;
                        obj.setAttribute('numHits',0);
                    }
                    obj.setAttribute('numHits',Math.min(obj.getAttribute('numHits') + 1,5));
                    obj
                        .setAttribute('drawColorR',1)
                        .setAttribute('drawColorG',1 - obj.getAttribute('numHits')/5)
                        .setAttribute('drawColorB',1 - obj.getAttribute('numHits')/5)
                        .setAttribute('drawColorA',1)
                    ;
                    health += healPerHit*obj.getAttribute('numHits')*obj.getAttribute('numHits') * kbInfo.dmg;
                    obj.setGraphic(SpriteSheet("assets/soldier-hit-up.png", 14,15, [0,1],1, true));
                    obj.setVelocity(
                        Vec2.fromPolar(
                            kbInfo.vel,
                            kbInfo.angle/180*Math.PI
                        ));
                    // obj.setVelocityY(-10);
                    obj.setAttribute('timer',20);

                    zoomCounter = 10;
                    followX = obj.position.x;
                    followY = obj.position.y;
                })
            .setUpdate(function(obj:GameObject)
                {
                    obj.setAttribute('timer',obj.getAttribute('timer') - 1);
                    if(obj.getAttribute('timer') <= 0)
                    {
                        obj.setState(states.get('soldierFlying'));
                    }

                    if(obj.position.y + obj.velocity.y >= sceneOptions.height/2 - 20 + obj.z*100)
                    {
                        // obj.position.y = sceneOptions.height/2 - 20 + obj.z*100;
                        obj.position.y =  sceneOptions.height/2 - 20 + obj.z*100 - 5;
                        obj.velocity.y = -(Math.min(obj.velocity.y*.8,13));
                    }
                    // finished = true;
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
                        // .setAttribute('drawColorR',1)
                        // .setAttribute('drawColorG',1)
                        // .setAttribute('drawColorB',1)
                        // .setAttribute('drawColorA',1)
                    ;
                    obj.setGraphic(Image("assets/soldier-dead.png"));
                    obj.setVelocity(new Vec2(0,0));
                })
            .setUpdate(function(obj:GameObject)
                {
                    obj
                        .setAttribute('timer',obj.getAttribute('timer') - 1)
                        .setAttribute('drawColorA',obj.getAttribute('timer')/100)
                        // .setAttribute('drawColorR',obj.getAttribute('timer')/100)
                        // .setAttribute('drawColorG',obj.getAttribute('timer')/100)
                        // .setAttribute('drawColorB',obj.getAttribute('timer')/100)
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

        numSoldiers = 0;
        // maxSoldiers = 200;

        health = 1;
        damagePerHit = .003;
        healPerHit = .001;

        stopFollow = false;

        zoomCounter = 0;

        finished = false;
        helpSpawned = false;

        score = 0;

        instructionsShown = false;
        scrolledDown = false;

        followX = 0.0;
        followY = 0.0;

        input
            .registerAxis(KeyboardKeys.LEFT,KeyboardKeys.RIGHT,'x')
            .registerAxis(KeyboardKeys.UP,KeyboardKeys.DOWN,'y')
            .registerAxis(KeyboardKeys.A,KeyboardKeys.D,'x')
            .registerAxis(KeyboardKeys.W,KeyboardKeys.S,'y')
            .registerAxis(KeyboardKeys.F,KeyboardKeys.G,'x')
            .registerAxis(KeyboardKeys.NUMBER_4,KeyboardKeys.P,'y')
            .registerInput(KeyboardKeys.Z,'jump')
            .registerInput(KeyboardKeys.X,'attack')
            .registerInput(KeyboardKeys.K,'jump')
            .registerInput(KeyboardKeys.J,'attack')
            .registerInput(KeyboardKeys.E,'jump')
            .registerInput(KeyboardKeys.N,'attack')
        ;
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
        if(!instructionsShown)
        {
            generate('instructionSign');
        }

        input                    
            .registerFunctionOnKeyDown('jump', function()
                {
                    if(stopFollow && scrolledDown)
                    {
                        finished = true;
                    }
                })             
            .registerFunctionOnKeyDown('attack', function()
                {
                    if(stopFollow && scrolledDown)
                    {
                        finished = true;
                    }
                })
        ;

    }

    public override function onReset()
    {
        body = null;
        leftArm = null;
        rightArm = null;
        player = null;
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

        if(!stopFollow)
        {
            if(zoomCounter > 0 && kbInfo.red)
            {
                cameraScale += (2 - cameraScale)/8;
                zoomCounter--;
                camera.x += (followX - camera.x)/3.5;
                camera.y += ((followY)/2 - camera.y)/3.5;
            }
            else
            {
                cameraScale = 1;
                zoomCounter = 0;
                camera.x += (player.position.x - camera.x)/3.5;
                camera.y += ((player.position.y)/2 - camera.y)/3.5;
            }
        }
        else
        {
            if(!helpSpawned)
            {
                generate('help');
            }
        }

        if(finished)
        {
            GameLayer.sendEventToLayers(new GameEvent('monsterFinished'));
        }
    }
}