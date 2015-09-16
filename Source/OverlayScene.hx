package ;

import fluidity.*;

import fluidity.input.KeyboardKeys;
// import fluidity.input.Input;

import fluidity.utils.Vec2;
import fluidity.utils.AdMob;

class OverlayScene extends GameScene {

    var sceneOptions = {
        width: 400,
        height: 300,
        gravity: .3
    }
       
    public function new () {

        super (new Vec2(0,0));

        var blankType = new ObjectType();

        addGenerator("screen",function()
            {
                return (new GameObject())
                    // .setGraphic(Image('assets/title.png'))
                    .setGraphic(Image('assets/gameboy.png'))
                    .setState(states.get('screen'))
                    // .setX(10)
                    .addType(blankType)
                    // .setAttribute('randomColor',true)
                ;

            });

    }


    public override function onStart()
    {
        generate('screen');
    }
}