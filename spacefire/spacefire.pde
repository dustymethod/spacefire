//nov_05_2015
//
//player,  enemies hud, enemies,
//level(spawns and draws landing pad, green strip, spawn enemies),
//flow elements: speed, speed of level completion, reward:
//Check the "info" tab for more information.
//
////add://
//upgrades: more health, fuel economy, water tank, intake rate, larger water area/hit box
//water ripple effect when over water.
//fix player ship push pop matrixes: merge
//animation for water intake; reverse water particle effect
//screen edges darken if water or fuel low?
//optimize enemy speed increment per level. float to int
//relax mode, and challenge mode. relax mode, enemy speed and size, and fire spread rate do not increase.
//controls, rules, instructions
//game pause if engine off?
//notification, or something to indicate when water or fuel level is low. blinking red light? triangle ! mark?
//do not: get rid of player.isOnFire, replace with damage(). otherwise damage will stack.
//void cleanup();
//refactor: color handler
//have ring color flash white instead of whole ship wne picking up item.
//larger fires that requre more water. drop items.
//player color starting as damaged color.
//issue with turning engine off while applying damage.
//pickup item initial collision. flash white when item picked up.
//increment color or h on absorbing water
//enemy[i].isCollidingWithPlayer vs player.isCollidingWithEnemy
//functions player.reset, launchpad.randomize
//refactor and rename colors
//if fuel runs out, turn engine off
//less time, better score. more fires put out, more upgrades; lower score. (bonuses for speed, and few items.)
//make enemy speeds same for each enemy
//A: upgrades based on level and exp, or upgrades based on random dropped items. drops can be upgrades or health repair kits.
//particle style: lines
//instruction: p to pause
//tutorial: enemy and health
//tutorial level condition. if fuel runs out, return player to launch pad.
//bonus for completing level within time limit. if goes over, time red.
//fix fuel particle animation and handling
//change level to stage
//upgrades each fire = exp point / lv?
//on level up, choose stat to upgrade(speed, health, fuel efficience, intake rate, water tank size)
//player upgrade menu. if game won
//hp does not restore after each level.
////fires sometimes drop healt potions/repair kits.
//description/key features, controls, instructions
//add fuel tip after first level complete.
//level progression: enemy speed, size, number of enemies, type of enemy, lake size, fire spread rate
//  boss fight
// special types of enemy: drain water, fuel, spread fires.
//add reason why player died. ran out of fuel, died
//handle how fires spread, rate
//score. refueling decreases score? final score: fires extinguished, fuel consumed, pixels travelled? times restarted? total time played?
//add later://
//if taking damage, jitter or make red health bar
//more complex enemy animation. angles, sin, follow player
//add animation for finishing level, ship teleporting out/in to new level
//add glow effects png to vector shapes
//increment color over time? tint based on prox to screen bounds? fire color change over time?
//if game not running or paused, display instructions
//make refueling animation more obvious
//color change on proximity to fire/heat

////problems
//player color doesnt reset if game reset, and player was over lake
//launch pad still spawns on top of lake
//>>>on game won or lost, diff button for restart/reset? game over screen displays too quickly-player might skip it by mistake.
//fire collision. player sometimes isn't damaged. isWatering
//fix collisions


//Declare variables
PImage screenShadow;

//Input
boolean LMB, RMB;

//Gamestates
boolean gameRunning, gameWon, gameLost, gamePaused, gameTutMode;

//Game variables
int fc; //Frame count
int level;
int bufferDist = 75; //Used so that elements don't spawn close to borders
boolean tutorialMode;
int tutPage =1; //tutorial page index
String instrText = ""; //string used to display instructions

//Custom colors. Initialized in setupColors() function.
color shipColor; //Ship's color
color bgColor; //Background color
color fireLiveColor, fireDeadColor; //colors for live and extinguished fires
color lakeColor, enemyColor, damageColor, particleColor;
int h, s, b; //HSB variables used for varying colors. see setupColors();
//int theme; #add player option to choose custom color hue

//Classes and class variables
Player player;
int playerEXP; //Player Stats #notused
float playerHealth; //Health persistent between levels.

Lake lake;

LaunchPad launchPad;

Parallax[] parallax = new Parallax[20];

Item[] item = new Item[10];

int fireCount;
int maxNumFires = 300; //lag at 400
Fire[] fire= new Fire[maxNumFires];

int maxNumEnemies = 4;
Enemy[] enemy = new Enemy[maxNumEnemies];

Particle[] particle = new Particle[40];



