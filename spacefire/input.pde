//char keyPressed(char k) {
void keyPressed() {
	if (key == 'q') {
		saveFrame("screenshot-######.jpg");
	}
	if (key == 'r') { //reset game
		resetGame();
	}
	if (gameRunning) {
		if (key == 'p') {
			//pause game
			if (gamePaused) {
				gamePaused = false;
			} else if (!gamePaused) {
				gamePaused = true;
			}
		}
	}
	//return k;
}


//Mouse Events//
void mousePressed() {
	if (mouseButton == LEFT) {
		LMB = true;
		if (!gameRunning) {
			gameRunning = true; //If game not running, start game
		}
		if (gameWon) {
			loadNextLevel();
		}
		if (gameLost) {
			resetLevel();
		}
	}

	//water & fuel intake
	if (mouseButton == RIGHT) {
		RMB = true;
		if (!gameRunning) {
			if (!tutorialMode) { //Show Hide tutorial
				tutorialMode = true;
				tutPage=0;
			} else {
				tutorialMode = false;
			}
			println(tutorialMode);
		}

		if (gameLost || gameWon) {
			resetGame();
		}
	}
}

void mouseReleased() {
	if (mouseButton == LEFT) {
		LMB = false;
	}
	if (mouseButton == RIGHT) {
		RMB = false;
	}
}

//Turn engine on or off
void mouseWheel(MouseEvent event) {
	float e = -1*event.getCount(); //scrolling up returns 1, down returns -1
	if (gameRunning && !gamePaused && !gameWon && !gameLost) {
		if (e>0 && !player.engineIsOn) {//Only turn engine on once.
			player.engineIsOn= true;
			player.enginefc = fc+45; //set engine fc animation frame counter
		} else if (e<0) {
			player.engineIsOn = false;
		}
	} else if (tutorialMode) {
		if (e<0) {
			if (tutPage<3) {
				tutPage++; //page up
			}
		}
		else if (e>0) {
			if (tutPage>1) {
				tutPage--; //page down
			}
			if (tutPage<1) {
				tutPage=1;
			}
		}
		println(tutPage);
	}
}
