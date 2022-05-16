import fs from 'fs';
import execa from 'execa';
import zlib from 'zlib';
import render from './render.js';
import { createBrowser, saveScreenshots, streamToString } from './utils.js';

const normalizeOptions = function (animationData, options) {
  if (!options.width || !options.height) {
    const { w = 512, h = 512 } = animationData;
    const aR = w / h;

    if (options.width) {
      options.height = options.width / aR;
    } else if (options.height) {
      options.width = options.height * aR;
    } else {
      options.width = w;
      options.height = h;
    }
  }

  options.width = options.width | 0;
  options.height = options.height | 0;

  return options;
};

const fromStream = function (converter) {
  return async (inputStream, outputPath, options = {}) => {
    const lottieString = await streamToString(inputStream.pipe(zlib.createGunzip()));
    let browser;
    if (!options.browser) {
      options.browser = browser = await createBrowser();
    }

    const animationData = JSON.parse(lottieString);
    const result = await converter(animationData, outputPath, normalizeOptions(animationData, options));
    if (browser) {
      await browser.close();
    }
    return result;
  }
};

const fromFile = function (converterFromStream) {
  return (inputPath, outputPath, options) => {
    return converterFromStream(fs.createReadStream(inputPath), outputPath, options);
  };
};

export const toGif = fromStream(async function (animationData, outputPath, options = {}) {
  options.quality = options.quality || 80;
  options.fps = options.fps || Math.min(animationData.fr, 50); // most viewers do not support gifs with FPS > 50

  const { dir, pattern } = await saveScreenshots(await render(options.browser, animationData, options));

  try {
    await execa.shell([
      process.env.GIFSKI_PATH || 'gifski',
      '-o', `"${outputPath}"`,
      '--fps', options.fps,
      '--quality', options.quality,
      '--height', options.height,
      '--width', options.width,
      '--quiet',
      pattern,
    ].join(' '));
  } catch (e) {
    throw e;
  } finally {
    fs.rmdir(dir, { recursive: true }, () => {});
  }
});
export const toGifFromFile = fromFile(toGif);

// for capability with previous version
export const convertFile = async function (inputPath, options = {}) {
  return toGifFromFile(inputPath, options.output || inputPath + '.gif', options);
};

export const toWebP = fromStream(async function (animationData, outputPath, options = {}) {
  options.fps = options.fps || animationData.fr;

  const { dir, pattern } = await saveScreenshots(await render(options.browser, animationData, options));

  try {
    await execa.shell([
      process.env.IMG2WEBP_PATH || 'img2webp',
      '-lossy',
      '-d', Math.round(1000 / options.fps),
      pattern,
      '-o', `"${outputPath}"`,
    ].join(' '));
  } catch (e) {
    throw e;
  } finally {
    fs.rmdir(dir, { recursive: true }, () => {});
  }
});
export const toWebpFromFile = fromFile(toWebP);