//Runs once at start of program
void setup() {
	size (640, 480); //Set window width and height
	background(0); //Set default background
	//frameRate(60);
	screenShadow = loadImage("screenshadow.png");

	resetGame(); //Initialize variables and classes
}

//Runs always
void draw() {
	background(bgColor); //Refresh
	runGame(); //Run the game code
}


void resetGame() {
	//Reset game variables
	fc = 0; //Reset timer

	level=1; //Reset level
	gameRunning=false; //Reset game state to not running (not started)
	tutorialMode = false;
	tutPage = 1; //Reset tutorial page index

	resetElements(); //Reset elements

	playerHealth = player.health; //set persistent health
}



//Initialize/reset classes and vairables
void resetElements() {
	setupColors(); //Randomize colors
	//Reset game states
	gameWon = false;
	gameLost = false;
	gamePaused = false;
	fc = 0; //Reset timer

	//Initialize classes
	lake = new Lake();
	launchPad = new LaunchPad();
	player = new Player(launchPad.x, launchPad.y); //Init player at launchPad's position

	//Initialize parallax array
	for (int i=0; i<parallax.length;i++) {
		parallax[i] = new Parallax();
	}

	//Initialize enemy array
	for (int i=0; i<maxNumEnemies; i++) {
		enemy[i] = new Enemy(i);
	}

	//Initialize water particles
	for (int i=0; i<particle.length; i++) {
		particle[i] = new Particle(player.x, player.y);
	}

	//Initialize fires, set isAlive and isStarted to false
	for (int i=0; i<maxNumFires;i++) {
		fire[i] = new Fire(false, false);
	}
	//Reinitialize, the number of fires level started is based on the current level.
	for (int i=0; i<level;i++) {
		fire[i] = new Fire(true, true);
		fire[i].checkCollisionWithLake();
		//If a fire spawns over the lake, respawn again. Prevents fires from spawning on the lake.
		while (fire[i].isOverLake) {
			fire[i] = new Fire (true, true);
			fire[i].checkCollisionWithLake();
		}
	}

	//Initialize items
	for (int i=0; i<item.length; i++) {
		item[i] = new Item(false, 0, 0);
	}
}



//Reset only some classes and vairables
//Original lake and launchPad positions stay the same.
void resetLevel() {
	fc = 0; //Reset timer
	gameWon = false;
	gameLost = false;
	gamePaused = false;

	//Reinitialize and reset certan classes
	launchPad.reset();
	player = new Player(launchPad.x, launchPad.y); //Reset player's position to launch pad's position
	player.health = playerHealth;

	//Initialize enemy array
	for (int i=0; i<maxNumEnemies; i++) {
		enemy[i] = new Enemy(i);
	}

	//Initialize fires, set isAlive and isStarted to false
	for (int i=0; i<maxNumFires;i++) {
		fire[i] = new Fire(false, false);
	}
	//Reinitialize, the number of fires level started is based on the current level.
	for (int i=0; i<level;i++) {
		fire[i] = new Fire(true, true);
		fire[i].checkCollisionWithLake();
		//If a fire spawns over the lake, respawn again. Prevents fires from spawning on the lake.
		while (fire[i].isOverLake) {
			fire[i] = new Fire (true, true);
			fire[i].checkCollisionWithLake();
		}
	}

	//Initialize items
	for (int i=0; i<item.length; i++) {
		item[i] = new Item(false, 0, 0);
	}
}



//Increment level, save player health, and resetElements()
//#persistent
void loadNextLevel() {
	level++;
	playerHealth = player.health;
	resetElements();
	player.health = playerHealth;
}




//Run game: update and display game elements
void runGame() {
	//If game has been started, and has not been won, lost, or paused
	if (gameRunning && !gamePaused && !gameWon && !gameLost) {
		updateElements(); //Update classes and movement
		updateGameState(); //Check win/lose conditions, and updat game state
	}
	displayElements(); //Display elements, even if game is paused, won, or lost.
}



//Update elements
void updateElements() {
	fc++; //Increment frame count
	player.update();
	lake.update();
	launchPad.update();
	for (int i=0; i<parallax.length; i++) {
		parallax[i].update();
	}

	for (int i=0; i<maxNumEnemies; i++) {
		enemy[i].update();
	}

	for (int i=0; i<maxNumFires; i++) {
		fire[i].update();
	}

	for (int i=0; i<particle.length; i++) {
		particle[i].update();
	}

	for (int i=0; i<item.length; i++) {
		item[i].update();
	}
}




