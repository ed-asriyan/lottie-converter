# Animated stickers for Telegram (*.tgs) to animated GIFs converter

<hr/>
<h3 align="center">
To easily convert stickers to GIFs you can use Telegram Bot</br></br>👉 https://t.me/tgstogifbot 👈
</h3>
<hr/>


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

## Using nodejs and gifski
### Install
1. Install [nodejs](https://nodejs.org).
2. Install [gifski](https://gif.ski).
3. Install npm dependencies:
    ```bash
    npm install
    ```
### Convert
Pass one or several stickers:
```bash
node cli.js sticker1.tgs sticker2.tgs ... 
```

or pass a directory:
```bash
node cli.js /home/ed/Downloads/super_pack/
```

The result will be saved next to each source sticker file in the same directory.

#### CLI arguments
```
$ node cli.js --help
usage: cli.js [-h] [--height HEIGHT] [--width WIDTH] paths [paths ...]

Animated stickers for Telegram (*.tgs) to animated GIFs converter

Positional arguments:
  paths            Paths to .tgs files to convert

Optional arguments:
  -h, --help       Show this help message and exit.
  --height HEIGHT  Output image height. Default: auto
  --width WIDTH    Output image width. Default: auto
```

## Notices
You can download .tgs files using [@Stickerdownloadbot](https://t.me/Stickerdownloadbot).
