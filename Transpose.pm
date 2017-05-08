#!/usr/local/bin/perl

package Transpose;

sub transpose {
 my @input = @_;										# get array from the main program

 # read input then split each comma delimited row into individual elements
 foreach my $row (@input) { chomp($row);				# remove newline at the end of each row
  my @elem = split (/,/, $row);							# split each comma delimited rows
  push @{$matrix}, \@elem;
 }

# transpose the matrix
 for (my $i = 0; $i < @$matrix; $i++) {
  for (my $j = 0; $j < @{$matrix->[$i]}; $j++) {
    $transposed->[$j][$i] = $matrix->[$i][$j];
  }
 }

# output transposed to tab delimited matrix
my @output = (); 
 for (my $i = 0; $i < @$transposed; $i++) {
 my $row = ();											# create blank string for each row
   for (my $j = 0; $j < @{$transposed->[$i]}; $j++) {
	$new_row = "\t$transposed->[$i][$j]";
	$row .= $new_row;
   } $\ = "\n"; $row = $row.$\; push (@output,$row); 	# insert newline at the end of each row
 }  return (@output);									# return transposed array to the main progam
} 1;