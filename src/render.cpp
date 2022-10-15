#include "render.h"

#define lp_COLOR_DEPTH 8
#define lp_COLOR_BYTES 4

void write_png(
	unsigned char* buffer,
	const size_t width,
	const size_t height,
	const std::filesystem::path& out_file_path
) {
	png_structp png_ptr = nullptr;
	png_infop info_ptr = nullptr;
	unsigned char** row_pointers;

	png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
	if (png_ptr == nullptr) {
		throw std::runtime_error("PNG export failed: unable to create structure");
	}

	info_ptr = png_create_info_struct(png_ptr);
	if (info_ptr == nullptr) {
		png_destroy_write_struct(&png_ptr, &info_ptr);
		throw std::runtime_error("PNG export failed: unable to create info data");
	}

	if (setjmp(png_jmpbuf(png_ptr))) {
		png_destroy_write_struct(&png_ptr, &info_ptr);
		throw std::runtime_error("PNG export failed: longjump error");
	}

	png_set_IHDR(
		png_ptr,
		info_ptr,
		width,
		height,
		lp_COLOR_DEPTH,
		PNG_COLOR_TYPE_RGB_ALPHA,
		PNG_INTERLACE_NONE,
		PNG_COMPRESSION_TYPE_DEFAULT,
		PNG_FILTER_TYPE_DEFAULT
	);

	row_pointers = (unsigned char**)png_malloc(png_ptr, height * sizeof(png_byte*));
	if (row_pointers == nullptr) {
		png_destroy_write_struct(&png_ptr, &info_ptr);
		throw std::runtime_error("PNG export failed");
	}
	for (unsigned int y = 0; y < height; ++y) {
		unsigned char* row = (unsigned char*)png_malloc(png_ptr, sizeof(unsigned char) * width * lp_COLOR_BYTES);
		if (row == nullptr) {
			for (unsigned int yy = 0; yy < y; ++yy) {
				png_free(png_ptr, row_pointers[yy]);
			}
			png_free(png_ptr, row_pointers);
			png_destroy_write_struct(&png_ptr, &info_ptr);
			throw std::runtime_error("PNG export failed");
		}
		row_pointers[y] = row;
		for (unsigned int x = 0; x < width; ++x) {
			unsigned char b, g, r;
			b = *buffer++;
			g = *buffer++;
			r = *buffer++;
			*row++ = r;
			*row++ = g;
			*row++ = b;
			*row++ = *buffer++;
		}
	}
	png_set_rows(png_ptr, info_ptr, row_pointers);

	FILE* out_file = fopen(out_file_path.c_str(), "wb");

	png_init_io(png_ptr, out_file);

	png_write_png(png_ptr, info_ptr, PNG_TRANSFORM_IDENTITY, nullptr);

	for (unsigned int y = 0; y < height; ++y) {
		png_free(png_ptr, row_pointers[y]);
	}
	png_free(png_ptr, row_pointers);
	png_destroy_write_struct(&png_ptr, &info_ptr);

	fclose(out_file);
}

void render(
	const std::string& lottie_data,
	const size_t width,
	const size_t height,
	const std::filesystem::path& output_directory,
	double fps,
	size_t threads_count
) {
	static unsigned int cache_counter = 0; // rlottie uses caches for internal optimizations
	const auto cache_counter_str = std::to_string(++cache_counter);
	auto player = rlottie::Animation::loadFromData(lottie_data, cache_counter_str);
	if (!player) throw std::runtime_error("can not load lottie animation");

	const size_t player_frame_count = player->totalFrame();
	const double player_fps = player->frameRate();
	if (fps == 0.0) fps = player_fps;
	const double duration = player_frame_count / (double)player_fps;
	const double step = player_fps / fps;
	const double output_frame_count = fps * duration;

	if (threads_count == 0) {
		threads_count = std::thread::hardware_concurrency();
	}
	auto threads = std::vector<std::thread>(threads_count);
	for (int i = 0; i < threads_count; ++i) {
		threads.push_back(std::thread([i, output_frame_count, step, width, height, threads_count, &output_directory, &lottie_data, cache_counter_str]() {
			auto local_player = rlottie::Animation::loadFromData(lottie_data, cache_counter_str);
			char file_name[8];
			uint32_t* const buffer = new uint32_t[width * height];
			for (size_t j = i; j < output_frame_count; j += threads_count) {
				rlottie::Surface surface(buffer, width, height, width * lp_COLOR_BYTES);
				local_player->renderSync(round(j * step), surface);

				sprintf(file_name, "%03zu.png", j);
				write_png(
					(unsigned char *)buffer,
					width,
					height,
					output_directory / std::filesystem::path(file_name)
				);
			}
			delete[] buffer;
		}));
	}

	for (auto& thread : threads) {
		if (thread.joinable()) {
			thread.join();
		}
	}
}
