const rl = @import("raylib");

const SNAKE_LENGTH = 256;
const SQUARE_SIZE = 31;

const Snake = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    speed: rl.Vector2,
    color: rl.Color,
    pub fn init(position: rl.Vector2, size: rl.Vector2, speed: rl.Vector2, color: rl.Color) Snake {
        return Snake{ .position = position, .size = size, .speed = speed, .color = color };
    }
};

const Food = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    active: bool,
    color: rl.Color,
};
const screenWidth = 800;
const screenHeight = 450;

var framesCount: i32 = 0;
var gameOver = false;
var pause = false;

var fruit = Food{ .active = false, .color = rl.Color.black, .position = rl.Vector2.init(0, 0), .size = rl.Vector2.init(0, 0) };
var snake: [SNAKE_LENGTH]Snake = .{Snake.init(rl.Vector2.init(0, 0), rl.Vector2.init(0, 0), rl.Vector2.init(0, 0), rl.Color.black)} ** SNAKE_LENGTH;
var snakePosition: [SNAKE_LENGTH]rl.Vector2 = .{rl.Vector2.init(0, 0)} ** SNAKE_LENGTH;

var allowMove = false;
var offset = rl.Vector2{ .x = 0, .y = 0 };

var counterTail: usize = 0;

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "Snake");
    defer rl.closeWindow();

    initGame();
    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        updateDrawFrame();
    }
}
fn initGame() void {
    framesCount = 0;
    gameOver = false;
    pause = false;

    counterTail = 1;
    allowMove = false;
    offset.x = screenWidth % SQUARE_SIZE;
    offset.y = screenHeight % SQUARE_SIZE;

    for (&snake, 0..) |*snakeBlock, i| {
        snakeBlock.position = rl.Vector2{ .x = offset.x / 2, .y = offset.y / 2 };
        snakeBlock.size = rl.Vector2{ .x = SQUARE_SIZE, .y = SQUARE_SIZE };
        snakeBlock.speed = rl.Vector2{ .x = SQUARE_SIZE, .y = 0 };
        if (i == 0) {
            snakeBlock.color = rl.Color.black;
        } else {
            snakeBlock.color = rl.Color.blue;
        }
    }
    for (&snakePosition) |*entry| {
        entry.* = rl.Vector2{ .x = 0, .y = 0 };
    }
    fruit.size = rl.Vector2{ .x = SQUARE_SIZE, .y = SQUARE_SIZE };
    fruit.color = rl.Color.sky_blue;
    fruit.active = false;
}
fn updateGame() void {
    if (!gameOver) {
        if (rl.isKeyPressed(.p)) {
            pause = !pause;
        }
        if (!pause) {
            if (rl.isKeyPressed(.right) and (snake[0].speed.x == 0) and allowMove) {
                snake[0].speed = rl.Vector2{ .x = SQUARE_SIZE, .y = 0 };
                allowMove = false;
            }
            if (rl.isKeyPressed(.left) and (snake[0].speed.x == 0) and allowMove) {
                snake[0].speed = rl.Vector2{ .x = -SQUARE_SIZE, .y = 0 };
                allowMove = false;
            }
            if (rl.isKeyPressed(.up) and (snake[0].speed.y == 0) and allowMove) {
                snake[0].speed = rl.Vector2{ .x = 0, .y = -SQUARE_SIZE };
                allowMove = false;
            }
            if (rl.isKeyPressed(.down) and (snake[0].speed.y == 0) and allowMove) {
                snake[0].speed = rl.Vector2{ .x = 0, .y = SQUARE_SIZE };
                allowMove = false;
            }

            for (0..counterTail) |i| {
                snakePosition[i] = snake[i].position;
            }
            if (@mod(framesCount, 5) == 0) {
                for (0..counterTail) |i| {
                    if (i == 0) {
                        snake[0].position.x += snake[0].speed.x;
                        snake[0].position.y += snake[0].speed.y;
                        allowMove = true;
                    } else {
                        snake[i].position = snakePosition[i - 1];
                    }
                }
            }
            if ((snake[0].position.x > (screenWidth - offset.x)) or (snake[0].position.y > (screenHeight - offset.y)) or (snake[0].position.x < 0) or (snake[0].position.y < 0)) {
                gameOver = true;
            }

            for (1..counterTail) |i| {
                if ((snake[0].position.x == snake[i].position.x) and (snake[0].position.y == snake[i].position.y)) {
                    gameOver = true;
                }
            }

            if (!fruit.active) {
                fruit.active = true;
                fruit.position = rl.Vector2{ .x = @as(f32, @floatFromInt(rl.getRandomValue(0, (screenWidth / SQUARE_SIZE) - 1))) * SQUARE_SIZE + offset.x / 2, .y = @as(f32, @floatFromInt(rl.getRandomValue(0, (screenHeight / SQUARE_SIZE) - 1))) * SQUARE_SIZE + offset.y / 2 };
                var i: usize = 0;
                while (i < counterTail) : (i += 1) {
                    if ((fruit.position.x == snake[i].position.x) and (fruit.position.y == snake[i].position.y)) {
                        fruit.position = rl.Vector2{ .x = @as(f32, @floatFromInt(rl.getRandomValue(0, (screenWidth / SQUARE_SIZE) - 1))) * SQUARE_SIZE + offset.x / 2, .y = @as(f32, @floatFromInt(rl.getRandomValue(0, (screenHeight / SQUARE_SIZE) - 1))) * SQUARE_SIZE + offset.y / 2 };
                        i = 0;
                    }
                }
            }
            if ((snake[0].position.x < (fruit.position.x + fruit.size.x)) and ((snake[0].position.x + snake[0].size.x) > fruit.position.x) and (snake[0].position.y < (fruit.position.y + fruit.size.y)) and ((snake[0].position.y + snake[0].size.y) > fruit.position.y)) {
                snake[counterTail].position = snakePosition[counterTail - 1];
                counterTail += 1;
                fruit.active = false;
            }
            framesCount += 1;
        }
    } else {
        if (rl.isKeyPressed(.enter)) {
            initGame();
            gameOver = false;
        }
    }
}
fn DrawGame() void {
    rl.beginDrawing();
    defer rl.endDrawing();
    rl.clearBackground(rl.Color.ray_white);
    if (!gameOver) {
        for (0..screenWidth / SQUARE_SIZE + 1) |i| {
            rl.drawLineV(rl.Vector2{ .x = @as(f32, @floatFromInt(SQUARE_SIZE * i)) + offset.x / 2, .y = offset.y / 2 }, rl.Vector2{ .x = @as(f32, @floatFromInt(SQUARE_SIZE * i)) + offset.x / 2, .y = screenHeight - offset.y / 2 }, rl.Color.light_gray);
        }
        for (0..screenHeight / SQUARE_SIZE + 1) |i| {
            rl.drawLineV(rl.Vector2{ .x = offset.x / 2, .y = @as(f32, @floatFromInt(SQUARE_SIZE * i)) + offset.y / 2 }, rl.Vector2{ .x = screenWidth - offset.x / 2, .y = @as(f32, @floatFromInt(SQUARE_SIZE * i)) + offset.y / 2 }, rl.Color.light_gray);
        }

        for (0..counterTail) |i| {
            rl.drawRectangleV(snake[i].position, snake[i].size, snake[i].color);
        }
        rl.drawRectangleV(fruit.position, fruit.size, fruit.color);
        if (pause) {
            rl.drawText("GAME PAUSED", screenWidth / 2 - @divExact(rl.measureText("GAME PAUSED", 40), 2), screenHeight / 2 - 40, 40, rl.Color.gray);
        }
    } else {
        rl.drawText("PRESS [ENTER] TO PLAY AGAIN", @divExact(rl.getScreenWidth(), 2) - @divExact(rl.measureText("PRESS [ENTER] TO PLAY AGAIN", 20), 2), @divExact(rl.getScreenHeight(), 2) - 50, 20, rl.Color.gray);
    }
}
fn updateDrawFrame() void {
    updateGame();
    DrawGame();
}
