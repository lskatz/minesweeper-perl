# minesweeper-perl
Making a minesweeper game in perl

# Usage

    minesweeper.pl: play minesweeper
      Usage: minesweeper.pl [options]
      --cheat  Tell me where the mines are
      --cols   10
      --rows   10
      --mines  10
      --help   This useful help menu

# This game is not finished

Still need to add flags and still need to make a "win" scenario

# Example

    $ perlcripts/minesweeper.pl --cheat --cols 5 --rows 5 --mines 5
    minesweeper.pl: Mines at 0,3 1,2 1,3 2,4 4,3
    .       A       B       C       D       E
    1       -       -       -       _       -
    2       -       -       _       _       -
    3       -       -       -       -       _
    4       -       -       -       -       -
    5       -       -       -       _       -

    Format in [CF]rowcol where C or F stands for Click or Flag, and rowcol is a coordinate.
    For example, 'C1A' clicks row 1, column A'
    Choice? C1A
    .       A       B       C       D       E
    1       0       -       -       _       -
    2       0       -       _       _       -
    3       0       -       -       -       _
    4       0       0       -       -       -
    5       0       0       -       _       -

    Format in [CF]rowcol where C or F stands for Click or Flag, and rowcol is a coordinate.
    For example, 'C1A' clicks row 1, column A'
    Choice? C3C
    .       A       B       C       D       E
    1       0       -       -       _       -
    2       0       -       _       _       -
    3       0       -       2       -       _
    4       0       0       -       -       -
    5       0       0       -       _       -

    Format in [CF]rowcol where C or F stands for Click or Flag, and rowcol is a coordinate.
    For example, 'C1A' clicks row 1, column A'
    Choice? C2C
    .       A       B       C       D       E
    1       0       -       -       _       -
    2       0       -       X       _       -
    3       0       -       2       -       _
    4       0       0       -       -       -
    5       0       0       -       _       -
    minesweeper.pl: You lost!
    scripts/minesweeper.pl --cheat --cols 5 --rows 5 --mines 5
