#!/usr/local/bin/perl

# Get filename containing IEDB data from the user
print "\nType the directory containing the IEDB data: "; 
$dir = <STDIN>; chomp ($dir);								# input dir

# Validate if the directory exist     
if (-d $dir) {	my @iedb_dir;											# check if the directory exists
 opendir(IEDB_DIR, $dir);{ @iedb_dir = readdir(IEDB_DIR); } 
 closedir (IEDB_DIR);		# open directory of files containing iedbs

  foreach my $file (@iedb_dir){
  open (INFILE, "$dir/$file"); { @iedb_file = <INFILE>; } close (INFILE);
	foreach $line (@iedb_file){ 
	  if ($line =~ m/No PDB hit/) {	$hit = 0; $comment = "NO_PDB_HIT"; 
		unlink "$dir/$file" or warn "Could not unlink $file: $!"; } 
	  elsif ($line =~ m/Epitope not found/) { $hit = 0; $comment = "EPITOPE_NOT_FOUND"; 
		unlink "$dir/$file" or warn "Could not unlink $file: $!"; }
	  elsif ($line =~ m/No source sequence/) { $hit = 0; $comment = "NO_SRC_SEQ"; 
		unlink "$dir/$file" or warn "Could not unlink $file: $!"; } 
	  elsif ($line =~ m/epitope sequence can not be mapped/) { $hit = 0; $comment = "SEQ_CANT_BE_MAPPED"; 
		unlink "$dir/$file" or warn "Could not unlink $file: $!"; } 
	  else {$hit = 1;}
	  
	  if ($hit == 0){	
		open (OUT, ">$dir/$comment/$file"); { print OUT @iedb_file; } close (OUT);
	  }
	}
  }
} else { print "\nDirectory does not exist!\n"; }