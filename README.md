# raytracer-zig
This repo contains a Zig implementation of [Ray Tracing in One Weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html). Ray tracing static scenes is a embarrassingly parallel task, so multithreading was leveraged in order to reduce rendering times. Visualization was possible using this [zig port of raylib](https://github.com/ryupold/raylib.zig).  

## Build dependencies

The following dependencies must be installed on Ubuntu if you intend to build the project:
```(bash)
sudo apt install libasound2-dev libx11-dev libxrandr-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev
``` 
For other GNU Linux distributions refer to the [raylib documentation](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux).

## Build 

Building and running is extremely straightforward due to Zig's integrated build system: 
```(bash)
zig build run -Doptimize=ReleaseFast
```
Note: I've only tested building with Zig 0.11.0.

## Demo 

Realtime ray tracing results running on a VM with 10 available cores. Demo was rendered with a relatively low quality: 50 samples/pixel and a max recursion depth of 20. 
![](https://github.com/ConstantinNicula/raytracer-zig/blob/main/demo/realtime_demo.gif)

Rendering with 500 samples/pixel and 50 max recursion depth, yields a much cleaner image: 
![](https://github.com/ConstantinNicula/raytracer-zig/blob/main/demo/high_res.png)
