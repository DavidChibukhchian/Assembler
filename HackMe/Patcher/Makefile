SFML_LIBS = -L C:\DOS\DOSBox\PROGRAMS\HackMe\Patcher\include\SFML\lib -lsfml-graphics-s -lsfml-window-s -lsfml-system-s -lopengl32 -lfreetype -lwinmm -lgdi32 -lsfml-main -mwindows
SFML_INCLUDE = -I C:\DOS\DOSBox\PROGRAMS\HackMe\Patcher\include\SFML\include

Patcher : build\main.o build\patcher.o build\graphics.o
	g++ $(SFML_LIBS) build\main.o build\patcher.o build\graphics.o -o Patcher.exe -lsfml-graphics-s -lsfml-window-s -lsfml-system-s -lopengl32 -lfreetype -lwinmm -lgdi32 -lsfml-main -mwindows

build\main.o : source\main.cpp
	g++ $(SFML_INCLUDE) -c source\main.cpp -o build\main.o -D SFML_STATIC

build\patcher.o : source\patcher.cpp
	g++ -c source\patcher.cpp -o build\patcher.o

build\graphics.o : source\graphics.cpp
	g++ $(SFML_INCLUDE) -c source\graphics.cpp -o build\graphics.o -D SFML_STATIC

.PHONY : clean

clean : 
	if exist Patcher.exe del Patcher.exe
	del /q .\build