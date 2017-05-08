#!/usr/local/bin/perl

# Get list of pdb files from the user
print "\nType the filename of the IEDB data: "; 
$iedb_data = <STDIN>; chomp ($iedb_data);								# input pdb list

# Validate if the list and directory exist     
if (-e $iedb_data) {													# check if the list exists
  print "\nWhere do you want to save the IEDB files: "; 				# ask the user where to save the files
  $iedb_dir = <STDIN>; chomp ($iedb_dir);
	if (-e $iedb_dir) {
	  print "\n$iedb_dir directory already exists."; 
	  &get_iedb($iedb_data,$iedb_dir); } 								# pass list and directory name to subroutine
	else { mkdir $iedb_dir;											# create directory if it does not exist
	  print "\n$iedb_dir directory created."; &get_iedb($iedb_data,$iedb_dir); } 
} else { print "\nFile doesn't exist!\n"; }

sub get_iedb {my $input = $_[0]; my $dir = $_[1]; my @iedb_input;
  use LWP::Simple;													# Required module for getting contents of a webpage
    
  open (IEDB, "$input"); { @iedb_input = <IEDB>; } 				# open the file containing the list of pdb files
  close (IEDB);
  #my $web = "http://tools.immuneepitope.org/esm/getMapping.do?epitope_id=$epitope[0]&source_id=genbank-$epitope[5]";
  my $file_ctr = 0; my $avail_file_ctr = 0; my $not_avail = 0;
  
 foreach my $iedb_file (@iedb_input) { 
	
	@epitope = split /,/,$iedb_file;		
	  print "\nSaving $epitope[0]_$epitope[5] to $dir directory . . . "; 	# epitope id and source accession 
	  if (is_success(getstore("http://tools.immuneepitope.org/esm/getMapping.do?epitope_id=$epitope[0]&source_id=genbank-$epitope[5]","$dir/$epitope[0]_$epitope[5].html"))){ # check if file is available, if yes save it to $dir
		print "done.";
	  }
	  else { print "failed. File not available."; }
	} 
}