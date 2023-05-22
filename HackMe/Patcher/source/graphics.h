#ifndef _GRAPHICS_H
#define _GRAPHICS_H

//-----------------------------------------------------------------------------------------------------------

#define HEIGHT_OF_WINDOW        400
#define WIDTH_OF_WINDOW         600
#define NUMBER_OF_MENU_BUTTONS  3
#define PAUSE_TIME              2

//-----------------------------------------------------------------------------------------------------------

#include <SFML/Graphics.hpp>
#include <stdio.h>
#include <time.h>
#include "patcher.h"

//-----------------------------------------------------------------------------------------------------------

struct Attributes
{
	sf::Font main_font;

	sf::Texture main_texture;
	sf::Texture patching_texture;
	sf::Texture about_texture;
};

//-----------------------------------------------------------------------------------------------------------

enum graphics_Errors
{
	Failed_To_Load_Music            = 1,
	Failed_To_Load_Font             = 2,
	Failed_To_Load_Main_Texture     = 3,
	Failed_To_Load_Patching_Texture = 4,
	Failed_To_Load_About_Texture    = 5
};

enum Menu_Buttons
{
	START = 0,
	ABOUT = 1,
	EXIT  = 2
};

//-----------------------------------------------------------------------------------------------------------

int load_attributes(Attributes* attributes);

void init_text(sf::Text* text, sf::Font* font, const char* str, size_t size, sf::Color color);

void init_menu_buttons(sf::Text* menu_button, sf::Font* font);

void handle_key_release(sf::RenderWindow* window, Attributes* attributes, sf::Sprite* sprite, sf::Text* title, sf::Event event,
                        sf::Text* menu_button, int* selected_button, int* main_page_is_open, int* about_page_is_open);

//-----------------------------------------------------------------------------------------------------------


#endif // _GRAPHICS_H