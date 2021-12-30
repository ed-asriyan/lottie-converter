import fs from 'fs';
import { join } from 'path';
import tempy from 'tempy';
import puppeteer from 'puppeteer';

export const createBrowser = function () {
    return puppeteer.launch({
        executablePath: process.env['CHROMIUM_PATH'],
        args: JSON.parse(process.env['USE_SANDBOX'] || 'true') ? undefined : ['--no-sandbox'],
    });
};

export const writeToFile = function (data, filePath) {
    return new Promise((resolve, reject) => {
        fs.writeFile(filePath, data, function (err) {
            if (err) {
                reject(err);
            } else {
                resolve();
            }
        });
    });
};

export const readFromFile = function (filePath) {
    return new Promise((resolve, reject) => {
        fs.readFile(filePath, 'utf8', function (err, data) {
            if (err) {
                reject(err);
            } else {
                resolve(data);
            }
        });
    });
};

export const saveScreenshots = async function (screenshots) {
    const dir = tempy.directory();
    const files = screenshots.map(() => null);

    await Promise.all(
        screenshots.map(
            async (screenshot, i) => {
                const filePath = join(dir, `file-${i}.png`);
                await writeToFile(screenshot, filePath);
                files[i] = filePath;
            }
        )
    );

    return { dir, files, pattern: join(dir, 'file-*.png') };
};

export const streamToString = function (stream) {
    const chunks = [];
    return new Promise((resolve, reject) => {
        stream.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
        stream.on('error', (err) => reject(err));
        stream.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
    });
};
