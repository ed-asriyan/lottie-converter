# Animated stickers for Telegram (*.tgs) to animated GIFs converter

<hr/>
<h3 align="center">
To easily convert stickers to GIFs you can use Telegram Bot</br></br>👉 https://t.me/tgstogifbot 👈
</h3>
<hr/>

_This is a C++ version of tgs-to-gif, generated GIFs may contain [some artifacts](https://github.com/ed-asriyan/tgs-to-gif/issues/13#issuecomment-633244547)._

## Using [Docker](https://www.docker.com/)
1. Build the image:
    ```bash
    docker build -t tgs-to-gif .
    ```

2. Convert! Pass directory with stickers and run:
    ```bash
    docker run --rm -v <path to directory with stickers>:/source tgs-to-gif
    ```

The result will be saved next to each source sticker file in the same directory.

## Building from sources
1. Install dependencies
    1. Make sure you have **g++** or **clang**, **make**, **cmake** and **conan** tools installed. Install them if it is not. 
    2. Install [rlottie](https://github.com/Samsung/rlottie).
       ```
       git clone git@github.com:Samsung/rlottie.git && \
       (cd rlottie && cmake CMakeLists.txt && make && sudo make install) && \
       rm -fr rlottie 
       ```
    3. Install conan dependencies.
       ```
       conan install .
       ```
2. Build
    ```
    cmake CMakeLists.txt && make
    ```

### Convert
Pass one or several stickers:
```bash
./tgs_to_gif sticker.tgs 
```

or pass a directory:
```bash
./tgs_to_gif /home/ed/Downloads/super_pack/
```

The result will be saved next to each source sticker file in the same directory.

#### CLI arguments
```terminal
$ ./tgs_to_gif --help
: expected 1 argument(s). 0 provided.
Usage: tgs-to-gif [options] path 

Positional arguments:
path        	path to telegram sticker file[Required]

Optional arguments:
-h --help   	show this help message and exit
-o --output 	path to output GIF file
-w --width  	output image width
-h --height 	output image height
-f --fps    	output animation FPS. If 0 use FPS from tgs animation
```

## Notices
You can download .tgs files using [@Stickerdownloadbot](https://t.me/Stickerdownloadbot).
