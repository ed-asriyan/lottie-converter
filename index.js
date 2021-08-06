const fs = require('fs');
const puppeteer = require('puppeteer');
const renderLottie = require('puppeteer-lottie');
const tempy = require('tempy');
const zlib = require('zlib');

const unzip = async function (inputPath, outputPath) {
  const inputStream = fs.createReadStream(inputPath);
  const outputStream = fs.createWriteStream(outputPath);
  try {
    await new Promise((resolve, reject) => inputStream.pipe(zlib.createGunzip()).on('error', (err) => reject(err)).pipe(outputStream).on('finish', (err) => err ? reject(err) : resolve()));
  } finally {
    outputStream.close();
    inputStream.close();
  }
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

  const output = options.output || inputPath + '.gif';

  await renderLottie({
    path: unzippedPath,
    output,
    ...options,
  });

  await new Promise(resolve => fs.unlink(unzippedPath, resolve));
};

module.exports = {
  createBrowser,
  convertFile,
};
