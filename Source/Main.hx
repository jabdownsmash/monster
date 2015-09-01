
package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import fluidity.backends.Backend;
import fluidity.backends.lime.CustomRenderer;
import fluidity.backends.GraphicsLime;
import fluidity.backends.PhysicsSimple;
import fluidity.GameScene;
import fluidity.GameObject;
import fluidity.GameLayer;

import fluidity.backends.LimeInput;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;

import lime.Assets;

import fluidity.utils.AdMob;

class Main extends Application {
	
	var titleScene:TitleScene;
	var gameScene:MonsterScene;

	var layer:GameLayer;

	var started = false;

	var limeInput:LimeInput;
	var customRenderer:CustomRenderer;

	public static var highScore = 0; 

	public static var randomColor:Bool = false;

	public static var drawColorR:Float = 1;
	public static var drawColorG:Float = 1;
	public static var drawColorB:Float = 1;
	public static var drawColorA:Float = 1;
	
	var interstitialId:String = "ca-app-pub-1216976235802236/6076892504";
	var bannerId:String = "ca-app-pub-1216976235802236/7374032503";

	public function new () {
		
		super ();
		
		AdMob.init();
		AdMob.cacheInterstitial(interstitialId);
	}

	public override function render (renderer):Void {

		if(!started)
		{
			customRenderer = new CustomRenderer();
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
	            	
					gl_FragColor = texel;

	            }";

	      	var colorUniform;

            customRenderer.customInitFunc = function(program:GLProgram) {

			        colorUniform = GL.getUniformLocation (program, "uColor");
			    };

			customRenderer.customRenderPreFunc = function(obj:GameObject) {

			        GL.uniform4f (colorUniform, 1,1,1,1);
					if(obj.getAttribute('randomColor') != null)
					{
						// if(randomColor)
						// {
				        	GL.uniform4f (colorUniform, Math.random()/2 + .5,Math.random()/2 + .5,Math.random()/2 + .5,1);
						// }
					}
					if(obj.getAttribute('drawColorR') != null)
					{
			        	GL.uniform4f (colorUniform, obj.getAttribute('drawColorR'),obj.getAttribute('drawColorG'),obj.getAttribute('drawColorB'),obj.getAttribute('drawColorA'));
					}
				};

			started = true;

			
			var lgb = new GraphicsLime(window);
			lgb.setCustom(customRenderer);

			Backend.graphics = lgb;
			Backend.physics = new PhysicsSimple();
			limeInput = new LimeInput();
			Backend.input = limeInput;

			layer = new GameLayer();

			// layer.vWidth = 400;
			// layer.vHeight = 300;

			layer
				.addScene('title',new TitleScene())
				.addScene('monster',new MonsterScene())
				.addTransition('titleFinished','title','monster')
				// .addTransition('monsterFinished','monster','title')
				.addTransition('monsterFinished','monster',true,'title',true)
				.start('title')
			;

			// scene = new MonsterScene();
			// titleScene = new TitleScene();

			// titleScene.start();
		}
		// if(titleScene.finished)
		// {
		// 	if(gameScene == null)
		// 	{
		// 		gameScene = new MonsterScene();
		// 		gameScene.start();
		// 	}
		// 	else
		// 	{
		// 		gameScene.update();
		// 		gameScene.render();
		// 		if(gameScene.finished)
		// 		{
		// 			if(gameScene.score > highScore)
		// 			{
		// 				highScore = gameScene.score;
		// 				fluidity.utils.Kongregate.submit('highScore',highScore);
		// 			}
		// 			var lgb = new GraphicsLime(window);
		// 			lgb.setCustom(customRenderer);

		// 			Backend.graphics = lgb;
		// 			Backend.physics = new PhysicsSimple();
		// 			limeInput = new LimeInput();
		// 			Backend.input = limeInput;

		// 			// scene = new MonsterScene();
		// 			titleScene = new TitleScene();

		// 			titleScene.start();

		// 			gameScene = null;

		// 		    AdMob.showInterstitial(interstitialId);
		// 		}
		// 	}
		// }
		// else
		// {
		// 	titleScene.update();
		// 	titleScene.render();
		// }
		layer.update().render();
	}
	
	
	public override function onKeyDown (window,key:KeyCode, modifier:KeyModifier):Void {
		limeInput.limeOnKeyDown(key);
	}
	public override function onKeyUp (window,key:KeyCode, modifier:KeyModifier):Void {
		limeInput.limeOnKeyUp(key);
	}

	public override function onTouchStart(touch)
	{
		titleScene.finished = true;
		if(gameScene != null)
			{
				// gameScene = new MonsterScene();
				// gameScene.start();
				gameScene.finished = true;
			}
		// 	else
		// 	{
		// 		gameScene.update();
		// 		gameScene.render();
		// 		if(gameScene.finished)
		// 		{
		// 			if(gameScene.score > highScore)
		// 			{
		// 				highScore = gameScene.score;
		// 			}
		// 			var lgb = new GraphicsLime(window);
		// 			lgb.setCustom(customRenderer);

		// 			Backend.graphics = lgb;
		// 			Backend.physics = new PhysicsSimple();
		// 			limeInput = new LimeInput();
		// 			Backend.input = limeInput;

		// 			// scene = new MonsterScene();
		// 			titleScene = new TitleScene();

		// 			titleScene.start();

		// 			gameScene = null;
		// 		}
		// 	}
	}
	
}