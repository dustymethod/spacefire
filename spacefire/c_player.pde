//Player class

class Player {
	//  float a;
	float waterLv = 0;
	float fuelLv = 100;
	float health=100;
	int exp;
	float intakeRate, consumptionRate;

	int w = 25; int h=25; //width and height
	float x, y; //position
	float hspd, vspd, spd;
	//#add float velocity
	float distX, distY; //distance from mouse
	float angdir; //angle of direction
	boolean isAlive;
	boolean engineIsOn;
	boolean isOverLake, isOverLaunchPad, isCollidingWithEnemy;
	boolean isOnFire, isOverFire;
	boolean isWatering, waterIsEmpty;
	float enginefc;

	Player(float xpos, float ypos) {
		x = xpos; y = ypos;
		intakeRate = 0.4;
		intakeRate = 1.5; //#testing
		consumptionRate = 1; //#consider renaming
	}

	void update() {
		//Fuel Intake,	 refuel. Fill even if engine is off.
		if (RMB && isOverLaunchPad && fuelLv < 100) {
			fuelLv += intakeRate; //fuel intake rate
			if (fuelLv>100) { //cap at 100
				fuelLv = 100;
			}
		}

		if (engineIsOn) {
			consumeFuel();
			//Player movement
			if (fuelLv > 0) { //Apply movement only if there's fuel
				//Update distance to mouse. Used to get proportional easing
				//PVector target = new PVector(mouseX, mouseY);
				//PVector position = new PVector(x, y);
				//PVector dist = new PVector(PVector.sub(target, position));
				distX = abs(mouseX - x)/150;
				distY = abs(mouseY - y)/150;
				//Update velocities
				//.5* for easing. * dist for further easing proportinal to distance from mouse.
				hspd = map(.5*(mouseX - x) * distX, -50, 50, -10, 10);
				vspd = map(.5*(mouseY - y) * distY, -50, 50, -10, 10);
				//Update position
				x += hspd*.5;
				y += vspd*.5;
				//Point towards mouse
				angdir = atan2(mouseY-y, mouseX-x)-radians(90);
				spd = abs(sqrt(sq(hspd)+sq(vspd)));
			}

			if (health>100) { //Cap health at 100
				health = 100;
			}

			//Check collision with lake, absorb water if RMB pressed
			if (isOverLake) {
				shipColor = lakeColor; //Change ship color to lake color if over lake.
				if (RMB && isOverLake) { //#doesn't take into consideration if intake rate is more than 1
					waterLv+=intakeRate;
						if (waterLv>100) //cap at 100.
						waterLv = 100;
						}
			}
			else { //if not over lake, change color back.
				shipColor = color(0);
			}

			if (LMB) { //Dispense water #promote to function
				if (waterLv > 0) {
					isWatering=true;
					//x += random(-.5, .5); //jitter effect while deploying water
					//y += random(0, 1);
					waterLv -= .3; //Decrement water level
					//dispense water
					for (int i=0; i<particle.length; i++) {
						if (!particle[i].isAlive) {
							particle[i].reset();
							break;
						}
					}
				} else if (player.waterLv<=0) {//#refactor
					player.waterLv = 0; //cap at zero
					isWatering=false;
				}
			} else {
				isWatering=false;
			}
		}
		checkCollisions();
	}

	void checkCollisions() {
		//If colliding with fire, set player.isOnFire to true, or destroy fire if water is being dispensed.
		for (int i=0; i<fire.length; i++) {
			if (fire[i].isCollidingWithPlayer && fire[i].isAlive) {
			if (!player.isWatering) { //If there's no water, set on fire to true
				player.isOnFire=true;
				} else if (player.isWatering) { //if there is water
					fire[i].destroy(); //Destroy fire
					player.isOnFire=false;
				}
			}
		}

		//If player is colliding with an enemy, apply damage
		for (int i=0; i<enemy.length; i++) {
			if (enemy[i].isCollidingWithPlayer) {
				//player.isOnFire=true;
				isCollidingWithEnemy=true;
				break;
			} else if (!enemy[i].isCollidingWithPlayer) {
				//player.isOnFire=false;
				isCollidingWithEnemy=false;
			}
		}

		if (isOnFire || isCollidingWithEnemy) { //apply damage
			damage();
		}
	}



