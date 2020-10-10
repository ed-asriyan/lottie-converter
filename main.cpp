#include <array>
#include <iostream>
#include <string>
#include <filesystem>
#include <argparse/argparse.hpp>
#include <typeinfo>

#include "zstr/zstr.h"
#include "gif/render.h"

namespace fs = std::filesystem;

std::string decompress(std::istream& inputFile) {
	zstr::istream zs(inputFile);
	return std::string(std::istreambuf_iterator<char>(zs), std::istreambuf_iterator<char>());
}

bool convert(std::string filePath, auto width, auto height, auto alphaThreshold, auto output, auto fps) {
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
	return render(decompressed, width, height, alphaThreshold, output, fps);
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
	const fs::path path(filePath);

	std::error_code ec;

	if (fs::is_directory(path, ec)) {
		int total = 0;
		for (auto& p: fs::recursive_directory_iterator(filePath))
			if (p.path().extension() == ".tgs") {
				total += (int) convert(std::string(p.path()), width, height, alphaThreshold, output, fps);
			}
		if (total == 0) {
			std::cerr << "No .tgs files found" << std::endl;
		} else if (total == 1) {
			std::cout << "Total 1 file was converted" << std::endl;
		} else {
			std::cout << "Total " << total << " files were converted" << std::endl;
		}
		return total > 0 ? 0 : 1;
	} else if (ec) {
		std::cerr << "Error while checking weather " << path << "is a directory: " << ec.message();
		return 1;
	} else if (fs::is_regular_file(path, ec)) {
		return convert(filePath, width, height, alphaThreshold, output, fps);
	} else if (ec) {
		std::cerr << "Error while checking weather " << path << "is a regular file: " << ec.message();
		return 1;
	}

}

