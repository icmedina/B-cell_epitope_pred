#!C:\Perl\bin -w

use strict;

my $file = "2A07.pdb";
open PDB_IN, '<', $file or die "Can't read file: $!"; 	my @file = <PDB_IN>; close PDB_IN;	 

# Parse the record types of the PDB file
my %recordtypes = parsePDBrecordtypes(@file);
my ($chains_ref, $db_ref ,$dbAccsn_ref, $dbIdCode_ref) = extractDBREF($recordtypes{"DBREF"});
outputDBREF($chains_ref, $db_ref ,$dbAccsn_ref, $dbIdCode_ref);  
  
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

# output the contents of the compnd hash to an external file
sub outputDBREF { my @chains = @{$_[0]}; my @db = @{$_[1]}; my @dbAccsn = @{$_[2]}; my @dbIdCode = @{$_[3]}; 					# get the reference to hash compnds
  my $chn_ctr = scalar (@chains);
  my $ctr = 0; 
  open OUTPUT, '>', "output.txt";
  for($ctr=0; $ctr < $chn_ctr; $ctr++){
    print OUTPUT "$chains[$ctr]\t$db[$ctr]\t$dbAccsn[$ctr]\t$dbIdCode[$ctr]\n"; 
  }
  close OUTPUT;
}
