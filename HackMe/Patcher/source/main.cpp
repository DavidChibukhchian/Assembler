#include <SFML/Graphics.hpp>
#include "graphics.h"

using namespace sf;

int main()
{
	int err = 0;

	Attributes_struct attributes = {};

	err = load_attributes(&attributes);
	if (err)
		return err;

	Sprite sprite;
	sprite.setTexture(attributes.main_texture);

	RenderWindow window(sf::VideoMode(WIDTH_OF_WINDOW, HEIGHT_OF_WINDOW), "HackMe Patcher");
	window.setMouseCursorVisible(false);

	sf::Text title;
	init_text(&title, &attributes.main_font, "HACKME PATCHER", 75, sf::Color(237, 147, 0));
	title.setPosition(WIDTH_OF_WINDOW / 2 - title.getGlobalBounds().width / 2, 10);

	sf::Text menu_button[NUMBER_OF_MENU_BUTTONS];
	init_menu_buttons(menu_button, &attributes.main_font);

	sf::Text about_text;
	init_text(&about_text, &attributes.main_font, "This program was \ncreated to hack\nVladimir's \nhackme program", 40, sf::Color(237, 147, 0));
	about_text.setPosition(30, 130);


	size_t selected_button = 0;
	bool main_page_is_open  = true;
	bool about_page_is_open = false;


	while (window.isOpen())
	{
		sf::Event event;

		while (window.pollEvent(event))
		{
			if (event.type == sf::Event::KeyReleased)
			{
				if (main_page_is_open)
				{
					if (event.key.code == Keyboard::Up)
					{
						if (selected_button > 0)
						{
							selected_button--;
							change_color_of_menu_buttons(menu_button, selected_button);
						}
					}


					if (event.key.code == Keyboard::Down)
					{
						if (selected_button < NUMBER_OF_MENU_BUTTONS - 1)
						{
							selected_button++;
							change_color_of_menu_buttons(menu_button, selected_button);
						}
					}


					if ((main_page_is_open) && (event.key.code == Keyboard::Return))
					{
						switch(selected_button)
						{
							case START:
								patch_program(&window, &attributes.patching_texture, &sprite, &title, &attributes.main_font);
								window.close();
								break;

							case ABOUT:
								sprite.setTexture(attributes.about_texture);
								main_page_is_open  = false;
								about_page_is_open = true;
								break;

							case EXIT:
								window.close();
								break;
						}
					}
				}

				if ((!main_page_is_open) && (event.key.code == Keyboard::Escape))
				{
					sprite.setTexture(attributes.main_texture);
					main_page_is_open  = true;
					about_page_is_open = false;
					about_page_is_open = false;
				}
			}
		}

		window.clear();
		window.draw(sprite);

		if (main_page_is_open)
		{
			for (size_t i = 0; i < NUMBER_OF_MENU_BUTTONS; i++)
				window.draw(menu_button[i]);
		}
		if (about_page_is_open)
			window.draw(about_text);

		window.draw(title);
		window.display();
	}

	return 0;
}