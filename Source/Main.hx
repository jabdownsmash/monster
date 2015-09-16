
package;

import fluidity.backends.Backend;
import fluidity.backends.lime.CustomRenderer;
import fluidity.backends.lime.LimeGameManager;
import fluidity.backends.GraphicsLime;
import fluidity.backends.PhysicsSimple;
import fluidity.GameScene;
import fluidity.GameObject;
import fluidity.GameLayer;
import fluidity.GameEvent;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;

import lime.Assets;

import fluidity.utils.AdMob;
import fluidity.utils.Vec2;

class Main extends LimeGameManager {

	public static var highScore = 0; 
	
	var interstitialId:String = "ca-app-pub-1216976235802236/6076892504";
	var bannerId:String = "ca-app-pub-1216976235802236/7374032503";

	public function new () {
		
		super ();

		AdMob.init();
		AdMob.cacheInterstitial(interstitialId);
	}

	public override function onInit ():Void 
	{
		var customRenderer = new CustomRenderer();
		customRenderer.fragmentSource = 
            
            #if !desktop
            "precision mediump float;" +
            #end
            "varying vec2 vTexCoord;
            uniform sampler2D uImage0;
            uniform vec4 uColor;

            
            void main(void)
            {
                vec4 texel = texture2D(uImage0, vTexCoord) * uColor;
                if (texel.a < 0.1)
                    discard; 
				gl_FragColor = texel;

            }";

      	var colorUniform;

        customRenderer.initFunc = function(program:GLProgram) {

		        colorUniform = GL.getUniformLocation (program, "uColor");
		    };

		customRenderer.renderPreFunc = function(obj:GameObject) {

		        GL.uniform4f (colorUniform, 1,1,1,1);
				if(obj.getAttribute('randomColor') != null)
				{
			        	GL.uniform4f (colorUniform, Math.random()/2 + .5,Math.random()/2 + .5,Math.random()/2 + .5,1);
				}
				if(obj.getAttribute('drawColorR') != null)
				{
		        	GL.uniform4f (colorUniform, obj.getAttribute('drawColorR'),obj.getAttribute('drawColorG'),obj.getAttribute('drawColorB'),obj.getAttribute('drawColorA'));
				}
			};
		// #if android
		// layers.get('overlay')
		// 	.addScene('overlay',new OverlayScene())
		// 	.start('overlay')
		// ;
		// #end

		lgb.setCustom(layers.get('game'),customRenderer);

		layers.get('game')
			.addScene('title',new TitleScene())
			.addScene('monster',new MonsterScene())
			.addTransition('titleFinished','title','monster')
			.addTransition('monsterFinished','monster',true,'title',true)
			.start('title')
		;

		onResize();

	}

	public override function onResize()
	{
		var tWidth = Backend.graphics.width;
		var tHeight = Math.floor(Backend.graphics.width*3020/1840);

		var left = 440/1840*tWidth;
		var right = 1400/1840*tWidth;
		var top = 400/3020*tHeight;
		var bottom = 1270/3020*tHeight;

		// #if android
		// layers.get('overlay')
		// 	.setVDimensions(1840,3020)
		// 	.setDimensions(tWidth,tHeight)
		// ;
		// #end

		layers.get('game')
			.setVDimensions(400,300)
			// #if android
			// .setDimensions(Math.floor(right - left),Math.floor(bottom - top))
			// .setY(-Math.floor(tHeight/2 - (bottom + top)/2))
			// #else
			// .setDimensions(800,600)
			// .setY(Math.floor(-Backend.graphics.height/2 + 300))
			// #end
		;
	}
}