//Check conditions for winning or losing
void updateGameState() {
	//Keep track of how many fires are left
	fireCount=0;
	for (int i=0; i<fire.length; i++) {
		if (fire[i].isAlive) {
			fireCount++;
		}
	}

	//WIN Condition: If all fires are out, and the player lands on the launch pad.
	if (fireCount == 0 && player.isOverLaunchPad && !player.engineIsOn) {
		gameWon = true;
	}

	//LOSE Condition: Player loses the level if health or fuel run out.
	if (player.fuelLv <= 0 || player.health <= 0) {
		gameLost = true;
	}
}



//Display updated elements, or pause/win/lose/start screens, depending on game state.
void displayElements() {

	//Display floating particles in background
	for (int i=0; i<parallax.length; i++) {
		parallax[i].display();
	}

	//Display ship's water particles when dispensed
	for (int i=0; i<particle.length; i++) {
		particle[i].display();
	}

	//Darkens screen edges
	imageMode(CORNER);
	image(screenShadow, 0, 0, width, height);

	lake.display(); //Display lake

	//Display any fires
	for (int i=0; i<maxNumFires; i++) {
		fire[i].display();
	}

	//Display any items
	for (int i=0; i<item.length; i++) {
		item[i].display();
	}

	//Display Enemies
	for (int i=0; i<enemy.length; i++) {
		enemy[i].display();
	}

	launchPad.display();
	player.display();
	displayHUD();

	//Draw level indicator at beginning of level, which fades out
	if (fc < 70) {
		fill(lakeColor, map(fc, 0, 70, 150, 0));
		noStroke();
		rectMode(CENTER);
		rect(width/2, height-40, width, 50 - map(fc, 0, 70, 0, 10));

		fill(0, map(fc, 50, 70, 200, 0));
		textAlign(CENTER);
		text("Level " + level, width/2, height-35);
	}

	//If gameLost conditions met, display lose screen
	if (gameLost) {
		drawLoseScreen();
	}
	//If gameWon conditions met, display win screen
	else if (gameWon) {
		drawWinScreen();
	}
	//If gamePaused, display pause screen
	else if (gamePaused) {
		drawPauseScreen();
	}
	//If game is not yet started, draw the start screen or tutorial screen
	else if (!gameRunning) {
		drawStartScreen();
		if (tutorialMode) {
			drawTutScreen();
		}
	}
}




//Draw start screen
void drawStartScreen() {
	//Start screen background
	noStroke();
	fill(0);
	rectMode(CORNER);
	rect(0, 0, width, height);

	//Animated triangle symbol
	for (int i=0; i<3; i++) {
		fill(lakeColor, int(random(23, 27)));
		stroke(lakeColor, 80);
		beginShape();
		vertex(width/3 +10*i*i, height/3*2);
		vertex(width/2 +int(random(-3, 3)), height/3 +15*i*i);
		vertex(width/3*2 -10*i*i, height/3*2);
		endShape();
	}
	//Draw start screen text
	fill(255);
	textAlign(CENTER);
	textSize(17);
	text("SPACE FIRE", width/2, height/2 + 25); //Title
	textSize(12);
	text("Press LMB to start", width/2, height/2+100);
	fill(255, 100);
	text("Press RMB for tutorial", width/2, height/2+115);
	textAlign(LEFT);//reset
}

//Draw pause screen
void drawPauseScreen() {
	//Draw pause screen background
	fill(0, 150);
	noStroke();
	rectMode(CORNER);
	rect(0, 0, width, height);

	//Draw pause screen text
	fill(255);
	textAlign(CENTER);
	text("Game Paused", width/2, height/2);
	text("Press p to resume", width/2, height/2 + 15);
}

//Draw win screen
void drawWinScreen() {
	fill(0, 80);
	noStroke();
	rectMode(CORNER);
	rect(0, 0, width, height);

	//fill(255);
	fill(lakeColor);
	textAlign(CENTER);
	textSize(15);
	text("Level " + level + " Completed!", width/2, height/2 -20);
	textSize(12); //reset
	text("You took " +nf((float)fc/60, 1, 2) + " seconds.", width/2, height/2);
	text("LMB: continue | RMB: quit", width/2, height/2 +20);
}

//Draw lose screen
void drawLoseScreen() {
	fill(10, 0, 0, 80);
	noStroke();
	rectMode(CORNER);
	rect(0, 0, width, height);

	fill(0);
	textAlign(CENTER);
	if (player.fuelLv <=0) {
		textSize(15);
		text("Your ship ran out of fuel! Restart level?", width/2, height/2 -20);
	}
	else if (player.health <=0) {
		textSize(15);
		text("Your ship's busted! Restart level?", width/2, height/2 -20);
	}
	textSize(12); //reset
	text("LMB: restart | RMB: reset", width/2, height/2 );
}



