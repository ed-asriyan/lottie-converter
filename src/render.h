#ifndef TGS_TO_GIF_RENDER_H
#define TGS_TO_GIF_RENDER_H

#include <cmath>
#include <filesystem>
#include <string>
#include <png.h>
#include <rlottie.h>

void render(
	const std::string& lottieData,
	const size_t width,
	const size_t height,
	const std::filesystem::path& output_directory,
	double fps = 0,
	size_t threads_count = 0
);

#endif //TGS_TO_GIF_RENDER_H
