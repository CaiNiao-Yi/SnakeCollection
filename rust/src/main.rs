use raylib::prelude::*;
const SNAKE_LENGTH: usize = 256;
const SQUARE_SIZE: usize = 31;
const SCREEN_WIDTH: i32 = 800;
const SCREEN_HEIGHT: i32 = 450;
#[derive(Default, Clone, Copy)]
struct Snake {
    position: Vector2,
    size: Vector2,
    speed: Vector2,
    color: Color,
}
#[derive(Default)]
struct Food {
    position: Vector2,
    size: Vector2,
    active: bool,
    color: Color,
}
struct GameState {
    frames_count: i32,
    game_over: bool,
    pause: bool,
    fruit: Food,
    snake: [Snake; SNAKE_LENGTH],
    snake_postion: [Vector2; SNAKE_LENGTH],
    allow_move: bool,
    offset: Vector2,
    counter_tail: usize,
}
impl GameState {
    fn reinit(&mut self) {
        let offset = Vector2 {
            x: (SCREEN_WIDTH % SQUARE_SIZE as i32) as f32,
            y: (SCREEN_HEIGHT % SQUARE_SIZE as i32) as f32,
        };
        self.frames_count = 0;
        self.game_over = false;
        self.pause = false;
        self.fruit = Food {
            position: Vector2::zero(),
            size: Vector2 {
                x: SQUARE_SIZE as f32,
                y: SQUARE_SIZE as f32,
            },
            active: false,
            color: Color::SKYBLUE,
        };
        self.snake = [Snake {
            position: Vector2 {
                x: offset.x / 2.,
                y: offset.y / 2.,
            },
            size: Vector2 {
                x: SQUARE_SIZE as f32,
                y: SQUARE_SIZE as f32,
            },
            speed: Vector2 {
                x: SQUARE_SIZE as f32,
                y: 0.,
            },
            color: Color::BLUE,
        }; SNAKE_LENGTH];
        self.snake[0].color = Color::BLACK;
        self.snake_postion = [Vector2 { x: 0., y: 0. }; SNAKE_LENGTH];
        self.allow_move = false;
        self.offset = offset;
        self.counter_tail = 1;
    }
}
impl Default for GameState {
    fn default() -> Self {
        let offset = Vector2 {
            x: (SCREEN_WIDTH % SQUARE_SIZE as i32) as f32,
            y: (SCREEN_HEIGHT % SQUARE_SIZE as i32) as f32,
        };
        let mut gs = GameState {
            frames_count: 0,
            game_over: false,
            pause: false,
            fruit: Food {
                position: Vector2::zero(),
                size: Vector2 {
                    x: SQUARE_SIZE as f32,
                    y: SQUARE_SIZE as f32,
                },
                active: false,
                color: Color::SKYBLUE,
            },
            snake: [Snake {
                position: Vector2 {
                    x: offset.x / 2.,
                    y: offset.y / 2.,
                },
                size: Vector2 {
                    x: SQUARE_SIZE as f32,
                    y: SQUARE_SIZE as f32,
                },
                speed: Vector2 {
                    x: SQUARE_SIZE as f32,
                    y: 0.,
                },
                color: Color::BLUE,
            }; SNAKE_LENGTH],
            snake_postion: [Vector2 { x: 0., y: 0. }; SNAKE_LENGTH],
            allow_move: false,
            offset,
            counter_tail: 1,
        };
        gs.snake[0].color = Color::BLACK;
        gs
    }
}
fn main() {
    let (mut rl, thread) = raylib::init()
        .size(SCREEN_WIDTH, SCREEN_HEIGHT)
        .title("Snake")
        .build();
    rl.set_target_fps(60);
    let mut game_state = GameState::default();
    while !rl.window_should_close() {
        update_draw_frame(&mut game_state, &mut rl, &thread)
    }
}
fn update_draw_frame(gs: &mut GameState, rl: &mut RaylibHandle, thread: &RaylibThread) {
    update_game(gs, rl);
    draw_frame(gs, rl, thread);
}

fn draw_frame(gs: &mut GameState, rl: &mut RaylibHandle, thread: &RaylibThread) {
    let mut d = rl.begin_drawing(thread);
    d.clear_background(Color::RAYWHITE);
    if !gs.game_over {
        for i in 0..SCREEN_WIDTH / SQUARE_SIZE as i32 + 1 {
            d.draw_line_v(
                Vector2 {
                    x: (SQUARE_SIZE as i32 * i) as f32 + gs.offset.x / 2.,
                    y: gs.offset.y / 2.,
                },
                Vector2 {
                    x: (SQUARE_SIZE as i32 * i) as f32 + gs.offset.x / 2.,
                    y: SCREEN_HEIGHT as f32 - gs.offset.y / 2.,
                },
                Color::LIGHTGRAY,
            );
        }
        for i in 0..SCREEN_HEIGHT / SQUARE_SIZE as i32 + 1 {
            d.draw_line_v(
                Vector2 {
                    x: gs.offset.x / 2.,
                    y: (SQUARE_SIZE as i32 * i) as f32 + gs.offset.y / 2.,
                },
                Vector2 {
                    x: SCREEN_WIDTH as f32 - gs.offset.x / 2.,
                    y: (SQUARE_SIZE as i32 * i) as f32 + gs.offset.y / 2.,
                },
                Color::LIGHTGRAY,
            );
        }
        for i in 0..gs.counter_tail {
            d.draw_rectangle_v(gs.snake[i].position, gs.snake[i].size, gs.snake[i].color);
        }
        d.draw_rectangle_v(gs.fruit.position, gs.fruit.size, gs.fruit.color);
        if gs.pause {
            d.draw_text(
                "GAME PAUSED",
                SCREEN_WIDTH / 2 - d.measure_text("GAME PAUSED", 40) / 2,
                SCREEN_HEIGHT / 2 - 40,
                40,
                Color::GRAY,
            );
        }
    } else {
        d.draw_text(
            "PRESS [ENTER] TO PLAY AGAIN",
            d.get_screen_width() / 2 - d.measure_text("PRESS [ENTER] TO PLAY AGAIN", 20) / 2,
            d.get_screen_height() / 2 - 50,
            20,
            Color::GRAY,
        );
    }
}

