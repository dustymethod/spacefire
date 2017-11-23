class Item {
	float x, y;
	int health;
	boolean isAlive;
	int dropChance;
	int w = 14/2; int h = 14/2;
	float itemfc;
	float distToPlayer;
	float itemfc02;
	Item(boolean a, float xpos, float ypos) {
		isAlive = a;
		x = xpos;
		y = ypos;
		itemfc = 0;
		itemfc02 = fc+14;
	}
	void update() {
		//check collision with player
		distToPlayer = dist(x, y, player.x, player.y);
		if (distToPlayer < 15 && isAlive) {
			shipColor = color(255);
			if (fc > itemfc02) {
				destroy();
			}
		}
	}
	//void drop() {
	//}
	void destroy() {
		//Restore a percentage of player;s health if picked up
		player.health *= 1.2;
		isAlive=false;
	}
	void display() {
		if (isAlive) {
			//set pulsing glow color for items
			if (itemfc < fc) {
				itemfc = fc+100;
			}
			if (fc <= itemfc-50) {
				fill(255, map(fc, itemfc-100, itemfc-50, 1, 180));
				stroke(255, map(fc, itemfc-100, itemfc-50, 100, 200));
			} else if (fc <= itemfc && fc > itemfc-50) {
				fill(255, map(fc, itemfc-50, itemfc, 180, 1));
				stroke(255, map(fc, itemfc-50, itemfc, 200, 100));
			}
			beginShape();
			vertex(x-w, y+h);
			vertex(x, y-h); //middle point
			vertex(x+w, y+h);
			endShape();
		}
	}
}
