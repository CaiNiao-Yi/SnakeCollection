// The Swift Programming Language
// https://docs.swift.org/swift-book
import Raylib

typealias rl = Raylib
let SNAKE_LENGTH:Int = 256
let SQUARE_SIZE:Int = 31

struct Snake {
    var position: Vector2 = .zero
    var size: Vector2 = .zero
    var speed: Vector2 = .zero
    var color: Color = .black
}

struct Food {
    var postion: Vector2 = .zero
    var size: Vector2 = .zero
    var active: Bool = false
    var color: Color = .black
}

let screenWidth:Int = 800
let screenHeight:Int = 450

var framesCount:Int = 0
var gameOver:Bool = false
var pause:Bool = false

var fruit:Food = Food()

var snake: [Snake] = Array(repeating: Snake(), count: Int(SNAKE_LENGTH))
var snakePosition: [Vector2] = Array(repeating: Vector2(), count: Int(SNAKE_LENGTH))

var allowMove:Bool = false

var offset:Vector2 = .zero

var counterTail:Int = 0

rl.initWindow(Int32(screenWidth), Int32(screenHeight), "Snake")
initGame()
rl.setTargetFPS(60)
while !rl.windowShouldClose {
    updateDrawFrame()
}

rl.closeWindow()
@MainActor func initGame() {
    framesCount = 0
    gameOver = false
    pause = false

    counterTail = 1
    allowMove = false

    offset.x = Float(screenWidth % SQUARE_SIZE)
    offset.y = Float(screenHeight % SQUARE_SIZE)

    for (index, _) in snake.enumerated() {
        snake[index].position = Vector2(x: offset.x / 2, y: offset.y / 2)
        snake[index].size = Vector2(x: Float(SQUARE_SIZE), y: Float(SQUARE_SIZE))
        snake[index].speed = Vector2(x: Float(SQUARE_SIZE), y: 0)
        snake[index].color = (index == 0) ? .black : .blue
    }
    for index in 0..<snakePosition.count {
        snakePosition[index] = Vector2(x: 0, y: 0)
    }
    fruit.size = Vector2(x: Float(SQUARE_SIZE), y: Float(SQUARE_SIZE))
    fruit.color = .skyBlue
    fruit.active = false
}

@MainActor func updateDrawFrame() {
    updateGame()
    drawFrame()
}

@MainActor func updateGame() {
    if !gameOver {
        if rl.isKeyPressed(.letterP){
            pause = !pause
        }
        if !pause {
            if rl.isKeyPressed(.right), snake[0].speed.x == 0, allowMove {
                snake[0].speed = Vector2(x: Float(SQUARE_SIZE), y: 0)
                allowMove = false
            }
            if rl.isKeyPressed(.left), snake[0].speed.x == 0, allowMove {
                snake[0].speed = Vector2(x: Float(-SQUARE_SIZE), y: 0)
                allowMove = false
            }
            if rl.isKeyPressed(.up), snake[0].speed.y == 0, allowMove {
                snake[0].speed = Vector2(x: 0, y: Float(-SQUARE_SIZE))
                allowMove = false
            }
            if rl.isKeyPressed(.down), snake[0].speed.y == 0, allowMove {
                snake[0].speed = Vector2(x: 0, y: Float(SQUARE_SIZE))
                allowMove = false
            }
            for index in 0..<counterTail {
                snakePosition[Int(index)] = snake[Int(index)].position
            }
            if framesCount % 5 == 0 {
                for index in 0..<counterTail {
                    if index == 0 {
                        snake[0].position.x += snake[0].speed.x
                        snake[0].position.y += snake[0].speed.y
                        allowMove = true
                    }else {
                        snake[index].position = snakePosition[index-1]
                    }
                }
            }
            if snake[0].position.x > (Float(screenWidth) - offset.x) || snake[0].position.y > (Float(screenHeight) - offset.y) ||
                snake[0].position.x < 0 || snake[0].position.y < 0
            {
                gameOver = true
            }
            for index in 1..<counterTail {
                if snake[0].position.x == snake[Int(index)].position.x, snake[0].position.y == snake[Int(index)].position.y {
                    gameOver = true
                }
            }
            if !fruit.active {
                fruit.active = true
                var newPosX = Float(Float(Int(rl.getRandomValue(0, Int32(screenWidth / SQUARE_SIZE - 1))) * SQUARE_SIZE) + offset.x / 2)
                var newPosY = Float(Float(Int(rl.getRandomValue(0, Int32(screenHeight / SQUARE_SIZE - 1))) * SQUARE_SIZE) + offset.y / 2)
                var index = 0
                while index < counterTail {
                    if newPosX == snake[index].position.x && newPosY == snake[index].position.y{
                        newPosX = Float(Float(Int(rl.getRandomValue(0, Int32(screenWidth / SQUARE_SIZE - 1))) * SQUARE_SIZE) + offset.x / 2)
                        newPosY = Float(Float(Int(rl.getRandomValue(0, Int32(screenHeight / SQUARE_SIZE - 1))) * SQUARE_SIZE) + offset.y / 2)
                        index = 0
                    }
                    index += 1
                }
                fruit.postion = Vector2(x: newPosX, y: newPosY)
            }
            if snake[0].position.x < (fruit.postion.x + fruit.size.x) && snake[0].position.x + snake[0].size.x > fruit.postion.x &&
                snake[0].position.y < (fruit.postion.y + fruit.size.y) &&
                snake[0].position.y + snake[0].size.y > fruit.postion.y{
                snake[Int(counterTail)].position = snakePosition[Int(counterTail) - 1]
                counterTail += 1
                fruit.active = false
            }
            framesCount += 1
        }
    } else {
        if rl.isKeyPressed(.enter) {
            initGame()
            gameOver = false
        }
    }
}

@MainActor func drawFrame() {
    rl.beginDrawing()
    rl.clearBackground(.rayWhite)
    if !gameOver {
        for i in 0..<(screenWidth / SQUARE_SIZE + 1) {
            rl.drawLineV(Vector2(x: Float(SQUARE_SIZE * i) + offset.x / 2, y: offset.y / 2), Vector2(x: Float(SQUARE_SIZE * i) + offset.x / 2, y: Float(screenHeight) - offset.y / 2), .lightGray)
        }
        for i in 0..<(screenHeight / SQUARE_SIZE + 1) {
            rl.drawLineV(Vector2(x: offset.x / 2, y: Float(SQUARE_SIZE * i) + offset.y / 2), Vector2(x: Float(screenWidth) - offset.x / 2, y: Float(SQUARE_SIZE * i) + offset.y / 2), .lightGray)
        }
        for index in 0..<counterTail {
            rl.drawRectangleV(snake[Int(index)].position, snake[Int(index)].size, snake[Int(index)].color)
        }
        rl.drawRectangleV(fruit.postion, fruit.size, fruit.color)
        if pause {
            rl.drawText("GAME PAUSED", Int32(screenWidth / 2) - rl.measureText("GAME PAUSED", 40) / 2, Int32(screenHeight / 2) - 40, 40, .gray)
        }
    } else {
        rl.drawText("PRESS [ENTER] TO PLAY AGAIN", Int32(rl.getScreenWidth() / 2) - rl.measureText("PRESS [ENTER] TO PLAY AGAIN", 20) / 2, Int32(rl.getScreenHeight() / 2) - 50, 20, .gray)
    }
    rl.endDrawing()
}
