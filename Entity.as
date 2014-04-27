package  
{
	/**
	 * ...
	 * @author Agecaf
	 */
	public class Entity 
	{
		// Constants
		public static const B_FOLLOW_MOUSE:int 			= 0;
		public static const B_FLEE:int 					= 1;
		public static const B_FLEE_UPWARDS:int 			= 2;
		public static const B_GET_CLOSER:int 			= 3;
		public static const B_GET_CLOSER_CIRCLING:int 	= 4;
		public static const B_IDDLE:int 				= 5;
		
		public static const A_PLAYER:int 	= 0;
		public static const A_IDDLER:int	= 1;
		public static const A_FLEEER:int	= 2;
		public static const A_CHASER:int 	= 3;
		public static const A_FOLLOWER:int 	= 5;
		public static const A_UPFLIER:int 	= 4;
		public static const A_CHASE_ME:int 	= 6;
		
		public static const M_MOUSE_PROPULSION:int 	= 0;
		public static const M_PROPULSION:int	 	= 1;
		public static const M_LINEAR:int 			= 2;
		public static const M_SLIDER:int			= 3;
		
		public static const S_CIRCLE:int 		= 0;
		public static const S_SQUARE:int 		= 1;
		public static const S_TRIANGLE:int 		= 2;
		public static const S_RHOMBUS:int 		= 3;
		public static const S_DART:int 			= 4;
		public static const S_PENTAGON:int 		= 5;
		
		private var P_NORMAL:int = 0;
		private var P_FROZEN:int = 1;
		private var P_FLEE:int = 2;
		
		
		// Shared Properties
		public static var tx:int = 0;
		public static var ty:int = 0;
		public static var t:int = 0;
		
		// Inner Properties
		public var x:Number = 1;		// Position
		public var y:Number = 1;
		public var s:int = 0;			// Shape
		public var h:Number = 0;		// Hue
		private var v:int = 0;			// Velocity
		public var a:int = 1;			// AI
		private var m:int = 0;			// Movement type
		
		
		public function Entity( x_pos:int, y_pos:int, ai:int, mov:int, shap:int = 0 ) 
		{
			// Sets Entity
			this.x = x_pos;
			this.y = y_pos;
			this.a = ai;
			this.m = mov;
			this.s = shap;
			this.h = Math.random() * 0.4 + 5.8;
			
			// Sets initial values
			switch ( m ) {
				case M_PROPULSION:
					v = Math.random () * 3 + 3;
			}
			
			// Randomly becomes a powerup.
			if (a != A_PLAYER && Math.random() < 0.02) {
				h = 4;
				a = A_CHASE_ME;
			}
			if (a != A_PLAYER && Math.random() < 0.02) {
				h = 2;
				a = A_CHASE_ME;
			}
			
		} // End of constructor
		
		public function update( mx:int, my:int, click:Boolean, mod:int ):Number
		{
			var b:int;
			var d:Number;
			
			// Set Behaviour
			switch ( a ) {
				case A_PLAYER:
					b = B_FOLLOW_MOUSE;
					break;
					
				case A_CHASER:
					b = dist > 500 ? B_GET_CLOSER : B_GET_CLOSER_CIRCLING;
					if ( Math.random() < 0.001) a = A_FLEEER;
					if ( Math.random() < 0.001) a = A_IDDLER;
					break;
					
				case A_CHASE_ME:
					b = dist > 100 ? B_IDDLE : B_FLEE;
					break;
					
				case A_FLEEER:
					b = B_FLEE;
					break;
					
				case A_UPFLIER:
					b = B_FLEE_UPWARDS;
					break;
					
				case A_IDDLER:
					b = dist < 700 ? B_IDDLE : B_GET_CLOSER;
					b = B_IDDLE;
					break;
					
				case A_FOLLOWER:
					b = dist > 300 ? B_IDDLE : B_GET_CLOSER_CIRCLING;
					if ( Math.random() < 0.001) a = A_FLEEER;
					if ( Math.random() < 0.001) a = A_IDDLER;
					break;
				
				default: b = B_IDDLE; break;
			}
			
			if ( mod == P_FLEE && a != A_PLAYER ) b = B_FLEE;
			
			// Set Direction
			switch ( b ) {
				case B_FOLLOW_MOUSE:
					d = Math.atan2(my - y, mx - x);
					break;
					
				case B_IDDLE:
					d = rand() * 2.943;
					break;
					
				case B_GET_CLOSER:
					d = Math.atan2(ty - y, tx - x);
					break;
					
				case B_FLEE:
					d = Math.atan2( y - ty, x - tx );
					break;
					
				case B_GET_CLOSER_CIRCLING:
					d = Math.atan2(ty - y, tx - x) + 0.2;
					break;
					
					
				default: d = 0.0; break;
			}
			
			// Accelerate
			switch ( m ) {
				case M_MOUSE_PROPULSION:
					if ( v > 0 ) v --;
					if ( v < 4 && click ) v = 12;
					break;
					
				case M_LINEAR:
					v = 2;
					break;
					
				case M_PROPULSION:
					if (t % 2) break;
					if ( v > 2 ) v--;
					else v = 6;
					break;
					
				case M_SLIDER:
					v = rand() * 4 + 2;
					
				default: v = 3; break; // No movement...
			}
			
			if ( mod == P_FROZEN && a != A_PLAYER ) v = 0;
			
			// Move
			x += v * Math.cos ( d );
			y += v * Math.sin ( d );
			if ( mod == P_FLEE && a == A_PLAYER ) y += 5;
			
			if ( a == A_PLAYER ) { tx = x; ty = y; }
			
			return d;
			
		} // End of function update
		
		public function get r ():int { return 10 - v / 8; }
		
		public function get dist():Number { return Math.sqrt( (x - tx) * (x - tx) + (y - ty) * (y - ty) ); }
		
		private function rand() : Number {			// I WANTED TO USE PERLIN NOISE BUT I DIDN'T HAVE IT!!!!
			return t / 50 + x / 1000;			// not-even-pseudo "random" function. But it kind of works nice.
		}
		
	} // End of class Entity

} // End of package