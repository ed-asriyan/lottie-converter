# Animated stickers for Telegram (*.tgs) to animated GIF/WEBP converter [![CircleCI](https://circleci.com/gh/ed-asriyan/tgs-to-gif/tree/master.svg?style=svg)](https://circleci.com/gh/ed-asriyan/tgs-to-gif/tree/master)

<hr/>
<h3 align="center">
To easily convert stickers to GIFs you can use Telegram Bot</br></br>👉 https://t.me/tgstogifbot 👈
</h3>
<hr/>

## How to use
There are several ways:

### Using [Docker](https://www.docker.com/)
1. Build the image:
    ```bash
    docker build --platform linux/x86_64 -t tgs-to-gif .
    ```

2. Convert! Pass directory with stickers and run:
   - Convert to GIF:
     ```bash
     docker run -e FORMAT=gif --platform linux/x86_64 --rm -v <path to directory with stickers>:/source tgs-to-gif
     ```
   - Convert to WEBP:
     ```bash
     docker run -e FORMAT=webp --platform linux/x86_64 --rm -v <path to directory with stickers>:/source tgs-to-gif
     ```
   Results will be saved next to each source sticker file in the same directory.

### Building from sources
1. Install dependencies
    1. Make sure you have **C++17 compiler**, **make**, **[cmake](https://cmake.org)** and **[conan](https://conan.io)** tools installed; otherwise install them
    2. Make sure you have the tools installed:
       - **[gifski](https://gif.ski)** if you want to convert to GIF
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
     ./tgs_to_gif.sh /home/ed/Downloads/sticker.tgs
     ```
   - To convert to WEBP: 
     ```terminal
     ./tgs_to_webp.sh /home/ed/Downloads/sticker.tgs
     ```
   Results will be saved next to each source sticker file in the same directory.

#### CLI arguments
```terminal
$ ./tgs_to_gif.sh --help 
usage: tgs_to_gif.sh [--help] [--output OUTPUT] [--height HEIGHT] [--width WIDTH] [--fps FPS] path

Animated sticker for Telegram (*.tgs) to animated .gif converter

Positional arguments:
 path             Path to .tgs file to convert

Optional arguments:
 -h, --help       show this help message and exit
 --output OUTPUT  Output file path
 --height HEIGHT  Output image height. Default: 512
 --width WIDTH    Output image width. Default: 512
 --fps FPS        Output frame rate. Default: 50
 --quality FPS    Output quality. Default: 90
```

## Notices
You can download .tgs files using [@Stickerdownloadbot](https://t.me/Stickerdownloadbot).
