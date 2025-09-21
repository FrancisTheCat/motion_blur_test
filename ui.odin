package ui

import "core:math/ease"
import "core:fmt"
import "core:time"
import glm "core:math/linalg/glsl"

import "vendor:glfw"

@(require)
import "core:image/png"

import "glodin"
import "shared:input"

main :: proc() {
	glfw.Init()
	defer glfw.Terminate()

	glfw.WindowHint(glfw.SAMPLES, 8)
	window := glfw.CreateWindow(900, 600, "Hello World", nil, nil)
	defer glfw.DestroyWindow(window)

	input.init(window)
	glodin.init_glfw(window)

	Quad :: struct {
		position:      glm.vec2,
		size:          glm.vec2,
		tex_rect:      glm.vec4,
		color:         glm.vec4,
		position_prev: glm.vec2,
		size_prev:     glm.vec2,
	}

	Vertex :: struct {
		position: glm.vec2,
	}

	quad_mesh := glodin.create_mesh_no_indices([]Vertex{
		{ position = {0, 0}, },
		{ position = {0, 1}, },
		{ position = {1, 1}, },
		{ position = {0, 0}, },
		{ position = {1, 0}, },
		{ position = {1, 1}, },
	})

	quads      := make([]Quad, 1)
	quads_mesh := glodin.create_instanced_mesh_from_base(quad_mesh, quads)

	for &q in quads {
		q.color = { 0x62 / 255.999, 0xAE / 255.999, 0xEF / 255.999, 1, }
	}

	program, program_ok := glodin.create_program_source(#load("vertex.glsl"), #load("fragment.glsl"))
	assert(program_ok)

	texture, texture_ok := glodin.create_texture_from_file("texture3.png")
	glodin.set_texture_sampling_state(texture, .Nearest)
	texture_width, texture_height := glodin.get_texture_dimensions(texture)
	assert(texture_ok)

	glodin.enable(.Blend)

	start_time := time.now()

	start_animation_time: f32
	reverse := false
	smooth  := true
	samples := 8

	for !glfw.WindowShouldClose(window) {
		glodin.clear_color({}, { 0x1E / 255.999, 0x21 / 255.999, 0x28 / 255.999, 1, })

		current_time := f32(f64(time.since(start_time)) / f64(time.Second))

		if input.get_key_down(.Space) {
			start_animation_time = current_time
			reverse             ~= true
		}

		if input.get_key_down(.Up) {
			samples *= 2
			fmt.println("samples:", samples)
		}
		if input.get_key_down(.Down) {
			samples /= 2
			fmt.println("samples:", samples)
		}
		if input.get_key_down(.S) {
			smooth ~= true
		}
		samples = max(samples, 1)

		window_size: glm.vec2
		{
			x, y         := glfw.GetWindowSize(window)
			window_size.x = f32(x)
			window_size.y = f32(y)
		}

		glodin.set_uniforms(program, {
			{ "u_inv_resolution", 1 / window_size, },
			{ "u_texture",        texture,         },
			{ "u_samples",        i32(samples),    },
		})

		t := clamp((current_time - start_animation_time) * 3, 0, 1)
		t  = ease.cubic_in_out(t)
		if reverse {
			t = 1 - t
		}

		for &q, i in quads {
			q.position_prev = q.position
			q.size_prev     = q.size

			q.position = glm.vec2(input.get_mouse_position()) + f32(i) * 40
			q.size     = input.get_mouse_position().x * 0.2
			q.size     = {
				f32(texture_width),
				f32(texture_height),
			}

			if !smooth {
				q.position_prev = q.position
				q.size_prev     = q.size
			}
		}

		glodin.set_instanced_mesh_data(quads_mesh, quads)

		glodin.draw({}, program, quads_mesh)

		input.poll()
		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}
}
