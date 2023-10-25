# Lottie Animations (.json) and Telegram Stickers (*.tgs) to FORMAT converter
Replace with directory with Lottie animations / Telegram stickers and run:
```bash
docker run --rm -v <path to directory>:/source edasriyan/lottie-to-format
```

You can provide parameters via env variables:
* `HEIGHT`: Output image height. Default: 512
* `WIDTH`: Output image width. Default: 512
* `FPS`: Output frame rate. Default: apng,png,webp - 60; gif - 50
* `QUALITY`: Output quality. Default: 90
* `THREADS`: Number of threads to use. Default: number of CPUs

Example:
```bash
docker run --rm -e HEIGHT=256 -e WIDTH=256 -e FPS=30 -v /home/ed/Downloads/lottie-animations:/source edasriyan/lottie-to-format
```

Results will be saved next to each source file in the same directory.

## Source
https://github.com/ed-asriyan/lottie-converter
