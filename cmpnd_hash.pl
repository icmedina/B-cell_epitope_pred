#!C:\perl\perl\bin -w

use strict;

my $file = "2A07.pdb";
open PDB_IN, '<', $file or die "Can't read file: $!"; my @file = <PDB_IN>; close PDB_IN;	 

# Parse the record types of the PDB file
my %recordtypes = parsePDBrecordtypes(@file);

# Extract the compound record in the protein
my $compnds_hash_ref = extractCMPND($recordtypes{"COMPND"});

outputCMPND ($compnds_hash_ref);										# pass the reference to hash compnds


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
  return (%recordtypes);
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
