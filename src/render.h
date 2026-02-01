#ifndef LOTTIE_TO_GIF_RENDER_H
#define LOTTIE_TO_GIF_RENDER_H

#include <cmath>
#include <filesystem>
#include <string>
#include <optional>
#include <png.h>
#include <rlottie.h>

struct BackgroundColor {
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
};

void render(
	const std::string& lottieData,
	const size_t width,
	const size_t height,
	const std::filesystem::path& output_directory,
	double fps = 0,
	size_t threads_count = 0,
	const std::optional<BackgroundColor>& background = std::nullopt
);

#endif //LOTTIE_TO_GIF_RENDER_H
