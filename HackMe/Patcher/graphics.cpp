#include "graphics.h"

sf::Color color_of_text = sf::Color(237, 147, 0);

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


void change_color_of_menu_buttons(sf::Text* menu_button, size_t selected_button)
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


void patch_program(sf::RenderWindow* window, sf::Texture* texture, sf::Sprite* sprite, sf::Text* title, sf::Font* font)
{
    sprite->setTexture(*texture);
    window->clear();
    window->draw(*sprite);
    window->draw(*title);
    window->display();

    pause(2);

    sf::Text patching_text;
    init_text(&patching_text, font, "Patching...", 60, color_of_text);
    patching_text.setPosition(WIDTH_OF_WINDOW / 2 - patching_text.getGlobalBounds().width / 2, 150);

    window->clear();
    window->draw(*sprite);
    window->draw(*title);
    window->draw(patching_text);
    window->display();

    patch_program();

    pause(4);

    sf::Text result_text;
    init_text(&result_text, font, "Well Done", 60, color_of_text);
    result_text.setPosition(WIDTH_OF_WINDOW / 2 - result_text.getGlobalBounds().width / 2, 150);

    window->clear();
    window->draw(*sprite);
    window->draw(*title);
    window->draw(result_text);
    window->display();

    pause(3);
}


//-----------------------------------------------------------------------------------------------------------
