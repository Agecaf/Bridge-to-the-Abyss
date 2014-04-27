package  
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Agecaf
	 */
	
	public class GameEngine extends Sprite
	{
		// Core
		private var _parent:Main;
		
		//Components
		private var myFont:TextFormat;
		private var score_t:TextField;
		private var hscore_t:TextField;
		
		
		// Entities
		private var plr:Entity;
		private var ets:Vector.<Entity> = new Vector.<Entity> ();
		
		// Control
		private var click:Boolean = false;
		private var t:int = 0;
		private var cx:int = 0;
		private var cy:int = 0;
		private var hue:Number = 4.0;
		public var state:int = 1;
		private var score:Number = 0;
		public var hscore:int = 0;
		
		// States
		private var S_TO_POSITION:int = 1;
		private var S_GAME:int = 0;
		private var S_FALLING:int = 2;
		
		// Modifiers
		private var P_NORMAL:int = 0;
		private var P_FROZEN:int = 1;
		private var P_FLEE:int = 2;
		private var currentModifier:int = 0;
		private var modifierCooldown:int = 0;
		
		// Miscellaneous
		private var ett:Entity;
		private var i:int;
		private var ang:Number = 0;
		
		public function GameEngine(  _parent:Main ) 
		{
			// Sets core
			this._parent = _parent;
			// Sets mainsprite
			this.graphics.beginFill(0x000000, 1);
			this.graphics.drawRect(0, 0, 640, 480);
			this.graphics.endFill();
			
			// Listens for Events
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			// Sets components
			myFont = new TextFormat( "OpenSans", 20, HSVtoRGB(4,0.5,0.8),null,null,null,null,null,"right");//0xFFFFBB );
			score_t = new TextField();
			score_t.embedFonts = true; 
			score_t.defaultTextFormat = myFont;
			score_t.selectable = false;
			score_t.x = 0;
			score_t.y = 40;
			score_t.width = 640;
			score_t.text = "0";
			addChild(score_t);
			
			hscore_t = new TextField();
			hscore_t.embedFonts = true; 
			hscore_t.defaultTextFormat = myFont;
			hscore_t.selectable = false;
			hscore_t.x = 0;
			hscore_t.y = 40;
			hscore_t.width = 640;
			hscore_t.text = hscore.toString();
			addChild(hscore_t);
			
			// Sets Player
			plr = new Entity( -20, -20, Entity.A_PLAYER, Entity.M_MOUSE_PROPULSION );
			
		} // End of constructor
		
		public function init():void
		{
			// Sets State
			state = S_GAME;
			_parent.state = 1;
			
			plr.x = 0;
			plr.y = 20;
			
			// Initial Enemies ???
			ets.length = 0;
			while ( ets.length < 40 ) {
				ang = Math.random() * Math.PI ;
				
				ets.push( new Entity(plr.x + 5000 * Math.cos(ang) * Math.random(), 
							plr.y + 5000 * Math.sin(ang) * Math.random() + 200, 
							Entity.A_IDDLER,
							Entity.M_SLIDER));
			}
			
			// Control
			cx = plr.x - 310;
			cy = plr.y - 240;
			t = 0;
			score = 0;
			currentModifier = P_NORMAL;
			modifierCooldown = 0;
			
		} // End of function init
		
		public function update() : void
		{
			if ( state == S_GAME ) {
				
				// Control
				if (currentModifier != P_FROZEN) { t++;
				score += plr.y * 0.005; 
				Entity.t = t; }
				
				// Clears Sprite
				this.graphics.clear();
				this.graphics.beginFill(HSVtoRGB(hue,0.5, 1 - plr.y / 10000), 1);
				this.graphics.drawRect(0, 0, 640, 480);
				this.graphics.endFill();
				
				// Updates & Renders Entities
				
				// Player
				ang = plr.update( this.mouseX + cx, this.mouseY + cy, click , currentModifier);
				
				
				// Enemies
				for each ( ett in ets ) {
					ang = ett.update( this.mouseX + cx, this.mouseY + cy, click, currentModifier );				
					this.graphics.lineStyle(1, HSVtoRGB(ett.h, 1, 0.4),  1.8 - ett.dist / 150 );
					this.graphics.beginFill(HSVtoRGB(ett.h, 1, 0.8),  1.8 - ett.dist / 150 );
					drawShape(ett.x - cx, ett.y - cy, ett.r, ang, ett.s);
					this.graphics.endFill();
				}
				
				
				// Renders surface
				this.graphics.beginFill(0xAACCFF, 1);
				this.graphics.drawRect( 0, 0, 640, - cy);
				this.graphics.endFill();
				
				// Score Text
				if (cy < 300) {
					score_t.text = int(score).toString();
					score_t.y = -cy - 30;
					hscore_t.y = -cy - 60;
				}
				
				// Renders Player
				this.graphics.beginFill(0xFFFFFF, 1);
				this.graphics.drawCircle( plr.x - cx, plr.y - cy, plr.r );
				this.graphics.endFill();
				
				// Checks collisions
				for each ( ett in ets ) {
					if ( ett.dist - ett.r <  plr.r ) {
						
						switch (true) {
							case ett.h == 4:
								ett.y = -4000; 
								freeze();
								break;
							case ett.h == 2:
								ett.y = -4000; 
								makeFlee();
								break;
							default:
								// End game
								die();
								break;
						}
					}
				}
				
				// Removes enemies
				for ( i = 0; i < ets.length; i++ ) {
					if (ets[i].dist > 600) {
						ets.splice(i, 1)
						i--;
					}
					if ( i < 0) i = 0;
				}
				
				// Adds new Enemies
				while ( ets.length < 40 ) {
					if (plr.y < 800) ang = Math.random() * Math.PI;
					else ang = ( Math.random() - 0.5 ) * Math.PI * 4;
					i = Math.random() * 100 + 400;
					ets.push( new Entity(plr.x + i * Math.cos(ang), 
								(plr.y + i * Math.sin(ang)) > 200 ? (plr.y + i * Math.sin(ang)) : 800 - (plr.y + i * Math.sin(ang)), 
								randomChoice(new <int>[0,5,0,3,0]), 
								randomChoice(new <int>[0,1,1,1]),
								randomChoice(new <int>[1,5,5,4,4,3])));
				}
				
				// Control
				cx = plr.x - 310;
				cy = plr.y - 240;
				if (modifierCooldown > 0) modifierCooldown--;
				if (modifierCooldown <= 0) { currentModifier = P_NORMAL; }
				if ( plr.y < 0 ) endDive();
			}
			if (state == S_TO_POSITION) {
				
				// Clears Sprite
				this.graphics.clear();
				this.graphics.beginFill(HSVtoRGB(hue,0.5, 1 - plr.y / 10000), 1);
				this.graphics.drawRect(0, 0, 640, 480);
				this.graphics.endFill();
				
				// Player
				plr.y = (plr.y * 9 - 40) * 0.1;
				
				// Enemies
				for each ( ett in ets ) {
					ang = ett.update( this.mouseX + cx, this.mouseY + cy, click, currentModifier );				
					this.graphics.beginFill(HSVtoRGB(ett.h, 1, 0.8),  1.7 - ett.dist / 150 );
					drawShape(ett.x - cx, ett.y - cy, ett.r, ang, ett.s);
					this.graphics.endFill();
				}
				
				// Renders surface
				this.graphics.beginFill(0xAACCFF, 1);
				this.graphics.drawRect( 0, 0, 640, - cy);
				this.graphics.endFill();
				
				// Renders Player
				this.graphics.beginFill(0xFFFFFF, 1);
				this.graphics.drawCircle( plr.x - cx, plr.y - cy, plr.r );
				this.graphics.endFill();
				
				// Score Text
				if (cy < 300) {
					score_t.text = int(score).toString();
					hscore_t.text = hscore.toString();
					score_t.y = -cy - 30;
					hscore_t.y = -cy - 60;
				}
				
				// Control
				if (plr.y < -38 && click) { state = S_FALLING; t = 0; }					
				cx = plr.x - 310;
				cy = plr.y - 240;
			}
			if (state == S_FALLING) 
			{
				// Clears Sprite
				this.graphics.clear();
				this.graphics.beginFill(HSVtoRGB(hue,0.5, 1 - plr.y / 10000), 1);
				this.graphics.drawRect(0, 0, 640, 480);
				this.graphics.endFill();
				
				// Player
				plr.y += plr.y < 0 ? t : 15 - t;
				t++;
				
				if (t == 10) _parent.playMusic(); // Starts musiiic
				
				// Score Text
				if (cy < 300) {
					score_t.text = int(score).toString();
					score_t.y = -cy - 30;
					hscore_t.y = -cy - 60;
				}
					
				// Control
				cx = plr.x - 310;
				cy = plr.y - 240;
				
				// Renders surface
				this.graphics.beginFill(0xAACCFF, 1);
				this.graphics.drawRect( 0, 0, 640, - cy);
				this.graphics.endFill();
				
				// Renders Player
				this.graphics.beginFill(0xFFFFFF, 1);
				this.graphics.drawCircle( plr.x - cx, plr.y - cy, plr.r );
				this.graphics.endFill();
				
				if (plr.y > 20) init();
			}
			
		} // End of function update()
		
		private function endDive():void 
		{
			// Changes State
			state = S_TO_POSITION;
			_parent.state = 2;
			
			// Clears enemies in a adequate fashion
			for each ( ett in ets ) {
					ett.a = Entity.A_FLEEER;
				}
				
			
			// Checks for highscore
			if ( hscore < score ) {
				hscore = int(score);
				hscore_t.text = hscore.toString();
				_parent.flushHighScore();
			}
			
			// Add music to the mix!
			_parent.playMusic();
			
		} // End of function endDive
		
		private function freeze():void
		{
			currentModifier = P_FROZEN;
			modifierCooldown = 200;
			for each ( ett in ets ) {
					ett.a = Entity.A_CHASER;
					ett.h = 3;
				}
			
		} // End of function freeze
		
		private function makeFlee():void {
			
			currentModifier = P_FLEE;
			modifierCooldown = 100;
			
		} // End of function make Flee
		
		private function die():void {
			
			// Changes State
			state = S_TO_POSITION;
			_parent.state = 2;
			
			// Clears enemies in a adequate fashion
			for each ( ett in ets ) {
				ett.a = Entity.A_FLEEER;
			}
			
			// The dead have no score to be proud of.
			score = 0;
			
			// And the music
			_parent.playMusic();
			
			
		} // End of function die
		
		private function onMouseDown(e:MouseEvent) : void
		{
			click = true;
			
		} // End of function onMouseClick
		
		private function onMouseUp(e:MouseEvent) : void
		{
			click = false;
			
		} // End of function onMouseClick
		
		private function randomChoice( v:Vector.<int> ): int {
			
			var s:int = 0;
			var j:int = 0;
			var r:int = 0;
			
			for (  j  = 0; j < v.length; j++ ) {
				s += v[j];
			}
			
			r = int( Math.random() * s) ;
			
			s = 0;
			
			for ( j = 0; j < v.length; j++ ) {
				s += v[j];
				if ( s > r ) return j;
			}
			
			return j;
			
		} // End of function randomChoice
		
		private function HSVtoRGB( h:Number, s:Number, v:Number ):uint 
		{
			h = h % 6;
			s = s > 1 ? 1 : s < 0 ? 0 : s;
			v = v > 1 ? 1 : v < 0 ? 0 : v;
			var c:Number = s * v;
			var x:Number = c * (1 - Math.abs(h % 2 - 1));
			var r:Number, g:Number, b:Number;
			switch(true) {
				case ( h >= 0 && h < 1 ): r = c; g = x; b = 0; break;
				case ( h >= 1 && h < 2 ): r = x; g = c; b = 0; break;
				case ( h >= 2 && h < 3 ): r = 0; g = c; b = x; break;
				case ( h >= 3 && h < 4 ): r = 0; g = x; b = c; break;
				case ( h >= 4 && h < 5 ): r = x; g = 0; b = c; break;
				case ( h >= 5 && h < 6 ): r = c; g = 0; b = x; break;
				default: r = 0; g = 0; b = 0; break;
			}
			var r2:uint = (r + v - c) * 0xFF;
			var g2:uint = (g + v - c) * 0xFF;
			var b2:uint = (b + v - c) * 0xFF;
			return r2 * 0x010000 + g2 * 0x000100 + b2;
		}
		
		private function drawShape( x:int, y:int, r:int, d:Number, shape:int ) : void {
			
			switch ( shape ) {
				case Entity.S_SQUARE: 
					graphics.moveTo ( 	x  	+ (  1.4 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.4 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  0.0 * Math.cos(d) -  1.4 * Math.sin(d)) * r,
										y	+ (  0.0 * Math.sin(d) +  1.4 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ ( -1.4 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ ( -1.4 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  0.0 * Math.cos(d) - -1.4 * Math.sin(d)) * r,
										y	+ (  0.0 * Math.sin(d) + -1.4 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  1.4 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.4 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
										break;
				case Entity.S_PENTAGON: 
					graphics.moveTo ( 	x  	+ (  1.4 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.4 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  0.4 * Math.cos(d) -  1.3 * Math.sin(d)) * r,
										y	+ (  0.4 * Math.sin(d) +  1.3 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ ( -1.1 * Math.cos(d) -  0.8 * Math.sin(d)) * r,
										y	+ ( -1.1 * Math.sin(d) +  0.8 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ ( -1.1 * Math.cos(d) - -0.8 * Math.sin(d)) * r,
										y	+ ( -1.1 * Math.sin(d) + -0.8 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  0.4 * Math.cos(d) - -1.3 * Math.sin(d)) * r,
										y	+ (  0.4 * Math.sin(d) + -1.3 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  1.4 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.4 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
										break;
				case Entity.S_RHOMBUS: 
					graphics.moveTo ( 	x  	+ (  1.4 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.4 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  0.0 * Math.cos(d) -  1.0 * Math.sin(d)) * r,
										y	+ (  0.0 * Math.sin(d) +  1.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ ( -1.4 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ ( -1.4 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  0.0 * Math.cos(d) - -1.0 * Math.sin(d)) * r,
										y	+ (  0.0 * Math.sin(d) + -1.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  1.4 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.4 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
										break;
				case Entity.S_TRIANGLE: 
					graphics.moveTo ( 	x  	+ (  1.2 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.2 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ ( -0.5 * Math.cos(d) -  0.7 * Math.sin(d)) * r,
										y	+ ( -0.5 * Math.sin(d) +  0.7 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ ( -0.5 * Math.cos(d) - -0.7 * Math.sin(d)) * r,
										y	+ ( -0.5 * Math.sin(d) + -0.7 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  1.2 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.2 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
										break;
				case Entity.S_DART: 
					graphics.moveTo ( 	x  	+ (  1.2 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.2 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ ( -0.6 * Math.cos(d) -  0.9 * Math.sin(d)) * r,
										y	+ ( -0.6 * Math.sin(d) +  0.9 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ ( -0.2 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ ( -0.2 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ ( -0.6 * Math.cos(d) - -0.9 * Math.sin(d)) * r,
										y	+ ( -0.6 * Math.sin(d) + -0.9 * Math.cos(d)) * r);
					graphics.lineTo ( 	x  	+ (  1.2 * Math.cos(d) -  0.0 * Math.sin(d)) * r,
										y	+ (  1.2 * Math.sin(d) +  0.0 * Math.cos(d)) * r);
										break;
					
				default : graphics.drawCircle(x,y,r); break;
			}
			
		}
		
	} // End of class GameEngine

} // End of package