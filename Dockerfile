FROM rust:alpine as builder
MAINTAINER Ed Asriyan <ed-asriyan@protonmail.com>

# https://stackoverflow.com/a/30873179
RUN apk add --no-cache musl-dev
RUN cargo install --version 1.4.3 gifski

FROM node:14-alpine
COPY --from=builder /usr/local/cargo/bin/gifski /usr/local/bin/gifski

# https://github.com/puppeteer/puppeteer/blob/master/docs/troubleshooting.md#running-on-alpine
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      freetype-dev \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      git \
      libwebp-tools

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

WORKDIR /app

# install dependencies
ADD package.json .
ADD package-lock.json .
RUN npm ci

# build the app
ADD tests tests
ADD cli.js .
ADD index.js .
ADD render.js .
ADD utils.js .

ENV USE_SANDBOX false
ENV CHROMIUM_PATH /usr/bin/chromium-browser

CMD node cli.js /source
