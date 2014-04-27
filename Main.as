package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Agecaf
	 */
	public class Main extends Sprite 
	{
		
		// Components
		private var ge:GameEngine;
		public var state:int = 0;
		
		// Constants
		public static const S_TITLE:int = 0;
		public static const S_GAME:int = 1;
		public static const S_SUCCESS:int = 2;
		public static const S_FAILURE:int = 3;
		
		// Text
		private var myFont:TextFormat;
		private var title:TextField;
		private var title2:TextField;
		private var subtitle:TextField;
		private var button:TextField;
		
		// Music
		private var music:SoundChannel;
		
		// Shared Object, for highscores and whatnot
		private var sharedObject:SharedObject;
		
		// Embeds
		[Embed(source = "../lib/beneath the surface main.mp3")] // Done in GarageBand
		private var main_mus:Class;
		
		[Embed(source="../lib/bridge to the abyss2.mp3")] // Same
		private var bridge_mus:Class;
		
		[Embed(source = "../lib/Surface's tranquility.mp3")] // And again.
		private var surf_mus:Class;
		
		[Embed(source="../lib/OpenSans-Regular.ttf", fontFamily = "OpenSans", embedAsCFF = "false")] // From http://www.fontsquirrel.com/fonts/open-sans
		private var openSans:Class;
		
		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		} // End of constructor
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			// Creates GameEngine
			ge = new GameEngine( this );
			//ge.init();
			addChild(ge);
			
			// Loads SharedObject
			sharedObject = SharedObject.getLocal("highscore");
			if ( sharedObject.data.hs == undefined ) {
				sharedObject.data.hs = 0;
			}
			ge.hscore = sharedObject.data.hs;
			
			// Background color
			this.graphics.beginFill(0xAACCFF, 1);
			this.graphics.drawRect(0, 0, 640, 480);
			this.graphics.endFill();
			
			// Creates Text Fields
			myFont = new TextFormat( "OpenSans", 70, 0x4444DD);//0xFFFFBB );
			title = new TextField();
			title.embedFonts = true; 
			title.defaultTextFormat = myFont;
			title.selectable = false;
			title.x = 100;
			title.y = 40;
			title.width = 300;
			title.text = "Bridge to";
			addChild(title);
			
			title2 = new TextField();
			title2.embedFonts = true; 
			title2.defaultTextFormat = myFont;
			title2.selectable = false;
			title2.x = 180;
			title2.y = 120;
			title2.width = 400;
			title2.text = "the Abyss";
			addChild(title2);
			
			myFont.size = 20;
			subtitle = new TextField();
			subtitle.embedFonts = true; 
			subtitle.defaultTextFormat = myFont;
			subtitle.selectable = false;
			subtitle.x = 400;
			subtitle.y = 240;
			subtitle.width = 300;
			subtitle.text = " - by Agecaf";
			addChild(subtitle);
			
			myFont.size = 40;
			button = new TextField();
			button.embedFonts = true; 
			button.defaultTextFormat = myFont;
			button.selectable = false;
			button.x = 200;
			button.y = 300;
			button.width = 300;
			button.text = "Play";
			button.addEventListener(MouseEvent.CLICK, titlePlay);
			addChild(button);
			
			
			
			// Listens for Events
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		} // End of function init
		
		private function nextOnePlease(e:Event):void 
		{
			if (ge.state == 0) {
				music = (new main_mus()).play(0, 1, new SoundTransform(1, 0))
				music.addEventListener(Event.SOUND_COMPLETE, nextOnePlease);
			} else {
				music = (new surf_mus()).play(0, 1, new SoundTransform(1, 0))
				music.addEventListener(Event.SOUND_COMPLETE, nextOnePlease);
			}
			
		}
		
		public function playMusic():void {
			music.stop();
			if (ge.state == 2) {
				music = (new bridge_mus()).play(0, 1, new SoundTransform(1, 0))
				music.addEventListener(Event.SOUND_COMPLETE, nextOnePlease);
			} else {
				music = (new surf_mus()).play(0, 1, new SoundTransform(1, 0))
				music.addEventListener(Event.SOUND_COMPLETE, nextOnePlease);
			}
		}
		
		public function flushHighScore():void 
		{
			sharedObject.data.hs = ge.hscore;
			sharedObject.flush();
		}
		
		private function titlePlay(e:MouseEvent):void 
		{
			// How... successful...
			state = S_SUCCESS;
			
			// Starts music???
			music = (new surf_mus()).play(0, 1, new SoundTransform(1, 0));
			music.addEventListener(Event.SOUND_COMPLETE, nextOnePlease);
			
		}
		
		private function onEnterFrame( e:Event ) : void
		{
			switch ( state ) {
				case S_TITLE:
					ge.visible = false;
					break;
				case S_GAME:
					ge.visible = true;
					title.visible = false;
					title2.visible = false;
					subtitle.visible = false;
					button.visible = false;
					ge.update();
					break;
				case S_SUCCESS:
					ge.visible = true;
					title.visible = false;
					title2.visible = false;
					subtitle.visible = false;
					button.visible = false;
					ge.update();
					break;
				case S_FAILURE:
					break;
				default:
					break;
			}
			
		} // End of function onEnterFrame
		
	} // End of class Main
	
} // End of package