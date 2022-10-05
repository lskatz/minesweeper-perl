#!/usr/bin/env perl 

use warnings;
use strict;
use Data::Dumper;
use Getopt::Long;
use File::Basename qw/basename/;

use constant "PLAYING" => 1;
use constant "WIN"     => 2;
use constant "LOSE"    => 3;

use version 0.77;
our $VERSION = '0.1.1';

local $0 = basename $0;
sub logmsg{local $0=basename $0; print STDERR "$0: @_\n";}
exit(main());

sub main{
  my $settings={};
  GetOptions($settings,qw(help maxRows|rows=i maxCols|cols=i numMines|mines=i cheat)) or die $!;
  usage() if($$settings{help});

  $$settings{maxRows} ||= 10;
  $$settings{maxCols} ||= 10;
  $$settings{numMines}||= 10;

  minesweeper($settings);

  return 0;
}

sub minesweeper{
  my($settings) = @_;

  my $state=PLAYING;
  my $board = initializeBoard($settings);
  do {
    printBoard($board, $settings);
    my $choice = userChooses($board, $settings);
    while(!$$choice{action}){
      $choice = userChooses($board, $settings);
    }

    $state = markChoice($choice, $board, $settings);

  } while($state eq PLAYING);

  if($state eq LOSE){
    printBoard($board, $settings);
    logmsg "You lost!";
  }
}

sub markChoice{
  my($c, $board, $settings) = @_;

  my $col = ord($$c{col}) - ord("A");
  my $row = $$c{row} - 1;

  my $cell = $$board[$col][$row];

  # If clicking on cell
  my $state = PLAYING;
  if($$c{action} eq "C"){
    $state = clickCell($col, $row, $board, $settings);
  }
  elsif($$c{action} eq "F"){
    #flagCell($col, $row, $board, $settings);
    logmsg "TODO flagging";
  }
  else{
    logmsg "I do not understand action $$c{action}";
  }
  return $state;
}

# cell is a hash with keys flagged (bool), clicked (bool), mine (bool), viz (str)
sub clickCell{
  my($col, $row, $board, $settings) = @_;
  my $cell = $$board[$col][$row];

  # Ignore this click if it's already been clicked
  if($$cell{clicked}){
    #logmsg "Clicked a cell that has already been clicked";
    return PLAYING;
  }
  # Ignore this click if it's already been flagged
  if($$cell{flagged}){
    #logmsg "Clicked a cell that has a flag on it";
    return PLAYING;
  }

  # If you click a mine, then mark it visually, mark it clicked, and return LOSE
  if($$cell{mine}){
    $$cell{viz} = 'X';
    $$cell{clicked} = 1;
    return LOSE;
  }

  # Mark this cell as clicked right away to avoid deep recursion
  $$cell{clicked} = 1;
  $$cell{viz} = $$cell{neighbors};

  # Click all adjacent cells if they have a neighbor count of zero
  for my $i(-1, 0, 1){
    for my $j(-1, 0, 1){
      next if($i==0 && $j==0);

      my $c = $col+$i;
      my $r = $row+$j;
      next if($c > $$settings{maxCols} || $c < 0);
      next if($r > $$settings{maxRows} || $r < 0);

      my $neighbor = $$board[$c][$r];

      # Only click if the neighbor count of this neighbor is zero
      if(defined $neighbor && $$neighbor{neighbors} == 0 && $$neighbor{mine} < 1){
        clickCell($c, $r, $board, $settings);
      }
    }
  }


  return PLAYING;
}

sub userChooses{
  my($board, $settings) = @_;
  print "\n";
  print "Format in [CF]rowcol where C or F stands for Click or Flag, and rowcol is a coordinate.\n";
  print "For example, 'C1A' clicks row 1, column A'\n";
  print "Choice? ";
  my $choice = <STDIN>;
  chomp($choice);
  
  my($action, $row, $col) = ("", "", "");
  if($choice =~ /([CF])(\d+)([A-Z]+)/i){
    ($action, $row, $col) = ($1, $2, $3);
  }
  # If the regex didn't match, switch row and column in the regex and try that
  if(!$action){
    if($choice =~ /([CF])([A-Z]+)(\d+)/i){
      ($action, $row, $col) = ($1, $2, $3);
    }
  }


  return {action=>uc($action), row=>$row, col=>uc($col)};

}

sub initializeBoard{
  my($settings) = @_;

  my $numRows=$$settings{maxRows};
  my $numCols=$$settings{maxCols};
  my $numMines=$$settings{numMines};

  if($numMines > $numRows * $numCols){
    die "ERROR: number of mines is more than the number of cells";
  }

  my @board;
  # Make a blank board with no mines (yet)
  my $blankCell = {mine=>0, clicked=>0, flagged=>0, viz=>"-", neighbors=>0};
  for(my $i=0; $i<$numCols; $i++){
    for(my $j=0; $j<$numRows; $j++){
      $board[$i][$j] = { %$blankCell };
    }
  }

  # Add mines
  my %mineLoc;
  while(keys(%mineLoc) < $numMines){
    my $randRow = int(rand($numRows));
    my $randCol = int(rand($numCols));
    # Mark the mine in this cell
    $board[$randCol][$randRow]{mine}++;

    # Mark the mine in our list, just for this subroutine
    $mineLoc{"$randRow,$randCol"}++;

    # Tell all the neighbors that there is a mine here
    for my $c(-1, 0, 1){
      for my $r(-1, 0, 1){
        my $neighborCol = $randCol + $c;
        my $neighborRow = $randRow + $r;
        
        # Don't tell certain cells
        next if($neighborCol==$randCol && $neighborRow==$randRow);
        next if($neighborCol < 0);
        next if($neighborRow < 0);
        next if($neighborCol >= $$settings{maxCols});
        next if($neighborRow >= $$settings{maxRows});
        
        $board[$neighborCol][$neighborRow]{neighbors}++;
      }
    }

    # Change the cell visually if there is a mine here and if cheating
    if($$settings{cheat}){
      $board[$randCol][$randRow]{viz} = "_";
    }
  }

  # If cheating, simply list all the mine locations
  if($$settings{cheat}){
    my @mineLoc = sort {$a cmp $b} keys(%mineLoc);
    logmsg "Mines at @mineLoc";
  }

  return \@board;
}

sub printBoard{
  my($board, $settings) = @_;
  my $numRows=$$settings{maxRows};
  my $numCols=$$settings{maxCols};

  my $lastLetter = chr($$settings{maxCols} + ord("A") - 1);

  print join("\t", ".", ("A"..$lastLetter))."\n";
  for(my $j=0; $j<$numRows; $j++){
    my $rowStr = $j+1;
    for(my $i=0; $i<$numCols; $i++){
      $rowStr .= "\t";
      $rowStr .= $$board[$i][$j]{viz};
      if($$settings{cheat}){
        #$rowStr .= "(M:".$$board[$i][$j]{mine}.")";
      }
    }
    print $rowStr ."\n";
  }

}

sub usage{
  print "$0: play minesweeper
  Usage: $0 [options] 
  --cheat  Tell me where the mines are
  --cols   10
  --rows   10
  --mines  10
  --help   This useful help menu
  \n";
  exit 0;
}
