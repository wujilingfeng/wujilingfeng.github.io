+++
author = 'libo'
date = '2025-07-16T10:22:34+08:00'
draft = false
title = 'Web端渲染'

image = "img.png"

+++

将使用 Dawn 库编写的渲染程序导出到 Web 端和本地端，需要采取不同的编译和部署策略，但核心思想是：**你的 C++ 渲染逻辑（使用 WebGPU API）大部分可以保持不变，而平台特定的部分（如窗口创建、文件IO、事件处理）则需要抽象或有条件编译。**

Dawn 本身是一个 C++ 库，实现了 WebGPU API 规范，并且是 Chromium 浏览器中 WebGPU 的底层实现。

### 核心思想：平台无关的 WebGPU 逻辑

你的渲染程序主体应该使用 WebGPU API（通过 `wgpu::Device`, `wgpu::Queue`, `wgpu::RenderPassEncoder` 等）来定义渲染管线、加载资源、绘制等。这部分代码在概念上是平台无关的。

然而，创建窗口/画布、获取 WebGPU 设备、处理用户输入等部分是与平台紧密相关的。

### 1. 导出到 Web 端 (浏览器)

在 Web 端，你的 C++ 代码需要被编译成 WebAssembly (WASM)，并在浏览器环境中运行。浏览器本身提供了原生的 WebGPU API 实现（在 Chromium 中，这个实现就是基于 Dawn 的）。这意味着你**不需要**将 Dawn 库本身编译进你的 WASM 包，你的 WASM 直接调用浏览器提供的 WebGPU API。

**主要工具：Emscripten**

1. **编写 C++ 渲染程序：**

   - 你的渲染代码会调用标准的 WebGPU API（封装在 Dawn 的 C++ 头文件中，如 `dawn/webgpu.h` 或直接使用 `wgpu` 名称空间）。

   - 对于画布的创建和获取 WebGPU 设备，你需要使用 Emscripten 提供的接口来与 JavaScript 环境交互。例如，获取 `navigator.gpu` 和请求设备。

   - 示例（概念性）：

     

     

     ```
     #include <webgpu/webgpu.h> // 使用 WebGPU API
     
     // Emscripten 提供的用于与 JS 交互的宏
     #include <emscripten/emscripten.h>
     #include <emscripten/html5.h>
     
     WGPUAdapter g_adapter = nullptr;
     WGPUDevice g_device = nullptr;
     WGPUQueue g_queue = nullptr;
     
     // C++ 函数，通过 Emscripten 暴露给 JS
     extern "C" EMSCRIPTEN_KEEPALIVE void init_webgpu(WGPUSurface surface_ptr) {
         // ... (请求 adapter, device, queue, config shader module, pipeline etc.)
         // 通常这一步需要异步回调，与 JS 交互
         // Emscripten 提供了异步回调机制，如 emscripten_async_call 或 Promise 桥接
     }
     
     // 渲染循环（通过 JS requestAnimationFrame 调用）
     extern "C" EMSCRIPTEN_KEEPALIVE void draw_frame() {
         if (!g_device) return;
         // ... (创建 command encoder, render pass, draw calls, submit commands)
     }
     
     int main() {
         // Emscripten_main_loop_set_timing(EM_HTML5_LOOP_RAF, 1); // 绑定到 requestAnimationFrame
         // 这是通常的 Emscripten 主循环设置，而不是无限循环
         return 0; // Emscripten 的 main 函数返回后不会退出程序
     }
     ```

   - 你需要处理异步操作（如 `requestAdapter` 和 `requestDevice`）以及如何将 WASM 渲染循环与 `requestAnimationFrame` 绑定。Emscripten 提供了相应的机制。

2. **使用 Emscripten 编译：**

   - Emscripten 编译命令会有点复杂，因为它需要知道你的 WebGPU 定义，但不会链接 Dawn 库本身：

     

     

     ```
     emcc your_renderer.cpp -o your_renderer.html \
            -s USE_WEBGPU=1 \
            -s ASYNCIFY \
            -s EXPORTED_FUNCTIONS="['_init_webgpu', '_draw_frame']" \
            -s NO_EXIT_RUNTIME=1 \
            -s FORCE_FILESYSTEM=1 # 如果有文件加载
            # ... 其他 Emscripten 参数
     ```

   - `-s USE_WEBGPU=1`：告诉 Emscripten，你的 C++ 代码将使用 WebGPU API，它会引入必要的 JS 胶水代码，并期望浏览器提供 WebGPU API。

   - `-s ASYNCIFY`：如果你的 WebGPU 初始化过程包含异步操作（如 `requestAdapter`），你需要它来暂停 C++ 执行直到异步操作完成。

   - `-s EXPORTED_FUNCTIONS`：暴露 C++ 函数给 JavaScript 调用。

   - `NO_EXIT_RUNTIME=1`：防止 WASM 模块在 `main()` 函数结束后立即退出。

