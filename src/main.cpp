#include <array>
#include <iostream>
#include <filesystem>
#include <string>
#include <filesystem>
#include <argparse/argparse.hpp>
#include <typeinfo>

#include "zstr/zstr.h"
#include "render.h"

std::string decompress(std::istream& inputFile) {
	zstr::istream zs(inputFile);
	return std::string(std::istreambuf_iterator<char>(zs), std::istreambuf_iterator<char>());
}

void convert(
	const std::filesystem::path& file_path,
	const size_t width,
	const size_t height,
	const std::filesystem::path& output,
	double fps,
	const size_t threads_count
) {
	std::ifstream input_file(file_path);
	if (!input_file.is_open()) {
		throw std::runtime_error("can not open .tgs file");
	}
	const std::string decompressed = decompress(input_file);
	input_file.close();
	render(decompressed, width, height, output, fps, threads_count);
}

int main(int argc, const char** argv) {
	argparse::ArgumentParser program("tgs_to_png");

	program.add_argument("path")
		.required()
		.help("path to telegram sticker file")
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
		.help("output animation FPS. If 0 use FPS from tgs animation")
		.action([](const std::string& value) { return std::stod(value); });

	program.add_argument("-t", "--threads")
		.default_value(0)
		.help("numbers of threads to use. If 0, number of CPUs is used")
		.action([](const std::string& value) { return std::stoul(value); });

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
	const auto threads = program.get<size_t>("--threads");

	convert(file_path, width, height, output, fps, threads);
	return 0;
}

