#ifndef _GRAPHICS_H
#define _GRAPHICS_H


//-----------------------------------------------------------------------------------------------------------


#define HEIGHT_OF_WINDOW 400
#define WIDTH_OF_WINDOW  600
#define NUMBER_OF_MENU_BUTTONS 3


//-----------------------------------------------------------------------------------------------------------


#include <SFML/Graphics.hpp>
#include <stdio.h>
#include <time.h>
#include "patcher.h"


//-----------------------------------------------------------------------------------------------------------


void init_text(sf::Text* text, sf::Font* font, const char* str, size_t size, sf::Color color);

void init_menu_buttons(sf::Text* menu_button, sf::Font* font);

void change_color_of_menu_buttons(sf::Text* menu_button, size_t selected_button);

void patch_program(sf::RenderWindow* window, sf::Texture* texture, sf::Sprite* sprite, sf::Text* title, sf::Font* font);


//-----------------------------------------------------------------------------------------------------------


#endif // _GRAPHICS_H
