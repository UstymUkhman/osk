#include "print.h"

const static size_t COLUMNS = 80;
const static size_t ROWS    = 25;

struct Char
{
  uint8_t character;
  uint8_t color;
};

struct Char* buffer = (struct Char*) 0xb8000;
uint8_t color = WHITE | BLACK << 4;

size_t column = 0;
size_t row = 0;

void clearRow (size_t row)
{
  struct Char empty = (struct Char)
  {
    character: ' ',
    color: color
  };

  for (size_t c = 0; c < COLUMNS; c++)
  {
    buffer[c + COLUMNS * row] = empty;
  }
}

void clear ()
{
  for (size_t r = 0; r < ROWS; r++)
  {
    clearRow(r);
  }
}

void setColor (uint8_t foreground, uint8_t background)
{
  color = foreground + (background << 4);
}