//Display HUD elements: frame count, current level, health, fuel, and water bars.
void displayHUD() {
	//set opacity and fill values for bars
	int guageOpacity = 80;
	int strokeOpacity = 200;

	//Display frame count
	fill(lakeColor);
	textAlign(RIGHT);
	text(""+nf((float)fc/60, 1, 2), width-20, 20);

	//display level
	fill(lakeColor);
	textAlign(RIGHT);
	text("Lv. "+level, width-20, 35);

	//Dislay circular water bar
	//Fill
	noStroke();
	fill(lakeColor, guageOpacity);
	//The arc's "height" determined by the player's water level.
	arc(width-37, height-40 , 50, 50, radians(90 - map(player.waterLv, 0, 100, 0, 180)), radians(90 + map(player.waterLv, 0, 100, 0, 180)), OPEN);
	//Outline
	noFill();
	stroke(lakeColor, strokeOpacity);
	ellipse(width-37, height-40, 50, 50);
	fill(lakeColor, 255);
	textAlign(CENTER);
	text("" + int(player.waterLv) + "%", width-36, height-36);

	//Fuel bar
	//Fill
	fill(0, guageOpacity);
	noStroke();
	rectMode(CORNERS);
	//Rect height determined by the player's fuel level.
	rect(595+16-7, height-15-60, 595+16+7, map(player.fuelLv, 0, 100, height-15-60, height-15-60-60));
	//Outline
	fill(0, 0);
	stroke(0, strokeOpacity);
	rectMode(CENTER);
	rect(595+16, height-45-60, 20-6, 60);

	//Health bar
	//Fill
	fill(255, guageOpacity);
	noStroke();
	rectMode(CORNERS);
	//Rect height determined by the player's health level.
	rect(595-3-7, height-15-60, 595-3+7, map(player.health, 0, 100, height-15-60, height-15-60-60));
	//Outline
	fill(0, 0);
	stroke(255, strokeOpacity);
	rectMode(CENTER);
	rect(595-3, height-45-60, 20-6, 60);
}



//Colors are randomized for each level.
//Most colors share the same hue; their saturation and brightness vary.
void setupColors() {
	colorMode(HSB, 359, 100, 100);
	int h = int(random(0, 360));
	int s = int(random(0, 101));
	int b = int(random(0, 101));
	bgColor = color(h, 12, map(b, 0, 101, 30, 50));
	fireLiveColor = color(h, 79, 81);
	fireDeadColor = color(h, 43, 40);
	lakeColor = color(h, 34, 98);
	enemyColor = color(h, s, b);
	//shipColor = color(h, 80, 70);
	damageColor = color(h, 75, 60);
	particleColor = color(h, s, 100);
	//colorMode(RGB); //reset
}