fn update_game(gs: &mut GameState, rl: &mut RaylibHandle) {
    if !gs.game_over {
        if rl.is_key_pressed(KeyboardKey::KEY_P) {
            gs.pause = !gs.pause;
        }
        if !gs.pause {
            if rl.is_key_pressed(KeyboardKey::KEY_RIGHT)
                && gs.snake[0].speed.x == 0.
                && gs.allow_move
            {
                gs.snake[0].speed = Vector2 {
                    x: SQUARE_SIZE as f32,
                    y: 0.,
                };
                gs.allow_move = false;
            }
            if rl.is_key_pressed(KeyboardKey::KEY_LEFT)
                && gs.snake[0].speed.x == 0.
                && gs.allow_move
            {
                gs.snake[0].speed = Vector2 {
                    x: -(SQUARE_SIZE as f32),
                    y: 0.,
                };
                gs.allow_move = false;
            }
            if rl.is_key_pressed(KeyboardKey::KEY_UP) && gs.snake[0].speed.y == 0. && gs.allow_move
            {
                gs.snake[0].speed = Vector2 {
                    x: 0.,
                    y: -(SQUARE_SIZE as f32),
                };
                gs.allow_move = false;
            }
            if rl.is_key_pressed(KeyboardKey::KEY_DOWN)
                && gs.snake[0].speed.y == 0.
                && gs.allow_move
            {
                gs.snake[0].speed = Vector2 {
                    x: 0.,
                    y: SQUARE_SIZE as f32,
                };
                gs.allow_move = false;
            }
            for i in 0..gs.counter_tail {
                gs.snake_postion[i] = gs.snake[i].position;
            }
            if gs.frames_count % 5 == 0 {
                for i in 0..gs.counter_tail {
                    if i == 0 {
                        gs.snake[0].position.x += gs.snake[0].speed.x;
                        gs.snake[0].position.y += gs.snake[0].speed.y;
                    } else {
                        gs.snake[i].position = gs.snake_postion[i - 1];
                    }
                }
            }
            if gs.snake[0].position.x > SCREEN_WIDTH as f32 - gs.offset.x
                || gs.snake[0].position.y > SCREEN_HEIGHT as f32 - gs.offset.y
                || gs.snake[0].position.x < 0.
                || gs.snake[0].position.y < 0.
            {
                gs.game_over = true;
            }
            for i in 1..gs.counter_tail {
                if gs.snake[0].position.x == gs.snake[i].position.x
                    && gs.snake[0].position.y == gs.snake[i].position.y
                {
                    gs.game_over = true;
                }
            }
            if !gs.fruit.active {
                gs.fruit.active = true;
                gs.fruit.position = Vector2 {
                    x: (rl.get_random_value::<i32>(0..(SCREEN_WIDTH / SQUARE_SIZE as i32) - 1)
                        * SQUARE_SIZE as i32) as f32
                        + gs.offset.x / 2.,
                    y: (rl.get_random_value::<i32>(0..(SCREEN_HEIGHT / SQUARE_SIZE as i32) - 1)
                        * SQUARE_SIZE as i32) as f32
                        + gs.offset.y / 2.,
                };
                let mut i: usize = 0;
                while i < gs.counter_tail {
                    if (gs.fruit.position.x == gs.snake[i].position.x)
                        && (gs.fruit.position.y == gs.snake[i].position.y)
                    {
                        gs.fruit.position = Vector2 {
                            x: (rl.get_random_value::<i32>(
                                0..(SCREEN_WIDTH / SQUARE_SIZE as i32) - 1,
                            ) * SQUARE_SIZE as i32) as f32
                                + gs.offset.x / 2.,
                            y: (rl.get_random_value::<i32>(
                                0..(SCREEN_HEIGHT / SQUARE_SIZE as i32) - 1,
                            ) * SQUARE_SIZE as i32) as f32
                                + gs.offset.y / 2.,
                        };
                        i = 0;
                    }
                    i += 1;
                }
            }
            if (gs.snake[0].position.x < (gs.fruit.position.x + gs.fruit.size.x))
                && ((gs.snake[0].position.x + gs.snake[0].size.x) > gs.fruit.position.x)
                && (gs.snake[0].position.y < (gs.fruit.position.y + gs.fruit.size.y))
                && ((gs.snake[0].position.y + gs.snake[0].size.y) > gs.fruit.position.y)
            {
                gs.snake[gs.counter_tail].position = gs.snake_postion[gs.counter_tail - 1];
                gs.counter_tail += 1;
                gs.fruit.active = false;
            }
            gs.frames_count += 1;
        }
    } else {
        if rl.is_key_pressed(KeyboardKey::KEY_ENTER) {
            gs.reinit();
        }
    }
}
