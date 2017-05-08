#!/usr/bin/perl
##!/usr/local/bin/perl
# script that extracts the coordinates of peptide from a Ab-peptide complex
# Get directory containing PDB data from the user
print "\nType the directory containing the PDB files: "; 
$directory = <STDIN>; chomp ($directory);							# input dir

$ch = "P";

if (-d $directory) { my @dir; my @pdb_file;							# check if the dir exists
 opendir(DIR, $directory);{ @dir = readdir(DIR); } closedir (DIR);	# open directory of files containing pdbs
 my $complex_ctr =0;
 
 
 foreach my $file (@dir){ my @pdb = split /\./,$file;
  open (INFILE, "$directory/$file"); { @pdb_file = <INFILE>; } close (INFILE);
  open (OUTFILE, ">$directory/$pdb[0]\_pep.pdb"); { 	
	
	# parse the content of the header section
	my $line_number = 1;
	foreach my $pdb_line(@pdb_file) { 
	  if ($pdb_line =~/^ATOM/){ 								# find the start of coordinate values
		$end = $line_number; last;								# assign the start of the coordinate values as the end of the header
	  } $line_number++;
	} @header = @pdb_file[1..($end-2)];
  
	print OUTFILE @header;

	# check if file contains peptide coordinates
	foreach my $line (@pdb_file){
	  if ($line=~m/^COMPND/){
		my $chain = substr($line,11,8);
		if ($line=~m/CHAIN\: $ch/){ $complex_ctr++; print "\n$file";
		}
	  }
  
	  my $peptide_atm = substr($line,21,1);							# check if chain is peptide: P
	  if (($line=~m/^ATOM/)&&($peptide_atm eq "$ch")){
		print OUTFILE "$line"; }									# output the coordinates of the peptide to peptide pdb  
	} 	print OUTFILE "END";
  } close (OUTFILE);
  } print "\n\nAntibody-peptide complex(es): $complex_ctr coordinate files";
} else { print "\nDirectory does not exist!\n"; }