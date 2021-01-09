const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');
const renderLottie = require('puppeteer-lottie');
const tempy = require('tempy');
const zlib = require('zlib');

const unzip = function (inputPath, outputPath) {
  const inputStream = fs.createReadStream(inputPath);
  const outputStream = fs.createWriteStream(outputPath);
  return new Promise((resolve, reject) => inputStream.pipe(zlib.createGunzip()).on('error', (err) => reject(err)).pipe(outputStream).on('finish', (err) => err ? reject(err) : resolve()));
};

const createBrowser = function ({chromiumPath, useSandbox = true}) {
  return puppeteer.launch({
    executablePath: chromiumPath,
    args: useSandbox ? undefined : ['--no-sandbox'],
  });
};

const convertFile = async function (inputPath, options = {}) {
  const unzippedPath = tempy.file({extension: 'json'});
  await unzip(inputPath, unzippedPath);

  output = options.output || inputPath + '.gif';

  await renderLottie({
    path: unzippedPath,
    output,
    ...options,
  });
};

module.exports = {
  createBrowser,
  convertFile,
};
