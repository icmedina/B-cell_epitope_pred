#!C:\perl\perl\bin -w

use strict;

my $file = "2A07.pdb";
print "\nPDB ID: $file\n";

# Extract sequence from PDB file
  open PDB_IN, '<', $file or die "Can't read file: $!"; my @file = <PDB_IN>; close PDB_IN;

# Parse the record types of the PDB file
my %recordtypes = parsePDBrecordtypes(@file);

# Extract the amino acid sequences of all chains in the protein
my ($chain_ref,$chn_len_ref) = extractSEQRES($recordtypes{"SEQRES"});

outputSEQRES ($chain_ref,$chn_len_ref);

# parsePDBrecordtypes: given an array of a PDB file, return a hash with
# keys = record type names; values = scalar containing lines for that record type
sub parsePDBrecordtypes { my @file = @_;
my %recordtypes = ( );
  foreach my $line (@file) {
  # Get the record type name which begins at the start of the line and ends at the first space
  my($recordtype) = ($line =~ /^(\S+)/);
  # .= fails if a key is undefined, so we have to
  # test for definition and use either .= or = depending
	  if(defined $recordtypes{$recordtype} ) {
		$recordtypes{$recordtype} .= $line;
	  } else {
		$recordtypes{$recordtype} = $line;
	  }
  }
  return %recordtypes;
}


# extractSEQRES: given an scalar containing SEQRES lines, then return an array containing the chains of the sequence
sub extractSEQRES { my($seqres) = @_;
my @record = split ( /\n/, $seqres);				# make array of lines
my ($sequence,$lastchain, @sequences,@chain_lens);

  foreach my $line (@record) {
    my($thischain) = substr($line, 11, 1);			# get chain identifier from column 12
	my($chain_len) = substr($line, 13, 4);$chain_len =~ s/^\s+//; # get chain length from column 13, trim leading spaces
	my($residues) = substr($line, 19, 52); 			# get residues starting at column 20 then add space at end
		if ($lastchain eq "") {						# Check if a new chain, or continuation of previous chain
			$sequence = $residues;
			push (@chain_lens, $chain_len);			# get the length of the first chain
		} elsif ("$thischain" eq "$lastchain") {
			$sequence .= $residues;
		# Finish gathering previous chain (unless first record)
		} elsif ($sequence) {
			push (@chain_lens, $chain_len);
			push(@sequences, $sequence);
			$sequence = $residues;
		} 
		$lastchain = $thischain;
  }
  push(@sequences, $sequence); # save last chain
  return (\@sequences,\@chain_lens);
}

# iub3to1: change string of 3-character IUB amino acid codes (whitespace separated) into a string of 1-character amino acid codes
sub iub3to1 { my($input) = @_;
  my %three2one = (
# amino acids  
	'ALA' => 'A',
	'VAL' => 'V',
	'LEU' => 'L',
	'ILE' => 'I',
	'PRO' => 'P',
	'TRP' => 'W',
	'PHE' => 'F',
	'MET' => 'M',
	'GLY' => 'G',
	'SER' => 'S',
	'THR' => 'T',
	'TYR' => 'Y',
	'CYS' => 'C',
	'ASN' => 'N',
	'GLN' => 'Q',
	'LYS' => 'K',
	'ARG' => 'R',
	'HIS' => 'H',
	'ASP' => 'D',
	'GLU' => 'E',
# nucleotides	
	'DA' => 'A',
	'DT' => 'T',
	'DG' => 'G',
	'DC' => 'C',
  );
# clean up the input
$input =~ s/\n/ /g;
my $seq = '';

# This use of split separates on any contiguous whitespace
my @code3 = split(' ', $input);
  foreach my $code (@code3) {
	# A little error checking
	if(not defined $three2one{$code}) {
	print "Code $code not defined\n";
	next;
	}
	$seq .= $three2one{$code};
  }
  return $seq;
}

sub outputSEQRES { my @chains = @{$_[0]}; my @chn_lens = @{$_[1]};
my $chn_ctr = scalar (@chains);
  open OUTPUT, '>>', "output.txt";
# Translate the 3-character codes to 1-character codes, and print
  for(my $ctr=0; $ctr<$chn_ctr; $ctr++) {
	#print "\n$chains[$ctr]";				# 3-letter codes
	print OUTPUT "\n$chn_lens[$ctr]:";				# chain length
	print OUTPUT iub3to1($chains[$ctr]);		# 1-letter codes
  } #exit;
  close OUTPUT;
}