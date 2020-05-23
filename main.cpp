#include <array>
#include <iostream>
#include <string>

#include <argparse/argparse.hpp>

#include "zstr/zstr.h"
#include "gif/render.h"


std::string decompress(std::istream& inputFile) {
	zstr::istream zs(inputFile);
	return std::string(std::istreambuf_iterator<char>(zs), std::istreambuf_iterator<char>());
}

int main(int argc, const char** argv) {
	argparse::ArgumentParser program("tgs-to-gif");

	program.add_argument("path")
		.required()
		.help("path to telegram sticker file");

	program.add_argument("-o", "--output")
		.default_value(std::string(""))
		.help("path to output GIF file");

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

	program.add_argument("-a", "--alpha-threshold")
		.default_value(1)
		.help("alpha threshold")
		.action([](const std::string& value) { return std::stoi(value); });

	try {
		program.parse_args(argc, argv);
	} catch (const std::runtime_error& err) {
		std::cout << err.what() << std::endl;
		std::cout << program;
		return -2;
	}

	const auto filePath = program.get<std::string>("path");
	const auto width = program.get<int>("--width");
	const auto height = program.get<int>("--height");
	const auto fps = program.get<double>("--fps");
	const auto alphaThreshold = program.get<int>("--alpha-threshold");
	auto output = program.get<std::string>("--output");

	std::ifstream inputFile(filePath);
	if (!inputFile.is_open()) {
		std::cerr << "Can not open file " << filePath << '.' << std::endl;
		return -1;
	}

	const std::string decompressed = decompress(inputFile);
	inputFile.close();

	if (!output.length()) {
		output = filePath + ".gif";
	}

	return !render(decompressed, width, height, alphaThreshold, output, fps);
}
