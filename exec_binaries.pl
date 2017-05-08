#!/usr/local/bin/perl

use strict;

my $DSSP = "dssp-2.0.4-win32.exe";							# name of the executable file/ binary
my $dir = "1K19/"; 
my $input = "1K19_1.pdb"; 
my $filein = $dir.$input;
my $out = "1K19_1.txt";
my @output=();
if( -f $DSSP ){											# check if file exists
  print "\nInput: $input\n\n";
  @output = qx/"$DSSP  -i $filein"/ or die $?;			# run executable by the system with defined input and output to an array
  #system ("$DSSP  -i $filein -o $out") or die $?;		# run executable by the system with defined input and output to a file ($out)
}

  my $output_len = @output;
  print "";
  for (my $line_len = 28; $line_len < $output_len; $line_len++) { 	# Get phi and psi values
	my $line = $output[$line_len];
	  print my $pos = substr($line,7,3), " "; 				# Get position at column 13, max of 3 characters
	  print my $chain = substr($line,11,1), " "; 			# Get chain type at column 1, max of 1 character
	  print my $res = substr($line,13,1), " "; 			# Get residue name at column 7, max of 3 characters
	  #$pos_res_ch = $pos.$res.$chain;					# concatenate strings into one
	  print  my $phi = substr($line,103,6), " "; 			# Get phi value at column 22, max of 6 characters
	  print  my $psi = substr($line,109,6), "\n"; 			# Get psi value at column 29, max of 6 characters
	 #push(@{$hash{$key}}, $insert_val);				Insert an element to an array 
 }