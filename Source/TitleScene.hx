package ;


// import openfl.display.Sprite;
// import gtoolbox.KeyboardKeys;
import nape.callbacks.*;

import fluidity2.*;

import nape.geom.Vec2;

import evsm.FState;

import gtoolbox.KeyboardKeys;
import gtoolbox.Input;

class TitleScene extends GameScene {

    var bobCounter = 0.0;

    var sceneOptions = {
        width: 400,
        height: 300,
        gravity: .3
    }

    public var finished:Bool = false;

    public var screenObjects:Array<GameObject> = [];
       
    public function new () {

        super (new Vec2(0,0));

        var states = new StringBin<FState<GameObject,GameEvent>>(function(name:String)
            {
                return new FState<GameObject,GameEvent>(name);
            });

        var blankType = new ObjectType();

        input
            .registerInput(KeyboardKeys.Z,'proceed')
            .registerInput(KeyboardKeys.J,'proceed')
            .registerInput(KeyboardKeys.N,'proceed')
        ;

        addGenerator("screen",function()
            {
                var screen = (new GameObject())
                    .setGraphic(Image('assets/title.png'))
                    // .setScale(1/4)
                    .setY(-300)
                    .setZ(-100)
                    .setState(states.get('screen'))
                    .addType(blankType)
                    .setAttribute('randomColor',true)
                ;

                input                    
                    .registerFunction(Input.ONKEYDOWN,'proceed', function()
                        {
                            screen.processEvent(new GameEvent("proceed"));
                        })    
                ;

                return screen;
            });

        addGenerator("name",function()
            {
                return (new GameObject())
                    .setGraphic(Image('assets/madeby.png'))
                    .setPosition(new Vec2(-120,140))
                    .setState(states.get('fadeIn'))
                    .addType(blankType)
                    .setZ(-100)
                ;
            });

        addGenerator("press",function()
            {
                return (new GameObject())
                    .setGraphic(Image('assets/presstostart.png'))
                    .setPosition(new Vec2(110,55))
                    .setState(states.get('fadeIn'))
                    .addType(blankType)
                    .setZ(-100)
                ;
            });

        addGenerator("number",function()
            {
                return (new GameObject())
                    .setState(states.get('fuk'))
                    .addType(blankType)
                ;
            })
        ;
        states.get('screen')
            .setUpdate(function(obj:GameObject)
                {
                    if(obj.position.y <0)
                    {
                        obj.position.y += 3;
                    }
                })
            .onEvent('proceed',function(obj:GameObject)
                {
                    for(object in screenObjects)
                    {
                        delete(object);
                    }
                    screenObjects = [];
                    finished = true;
                })
        ;

        states.get('fadeIn')
            .setStart(function (obj:GameObject)
                {
                    obj
                        .setAttribute('timer',300)
                        .setAttribute('drawColorR',0)
                        .setAttribute('drawColorG',0)
                        .setAttribute('drawColorB',0)
                        .setAttribute('drawColorA',0)
                    ;
                })
            .setUpdate(function (obj:GameObject)
                {
                    obj.setAttribute('timer',obj.getAttribute('timer') - 1);
                    if(obj.getAttribute('timer') >= 0)
                    {
                        obj
                            .setAttribute('drawColorR',1 - obj.getAttribute('timer')/300)
                            .setAttribute('drawColorG',1 - obj.getAttribute('timer')/300)
                            .setAttribute('drawColorB',1 - obj.getAttribute('timer')/300)
                            .setAttribute('drawColorA',1)
                        ;
                    }
                })
        ;

        // states.get('fadeIn')
        //     .setStart()
    }


    public override function onStart()
    {
        screenObjects = [generate('screen'), generate('name'),generate('press')];

        var kek:Int = Main.highScore;

        var i:Int = 0;
        while(kek > 0)
        {
            var digit = kek % 10;

            screenObjects.push(generate('number')
                .setPosition(new Vec2(190 - i*6,140))
                .setGraphic(Image('assets/num' + digit + '.png'))
            );

            kek = Math.floor(kek/10);
            i++;
        }
        if(i > 0)
        {
            screenObjects.push(generate('number')
                .setPosition(new Vec2(190 - i*6 - 20,140))
                .setGraphic(Image('assets/hiscore.png'))
            );
        }
    }
}