3. **Web 页面 (HTML/JavaScript)：**

   - Emscripten 会生成一个 `.html` 文件和一个 `.js` 胶水文件，以及 `.wasm` 文件。

   - JavaScript 会负责加载 WASM 模块，创建一个 `<canvas>` 元素，然后通过 Emscripten 暴露的 C++ 函数来初始化 WebGPU，并设置 `requestAnimationFrame` 循环来调用 WASM 中的 `draw_frame` 函数。

   - 示例 (your_renderer.js / your_renderer.html 内部的 JS):

     

     

     ```
     var Module = {
         preRun: [],
         postRun: [],
         print: (function() { /* ... */ })(),
         printErr: (function() { /* ... */ })(),
         canvas: (function() {
             var canvas = document.getElementById('canvas');
             // Emscripten 会自动将其绑定到渲染上下文
             return canvas;
         })(),
         setStatus: (function() { /* ... */ })(),
         totalDependencies: 0,
         monitorRunDependencies: function(left) { /* ... */ }
     };
     
     // 异步加载 WASM 模块
     Module.onRuntimeInitialized = async () => {
         const canvas = Module.canvas; // Emscripten already binds the canvas
         const context = canvas.getContext('webgpu'); // Get WebGPU context
     
         // Important: Get a WGPUSurface from the canvas context
         const surface = Module.WebGPUMakeSurfaceFromCanvasContext(context);
     
         // Call C++ init function, passing the surface pointer
         Module._init_webgpu(surface); // Assuming _init_webgpu expects a surface pointer
     
         // Setup render loop
         function frame() {
             Module._draw_frame();
             requestAnimationFrame(frame);
         }
         requestAnimationFrame(frame);
     };
     ```

   - 请注意 `WebGPUMakeSurfaceFromCanvasContext` 是 Emscripten 在使用 `USE_WEBGPU=1` 时提供的一个辅助函数。

### 2. 导出到本地端 (桌面应用)

在本地端，你的 C++ 程序将直接链接到 Dawn 库，并使用操作系统特定的接口（如 GLFW, SDL2, Native Windowing API）来创建窗口和管理事件。

**主要工具：C++ 编译器 (Clang, GCC, MSVC) + Dawn 库 + 窗口库**

