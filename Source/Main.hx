
package;

import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import fluidity2.Backend;
import fluidity2.backends.*;
import fluidity2.GameScene;
import fluidity2.GameObject;

import gtoolbox.LimeInput;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;

import lime.Assets;


class Main extends Application {
	
	var titleScene:TitleScene;
	var gameScene:MonsterScene;

	var started = false;

	var limeInput:LimeInput;
		var customRenderer:CustomRenderer;

	public static var randomColor:Bool = false;

	public static var drawColorR:Float = 1;
	public static var drawColorG:Float = 1;
	public static var drawColorB:Float = 1;
	public static var drawColorA:Float = 1;
	
	public function new () {
		
		super ();
		
	}

	public override function render (context:RenderContext):Void {

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
	            	
					if(texel.a < 0.5)
					    discard;
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

			
			var lgb = new LimeGraphicsBackend(window);
			lgb.setCustom(customRenderer);

			Backend.graphics = lgb;
			Backend.physics = new SimplePhysicsBackend();
			limeInput = new LimeInput();
			Backend.input = limeInput;

			// scene = new MonsterScene();
			titleScene = new TitleScene();

			titleScene.start();
		}
		if(titleScene.finished)
		{
			if(gameScene == null)
			{
				gameScene = new MonsterScene();
				gameScene.start();
			}
			else
			{
				gameScene.update();
				gameScene.render();
				if(gameScene.finished)
				{
					var lgb = new LimeGraphicsBackend(window);
					lgb.setCustom(customRenderer);

					Backend.graphics = lgb;
					Backend.physics = new SimplePhysicsBackend();
					limeInput = new LimeInput();
					Backend.input = limeInput;

					// scene = new MonsterScene();
					titleScene = new TitleScene();

					titleScene.start();

					gameScene = null;
				}
			}
		}
		else
		{
			titleScene.update();
			titleScene.render();
		}
	}
	
	
	public override function onKeyDown (key:KeyCode, modifier:KeyModifier):Void {
		limeInput.limeOnKeyDown(key);
	}
	public override function onKeyUp (key:KeyCode, modifier:KeyModifier):Void {
		limeInput.limeOnKeyUp(key);
	}
	
}