	//if player turns of engine while being damaged. stays damage color, as it is no longer updated when
	//engine is off.

	void damage() {
		if (engineIsOn) {
			shipColor = color(damageColor);
			player.health --;
			//jitter animation effect when damaged
			x += random(0, 2);
			y += random(0, 2);
			if (health < 0) { //Make sure health does not keep decrementing. #refactor so that decrement stops at 0
				health = -1; //#change to 0?
			}
		} else {
			shipColor = color(0, 100);
		}
	}

	//Consume fuel based on player's speed
	void consumeFuel() {
		fuelLv -= .05 * map(spd, -10, 10, 0, 2);
		if (fuelLv <= 0) {
			fuelLv = 0;
		}
	}

	void reset() {
		//set position to launchpad position
		//x = launchPad.x;
		//y = launchPad.y;
	}

	void display() {
		//Ship's circular water tank
		//Transforamtions (separate so that it doesn't rotate wiht ship)
		pushMatrix();
		translate(x, y);
		scale(.5);
		translate(-x, -y);
		noStroke();
		//Water tank fill
		fill(lakeColor, map(waterLv, 0, 100, 100, 220));
		arc(x, y, 25, 25,
		radians(90 - map(player.waterLv, 0, 100, 0, 180)), radians(90 + map(player.waterLv, 0, 100, 0, 180)), OPEN);
		strokeWeight(1);//reset
		popMatrix();

		//Ship
		//Transformations
		pushMatrix();
		translate(x, y);
		rotate(angdir);
		scale(.5);
		translate(-x, -y);

		//Engine flare animation for when ship turns on
		if (fc < enginefc) {
			stroke(lakeColor, map(fc, enginefc-35, enginefc, 200, 0));
			fill(lakeColor, map(fc, enginefc-35, enginefc, 200, 0));
			ellipse(x-20, y-35-spd, 20, 20);
			ellipse(x+20, y-35-spd, 20, 20);
		}

		//Set shipColor alpha based on engineIsOn
		if (engineIsOn) {
			stroke(shipColor, map(fuelLv, 0, 100, 20, 255));
		} else if (!engineIsOn) {
			stroke(shipColor, 100);
		}
		if (fireCount<=0 && isOverLaunchPad) {
			stroke(lakeColor);
			println("stroke");
		}

		//Ship fill
		if (fuelLv > 30) {
			fill(shipColor, 60);
		}
		else
		//fill(0, map(fuelLv, 0, 30, -50, 110));
		fill(shipColor, map(fuelLv, 0, 30, -50, 110));
		strokeWeight(2);
		//Shipe shape
		beginShape();
		vertex(x-1+50, y-72+50);
		vertex(x-50+50, y-13+50);
		vertex(x-99+50, y-73+50);
		vertex(x-64+50, y-64+50);
		vertex(x-50+50, y-77+50);
		vertex(x-35+50, y-63+50);
		vertex(x-1+50, y-72+50);
		endShape();

		//Draw engine thingies
		triangle(x-10-20, y-25-2*spd, x+10-20, y-25-2*spd, x-20, y-10 -2*spd);
		triangle(x-10+20, y-25-2*spd, x+10+20, y-25-2*spd, x+20, y-10 -2*spd);

		//Water tank circular outline ring
		noFill();
		if (waterLv <=0) {
			stroke(0, map(fuelLv, 0, 100, 20, 255));
		}
		else
			stroke(lakeColor, map(waterLv, 0, 100, 50, 255));
		ellipse(x, y, 25, 25);
		popMatrix();
	}
}
