#!/usr/local/bin/perl

#################################################################################################################
# Description:  A perl script that automatically downloads pdb files from Protein Data Bank (rcsb.org)			#
# Input: 		A list of pdb files. One PDB ID per line														#
# Output:		Coordinate files in pdb format saved in a specified forlder with a list of downloaded files		#
# Author: 	    Isidro C. Medina Jr.																			#
# Date: 	    2013																							#
#################################################################################################################

# Get list of pdb files from the user
print "\nType the filename of the pdb list: "; 
$pdblist = <STDIN>; chomp ($pdblist);								# input pdb list

# Validate if the list and directory exist     
if (-e $pdblist) {													# check if the list exists
  print "\nWhere do you want to save the pdb files: "; 				# ask the user where to save the files
  $pdb_dir = <STDIN>; chomp ($pdb_dir);
	if (-e $pdb_dir) {
	  print "\n$pdb_dir directory already exists."; 
	  &get_pdb($pdblist,$pdb_dir); } 								# pass list and directory name to subroutine
	else { mkdir $pdb_dir;											# create directory if it does not exist
	  print "\n$pdb_dir directory created."; &get_pdb($pdblist,$pdb_dir); } 
} else { print "\nFile doesn't exist!\n"; }

sub get_pdb {my $input = $_[0]; my $dir = $_[1]; my @pdb_list;
  use LWP::Simple;													# Required module for getting contents of a webpage
    
  open (PDBLIST, "$input"); { @pdb_list = <PDBLIST>; } 				# open the file containing the list of pdb files
  close (PDBLIST);
  
  my $web = "http://rcsb.org/pdb/download/downloadFile.do?fileFormat=pdb&compression=NO&structureId=";
  my $file_ctr = 0; my $avail_file_ctr = 0; my $not_avail = 0;
  
 open (NEWLIST, ">$dir/new_pdb_list.txt");{  
  print NEWLIST "PDB files with thermodynamic/kinetic data.\n"; print "\n\nPDB files with thermodynamic/kinetic data.\n";
  foreach my $pdb_file (@pdb_list) { 
	if ($pdb_file ne "\n"){ chomp ($pdb_file); $file_ctr++;
	  print "\nSaving $pdb_file to $dir directory . . . "; 
	  #getstore("http://path.to.web/file.ext","/path/to/file.ext");	
	  if (is_success(getstore("$web"."$pdb_file","$dir/$pdb_file\.pdb"))){ # check if file is available, if yes save it to $dir
		print "done."; print NEWLIST "\n$pdb_file"; $avail_file_ctr++;
	  }
	  else { print "failed. File not available."; 
		print NEWLIST "\n$pdb_file - not available"; $not_avail++;
	  }
	} 
  } print NEWLIST "\n\nTotal: $file_ctr files"; print "\n\nTotal: $file_ctr coordinate files";
	print NEWLIST "\nDownloaded: $avail_file_ctr files"; print "\nDownloaded: $avail_file_ctr coordinate files";
	print NEWLIST "\nNot Available: $not_avail file(s)"; print "\nNot Available: $not_avail coordinate file(s)\n";
 } close (NEWLIST);
}