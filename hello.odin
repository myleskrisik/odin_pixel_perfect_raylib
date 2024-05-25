package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

main :: proc() {
	screenWidth :: 800
	screenHeight :: 450

	virtualScreenWidth :: 160
	virtualScreenHeight :: 90

	#assert(screenWidth / virtualScreenWidth == screenHeight / virtualScreenHeight)
	virtualRatio :: screenWidth / virtualScreenWidth
	rl.InitWindow(screenWidth, screenHeight, "hellooo")
	defer rl.CloseWindow()

	worldSpaceCamera, screenSpaceCamera: rl.Camera2D
	worldSpaceCamera.zoom = 1
	screenSpaceCamera.zoom = 1

	target := rl.LoadRenderTexture(virtualScreenWidth, virtualScreenHeight)
	defer rl.UnloadRenderTexture(target)

	rec00 := rl.Rectangle{70, 35, 20, 20}
	rec01 := rl.Rectangle{90, 55, 30, 10}
	rec02 := rl.Rectangle{80, 65, 15, 25}

	sourceRec := rl.Rectangle {
		0,
		0,
		auto_cast target.texture.width,
		auto_cast -target.texture.height,
	}
	destRec := rl.Rectangle {
		-virtualRatio,
		-virtualRatio,
		screenWidth + (virtualRatio * 2),
		screenHeight + (virtualRatio * 2),
	}

	origin := rl.Vector2{0, 0}
	rotation: f32 = 0.0

	cameraX := 0.0
	cameraY := 0.0

	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		{ 	// Update game
			rotation += 60 * rl.GetFrameTime()

			cameraX = auto_cast (math.sin(rl.GetTime()) * 50) - 10
			cameraY = auto_cast math.cos(rl.GetTime()) * 30

			screenSpaceCamera.target = rl.Vector2{auto_cast cameraX, auto_cast cameraY}

			worldSpaceCamera.target.x = auto_cast screenSpaceCamera.target.x
			screenSpaceCamera.target.x -= worldSpaceCamera.target.x
			screenSpaceCamera.target.x *= virtualRatio

			worldSpaceCamera.target.y = auto_cast screenSpaceCamera.target.y
			screenSpaceCamera.target.y -= worldSpaceCamera.target.y
			screenSpaceCamera.target.y *= virtualRatio
		}
		{ 	// Draw world space
			rl.BeginTextureMode(target)
			defer rl.EndTextureMode()
			rl.ClearBackground(rl.RAYWHITE)
			{
				rl.BeginMode2D(worldSpaceCamera)
				defer rl.EndMode2D()
				rl.DrawRectanglePro(rec00, origin, rotation, rl.BLACK)
				rl.DrawRectanglePro(rec01, origin, -rotation, rl.RED)
				rl.DrawRectanglePro(rec02, origin, rotation + 45, rl.BLUE)
			}
		}
		{ 	// Draw screen space
			rl.BeginDrawing()
			defer rl.EndDrawing()
			rl.ClearBackground(rl.RED)
			{
				rl.BeginMode2D(screenSpaceCamera)
				defer rl.EndMode2D()
				rl.DrawTexturePro(target.texture, sourceRec, destRec, origin, 0, rl.WHITE)
			}
			rl.DrawFPS(rl.GetScreenWidth() - 95, 10)
		}
	}
}
