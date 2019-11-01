const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer');
const renderLottie = require('puppeteer-lottie');
const tempy = require('tempy');
const zlib = require('zlib');

const unzip = function(inputPath, outputPath) {
  const inputStream = fs.createReadStream(inputPath);
  const outputStream = fs.createWriteStream(outputPath);
  return new Promise((resolve, reject) => inputStream.pipe(zlib.createGunzip()).
    pipe(outputStream).
    on('finish', (err) => err ? reject(err) : resolve()));
};

const convertFiles = async function(files) {
  const browser = await puppeteer.launch();
  for (const path of files) {
    console.log(`Converting ${path}...`);

    try {
      const unzippedPath = tempy.file({extension: 'json'});
      await unzip(path, unzippedPath);

      await renderLottie({
        path: unzippedPath,
        output: path + '.gif',
        browser,
      });
    } catch (e) {
      console.error(e);
    }
  }
  await browser.close();
};

const paths = process.argv.slice(2);
for (let i = 0; i < paths.length; ++i) {
  let filePath = paths[i];
  if (fs.lstatSync(filePath).isDirectory()) {
    for (const subFilePath of fs.readdirSync(filePath)) {
      if (path.extname(subFilePath) === '.tgs') {
        paths.push(path.join(filePath, subFilePath));
      }
    }
    paths.splice(i--, 1);
  }
}

convertFiles(paths);
