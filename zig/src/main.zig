const rl = @import("raylib");

const screen_width = 800;
const screen_height = 450;
const square_size = 32;
const snake_length = 256;
const offset = rl.Vector2{
    .x = screen_width % square_size,
    .y = screen_height % square_size,
};

const Snake = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    speed: rl.Vector2,
    color: rl.Color,

    pub fn init(x: f32, y: f32, color: rl.Color) Snake {
        return Snake{
            .position = rl.Vector2{ .x = x, .y = y },
            .size = rl.Vector2{ .x = square_size, .y = square_size },
            .speed = rl.Vector2{ .x = square_size, .y = 0 },
            .color = color,
        };
    }
};

const Food = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    active: bool,
    color: rl.Color,
};

var game_state = struct {
    frames_count: i32 = 0,
    game_over: bool = false,
    pause: bool = false,
    current_snake_length: usize = 1,
    fruit: Food = Food{
        .active = false,
        .color = rl.Color.sky_blue,
        .position = rl.Vector2.init(0, 0),
        .size = rl.Vector2{ .x = square_size, .y = square_size },
    },
    snake: [snake_length]Snake = .{Snake.init(offset.x / 2, offset.y / 2, rl.Color.black)} ** snake_length,
    snake_positions: [snake_length]rl.Vector2 = .{rl.Vector2.init(0, 0)} ** snake_length,
}{};

pub fn main() !void {
    rl.initWindow(screen_width, screen_height, "Snake");
    defer rl.closeWindow();

    initGame();
    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        updateDrawFrame();
    }
}

fn initGame() void {
    game_state.frames_count = 0;
    game_state.game_over = false;
    game_state.pause = false;
    game_state.current_snake_length = 1;

    game_state.snake[0] = Snake.init(offset.x / 2, offset.y / 2, rl.Color.black);
    for (1..snake_length) |i| {
        game_state.snake[i] = Snake.init(0, 0, rl.Color.blue);
    }
    for (&game_state.snake_positions) |*entry| {
        entry.* = rl.Vector2{ .x = 0, .y = 0 };
    }

    game_state.fruit.active = false;
}

fn updateGame() void {
    if (game_state.game_over) {
        if (rl.isKeyPressed(.enter)) {
            initGame();
        }
        return;
    }

    handleInput();
    updateSnake();
    checkCollisions();
    game_state.frames_count += 1;
}

fn handleInput() void {
    if (rl.isKeyPressed(.p)) {
        game_state.pause = !game_state.pause;
    }
    if (game_state.pause) return;

    const input = rl.getKeyPressed();
    switch (input) {
        .right => {
            if (game_state.snake[0].speed.x == 0) game_state.snake[0].speed = rl.Vector2{ .x = square_size, .y = 0 };
        },
        .left => {
            if (game_state.snake[0].speed.x == 0) game_state.snake[0].speed = rl.Vector2{ .x = -square_size, .y = 0 };
        },
        .up => {
            if (game_state.snake[0].speed.y == 0) game_state.snake[0].speed = rl.Vector2{ .x = 0, .y = -square_size };
        },
        .down => {
            if (game_state.snake[0].speed.y == 0) game_state.snake[0].speed = rl.Vector2{ .x = 0, .y = square_size };
        },
        else => {},
    }
}

fn updateSnake() void {
    for (0..game_state.current_snake_length) |i| {
        game_state.snake_positions[i] = game_state.snake[i].position;
    }

    if (@mod(game_state.frames_count, 5) == 0) {
        for (0..game_state.current_snake_length) |i| {
            if (i == 0) {
                game_state.snake[0].position.x += game_state.snake[0].speed.x;
                game_state.snake[0].position.y += game_state.snake[0].speed.y;
            } else {
                game_state.snake[i].position = game_state.snake_positions[i - 1];
            }
        }
    }
}

