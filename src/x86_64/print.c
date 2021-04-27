#include "print.h"
#include <stdbool.h>

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

void printLine ()
{
  column = 0;

  if (row < ROWS - 1)
  {
    row++;
    return;
  }

  for (size_t r = 1; r < ROWS; r++)
  {
    for (size_t c = 0; c < COLUMNS; c++)
    {
      struct Char character = buffer[c + COLUMNS * r];
      buffer[c + COLUMNS * (r - 1)] = character;
    }
  }

  clearRow(COLUMNS - 1);
}

void printChar (char character)
{
  if (character == '\n')
  {
    return printLine();
  }

  if (column >= COLUMNS)
  {
    printLine();
  }

  buffer[column + COLUMNS * row] = (struct Char)
  {
    character: (uint8_t) character,
    color: color
  };

  column++;
}

void printString (char* string)
{
  for (size_t s = 0; true; s++)
  {
    char character = (uint8_t) string[s];

    if (character == '\0')
    {
      return;
    }

    printChar(character);
  }
}

void slice (const char* string, char* buffer, size_t start, size_t end)
{
  size_t e = 0;

  for (size_t s = start; s <= end; s++)
  {
    buffer[e++] = string[s];
  }

  buffer[e] = 0;
}

void centerString (char* string)
{
  size_t lines[ROWS];
  size_t length = 0;
  size_t rows = 1;

  while (*string)
  {
    if (*string == '\n' || *string == '\0')
    {
      rows++;
    }

    *string++;
    length++;
  }

  string -= length;

  for (size_t r = 0; r < rows; r++)
  {
    size_t characters = 0;

    while (*string)
    {
      if (*string++ != '\n')
      {
        characters++;
      }
      else
      {
        break;
      }
    }

    lines[r] = characters;
  }

  row = (ROWS - rows) / 2;
  string -= length;
  size_t start = 0;

  if (rows == 1)
  {
    row -= length / COLUMNS;
  }

  for (size_t r = 0; r < rows; r++)
  {
    size_t endLine = lines[r];
    column = (80 - endLine) / 2;
    char lineBuffer[endLine + 1];

    slice(string, lineBuffer, start, start + endLine);
    printString(lineBuffer);
    start += endLine + 1;
  }
}

void setColor (uint8_t background, uint8_t foreground)
{
  color = foreground + (background << 4);
}
