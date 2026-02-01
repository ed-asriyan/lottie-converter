#include <array>
#include <iostream>
#include <filesystem>
#include <fstream>
#include <string>
#include <filesystem>
#include <argparse/argparse.hpp>
#include <typeinfo>
#include <regex>
#include <sstream>

#include "render.h"

std::optional<BackgroundColor> parse_background_color(const std::string& color_str) {
	if (color_str.empty()) {
		return std::nullopt;
	}
	
	// Remove spaces
	std::string cleaned = color_str;
	cleaned.erase(std::remove_if(cleaned.begin(), cleaned.end(), ::isspace), cleaned.end());
	
	// Support formats: rgb(r,g,b), rgba(r,g,b,a), #RRGGBB, #RRGGBBAA
	std::smatch matches;
	
	// Try rgba(r,g,b,a) format
	std::regex rgba_regex(R"(rgba?\((\d+),(\d+),(\d+)(?:,(\d+))?\))");
	if (std::regex_match(cleaned, matches, rgba_regex)) {
		int r = std::stoi(matches[1].str());
		int g = std::stoi(matches[2].str());
		int b = std::stoi(matches[3].str());
		int a = matches[4].matched ? std::stoi(matches[4].str()) : 255;
		
		// Validate ranges (regex only matches positive digits but allows values > 255)
		if (r > 255 || g > 255 || b > 255 || a > 255) {
			throw std::runtime_error("RGB and alpha values must be in range 0-255");
		}
		
		BackgroundColor color;
		color.r = static_cast<unsigned char>(r);
		color.g = static_cast<unsigned char>(g);
		color.b = static_cast<unsigned char>(b);
		color.a = static_cast<unsigned char>(a);
		return color;
	}
	
	// Try hex format #RRGGBB or #RRGGBBAA
	std::regex hex_regex(R"(#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8}))");
	if (std::regex_match(cleaned, matches, hex_regex)) {
		std::string hex = matches[1].str();
		BackgroundColor color;
		color.r = std::stoi(hex.substr(0, 2), nullptr, 16);
		color.g = std::stoi(hex.substr(2, 2), nullptr, 16);
		color.b = std::stoi(hex.substr(4, 2), nullptr, 16);
		color.a = hex.length() == 8 ? std::stoi(hex.substr(6, 2), nullptr, 16) : 255;
		return color;
	}
	
	throw std::runtime_error("Invalid background color format. Use rgb(r,g,b), rgba(r,g,b,a), #RRGGBB, or #RRGGBBAA");
}

void convert(
	const std::filesystem::path& file_path,
	const size_t width,
	const size_t height,
	const std::filesystem::path& output,
	double fps,
	const size_t threads_count,
	const std::optional<BackgroundColor>& background
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
		threads_count,
		background
	);
}

int main(int argc, const char** argv) {
	argparse::ArgumentParser program("lottie_to_png", "<local-build>");

	program.add_description(
		"Lottie animations (.json) to frames as .png files converter.\n"
		"This executable is one of components of lottie-converter project and isn't supposed to be used directly."
	);

	program.add_epilog(
		"It's open-source project: https://github.com/ed-asriyan/lottie-converter\n"
		"Author: Ed Asriyan <contact.lottie-converter@asriyan.me>"
	);

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

	program.add_argument("-b", "--background")
		.default_value(std::string(""))
		.help("background color to replace transparent pixels. Formats: rgb(r,g,b), rgba(r,g,b,a), #RRGGBB, #RRGGBBAA");

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
	const auto background_str = program.get<std::string>("--background");
	const auto background = parse_background_color(background_str);

	convert(file_path, width, height, output, fps, threads, background);
	return 0;
}
