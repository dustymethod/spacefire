class Particle {
	float x, y;
	//float hspd, vspd;
	float deltaX, deltaY;
	float radius;
	boolean isAlive;
	float particlefc;
	int rate = 20;

	Particle(float xpos, float ypos) {
		//x = xpos; y = ypos;
		//deltaX = random(-2, 2); deltaY = random(-2, 2);
		//radius = (int)random(10, 50);
		//particlefc = fc +rate;
		isAlive = false;
	}

	void reset() {
		x = player.x; y = player.y;
		deltaX = random(-2, 2); deltaY = random(-2, 2);
		radius = 50 * map(player.waterLv, 0, 100, 0, 1);
		isAlive = true;
		particlefc = fc +rate;
	}

	void update() {
		if (isAlive) {
			x += deltaX*.5;
			y += deltaY*.5;
			radius *= .9;
			if (fc > particlefc) {
				isAlive = false;
			}
		}
	}

	void display() {
		if (isAlive) {
			fill(lakeColor, map(fc, particlefc-rate, particlefc, 100, 0));
			strokeWeight(1);
			stroke(lakeColor, 100);
			ellipse(x, y, map(radius, 0, 50, radius, 0), map(radius, 0, 50, radius, 0));
		}
	}
}
