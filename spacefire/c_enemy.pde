class Enemy {
	float w = 20; float h = 20;
	float x, y;
	float hspd, vspd;
	boolean isAlive;
	boolean isCollidingWithPlayer;
	float distToPlayer;
	float ang; //Angle of rotation in radians
	Enemy(int i) {
		//w = 20*map(level, 0, 25, 1, 4);
		//h = 20*map(level, 0, 25, 1, 4);
		w = 20 + map(level, 0, 25, 0, 40);
		h = 20 + map(level, 0, 25, 0, 40);
		isAlive = true;

		switch (i) { //Set default positions at screen corners
			case 0:
				x = 0+50;
				y = 0+50;
				break;
			case 1:
				x = width-50;
				y = 0+50;
				break;
			case 2:
				x = 0+50;
				y = height-50;
				break;
			case 3:
				x = width-50;
				y = height-50;
				break;
		}
		randomize();
	}

	void randomize() {
		float spd;
		//randomize velocities & direction, reset width and height
		if (level <8) {
			spd = map(level, 1, 7, 1, 1.5);
			hspd = (-1 + (int)random(2) * 2) * spd;
			vspd = (-1 + (int)random(2) * 2) * spd;
		}
		else if (level >=8)  {
			spd = map(level, 8, 25, 1.5, 3.5);
			hspd = (-1 + (int)random(2) * 2) * spd;
			vspd = (-1 + (int)random(2) * 2) * spd;
		}
	}

	void update() {
	//if (isAlive) {
	//Movement and rotation animation
	x+=hspd;
	y+=vspd;
	ang +=.05;

	//check bounds, bounce if enemy hits boundary.
	if (x < 0){
		x = 0;
		hspd= hspd * -1;
	}
	if (x > width) {
		x = width;
		hspd= hspd * -1;
	}
	if (y < 0) {
		y = 0;
		vspd = vspd * -1;
	}
	if (y > height) {
		y = height;
		vspd= vspd * -1;
	}

	checkCollisionWithPlayer();
	}

	void checkCollisionWithPlayer() {
		distToPlayer = dist(x, y, player.x, player.y);
		for (int i=0; i<enemy.length; i++) {
			if (player.engineIsOn && !player.isOverLaunchPad) {
				if (enemy[i].distToPlayer < 20+w/4) {
					enemy[i].isCollidingWithPlayer=true;
					//player.isCollidingWithEnemy=true;
				} else {
					enemy[i].isCollidingWithPlayer=false;
					//player.isCollidingWithEnemy=false;
				}
			}
		}
	}

	void display() {
		//if (isAlive) {
		pushMatrix();
		translate(x, y);
		rotate(ang);
		translate(-x, -y);
		fill(enemyColor, 50);
		stroke(enemyColor);
		rectMode(CENTER);
		rect(x, y, w, h);
		popMatrix();
		//}
	}
}
