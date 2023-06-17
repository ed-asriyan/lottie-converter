# Lottie Animations (.json) and Telegram Stickers (*.tgs) to GIF/PNG/APNG/WEBP converter
[![CI | Build & Test](https://github.com/ed-asriyan/tgs-to-gif/actions/workflows/ci-build-and-test.yml/badge.svg)](https://github.com/ed-asriyan/tgs-to-gif/actions/workflows/ci-build-and-test.yml)
[![CD | Push to DockerHub](https://github.com/ed-asriyan/tgs-to-gif/actions/workflows/cd-push-dockerhub.yml/badge.svg)](https://github.com/ed-asriyan/tgs-to-gif/actions/workflows/cd-push-dockerhub.yml)

<hr/>
<h3 align="center">
To easily convert Telegram stickers to GIFs you can use Telegram Bot</br></br>👉 https://t.me/tgstogifbot 👈
</h3>
<hr/>

## How to use
There are two options: run using [Docker](https://www.docker.com/) and run from source.

### Using Docker
Replace with directory with Lottie animations / Telegram stickers and run:
- Convert to GIF:
  ```bash
  docker run --rm -v <path to directory>:/source edasriyan/lottie-to-gif
  ```
- Convert to PNG:
  ```bash
  docker run --rm -v <path to directory>:/source edasriyan/lottie-to-png
  ```
- Convert to APNG:
  ```bash
  docker run --rm -v <path to directory>:/source edasriyan/lottie-to-apng
  ```
- Convert to WEBP:
  ```bash
  docker run --rm -v <path to directory>:/source edasriyan/lottie-to-webp
  ```

You can provide parameters via env variables:
* `HEIGHT`: Output image height. Default: 512
* `WIDTH`: Output image width. Default: 512
* `FPS`: Output frame rate. Default: apng,png,webp - 60; gif - 50
* `QUALITY`: Output quality. Default: 90
* `THREADS`: Number of threads to use. Default: number of CPUs

Example:
```bash
docker run --rm -e HEIGHT=256 -e WIDTH=256 -e FPS=30 -v /home/ed/Downloads/lottie-animations:/source edasriyan/lottie-to-apng
```

Results will be saved next to each source file in the same directory.

### From source
1. Install dependencies
    1. Make sure you have **C++17 compiler**, **make**, **[cmake](https://cmake.org)** and **[conan](https://conan.io)** tools installed; otherwise install them
    2. Make sure you have the tools installed:
       - **[gifski](https://gif.ski)** if you want to convert to GIF
       - **[ffmpeg](https://ffmpeg.org)** if you want to convert to APNG
       - **[img2webp](https://developers.google.com/speed/webp/docs/img2webp)** if you want to convert to WEBP
    3. Install conan dependencies
       ```terminal
       conan install .
       ```
2. Build
   ```terminal
   cmake CMakeLists.txt && make
   ```
   <details>
       <summary>CMake options</summary>
       <code>LOTTIE_TO_PNG_STATIC_LINKING</code>: enable static linking. Default value: <code>OFF</code> if OS is darwin; otherwise <code>ON</code>

       cmake -DLOTTIE_TO_PNG_STATIC_LINKING=ON CMakeLists.txt && make
       
       cmake -DLOTTIE_TO_PNG_STATIC_LINKING=OFF CMakeLists.txt && make
   </details>
   <details>
       <summary>ARM troubleshooting (including Apple M1)</summary>
       Run the following command and try again:
   
       echo '#if defined(__ARM_NEON__)
   
       #include "vdrawhelper.h"
    
       void memfill32(uint32_t *dest, uint32_t value, int length)
       {
           memset(dest, value, length);
       }
   
       static void color_SourceOver(uint32_t *dest, int length, uint32_t color, uint32_t alpha)
       {
           int ialpha, i;

           if (alpha != 255) color = BYTE_MUL(color, alpha);
           ialpha = 255 - vAlpha(color);
           for (i = 0; i < length; ++i) dest[i] = color + BYTE_MUL(dest[i], ialpha);
       }
   
       void RenderFuncTable::neon()
       {
           updateColor(BlendMode::Src , color_SourceOver);
       }
       #endif
       ' > lib/src/rlottie/src/vector/vdrawhelper_neon.cpp
    </details>
3. Convert!
   - To convert to GIF: 
     ```terminal
     ./bin/lottie_to_gif.sh /home/ed/Downloads/animation.json
     ```
   - To convert to PNG: 
     ```terminal
     ./bin/lottie_to_png.sh /home/ed/Downloads/animation.json
     ```
   - To convert to APNG:
     ```terminal
     ./bin/lottie_to_apng.sh /home/ed/Downloads/animation.json
     ```
   - To convert to WEBP: 
     ```terminal
     ./bin/lottie_to_webp.sh /home/ed/Downloads/animation.json
     ```
   Results will be saved next to each source file in the same directory.

#### CLI arguments
```terminal
$ ./bin/lottie_to_gif.sh --help 
usage: ./bin/lottie_to_gif.sh [--help] [--output OUTPUT] [--height HEIGHT] [--width WIDTH] [--threads THREADS] [--fps FPS] [--quality QUALITY] path

Lottie animations (.json) and Telegram stickers for Telegram (*.tgs) to animated .gif converter

Positional arguments:
 path              Path to .json or .tgs file to convert

Optional arguments:
 -h, --help        show this help message and exit
 --output OUTPUT   Output file path
 --height HEIGHT   Output image height. Default: 512
 --width WIDTH     Output image width. Default: 512
 --fps FPS         Output frame rate. Default: 50
 --threads THREADS Number of threads to use. Default: number of CPUs
 --quality QUALITY Output quality. Default: 90
```

## Notices
* What is lottie? - https://airbnb.design/lottie/
* You can download Telegram sticker files (.tgs) using [@Stickerdownloadbot](https://t.me/Stickerdownloadbot).

|<a href="https://www.jetbrains.com/clion/" ><img src="https://resources.jetbrains.com/storage/products/company/brand/logos/CLion.png" alt="CLion logo." style="height: 100px"></a>|
|--|
|Project is made with [Jetbrains](https://www.jetbrains.com) support ❤️|
