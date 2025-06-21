# Lottie Animations (.json) and Telegram Stickers (*.tgs) to GIF/PNG/APNG/WEBP/WEBM converter
[![CI | Build & Test](https://github.com/ed-asriyan/lottie-converter/actions/workflows/ci-build-and-test.yml/badge.svg)](https://github.com/ed-asriyan/lottie-converter/actions/workflows/ci-build-and-test.yml)
[![CD | Release & Push to Dockerhub](https://github.com/ed-asriyan/lottie-converter/actions/workflows/cd-release.yml/badge.svg)](https://github.com/ed-asriyan/lottie-converter/actions/workflows/cd-release.yml)


<hr/>
<h3 align="center">
To easily transfer Telegram stickers to WhatsApp you can use Telegram Bot</br></br>👉 https://t.me/tgtowabot 👈
</h3>
<hr/>

## How to use
There are 2 options:
* Run using [Docker](https://www.docker.com/). One-line command, the option requires only Docker installed
* Download and run compiled executable files. The option requires run-time dependecies installed

### 1 Using compiled executables
1. Install run-time dependencies. Make sure the path to them present in `PATH` variable:
   - **[gifski](https://gif.ski)** if you want to convert to GIF
   - **[ffmpeg](https://ffmpeg.org)** if you want to convert to APNG or WEBM
   - **[img2webp](https://developers.google.com/speed/webp/docs/img2webp)** if you want to convert to WEBP
   - Download executable from [releases section of this repo](https://github.com/ed-asriyan/lottie-converter/releases) for your OS and arch

> [!TIP]
> On Windows, you can use Chocolatey or Winget to install it.
Example: 
```
choco webp ffmpeg-full gifski git -y
```
Or if you prefer you can manually install each one.

Run Downloader.sh
Paste your bot API token obtained from [botFather](https://t.me/BotFather).
Then it will ask you which sticker pack you want to download. You can enter the name or the link. If the stickers are classic, they will be downloaded to /converted. If the stickers are animated (tgs), the templates will be downloaded to /TGSs. Then you must use ./converter.sh to convert them to webp.


https://github.com/user-attachments/assets/c7ce3b98-7b0b-44ab-b9bf-c0f4fff7fb6d

> [!TIP]
> You can edit `converter.sh` to change the graphics settings.
The default for `converter.sh` is
```
HEIGHT=200 #
WIDTH=200 #
FPS=40 # fluidity
QUALITY=50 # Quality
```
## 2 Using Docker
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
- Convert to WEBM:
  ```bash
  docker run --rm -v <path to directory>:/source edasriyan/lottie-to-webm
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

2. Download executable from [releases section of this repo](https://github.com/ed-asriyan/lottie-converter/releases) for your OS and arch
3. In downloaded archive find the following executable scripts:
   - `lottie_to_apng.sh`
   - `lottie_to_gif.sh`
   - `lottie_to_png.sh`
   - `lottie_to_webp.sh`
   - `lottie_to_webm.sh`
   
   All of them have the same CLI:
   ```commandline
   $ ./bin/lottie_to_gif.sh -h                       
   usage: ./bin/lottie_to_gif.sh [--help] [--output OUTPUT] [--height HEIGHT] [--width WIDTH] [--threads THREADS] [--fps FPS] [--quality QUALITY] path
 
   Lottie animations (.json) and Telegram stickers for Telegram (*.tgs) to animated .gif converter

   Positional arguments:
   path              Path to .json or .tgs file to convert

   Optional arguments:
   -h, --help        show this help message and exit
   --output OUTPUT   Output file path
   --height HEIGHT   Output image height. Default: 
   --width WIDTH     Output image width. Default: 512
   --fps FPS         Output frame rate. Default: 50
   --threads THREADS Number of threads to use. Default: number of CPUs
   --quality QUALITY Output quality. Default: 90
   ```

# Build
1. Install dependencies
   1. Make sure you have **C++17 compiler**, **make**, **[cmake](https://cmake.org)** and **[conan](https://conan.io)** tools installed; otherwise install them
   2. Detect your conan profile
      ```commandline
      conan profile detect
      ```
   3. Install conan dependencies
      ```commandline
      conan install --build=missing .
      ```
2. Invoke conan preset
      * Linux & MacOS
        ```commandline
        cmake --preset conan-release
        ```
      * Windows
        ```commandline
        cmake --preset conan-default
        ```
3. Build
   ```commandline
   cmake -DCMAKE_BUILD_TYPE=Release -DLOTTIE_MODULE=OFF CMakeLists.txt && cmake --build . --config Release
   ```
4. Convert!
   - To convert to GIF:
     ```commandline
     ./bin/lottie_to_gif.sh /home/ed/Downloads/animation.json
     ```
   - To convert to PNG:
     ```commandline
     ./bin/lottie_to_png.sh /home/ed/Downloads/animation.json
     ```
   - To convert to APNG:
     ```commandline
     ./bin/lottie_to_apng.sh /home/ed/Downloads/animation.json
     ```
   - To convert to WEBP:
     ```commandline
     ./bin/lottie_to_webp.sh /home/ed/Downloads/animation.json
     ```
   - To convert to WEBM:
     ```commandline
     ./bin/lottie_to_webm.sh /home/ed/Downloads/animation.json
     ```
   Results will be saved next to each source file in the same directory.

## Notices
* What is lottie? - https://airbnb.design/lottie/
* You can download Telegram sticker files (.tgs) using [@Stickerdownloadbot](https://t.me/Stickerdownloadbot).

<div align="center">
  <a href="https://star-history.com"><img src="https://api.star-history.com/svg?repos=ed-asriyan/lottie-converter&type=Date"/></a>
  <a href="https://info.flagcounter.com/0hsy"><img src="https://s01.flagcounter.com/count2/0hsy/bg_FFFFFF/txt_000000/border_CCCCCC/columns_4/maxflags_12/viewers_0/labels_0/pageviews_1/flags_0/percent_0"/></a>
</div>