1. **构建 Dawn 库：**

   - 你需要从 Dawn 的 GitHub 仓库 (https://dawn.googlesource.com/dawn 或 GitHub mirror) 克隆代码。
   - Dawn 使用 GN 和 Ninja 作为其构建系统。你需要按照 Dawn 仓库中的说明来构建它。这通常涉及：
     - 安装 depot_tools (Google 的工具链管理)。
     - `gclient sync` 下载依赖。
     - `gn gen out/Default` 或 `gn gen out/Debug` 生成构建文件。
     - `ninja -C out/Default` 编译 Dawn。
   - 这会生成 Dawn 的库文件（`.lib`, `.a`, `.so`, `.dll` 等取决于你的操作系统）。

2. **编写 C++ 渲染程序：**

   - 你的渲染代码会直接使用 Dawn 的 `wgpu::Instance`, `wgpu::Adapter`, `wgpu::Device` 等本地 Dawn 对象。
   - 创建窗口：使用如 GLFW 或 SDL2 这样的库来创建 OS 窗口，并获取其 `HWND` (Windows), `xcb_connection_t`/`Window` (Linux X11), `NSWindow` (macOS) 等句柄。
   - 通过 Dawn 的 `wgpu::Instance::CreateSurface` 方法，利用窗口句柄创建 `wgpu::Surface`。

   **示例（概念性）：**

   

   

   ```
   #include <GLFW/glfw3.h> // 用于窗口管理
   #include <dawn/webgpu_cpp.h> // 使用 Dawn 的 C++ 绑定
   #include <dawn/native/DawnNative.h> // 用于 WGPUNativeInstance
   
   // 全局实例、Adapter、Device等
   std::unique_ptr<dawn::native::Instance> g_instance;
   wgpu::Adapter g_adapter;
   wgpu::Device g_device;
   wgpu::Queue g_queue;
   wgpu::TextureFormat g_surfaceFormat;
   wgpu::Surface g_surface;
   
   void init_dawn_native(GLFWwindow* window) {
       g_instance = std::make_unique<dawn::native::Instance>();
       g_instance->DiscoverDefaultAdapters(); // 或手动选择
   
       // 获取 SurfaceDescriptor 适配平台
       #if defined(_WIN32)
           WGPUSurfaceDescriptorWindowsHWND surfaceDesc;
           surfaceDesc.chain.next = nullptr;
           surfaceDesc.chain.sType = WGPUSType_SurfaceDescriptorWindowsHWND;
           surfaceDesc.hinstance = GetModuleHandle(nullptr);
           surfaceDesc.hwnd = glfwGetWin32Window(window);
           WGPUSurfaceDescriptor sDesc;
           sDesc.nextInChain = reinterpret_cast<WGPUChainedStruct*>(&surfaceDesc);
           g_surface = g_instance->CreateSurface(&sDesc);
       #elif defined(__APPLE__)
           // ... macOS specific surface creation
       #elif defined(__linux__)
           // ... Linux specific surface creation
       #endif
   
       // 请求 adapter 和 device
       // 这一步在本地通常是同步的，但在某些复杂配置下也可以异步
       std::vector<wgpu::Adapter> adapters = g_instance->Get   Adapters();
       if (adapters.empty()) return; The adapters here are wgpu::Adapter which are not exposed from the instance.
       adapters[0].RequestDevice(nullptr, [](WGPURequestDeviceStatus status, WGPUDevice cDevice, const char* message, void* userdata) {
           if (status == WGPURequestDeviceStatus_Success) {
               g_device = wgpu::Device::Acquire(cDevice);
               g_queue = g_device.GetDefaultQueue();
           } else {
               // Error handling
           }
       }, nullptr);
   
       // ... (配置渲染管线等)
   }
   
   void draw_frame_native() {
       if (!g_device) return;
       // ... (创建 command encoder, render pass, draw calls, submit commands)
   }
   
   int main() {
       glfwInit();
       glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API); // 禁用 OpenGL 上下文
       GLFWwindow* window = glfwCreateWindow(800, 600, "Dawn Native", nullptr, nullptr);
   
       init_dawn_native(window); // 初始化 Dawn
   
       while (!glfwWindowShouldClose(window)) {
           glfwPollEvents();
           draw_frame_native(); // 渲染帧
       }
   
       glfwDestroyWindow(window);
       glfwTerminate();
       return 0;
   }
   ```

3. **编译与链接：**

   - 使用你的 C++ 编译器编译你的应用程序代码。
   - 链接到你之前构建的 Dawn 库文件以及窗口库（如 GLFW）。确保编译器能找到头文件（`-I`）和库文件（`-L`）。
   - 还需要链接到驱动程序 API（如 Vulkan, D3D12, Metal）的库，具体取决于 Dawn 的后端配置和你的目标平台。

### 总结与注意事项：

- **代码共享：** 努力将核心的 WebGPU 渲染逻辑（管线创建、资源管理、绘制调用）放在一个平台无关的模块中。只有窗口创建、设备获取和主循环部分需要平台特化。
- **平台抽象：** 可以引入一个抽象层，例如 `IPlatform` 接口，来处理窗口创建、事件监听和异步回调，然后针对 Web 和 Native 分别实现这个接口。
- **异步性：** WebGPU API 本身就包含许多异步操作（`requestAdapter`, `requestDevice`, `mapAsync`），在 Web 端这天然是异步的，但在本地端，某些操作可能是同步或通过回调模拟异步。你需要兼容这种行为差异。
- **文件 I/O：** 在 Web 端，直接文件 I/O 是受限的，通常需要通过 `fetch` API 或打包到 WASM 中；在本地端则可以自由访问文件系统。
- **调试：** WebGPU 在浏览器中有强大的调试工具（例如 Chrome DevTools 中的 GPU 面板）。本地 Dawn 也有自己的调试层。
