package ;

import fluidity.*;

import fluidity.utils.KeyboardKeys;
import fluidity.backends.Input;

import fluidity.utils.Vec2;
import fluidity.utils.AdMob;

class TitleScene extends GameScene {

    var sceneOptions = {
        width: 400,
        height: 300,
        gravity: .3
    }

    public var finished:Bool = false;
    var interstitialId:String = "ca-app-pub-1216976235802236/6076892504";

    public var screenObjects:Array<GameObject> = [];
       
    public function new () {

        super (new Vec2(0,0));

        var blankType = new ObjectType();

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
                    GameLayer.sendEventToLayers(new GameEvent('titleFinished'));
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
        AdMob.showInterstitial(interstitialId);
        if(MonsterScene.score > Main.highScore)
        {
            Main.highScore = MonsterScene.score;
            fluidity.utils.Kongregate.submit('highScore',Main.highScore);
        }

        input
            .registerInput(KeyboardKeys.Z,'proceed')
            .registerInput(KeyboardKeys.J,'proceed')
            .registerInput(KeyboardKeys.K,'proceed')
            .registerInput(KeyboardKeys.X,'proceed')
            .registerInput(KeyboardKeys.N,'proceed')
            .registerInput(KeyboardKeys.E,'proceed')
        ;

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
        AdMob.cacheInterstitial(interstitialId);
    }
}