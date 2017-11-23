class Fire {
	float firefc, steamfc, spreadTimer;
	float x, y;
	float w = 20; float h = 20;
	boolean isAlive;
	float distToPlayer;
	boolean isCollidingWithPlayer, isOverLake;
	boolean isStarted;
	//Fire(float xpos, float ypos, boolean a, boolean s) {
	Fire(boolean a, boolean s) {
		isStarted = s;
		isAlive = a;
		//x = xpos; y = ypos;
		reset();
	}

	void reset() {
		x =int(random(0+bufferDist, width-bufferDist));
		y =int(random(0+bufferDist, height-bufferDist));
	}

	void update() {
		if (isAlive) {
			spreadFire();
			checkCollisionWithPlayer();
			checkCollisionWithLake();

			//check bounds
			if (x>width || x < 0 || y < 0 || y > height) {
				isAlive = false;
			}
		}
	}

	void checkCollisionWithPlayer() {
		distToPlayer = dist(x, y, player.x, player.y);
		if (distToPlayer <= 15) {
			isCollidingWithPlayer=true;
			player.isOnFire=true;
		} else if (distToPlayer > 15){
			isCollidingWithPlayer=false;
			player.isOnFire=false;
		}
	}

	//Extinguish fire if it spawns or is over a lake
	void checkCollisionWithLake() {
		if(x+w/2 > lake.x-lake.w/2 && x-w/2 < lake.x+lake.w/2 &&
			y+h/2 > lake.y-lake.h/2 && y-h/2 < lake.y+lake.h/2) {
			isOverLake = true;
			destroy();
		}
	}

	//Destroy. Set alive to false, add to player exp, and chance to drop item.
	void destroy() {
		isAlive=false;
		player.exp+=1;
		playerEXP ++;
		if (player.health < 50) { //chance to drop item if health is below 50
			dropItem();
		}
	}

	void dropItem() {
		int c = int(random(0, 8));
		if (c==0) {
			for (int i=0; i<item.length; i++) {
				if (!item[i].isAlive) {
					item[i] = new Item(true, x, y);
					//println("itemDropped"); //#prints to console on each new level, for some reason.
					break;
				}
			}
		}
	}

	//spread fire
	void spreadFire() {
		if (spreadTimer < 100) { //fire spread rate
			spreadTimer += 1 + int(map(level, 0, 50, 0, 8)); //Increment
		}
		if (spreadTimer >= 100) {
			//Chance to spawn new fire. Chance increases with each level.
			int n = int(random(0, map(level, 0, 30, 10, 7)));
			//if n = 0, spawn a new fire.
			if (n == 0) {
				for (int i=0; i<fire.length; i++) {
				//Make active a fire that hasn't been made active.
				if (!fire[i].isStarted && !fire[i].isAlive) {
					fire[i] = new Fire(true, true); //Set to isStarted and isAlive
					//set to a random location close to parent fire
					fire[i].x = x +int(random(-25, 25));
					fire[i].y = y + int(random(-25, 25));
					break;
				}
			}
		}
		spreadTimer = 0; //reset spawn timer
		}
	}

	//Draw any fires that have been started
	void display() {
		if (isStarted) {
			//Draw extinguished fires
			if (!isAlive) {
				fill(fireDeadColor, 50);
				stroke(fireDeadColor, 75);

				beginShape();
				vertex(x-10, y+10);
				vertex(x, y-10); //mid point
				vertex(x+10, y+10);
				endShape();
			}
			//Draw live fires
			if (isAlive) {
				fill(fireLiveColor, 0, 0, 40);
				stroke(fireLiveColor, 0, 0, 180);

				beginShape();
				vertex(x-10, y+10);
				vertex(x, y-10 -int(random(0, 5)));
				vertex(x+10, y+10);
				endShape();
			}
		}
	}

	//void drawSteam() {
	//}
}
