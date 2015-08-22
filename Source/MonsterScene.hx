package ;


// import openfl.display.Sprite;
// import gtoolbox.KeyboardKeys;
import nape.callbacks.*;

import fluidity2.*;

import nape.geom.Vec2;

import evsm.FState;

import gtoolbox.KeyboardKeys;


class MonsterScene extends GameScene {
       
    public function new () {

        super (new Vec2(0,0));

        var states = new StringBin<FState<GameObject,GameEvent>>(function(name:String)
            {
                return new FState<GameObject,GameEvent>(name);
            });

        var headOptions = {
            image: "assets/head.png",
            startPosition: new Vec2(100,200)
        };

        var rightArmOptions = {
            image: "assets/rightarm.png",
            restingPosition: new Vec2(-40,70),
            bobHeight:10,
            bobSpeed: 2,
            followSpeed: 1/6
        };

        var leftArmOptions = {
            image: "assets/leftarm.png",
            restingPosition: new Vec2(30,70),
            bobHeight:10,
            bobSpeed: 3,
            followSpeed: 1/6
        };

        var bodyOptions = {
            image: "assets/body.png",
            restingPosition: new Vec2(-10,60),
            bobHeight:10,
            bobSpeed: 4,
            followSpeed: 1/2
        };

        input
            .registerAxis(KeyboardKeys.LEFT,KeyboardKeys.RIGHT,'x')
            .registerAxis(KeyboardKeys.UP,KeyboardKeys.DOWN,'y')
        ;

        var playerType = new ObjectType();

        addGenerator("player",function()
            {
                var head:GameObject = (new GameObject())
                    .setGraphic(Image(headOptions.image))
                    .setScale(1/4)
                    .setState(states.get('playerNormal'))
                    .addType(playerType)
                ;

                generate("part",[rightArmOptions,head]);
                generate("part",[leftArmOptions,head]);
                generate("part",[bodyOptions,head]);

                return head;
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
                    .setAttribute('head',args[1])
                    .addType(playerType)
                ;
            });

        addGenerator("soldier",function()
            {
                return (new GameObject())
                    .setGraphic(SpriteSheet("assets/soldier-runcycle.png", 16,14, [0,1,2,3],5, true))
                    // .setScale(1/4)
                    .setState(states.get('soldierNormal'))
                    .addType(playerType)
                ;
            });

        var bobCounter = 0.0;

        states.get('playerNormal')
            .setUpdate(function(obj:GameObject)
                {
                    bobCounter += .01;
                    obj.velocity.setxy(
                        input.getAxis('x') * 5,
                        input.getAxis('y') * 5);
                })
        ;

        states.get('restingBob')
            .setUpdate(function(obj:GameObject)
                {
                    var targetPosition:Vec2 = obj.getAttribute('head').position;
                    var restingPosition:Vec2 = obj.getAttribute('restingPosition');
                    var bobSpeed:Float = obj.getAttribute('bobSpeed');
                    var bobHeight:Float = obj.getAttribute('bobHeight');
                    var followSpeed:Float = obj.getAttribute('followSpeed');

                    targetPosition = targetPosition.copy();
                    targetPosition.x += (restingPosition.x);
                    targetPosition.y += (restingPosition.y + Math.sin(bobCounter*bobSpeed)*bobHeight);
                    
                    var velocity:Vec2 = targetPosition.sub(obj.position);

                    if(velocity.length != 0)
                    {
                        velocity.length *= followSpeed;
                    }

                    obj.setVelocity(velocity);

                })
        ;

        states.get('soldierNormal')

        ;

    }


    public override function onStart()
    {
        generate('player');
        generate('soldier');
    }
}