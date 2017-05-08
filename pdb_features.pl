#!C:\perl\perl\bin -w

use strict;

my $file = "2A07.pdb";
print "\nPDB ID: $file\n";

# Extract sequence from PDB file
  open PDB_IN, '<', $file or die "Can't read file: $!"; my @file = <PDB_IN>; close PDB_IN;

# Parse the record types of the PDB file
my %recordtypes = parsePDBrecordtypes(@file);

# Extract the records in the pdb
my $compnds_hash_ref = extractCMPND($recordtypes{"COMPND"});			# Extract the compound record in the pdb file
my ($chains_ref, $db_ref ,$dbAccsn_ref, $dbIdCode_ref) = extractDBREF($recordtypes{"DBREF"});
my ($chain_ref,$chn_len_ref) = extractSEQRES($recordtypes{"SEQRES"});	# Extract the amino acid sequences of all chains in the pdb file

outputCMPND ($compnds_hash_ref);										# pass the reference to hash compnds
outputDBREF($chains_ref, $db_ref ,$dbAccsn_ref, $dbIdCode_ref);  
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

sub extractCMPND {my $input = $_[0];
my @file = split ( /\n/, $input);				# make array of lines  
my (%compnds, $mol_id,$token,$val,$cur_val,$cur_token);
  foreach my $line (@file){
	if ($line=~m/^(COMPND)\s+(\d*)\s(MOL_ID:)\s(\d+);/){	# match the line containing molecule id
	  $mol_id = "$4";										# set the molecule id
	}
	elsif ($line=~m/^(COMPND)\s+(\d*)\s(.+):\s(.+);/){		# match a line containing the token name (separated by :) 
	  $token = lc("$3"); $val = "$4";  						# and the complete value (ending in ;)
	  $val =~ s/\s+$//;										# remove trailing spaces
	  $val =~s/(\w+)/\u\L$1/g;								# convert values to mixed case
	  $compnds{$mol_id}{ucfirst($token)} = $val;			# enter the token and values to mol_id hash
	}
	elsif ($line=~m/^(COMPND)\s+(\d*)\s(.+):\s(.+)/){		# a line containing the token name with incomplete value
	  $token = lc("$3"); $val = "$4";
	  $val =~s/(\w+)/\u\L$1/g; $val =~ s/\s+$//;			# note, the line is not yet printed at this point
	} 
	elsif ($line=~m/^(COMPND)\s+(\d*)\s(.+)/){				# a line without token name with continuation value
	  $cur_token = $token; 									# get the current token name from the last token
	  $cur_val = "$3"; $cur_val =~ s/;//; 					# the current value is the continuation of the last val
	  $cur_val =~ s/\s+$//; $cur_val =~s/(\w+)/\u\L$1/g; 
	  $val .= $cur_val;										# concatenate the current value with the last value
	  $compnds{$mol_id}{ucfirst($cur_token)} =  $val;
	}
  }
  return (\%compnds);											# return the reference to hash compnds
}

sub extractDBREF { my ($input) = @_;
my @file = split ( /\n/, $input);				# make array of lines

  my ($chain, $prev_chain, $numRes, $prev_seq, $seq,$web);  
  my (@chains, @db ,@dbAccsn, @dbIdCode);
  
  foreach my $line (@file){
	  if ($line=~m/^DBREF/){
		my $chain =  substr($line,12,1); push (@chains, $chain);							# get chain  identifier
		my $db =  substr($line,26,6); $db =~ s/\s+$//; push (@db, $db);						# get sequence database name, then trim trailing spaces
		my $dbAccsn =  substr($line,33,8); $dbAccsn =~ s/\s+$//; push (@dbAccsn, $dbAccsn); # get sequence database accession code, then trim trailing spaces
		my $dbIdCode  =  substr($line,42,11); $dbIdCode =~ s/\s+$//; push (@dbIdCode, $dbIdCode); # get sequence database identification code, then trim trailing spaces
	  }			
  }
  return (\@chains, \@db ,\@dbAccsn, \@dbIdCode); 
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

# output the contents of the compnd hash to an external file
sub outputCMPND { my %compnds_hash = %{$_[0]}; 					# get the reference to hash compnds
  open OUTPUT, '>', "output.txt";
  foreach my $molecule_id (sort keys %compnds_hash) {
    foreach my $tokens (keys %{ $compnds_hash{$molecule_id} }) {
	  print OUTPUT "$molecule_id, $tokens: $compnds_hash{$molecule_id}{$tokens}\n";
    }
  }
  close OUTPUT;
}

# output the contents of the compnd hash to an external file
sub outputDBREF { my @chains = @{$_[0]}; my @db = @{$_[1]}; my @dbAccsn = @{$_[2]}; my @dbIdCode = @{$_[3]}; 					# get the reference to hash compnds
  my $chn_ctr = scalar (@chains);
  my $ctr = 0; 
  open OUTPUT, '>>', "output.txt";
  for($ctr=0; $ctr < $chn_ctr; $ctr++){
    print OUTPUT "$chains[$ctr]\t$db[$ctr]\t$dbAccsn[$ctr]\t$dbIdCode[$ctr]\n"; 
  }
  close OUTPUT;
}

sub outputSEQRES { my @chains = @{$_[0]}; my @chn_lens = @{$_[1]};
my $chn_ctr = scalar (@chains);
  open OUTPUT, '>>', "output.txt";
# Translate the 3-character codes to 1-character codes, and print
  for(my $ctr=0; $ctr<$chn_ctr; $ctr++) {
	#print "\n$chains[$ctr]";				# 3-letter codes
	print OUTPUT "\n$chn_lens[$ctr]:";				# chain length
	print OUTPUT iub3to1($chains[$ctr]);		# 1-letter codes
  } exit;
  close OUTPUT;
}
