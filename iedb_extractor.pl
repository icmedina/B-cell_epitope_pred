#!/usr/local/bin/perl

# Get filename containing IEDB data from the user
print "\nType the filename of the IEDB data: "; 
$iedb = <STDIN>; chomp ($iedb);								# input iedb data

# Validate if the list and directory exist     
if (-e $iedb) {												# check if the list exists
 &extract_iedb($iedb); 										# pass filename to subroutine
}
else { print "\nFile doesn't exist!\n"; }

sub extract_iedb {my $input = $_[0]; my @iedb_input;
 open (IEDB, "$input"); { @iedb_input = <IEDB>; } 			# open the file containing the full iedb data
 close (IEDB);
 $ctr = 0; $delim =  "\",\"";
 
  open (IEDB, ">iedb_data.csv");{ 

print IEDB "Epitope ID,Epitope Object Type,Epitope Object Primary Molecule Sequence,Epitope Object Starting Position,Epitope Object Ending Position,Epitope Object Secondary Molecule Source Accession Number,Epitope Structure Defines,Method/Technique,Measurement of,Assay Type Units,Measurement Inequality,Quantitative measurement,Antigen PDB Chain,Epitope Residues\n";
	foreach my $line (@iedb_input){ @iedb = split /$delim/,$line;
 	 if (($iedb[282] ne "")&&($iedb[19] ne "Non-peptidic")&&(($iedb[281] eq "")||($iedb[281] eq "\="))&&(($iedb[280]=~m/KA/)||($iedb[280]=~m/KD/))){			# retrieve all peptidic data with thermodynamic/kinetic data
		print IEDB "$iedb[18],"; # Epitope ID
		print IEDB "$iedb[19],"; # Epitope Object Type
		print IEDB "$iedb[25],"; # Epitope Object Primary Molecule Sequence
		print IEDB "$iedb[31],"; # Epitope Object Starting Position
		print IEDB "$iedb[32],"; # Epitope Object Ending Position
#		print IEDB "$iedb[37],"; # Epitope Object Secondary Molecule Source Name
		print IEDB "$iedb[38],"; # Epitope Object Secondary Molecule Source Accession Number
		print IEDB "$iedb[41],"; # Epitope Structure Defines
#		print IEDB "$iedb[43],"; # Epitope Name
#		print IEDB "$iedb[72],"; # BCell ID
#		print IEDB "$iedb[87],"; # 1st Immunogen Object Type
#		print IEDB "$iedb[93],"; # 1st Immunogen Object Primary Molecule Sequence
#		print IEDB "$iedb[97],"; # 1st Immunogen Object Primary Molecule Source Name
#		print IEDB "$iedb[98],"; # 1st Immunogen Object Primary Molecule Source Accession Number
#		print IEDB "$iedb[101],"; # 1st Immunogen Object Primary Organism Name
		print IEDB "$iedb[278],"; # Method/Technique
		print IEDB "$iedb[279],"; # Measurement of
		print IEDB "$iedb[280],"; # Assay Type Units
		print IEDB "$iedb[281],"; # Measurement Inequality
		print IEDB "$iedb[282],"; # Quantitative measurement
#		print IEDB "$iedb[315],"; # Antigen Object Type
#		print IEDB "$iedb[361],"; # 3D Structure of Complex
		print IEDB "$iedb[364],"; # Antigen PDB Chain
		print IEDB "$iedb[367]"; # Epitope Residues
#		print IEDB "$iedb[368],"; # Antibody Residues Interacting with Antigen
		print IEDB "\n";
	  }
	} 
  } close (IEDB); print "\nExtracted data saved as: iedb_data.csv";
}

# Retrieve : http://tools.immuneepitope.org/esm/getMapping.do?epitope_id=$iedb[18]&source_id=genbank-$iedb[38]