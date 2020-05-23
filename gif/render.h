#ifndef TGS_TO_GIF_RENDER_H
#define TGS_TO_GIF_RENDER_H

#include <cmath>
#include <string>
#include <rlottie.h>

#include "gif_builder.h"

bool render(
	const std::string& lottieData,
	size_t width,
	size_t height,
	size_t alphaThreshold,
	const std::string& outputPath,
	double fps = 0
);

#endif //TGS_TO_GIF_RENDER_H