//Draw Tutorial Screen
void drawTutScreen() {

	//Tutorial ackground
	noStroke();
	rectMode(CENTER);
	fill(0, 200);
	rect(width/2, height/2, width, height);

	switch (tutPage) {
		case 1: //Page 1: Legend
			//Scroll bar selected
			strokeWeight(1);
			fill(255, 50);
			stroke(255, 200);
			rectMode(CENTER);
			rect(width-25, height/2 -15, 10, 30);

			//Header
			fill(255);
			textAlign(CENTER);
			text("- LEGEND -", width/2, 25);


			//Player Ship//
			pushMatrix();
			translate(width/3, height/3);
			fill(255);
			text("Player Ship", 0, 0);
			scale(.5);
			rotate(radians(180));

			//Water tank
			fill(255);
			arc(0, 0, 25, 25, radians(-180), radians(0), OPEN);

			//Ship
			fill(255, 50);
			stroke(255);
			strokeWeight(2);
			beginShape();
			vertex(0-1+50, 0-72+50);
			vertex(0-50+50, 0-13+50);
			vertex(0-99+50, 0-73+50);
			vertex(0-64+50, 0-64+50);
			vertex(0-50+50, 0-77+50);
			vertex(0-35+50, 0-63+50);
			vertex(0-1+50, 0-72+50);
			endShape();

			//Draw engine thingies
			triangle(0-10-20, 0-25-2, 0+10-20, 0-25-2, 0-20, 0-10 -2);
			triangle(0-10+20, 0-25-2, 0+10+20, 0-25-2, 0+20, 0-10 -2);

			//Draw circular water tank ouline
			noFill();
			ellipse(0, 0, 25, 25);
			strokeWeight(1); //reset
			popMatrix();


			//Draw lake//
			pushMatrix();
			translate(width/3*2, height/3);
			fill(255);
			text("Lake", 0, 0);
			fill(255, 5);
			stroke(255, 18);
			ellipse(0 - parallax[0].bufferX, 0 - parallax[0].bufferY, 70, 70);
			stroke(lakeColor, 40);
			ellipse(0 - parallax[0].bufferX *.5, 0 - parallax[0].bufferY*.5, 60, 60);
			fill(255, 10);
			stroke(255);
			ellipse(0, 0, 80, 80);
			popMatrix();


			//Draw LaunchPad//
			pushMatrix();
			translate(width/3, height/2);
			fill(255);
			text("Launch Pad / Teleporter", 0, 0);

			//launchPad parallax shadow effect
			rectMode(CENTER);
			noFill();
			strokeWeight(1);
			stroke(255, 50);
			rect(0 - parallax[0].bufferX *.5, 0 - parallax[0].bufferY*.5, launchPad.w-2, launchPad.h-2);
			rectMode(CORNER); //reset

			//Draw X lines on launch pad
			stroke(255, 100);
			line(0-launchPad.w/2, 0-launchPad.h/2, 0+launchPad.w/2, 0+launchPad.w/2);
			line(0-launchPad.w/2, 0+launchPad.h/2, 0+launchPad.w/2, 0-launchPad.h/2);
			popMatrix();


			//Draw Fire//
			pushMatrix();
			translate(width/3, height/3*2);
			fill(255);
			text("Fire", 0, 0);
			fill(255, 40);
			stroke(255, 180);
			beginShape();
			vertex(0-10, 0+10);
			vertex(0, 0-10 -int(random(0, 5)));
			vertex(0+10, 0+10);
			endShape();
			popMatrix();


			//Draw Enemy//
			pushMatrix();
			translate(width/3*2,height/2);
			fill(255);
			text("enemy", 0, 0);
			//rotate();
			fill(255, 50);
			stroke(255);
			rectMode(CENTER);
			rect(0, 0, enemy[0].w, enemy[0].h);
			popMatrix();


			//Draw Item//
			pushMatrix();
			translate(width/3*2, height/3*2);
			fill(255);
			text("Item", 0, 0);
			fill(255, 170);
			stroke(255, 200);
			beginShape();
			vertex(0-item[0].w, 0+item[0].h);
			vertex(0, 0-item[0].h); //middle point
			vertex(0+item[0].w, 0+item[0].h);
			endShape();
			popMatrix();
			break;

		case 2: //Page 2:
			//Scroll bar selected
			rectMode(CENTER);
			strokeWeight(1);
			fill(255, 50);
			stroke(255, 200);
			rect(width-25, height/2, 10, 30);

			//Header
			fill(255);
			textAlign(CENTER);
			text("- CONTROLS -", width/2, 25);

			int t = 25;
			//Instruction Text
			textAlign(LEFT);
			//text("Mouse: Steer the ship", width/3, t*6);
			text("Scroll: Switch the ship's engine on/off", width/3, t*7);
			text("LMB: Hold to dispense water", width/3, t*8);
			text("RMB: Hold while over a lake to refill water", width/3, t*9);
			text("RMB: Hold while over the launch pad to refuel", width/3, t*10);

			text("P: pause", width/3, t*12);
			text("R: reset game", width/3, t*13);
			text("Q: take screenshot", width/3, t*14);
			textAlign(CENTER);//reset
			break;

		case 3: //
			//Scroll bar selected
			strokeWeight(1);
			fill(255, 50);
			stroke(255, 200);
			rectMode(CENTER);
			rect(width -25, height/2 +15, 10, 30);

			//Header
			fill(255);
			textAlign(CENTER);
			text("- RULES -", width/2, 25);

			int u = 25;
			//Rules
			textAlign(LEFT);
			text("Goal: Put out all the fires.", width/3, u*7);
			text("Land on the launchpad to complete the level.", width/3, u*8);
			text("Avoid being damaged by fire or enemies.", width/3, u*9);
			text("Remember to keep your ship fuelled.", width/3, u*10);
			text("If your health is low, fires may drop healing items.", width/3, u*11);
			break;

		default:
			tutPage=1;
	}
	//Scroll bars
	strokeWeight(1);
	fill(200,50);
	noStroke();
	rect(width-25, height/2, 10, 60);

	fill(255);
	textAlign(CENTER);
	text("LMB: Start  |  RMB: back", width/2, height-20);
}