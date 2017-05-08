#!/usr/local/bin/perl

# Get filename containing IEDB data from the user
print "\nType the directory containing the IEDB data: "; 
$dir = <STDIN>; chomp ($dir);								# input dir

# Validate if the directory exist     
if (-d $dir) {	my @iedb_dir;											# check if the directory exists
 opendir(IEDB_DIR, $dir);{ @iedb_dir = readdir(IEDB_DIR); } 
 closedir (IEDB_DIR);		# open directory of files containing iedbs

open (OUT, ">$dir/epitope_structure_homologs.csv"); { 
open (TOP, ">$dir/top_structure_homolog.csv"); {
  print OUT "Epitope ID,Epitope Source Accession No.,PDB ID,Chain,E-val,Sensitivity,Identical Residues\n"; print "Epitope ID,Epitope Source Accession No.,PDB ID,Chain,E-val,Sensitivity,Identical Residues\n";
  foreach my $file (@iedb_dir){
  open (INFILE, "$dir/$file"); { @iedb_file = <INFILE>; } close (INFILE);
	$file_len = @iedb_file;
	@pdbs =();
	for ($line_num=1;$line_num < $file_len; $line_num++){
	$file=~s/.html//sg; @epitope = split /\_/,$file; 
	  if ($iedb_file[$line_num]=~m/target\=\"pdb\"/){
	  # remove html tags, tabs and spaces
	  $iedb_file[$line_num]=~s/<.+?>//sg; $iedb_file[$line_num]=~s/\t//sg; $iedb_file[$line_num]=~s/\s//sg; 
	  $chain = $line_num+2;
	  $iedb_file[$chain]=~s/<.+?>//sg; $iedb_file[$chain]=~s/\t//sg; $iedb_file[$chain]=~s/\s//sg; 
	  $e_val = $line_num+4;
	  $iedb_file[$e_val]=~s/<.+?>//sg; $iedb_file[$e_val]=~s/\t//sg; $iedb_file[$e_val]=~s/\s//sg; 
	  $sensitivity = $line_num+6;
	  $iedb_file[$sensitivity]=~s/<.+?>//sg; $iedb_file[$sensitivity]=~s/\t//sg; $iedb_file[$sensitivity]=~s/\s//sg; 
	  $identical = $line_num+19;
	  $iedb_file[$identical]=~s/<.+?>//sg; $iedb_file[$identical]=~s/\t//sg; $iedb_file[$identical]=~s/ Identical Residues://sg; 
	  print "$epitope[0],$epitope[1],$iedb_file[$line_num],$iedb_file[$chain],$iedb_file[$e_val],$iedb_file[$sensitivity],$iedb_file[$identical]";
	  print OUT "$epitope[0],$epitope[1],$iedb_file[$line_num],$iedb_file[$chain],$iedb_file[$e_val],$iedb_file[$sensitivity],$iedb_file[$identical]";
	  push (@pdbs, $iedb_file[$line_num]);
	  $ctr++;	
	  }
	}print OUT "\n"; print "\n";  print TOP "$epitope[0],$epitope[1],$pdbs[0]\n";
	
	
  } print OUT "\n$ctr epitopes mapped";
  } close (TOP);    
} close (OUT);    
} else { print "\nDirectory does not exist!\n"; }