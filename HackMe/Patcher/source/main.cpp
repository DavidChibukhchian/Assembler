#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include "graphics.h"

using namespace sf;

int main()
{
    sf::Music music;
    if (!music.openFromFile("music/bitmusic.wav"))
        return Failed_To_Load_Music;
    music.play();

    sf::Font font;
    if (!font.loadFromFile("fonts/font.otf"))
        return Failed_To_Load_Font;

    Texture main_texture;
    if (!main_texture.loadFromFile("images/main_background.jpg"))
        return Failed_To_Load_Main_Texture;

    Texture patching_texture;
    if (!patching_texture.loadFromFile("images/patching_background.jpg"))
        return Failed_To_Load_Patching_Texture;

    Texture about_texture;
    if (!about_texture.loadFromFile("images/about_background.jpg"))
        return Failed_To_Load_About_Texture;


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
                                patch_program(&window, &patching_texture, &sprite, &title, &font);
                                window.close();
                                break;

                            case ABOUT:
                                sprite.setTexture(about_texture);
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
                    sprite.setTexture(main_texture);
                    main_page_is_open  = true;
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
