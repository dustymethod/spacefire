//Contains stationary game classes//
//class Lake
//class Launchpad
//class Parallax

class Lake {
	float x, y;
	int w, h;
	//Lake(float xpos, float ypos, int hie, int wid) {
	Lake() {
		//x = xpos;
		//y = ypos;
		//w = wid;
		//h = hie;
		x = int(random(0+100, width-200)); //x, y, width, height (+specific buffer distance)
		y = int(random(0+100, width-200));
		w = int(random(150, 200)) - int(map(level, 10, 30, 10, 30)); //#refactor: move all this stuff into a randomize() func
		h = int(random(150, 200))- int(map(level, 10, 30, 10, 30));
	}

	void update() {
		////check collision with player
		if (dist(x, y, player.x, player.y) <= w/2) {
			player.isOverLake=true;
		} else
			player.isOverLake=false;
		}

		void display() {
		//lake parallax effects
		fill(lakeColor, 5);
		stroke(lakeColor, 18);
		ellipse(x - parallax[0].bufferX, y - parallax[0].bufferY, w-20, w-20);
		stroke(lakeColor, 40);
		ellipse(x - parallax[0].bufferX *.5, y - parallax[0].bufferY*.5, w-10, w-10);

		fill(lakeColor, 10);
		stroke(lakeColor);
		ellipse(x, y, w, w);
	}
}




class LaunchPad {
	float distToPlayer;
	float x, y;
	int w = 35; int h = 35;
	float[] fctest = new float[2];
	//LaunchPad(float xpos, float ypos) {
	LaunchPad() {
		//x = xpos;
		//y = ypos;
		//fctest[0] = 0;
		//fctest[1] = 0;
		x = int(random(0+bufferDist, width-bufferDist));
		y = int(random(0+bufferDist, height-bufferDist)); //randomize location
		while (dist(x, y, lake.x, lake.y) <= lake.w/2) { //if over lake, respawn again
			x = int(random(0+bufferDist, width-bufferDist));
			y = int(random(0+bufferDist, height-bufferDist)); //randomize location
		}
	}
	void reset() {
		fctest[0] = 0;
		fctest[1] = 0;
	}

	//Check collision with player
	void update() {
		distToPlayer = dist(x, y, player.x, player.y);
		if (distToPlayer < 15) {
			player.isOverLaunchPad = true;
		}
		else {
			player.isOverLaunchPad = false;
		}
	}

	void display() { //#refactor
		//launchPad parallax shadow effect
		noFill();
		stroke(0, 50);
		rect(x - parallax[0].bufferX *.5, y - parallax[0].bufferY*.5, w-2, h-2);

		//If all fires out, display pulsing effect
		if (fireCount <=0) {
			if (fctest[0] < fc) {
				fctest[0] = fc+40;
			}
			if (fc < fctest[0]) {
				//Inner pulse
				stroke(lakeColor, 50);
				rect(x, y, 0 +map(fc, fctest[0]-40, fctest[0], 0, w),
					0 +map(fc, fctest[0]-40, fctest[0], 0, h));
				//Outer pulse
				stroke(lakeColor, map(fc, fctest[0]-40, fctest[0], 200, 0));
				rect(x, y, w +map(fc, fctest[0]-40, fctest[0], 0, 20),
					h +map(fc, fctest[0]-40, fctest[0], 0, 20));
			}
		}

		//If player is refuelling, display pulsing effect
		if (RMB && player.isOverLaunchPad) {
			if (fctest[1] < fc) {
				fctest[1] = fc+40;
			}
			if (fc < fctest[1]) {
				//Pulsing lines
				strokeWeight(map(fc, fctest[1]-40, fctest[1], .1, 1.3));
				stroke(0, map(fc, fctest[1]-40, fctest[1], 0, 150));
				rect(x, y,  w +map(fc, fctest[1]-40, fctest[1], 25, 0),
					h +map(fc, fctest[1]-40, fctest[1], 25, 0));
				fill(0, map(fc, fctest[1]-40, fctest[1], 100, 0));
				rect(x, y, w, h);
			}
		}

		//Draw launch pad X lines
		//If player is over launch pad, set stroke alpha to darker
		if (player.isOverLaunchPad) {
			stroke(0);
		}
		//If player is not over launch pad, set stroke alpha to lighter
		else if (!player.isOverLaunchPad) {
			stroke(0, 100);
		}
		//Draw X lines on launch pad
		line(x-w/2, y-h/2, x+w/2, y+w/2);
		line(x-w/2, y+h/2, x+w/2, y-h/2);

		//Draw launchpad , set color based on if player's engine is on, or if no over launchpad
		if (player.engineIsOn || !player.isOverLaunchPad) {
			fill(0, 20);
			stroke(0, 20);
		} else {
			fill(0, 50);
			stroke(0, 175);
		}
		rectMode(CENTER);
		rect(x, y, w, h);

		//If win condition possible, when player is over the launch pad, draw light outline
		if (fireCount <=0) {
			noFill();
			if (player.engineIsOn && player.isOverLaunchPad) {
				stroke(lakeColor, 110);
			} else if (!player.engineIsOn && player.isOverLaunchPad) {
				stroke(lakeColor);
			}
			rect(x, y, w, h);

			//Draw light points on launch pad
			strokeWeight(2);
			strokeWeight(2);
			stroke (255);
			point(x-w/2, y-h/2);
			point(x+w/2, y-h/2);
			point(x-w/2, y+h/2);
			point(x+w/2, y+h/2);
			point(x, y);
			strokeWeight(1);//reset
		}
	}
}


//stars in background effect
class Parallax {
	float x, y;
	float bufferX, bufferY;
	int depth;
	//Parallax(float xpos, float ypos, int d) {
	Parallax() {
		//x = xpos;
		//y = ypos;
		//depth = d; //0 = closest

		x = int(random(0, width));
		y = int(random(0, height));
		depth = int(random(0, 2));
	}

	void update(){
		bufferX = map(player.x, 0, width, -30, 30);
		bufferY = map(player.y, 0, height, -30, 30);
	}

	void display() {
		float dist = dist(x, y, height/2, width/2);
		stroke(particleColor, map(dist, 0, 100, 80, 250));
		if (depth == 0) {
			strokeWeight(1.4);
			stroke(particleColor, 170);
			point(x-bufferX*.3, y-bufferY*.3);
		} else if (depth == 1) {
			strokeWeight(1.1);
			stroke(particleColor, 100);
			point(x -bufferX*.05, y -bufferX*.05);
		}
		strokeWeight(1); //reset
	}
}