fn checkCollisions() void {
    if (game_state.snake[0].position.x < 0 or game_state.snake[0].position.x > screen_width - offset.x or
        game_state.snake[0].position.y < 0 or game_state.snake[0].position.y > screen_height - offset.y)
    {
        game_state.game_over = true;
    }

    for (1..game_state.current_snake_length) |i| {
        if (game_state.snake[0].position.x == game_state.snake[i].position.x and game_state.snake[0].position.y == game_state.snake[i].position.y) {
            game_state.game_over = true;
        }
    }

    if (!game_state.fruit.active) {
        game_state.fruit.position = randomPosition();
        var index: usize = 0;
        while (index < game_state.current_snake_length) : (index += 1) {
            if (rl.checkCollisionRecs(.{ .x = game_state.snake[index].position.x, .y = game_state.snake[index].position.y, .width = game_state.snake[index].size.x, .height = game_state.snake[index].size.y }, .{ .x = game_state.fruit.position.x, .y = game_state.fruit.position.y, .width = game_state.fruit.size.x, .height = game_state.fruit.size.y })) {
                game_state.fruit.position = randomPosition();
                index = 0;
            }
        }
        game_state.fruit.active = true;
    }

    if (rl.checkCollisionRecs(.{ .x = game_state.snake[0].position.x, .y = game_state.snake[0].position.y, .width = game_state.snake[0].size.x, .height = game_state.snake[0].size.y }, .{ .x = game_state.fruit.position.x, .y = game_state.fruit.position.y, .width = game_state.fruit.size.x, .height = game_state.fruit.size.y })) {
        game_state.snake[game_state.current_snake_length].position = game_state.snake_positions[game_state.current_snake_length - 1];
        game_state.current_snake_length += 1;
        game_state.fruit.active = false;
    }
}

fn updateDrawFrame() void {
    updateGame();
    drawGame();
}

fn drawGame() void {
    rl.beginDrawing();
    defer rl.endDrawing();
    rl.clearBackground(rl.Color.ray_white);

    if (game_state.game_over) {
        rl.drawText(
            "PRESS [ENTER] TO PLAY AGAIN",
            screen_width / 2 - @divExact(rl.measureText("PRESS [ENTER] TO PLAY AGAIN", 20), 2),
            screen_height / 2 - 50,
            20,
            rl.Color.gray,
        );
        return;
    }

    drawGrid();

    for (0..game_state.current_snake_length) |i| {
        rl.drawRectangleV(game_state.snake[i].position, game_state.snake[i].size, game_state.snake[i].color);
    }

    rl.drawRectangleV(game_state.fruit.position, game_state.fruit.size, game_state.fruit.color);

    if (game_state.pause) {
        rl.drawText(
            "GAME PAUSED",
            screen_width / 2 - @divExact(rl.measureText("GAME PAUSED", 40), 2),
            screen_height / 2 - 40,
            40,
            rl.Color.gray,
        );
    }
}
fn drawGrid() void {
    for (0..screen_width / square_size + 1) |i| {
        rl.drawLineV(rl.Vector2{ .x = @as(f32, @floatFromInt(square_size * i)) + offset.x / 2, .y = offset.y / 2 }, rl.Vector2{ .x = @as(f32, @floatFromInt(square_size * i)) + offset.x / 2, .y = screen_height - offset.y / 2 }, rl.Color.light_gray);
    }
    for (0..screen_height / square_size + 1) |i| {
        rl.drawLineV(rl.Vector2{ .x = offset.x / 2, .y = @as(f32, @floatFromInt(square_size * i)) + offset.y / 2 }, rl.Vector2{ .x = screen_width - offset.x / 2, .y = @as(f32, @floatFromInt(square_size * i)) + offset.y / 2 }, rl.Color.light_gray);
    }
}

fn randomPosition() rl.Vector2 {
    return rl.Vector2{
        .x = @as(f32, @floatFromInt(rl.getRandomValue(0, screen_width / square_size - 1))) * square_size + offset.x / 2,
        .y = @as(f32, @floatFromInt(rl.getRandomValue(0, screen_height / square_size - 1))) * square_size + offset.y / 2,
    };
}
