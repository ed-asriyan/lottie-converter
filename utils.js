import * as fs from 'fs';
import { join } from 'path';
import os from 'os';
import puppeteer from 'puppeteer';

export const createBrowser = function () {
    return puppeteer.launch({
        executablePath: process.env['CHROMIUM_PATH'],
        args: JSON.parse(process.env['USE_SANDBOX'] || 'true') ? undefined : ['--no-sandbox'],
    });
};

const rootTemporaryDirectory = os.tmpdir();
export const createTemporaryDirectory = async function () {
    return new Promise((resolve, reject) => fs.mkdtemp(
        join(rootTemporaryDirectory, `tgs-to-gif-`),
        function (err, data) {
            if (err) {
                reject(err);
            } else {
                resolve(data);
            }
        }
    ));
}

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
    const dir = await createTemporaryDirectory();
    const files = screenshots.map(() => null);

    await Promise.all(
        screenshots.map(
            async (screenshot, i) => {
                const filePath = join(dir, `file-${pad(i, 4)}.png`);
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

export const pad = function (num, size) {
    const s = `000000000${num}`;
    return s.slice(s.length - size);
};

export const removeDirectory = function (directoryPath) {
    return new Promise((resolve, reject) => fs.rmdir(directoryPath, { recursive: true }, function (err, data) {
        if (err) {
            reject(err);
        } else {
            resolve(data);
        }
    }));
};
