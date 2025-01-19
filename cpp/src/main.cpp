#include "raylib.h"
#include <array>
#include <cstddef>
#include <vector>

constexpr int SNAKE_LENGTH = 256;
constexpr int SQUARE_SIZE = 32;
constexpr int SCREEN_WIDTH = 800;
constexpr int SCREEN_HEIGHT = 450;

struct Snake {
  Vector2 position;
  Vector2 size;
  Vector2 speed;
  Color color;

  Snake() = default;
  Snake(Vector2 pos, Vector2 sz, Vector2 spd, Color col)
      : position(pos), size(sz), speed(spd), color(col) {}
};
struct Food {
  Vector2 position;
  Vector2 size;
  bool active;
  Color color;
};

int framesCount = 0;
bool gameOver = false;
bool pause = false;
bool allowMove = false;
size_t counterTail = 0;

Vector2 offset = {0, 0};
Food fruit = {{0, 0}, {0, 0}, false, SKYBLUE};
std::array<Snake, SNAKE_LENGTH> snake;
std::array<Vector2, SNAKE_LENGTH> snakePosition;

void InitGame() {
  framesCount = 0;
  gameOver = false;
  pause = false;
  counterTail = 1;
  allowMove = false;
  offset = {SCREEN_WIDTH % SQUARE_SIZE, SCREEN_HEIGHT % SQUARE_SIZE};
  for (size_t i = 0; i < SNAKE_LENGTH; ++i) {
    snake[i] = Snake({offset.x / 2, offset.y / 2}, {SQUARE_SIZE, SQUARE_SIZE},
                     {SQUARE_SIZE, 0}, (i == 0) ? BLACK : BLUE);
    snakePosition[i] = {0, 0};
  }
  fruit.size = {SQUARE_SIZE, SQUARE_SIZE};
  fruit.active = false;
}
void UpdateGame() {
  if (!gameOver) {
    if (IsKeyPressed(KEY_P))
      pause = !pause;
    if (!pause) {
      if (IsKeyPressed(KEY_RIGHT) && snake[0].speed.x == 0 && allowMove) {
        snake[0].speed = {SQUARE_SIZE, 0};
        allowMove = false;
      }
      if (IsKeyPressed(KEY_LEFT) && snake[0].speed.x == 0 && allowMove) {
        snake[0].speed = {-SQUARE_SIZE, 0};
        allowMove = false;
      }
      if (IsKeyPressed(KEY_UP) && snake[0].speed.y == 0 && allowMove) {
        snake[0].speed = {0, -SQUARE_SIZE};
        allowMove = false;
      }
      if (IsKeyPressed(KEY_DOWN) && snake[0].speed.y == 0 && allowMove) {
        snake[0].speed = {0, SQUARE_SIZE};
        allowMove = false;
      }

      for (size_t i = 0; i < counterTail; ++i) {
        snakePosition[i] = snake[i].position;
      }
      if (framesCount % 5 == 0) {
        for (size_t i = counterTail; i > 0; --i) {
          snake[i].position = snakePosition[i - 1];
        }
        snake[0].position.x += snake[0].speed.x;
        snake[0].position.y += snake[0].speed.y;
        allowMove = true;
      }
      if (snake[0].position.x >= SCREEN_WIDTH - offset.x ||
          snake[0].position.y >= SCREEN_HEIGHT - offset.y ||
          snake[0].position.x < 0 || snake[0].position.y < 0) {
        gameOver = true;
      }
      for (size_t i = 1; i < counterTail; ++i) {
        if (snake[0].position.x == snake[i].position.x &&
            snake[0].position.y == snake[i].position.y) {
          gameOver = true;
        }
      }
      if (!fruit.active) {
        fruit.active = true;
        fruit.position = {
            GetRandomValue(0, (SCREEN_WIDTH / SQUARE_SIZE) - 1) * SQUARE_SIZE +
                offset.x / 2,
            GetRandomValue(0, (SCREEN_HEIGHT / SQUARE_SIZE) - 1) * SQUARE_SIZE +
                offset.y / 2};
        for (size_t i = 0; i < counterTail; ++i) {
          if (fruit.position.x == snake[i].position.x &&
              fruit.position.y == snake[i].position.y) {
            fruit.position = {
                GetRandomValue(0, (SCREEN_WIDTH / SQUARE_SIZE) - 1) *
                        SQUARE_SIZE +
                    offset.x / 2,
                GetRandomValue(0, (SCREEN_HEIGHT / SQUARE_SIZE) - 1) *
                        SQUARE_SIZE +
                    offset.y / 2};
            i = 0;
          }
        }
      }
      if (CheckCollisionRecs({snake[0].position.x, snake[0].position.y,
                              snake[0].size.x, snake[0].size.y},
                             {fruit.position.x, fruit.position.y, fruit.size.x,
                              fruit.size.y})) {
        counterTail++;
        fruit.active = false;
      }

      framesCount++;
    }
  } else if (IsKeyPressed(KEY_ENTER)) {
    InitGame();
  }
}
void DrawGame() {
  BeginDrawing();
  ClearBackground(RAYWHITE);

  if (!gameOver) {
    for (int i = 0; i < SCREEN_WIDTH / SQUARE_SIZE; ++i) {
      DrawLineV({SQUARE_SIZE * i + offset.x / 2, offset.y / 2},
                {SQUARE_SIZE * i + offset.x / 2, SCREEN_HEIGHT - offset.y / 2},
                LIGHTGRAY);
    }
    for (int i = 0; i < SCREEN_HEIGHT / SQUARE_SIZE; ++i) {
      DrawLineV({offset.x / 2, SQUARE_SIZE * i + offset.y / 2},
                {SCREEN_WIDTH - offset.x / 2, SQUARE_SIZE * i + offset.y / 2},
                LIGHTGRAY);
    }
    for (size_t i = 0; i < counterTail; ++i) {
      DrawRectangleV(snake[i].position, snake[i].size, snake[i].color);
    }
    DrawRectangleV(fruit.position, fruit.size, fruit.color);
    if (pause)
      DrawText("GAME PAUSED",
               SCREEN_WIDTH / 2 - MeasureText("GAME PAUSED", 40) / 2,
               SCREEN_HEIGHT / 2 - 40, 40, GRAY);
  } else {
    DrawText("PRESS [ENTER] TO PLAY AGAIN",
             SCREEN_WIDTH / 2 -
                 MeasureText("PRESS [ENTER] TO PLAY AGAIN", 20) / 2,
             SCREEN_HEIGHT / 2 - 50, 20, GRAY);
  }
  EndDrawing();
}
int main(int argc, char *argv[]) {
  InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "snake");
  SetTargetFPS(60);
  InitGame();
  while (!WindowShouldClose()) {
    UpdateGame();
    DrawGame();
  }
  CloseWindow();
  return 0;
}
