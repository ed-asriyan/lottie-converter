const fs = require('fs');
const path = require('path');

const {createBrowser, convertFile} = require('./index.js');

const convertFiles = async function (filePaths, browser) {
  for (const filePath of filePaths) {
    console.log(`Converting ${filePath}...`);

    try {
      await convertFile(filePath, {output: `${filePath}.gif`, browser});
    } catch (e) {
      console.error(e);
    }
  }
};

const main = async function () {
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

  const browser = await createBrowser({
    chromiumPath: process.env['CHROMIUM_PATH'],
    useSandbox: JSON.parse(process.env['USE_SANDBOX'] || 'true'),
  });
  await convertFiles(paths, browser);
  await browser.close();
};

main();
