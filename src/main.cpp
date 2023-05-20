#include <array>
#include <iostream>
#include <filesystem>
#include <fstream>
#include <string>
#include <filesystem>
#include <argparse/argparse.hpp>
#include <typeinfo>

#include "render.h"

void convert(
	const std::filesystem::path& file_path,
	const size_t width,
	const size_t height,
	const std::filesystem::path& output,
	double fps,
	const size_t threads_count
) {
	std::ifstream input_file(file_path);
	if (!input_file.is_open())
	{
		throw std::runtime_error("can not open lottie file");
	}
	const std::string lottie_data((std::istreambuf_iterator<char>(input_file)), std::istreambuf_iterator<char>());
	input_file.close();
	render(
		lottie_data,
		width,
		height,
		output,
		fps,
		threads_count
	);
}

int main(int argc, const char** argv) {
	argparse::ArgumentParser program("lottie_to_png");

	program.add_argument("path")
		.required()
		.help("path to lottie animation file")
		.action([](const std::string& value) { return std::filesystem::path(value); });

	program.add_argument("-o", "--output")
		.default_value(std::string(""))
		.help("path to output directory")
		.action([](const std::string& value) { return std::filesystem::path(value); });

	program.add_argument("-w", "--width")
		.default_value(512)
		.help("output image width")
		.action([](const std::string& value) { return std::stoi(value); });

	program.add_argument("-h", "--height")
		.default_value(512)
		.help("output image height")
		.action([](const std::string& value) { return std::stoi(value); });

	program.add_argument("-f", "--fps")
		.default_value(0.0)
		.help("output animation FPS. If 0 use FPS from source animation")
		.action([](const std::string& value) { return std::stod(value); });

	program.add_argument("-t", "--threads")
		.default_value(0)
		.help("numbers of threads to use. If 0, number of CPUs is used")
		.action([](const std::string& value) { return std::stoi(value); });

	try {
		program.parse_args(argc, argv);
	} catch (const std::runtime_error& err) {
		std::cout << err.what() << std::endl;
		std::cout << program;
		return -2;
	}

	const auto file_path = program.get<std::filesystem::path>("path");
	const auto width = program.get<int>("--width");
	const auto height = program.get<int>("--height");
	const auto fps = program.get<double>("--fps");
	const auto output = program.get<std::filesystem::path>("--output");
	const auto threads = program.get<int>("--threads");

	convert(file_path, width, height, output, fps, threads);
	return 0;
}
