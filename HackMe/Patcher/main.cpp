#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include "graphics.h"

using namespace sf;

int main()
{
  sf::Music music;
  music.openFromFile("music/bitmusic.wav");
  music.play();

  sf::Font font;
  font.loadFromFile("fonts/font.otf");

	Texture main_texture;
	main_texture.loadFromFile("images/main_background.jpg");

	Texture patching_texture;
	patching_texture.loadFromFile("images/patching_background.jpg");

	Texture about_texture;
	about_texture.loadFromFile("images/about_background.jpg");

	Sprite sprite;
	sprite.setTexture(main_texture);


	RenderWindow window(sf::VideoMode(WIDTH_OF_WINDOW, HEIGHT_OF_WINDOW), "HackMe Patcher");
	window.setMouseCursorVisible(false);


	sf::Text title;
	init_text(&title, &font, "HACKME PATCHER", 75, sf::Color(237, 147, 0));
	title.setPosition(WIDTH_OF_WINDOW / 2 - title.getGlobalBounds().width / 2, 10);

	sf::Text menu_button[NUMBER_OF_MENU_BUTTONS];
  init_menu_buttons(menu_button, &font);

  sf::Text about_text;
  init_text(&about_text, &font, "This program was \ncreated to hack\nVladimir's \nhackme program", 40, sf::Color(237, 147, 0));
  about_text.setPosition(30, 130);


  size_t selected_button = 0;
  bool main_page  = true;
  bool about_page = false;


	while (window.isOpen())
	{
		sf::Event event;

		while (window.pollEvent(event))
		{
            if (event.type == sf::Event::KeyReleased)
            {
                if (main_page)
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


                    if ((main_page) && (event.key.code == Keyboard::Return))
                    {
                        switch(selected_button)
                        {
                            case 0:
                                patch_program(&window, &patching_texture, &sprite, &title, &font);
                                window.close();
                                break;

                            case 1:
                                sprite.setTexture(about_texture);
                                main_page  = false;
                                about_page = true;
                                break;

                            case 2:
                                window.close();
                                break;
                        }
                    }
                }

                if ((!main_page) && (event.key.code == Keyboard::Escape))
                {
                    sprite.setTexture(main_texture);
                    main_page  = true;
                    about_page = false;
                }
            }
		}

		window.clear();
		window.draw(sprite);

		if (main_page)
		{
            for (size_t i = 0; i < NUMBER_OF_MENU_BUTTONS; i++)
            window.draw(menu_button[i]);
		}
		if (about_page)
		{
            window.draw(about_text);
		}

    window.draw(title);
		window.display();
	}

	return 0;
}
