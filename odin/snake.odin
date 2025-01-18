package example

import rl "vendor:raylib"
SNAKE_LENGTH :: 256
SQUARE_SIZE :: 31

Snake :: struct {
	position: rl.Vector2,
	size:     rl.Vector2,
	speed:    rl.Vector2,
	color:    rl.Color,
}
Food :: struct {
	position: rl.Vector2,
	size:     rl.Vector2,
	active:   bool,
	color:    rl.Color,
}
screenWidth :: 800
screenHeight :: 450

framesCount := 0
gameOver := false
pause := false

fruit: Food

snake: [SNAKE_LENGTH]Snake
snakePosition: [SNAKE_LENGTH]rl.Vector2

allowMove := false
offset: rl.Vector2 = {0, 0}

counterTail := 0

main :: proc() {
	rl.InitWindow(screenWidth, screenHeight, "Snake")
	initGame()
	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {
		updateDrawFrame()
	}

	rl.CloseWindow()
}

initGame :: proc() {
	framesCount = 0
	gameOver = false
	pause = false

	counterTail = 1

	allowMove = false

	offset.x = screenWidth % SQUARE_SIZE
	offset.y = screenWidth % SQUARE_SIZE
	for i := 0; i < len(snake); i += 1 {
		snake[i].position = rl.Vector2{offset.x / 2, offset.y / 2}
		snake[i].size = rl.Vector2{SQUARE_SIZE, SQUARE_SIZE}
		snake[i].speed = rl.Vector2{SQUARE_SIZE, 0}
		if i == 0 {
			snake[i].color = rl.BLACK
		} else {
			snake[i].color = rl.BLUE
		}
	}
	for i := 1; i < len(snakePosition); i += 1 {
		snakePosition[i] = rl.Vector2{0, 0}
	}
	fruit.size = rl.Vector2{SQUARE_SIZE, SQUARE_SIZE}
	fruit.color = rl.SKYBLUE
	fruit.active = false
}
updateGame :: proc() {
	if (!gameOver) {
		if (rl.IsKeyPressed(.P)) {
			pause = !pause
		}
		if (!pause) {
			if (rl.IsKeyPressed(.RIGHT) && (snake[0].speed.x == 0) && allowMove) {
				snake[0].speed = rl.Vector2{SQUARE_SIZE, 0}
				allowMove = false
			}
			if (rl.IsKeyPressed(.LEFT) && (snake[0].speed.x == 0) && allowMove) {
				snake[0].speed = rl.Vector2{-SQUARE_SIZE, 0}
				allowMove = false
			}
			if (rl.IsKeyPressed(.UP) && (snake[0].speed.y == 0) && allowMove) {
				snake[0].speed = rl.Vector2{0, -SQUARE_SIZE}
				allowMove = false
			}
			if (rl.IsKeyPressed(.DOWN) && (snake[0].speed.y == 0) && allowMove) {
				snake[0].speed = rl.Vector2{0, SQUARE_SIZE}
				allowMove = false
			}
			for i in 0 ..< counterTail {
				snakePosition[i] = snake[i].position
			}
			if (framesCount % 5 == 0) {
				for i in 0 ..< counterTail {
					if (i == 0) {
						snake[0].position.x += snake[0].speed.x
						snake[0].position.y += snake[0].speed.y
						allowMove = true
					} else {
						snake[i].position = snakePosition[i - 1]
					}
				}
			}
			if ((snake[0].position.x > (screenWidth - offset.x)) ||
				   (snake[0].position.y > (screenHeight - offset.y)) ||
				   (snake[0].position.x < 0) ||
				   (snake[0].position.y < 0)) {
				gameOver = true
			}
			for i in 1 ..< counterTail {
				if ((snake[0].position.x == snake[i].position.x) &&
					   (snake[0].position.y == snake[i].position.y)) {
					gameOver = true
				}
			}
			if (!fruit.active) {
				fruit.active = true
				fruit.position = rl.Vector2 {
					f32(rl.GetRandomValue(0, (screenWidth / SQUARE_SIZE) - 1)) * SQUARE_SIZE +
					offset.x / 2,
					f32(rl.GetRandomValue(0, (screenHeight / SQUARE_SIZE) - 1)) * SQUARE_SIZE +
					offset.y / 2,
				}
				for i := 0; i < counterTail; i += 1 {
					for (fruit.position.x == snake[i].position.x) &&
					    (fruit.position.y == snake[i].position.y) {
						fruit.position = rl.Vector2 {
							f32(rl.GetRandomValue(0, (screenWidth / SQUARE_SIZE) - 1)) *
								SQUARE_SIZE +
							offset.x / 2,
							f32(rl.GetRandomValue(0, (screenHeight / SQUARE_SIZE) - 1)) *
								SQUARE_SIZE +
							offset.y / 2,
						}
						i = 0
					}
				}
			}
			if ((snake[0].position.x < (fruit.position.x + fruit.size.x)) &&
				   ((snake[0].position.x + snake[0].size.x) > fruit.position.x) &&
				   (snake[0].position.y < (fruit.position.y + fruit.size.y)) &&
				   ((snake[0].position.y + snake[0].size.y) > fruit.position.y)) {
				snake[counterTail].position = snakePosition[counterTail - 1]
				counterTail += 1
				fruit.active = false
			}
			framesCount = framesCount + 1
		}
	} else {
		if rl.IsKeyPressed(.ENTER) {
			initGame()
			gameOver = false
		}
	}
}
DrawFrame :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.RAYWHITE)
	if (!gameOver) {
		for i in 0 ..< screenWidth / SQUARE_SIZE + 1 {
			rl.DrawLineV(
				rl.Vector2{f32(SQUARE_SIZE * i) + offset.x / 2, offset.y / 2},
				rl.Vector2{f32(SQUARE_SIZE * i) + offset.x / 2, screenHeight - offset.y / 2},
				rl.LIGHTGRAY,
			)
		}
		for i in 0 ..< screenWidth / SQUARE_SIZE + 1 {
			rl.DrawLineV(
				rl.Vector2{offset.x / 2, f32(SQUARE_SIZE * i) + offset.y / 2},
				rl.Vector2{screenWidth - offset.x / 2, f32(SQUARE_SIZE * i) + offset.y / 2},
				rl.LIGHTGRAY,
			)
		}

		for i in 0 ..< counterTail {
			rl.DrawRectangleV(snake[i].position, snake[i].size, snake[i].color)
		}
		rl.DrawRectangleV(fruit.position, fruit.size, fruit.color)
		if (pause) {
			rl.DrawText(
				"GAME PAUSED",
				screenWidth / 2 - rl.MeasureText("GAME PAUSED", 40) / 2,
				screenHeight / 2 - 40,
				40,
				rl.GRAY,
			)
		}
	} else {
		rl.DrawText(
			"PRESS [ENTER] TO PLAY AGAIN",
			rl.GetScreenWidth() / 2 - rl.MeasureText("PRESS [ENTER] TO PLAY AGAIN", 20) / 2,
			rl.GetScreenHeight() / 2 - 50,
			20,
			rl.GRAY,
		)
	}
	rl.EndDrawing()
}
updateDrawFrame :: proc() {
	updateGame()
	DrawFrame()
}
