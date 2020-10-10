#include "render.h"

bool render(
	const std::string& lottieData,
	size_t width,
	size_t height,
	size_t alphaThreshold,
	const std::string& outputPath,
	double fps
) {
	static unsigned int cacheCounter = 0; // rlottie uses caches for internal optimizations
	auto player = rlottie::Animation::loadFromData(lottieData, std::to_string(cacheCounter++));
	if (!player) return false;

	if (fps == 0.0) {
		fps = player->frameRate();
	}

	const double averageDelay = 100 / fps;
	const double averageDelayFractional = averageDelay - (int) averageDelay;
	const int longFrameFrequency = averageDelayFractional > 0 ? (int) round(1 / averageDelayFractional) : 1;

	// the most of gif viewers does not properly play gif with duration = 1
	const size_t longFrameDuration = (size_t) std::max(2.0, ceil(averageDelay));
	const size_t shortFrameDuration = (size_t) std::max(2.0, floor(averageDelay));

	auto buffer = std::unique_ptr<uint32_t[]>(new uint32_t[width * height]);
	size_t frameCount = player->totalFrame();

	GifBuilder builder(outputPath, width, height, 2, alphaThreshold);
	for (size_t i = 0; i < frameCount; i++) {
		rlottie::Surface surface(buffer.get(), width, height, width * 4);
		player->renderSync(i, surface);

		const auto currentDelay = i % longFrameFrequency ? shortFrameDuration : longFrameDuration;
		builder.addFrame(surface, currentDelay);
	}
	return true;
}
