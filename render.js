import { createRequire } from 'module';
import { readFromFile } from './utils.js';

let lottieScript;

const getHtml = async function ({ animationData, background, width, height }) {
    if (!lottieScript) {
        const require = createRequire(import.meta.url);
        lottieScript = await readFromFile(require.resolve('lottie-web').replace('.js', '.min.js'));
    }

    return `
<html>
<head>
  <meta charset="UTF-8">

  <script>${lottieScript}</script>

  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
        
    body {
      background: ${background};
    
      ${width ? 'width: ' + width + 'px;' : ''}
      ${height ? 'height: ' + height + 'px;' : ''}
    
      overflow: hidden;
    }
  </style>
</head>

<body>

<div id="root"></div>

<script>
  const animationData = ${JSON.stringify(animationData)}
  let animation = null
  let duration
  let numFrames

  function onReady () {
    animation = lottie.loadAnimation({
      container: document.getElementById('root'),
      renderer: 'svg',
      loop: false,
      autoplay: false,
      animationData: animationData
    })

    duration = animation.getDuration()
    numFrames = animation.getDuration(true)

    var div = document.createElement('div')
    div.className = 'ready'
    document.body.appendChild(div)
  }

  document.addEventListener('DOMContentLoaded', onReady)
</script>

</body>
</html>
`;
}

export default async function (browser, animationData, options = {}) {
    const {
        background = 'transparent',
        width = undefined,
        height = undefined,
        fps = ~~animationData.fr,
    } = options;

    const html = await getHtml({ animationData, background, width, height });
    const fpsRatio = ~~animationData.fr / fps;

    const page = await browser.newPage();

    page.on('console', console.log.bind(console));
    page.on('error', console.error.bind(console));

    await page.setContent(html);
    await page.waitForSelector('.ready');

    const duration = await page.evaluate(() => duration);
    const outputNumFrames = fps * duration;

    const pageFrame = page.mainFrame();
    const rootHandle = await pageFrame.$('#root');

    const result = [];
    for (let frame = 0; frame < outputNumFrames; ++frame) {
        await page.evaluate((frame) => animation.goToAndStop(frame, true), frame * fpsRatio);
        result.push(await rootHandle.screenshot({ omitBackground: true, type: 'png' }));
    }
    return result;
};
