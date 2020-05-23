#ifndef TGS_TO_GIF_GIF_BUILDER_H
#define TGS_TO_GIF_GIF_BUILDER_H

#include <string>
#include <rlottie.h>

#include "gif.h"

class GifBuilder {
public:
	explicit GifBuilder(
		const std::string& fileName,
		uint32_t width,
		uint32_t height,
		uint32_t delay,
		uint32_t alphaThreshold
	);

	~GifBuilder();

	void addFrame(rlottie::Surface& s, uint32_t delay);

	void argbTorgba(rlottie::Surface& s);

private:
	GifWriter handle;

	uint32_t alphaThreshold;
};

#endif //TGS_TO_GIF_GIF_BUILDER_H
