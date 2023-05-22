#include "graphics.h"

sf::Color color_of_text = sf::Color(237, 147, 0);

#define RESET_WINDOW               \
	window->clear();               \
	window->draw(*sprite);         \
	window->draw(*title);      

//-----------------------------------------------------------------------------------------------------------

static void pause(size_t pause_time)
{
	clock_t start = clock();
	double difference = 0;

	while (difference < pause_time)
	{
		difference = (double)(clock() - start) / CLOCKS_PER_SEC;
	}
}

//-----------------------------------------------------------------------------------------------------------

int load_attributes(Attributes* attributes)
{
	sf::Font font;
	if (!font.loadFromFile("fonts/font.otf"))
		return Failed_To_Load_Font;
	attributes->main_font = font;

	sf::Texture main_texture;
	if (!main_texture.loadFromFile("images/main_background.jpg"))
		return Failed_To_Load_Main_Texture;
	attributes->main_texture = main_texture;

	sf::Texture patching_texture;
	if (!patching_texture.loadFromFile("images/patching_background.jpg"))
		return Failed_To_Load_Patching_Texture;
	attributes->patching_texture = patching_texture;

	sf::Texture about_texture;
	if (!about_texture.loadFromFile("images/about_background.jpg"))
		return Failed_To_Load_About_Texture;
	attributes->about_texture = about_texture;

	return Done_Successfully;
}

//-----------------------------------------------------------------------------------------------------------

static void patch_program(sf::RenderWindow* window, sf::Texture* texture, sf::Sprite* sprite, sf::Text* title, sf::Font* font)
{
	sprite->setTexture(*texture);
	RESET_WINDOW;
	window->display();

	pause(PAUSE_TIME);

	sf::Text patching_text;
	init_text(&patching_text, font, "Patching...", 60, color_of_text);
	patching_text.setPosition(WIDTH_OF_WINDOW / 2 - patching_text.getGlobalBounds().width / 2, 150);

	RESET_WINDOW;
	window->draw(patching_text);
	window->display();

	int err = patch_hackme();
	//if (err) return;

	pause(2*PAUSE_TIME);

	sf::Text result_text;
	init_text(&result_text, font, "Well Done", 60, color_of_text);
	result_text.setPosition(WIDTH_OF_WINDOW / 2 - result_text.getGlobalBounds().width / 2, 150);

	RESET_WINDOW;
	window->draw(result_text);
	window->display();

	pause(PAUSE_TIME);
}

//-----------------------------------------------------------------------------------------------------------

static void another_function(sf::RenderWindow* window, sf::Sprite* sprite, Attributes* attributes, sf::Text* title, int selected_button, int* main_page_is_open, int* about_page_is_open)
{
	switch(selected_button)
	{
		case START:
			patch_program(window, &(attributes->patching_texture), sprite, title, &(attributes->main_font));
			window->close();
			break;

		case ABOUT:
			sprite->setTexture(attributes->about_texture);
			*main_page_is_open  = false;
			*about_page_is_open = true;
			break;

		case EXIT:
			window->close();
			break;
	}
}

//-----------------------------------------------------------------------------------------------------------

static void change_color_of_menu_buttons(sf::Text* menu_button, size_t selected_button)
{
	for (size_t i = 0; i < NUMBER_OF_MENU_BUTTONS; i++)
	{
		menu_button[i].setFillColor(color_of_text);
		menu_button[i].setOutlineThickness(2);
		menu_button[i].setOutlineColor(sf::Color::Black);
	}

	menu_button[selected_button].setFillColor(sf::Color::Green);
}

//-----------------------------------------------------------------------------------------------------------

void function(sf::RenderWindow* window, Attributes* attributes, sf::Sprite* sprite, sf::Text* title, sf::Event event,
              sf::Text* menu_button, int* selected_button, int* main_page_is_open, int* about_page_is_open)
{
	if (*main_page_is_open)
	{
		switch(event.key.code)
		{
			case sf::Keyboard::Up:
				if ((*selected_button) > 0)
				{
					(*selected_button)--;
					change_color_of_menu_buttons(menu_button, *selected_button);
				}
				break;
			
			case sf::Keyboard::Down:
				if ((*selected_button) < NUMBER_OF_MENU_BUTTONS - 1)
				{
					(*selected_button)++;
					change_color_of_menu_buttons(menu_button, *selected_button);
				}
				break;

			case sf::Keyboard::Return:
				another_function(window, sprite, attributes, title, *selected_button, main_page_is_open, about_page_is_open);
				break;
		}
	}

	if ((!(*main_page_is_open)) && (event.key.code == sf::Keyboard::Escape))
	{
		sprite->setTexture(attributes->main_texture);
		*main_page_is_open  = true;
		*about_page_is_open = false;
	}
}

//-----------------------------------------------------------------------------------------------------------

void init_text(sf::Text* text, sf::Font* font, const char* str, size_t size, sf::Color color)
{
	text->setFont(*font);
	text->setString(str);

	text->setCharacterSize(size);
	text->setFillColor(color);

	text->setOutlineThickness(2);
	text->setOutlineColor(sf::Color::Black);
}

//-----------------------------------------------------------------------------------------------------------

void init_menu_buttons(sf::Text* menu_button, sf::Font* font)
{
	const char* button[] = { "Start", "About", "Exit" };

	for (size_t i = 0; i < NUMBER_OF_MENU_BUTTONS; i++)
	{
		init_text(&menu_button[i], font, button[i], 60, color_of_text);
		menu_button[i].setPosition(WIDTH_OF_WINDOW / 2 - menu_button[i].getGlobalBounds().width / 2, 120 + 80*i);
	}

	menu_button[0].setFillColor(sf::Color::Green);
}

//-----------------------------------------------------------------------------------------------------------