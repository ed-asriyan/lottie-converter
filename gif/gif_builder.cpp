#include "gif_builder.h"

GifBuilder::GifBuilder(
	const std::string& fileName,
	uint32_t width,
	uint32_t height,
	uint32_t delay,
	uint32_t alphaThreshold
) : alphaThreshold(alphaThreshold) {
	GifBegin(&handle, fileName.c_str(), width, height, delay);
}

GifBuilder::~GifBuilder() {
	GifEnd(&handle);
}

void GifBuilder::addFrame(rlottie::Surface& s, uint32_t delay = 2) {
	argbTorgba(s);
	GifWriteFrame(
		&handle,
		reinterpret_cast<uint8_t*>(s.buffer()),
		s.width(),
		s.height(),
		delay,
		8,
		1
	);
}

void GifBuilder::argbTorgba(rlottie::Surface& s) {
	uint8_t* buffer = reinterpret_cast<uint8_t*>(s.buffer());
	uint32_t totalBytes = s.height() * s.bytesPerLine();

	for (uint32_t i = 0; i < totalBytes; i += 4) {
		unsigned char a = buffer[i + 3];
		// compute only if alpha is non zero
		if (a) {
			unsigned char r = buffer[i + 2];
			unsigned char g = buffer[i + 1];
			unsigned char b = buffer[i];
			if (a != 255) { //un premultiply
				r = (r * 255) / a;
				g = (g * 255) / a;
				b = (b * 255) / a;

				buffer[i] = r;
				buffer[i + 1] = g;
				buffer[i + 2] = b;
			} else {
				// only swizzle r and b
				buffer[i] = r;
				buffer[i + 2] = b;
			}
		}
	}
}
