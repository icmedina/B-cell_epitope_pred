#!/usr/local/bin/perl

# three2one_aa 
# A subroutine that converts a 3-character code amino acid to one letter code
 
@amino_seq = qw (GLU ASP LYS TYR THR ASP LYS TYR ASP ASN ILE ASN LEU ASP GLU ILE LEU ALA ASN LYS ARG LEU LEU VAL ALA TYR VAL ASN CYS VAL MET GLU ARG GLY LYS CYS SER PRO GLU GLY LYS GLU LEU LYS GLU HIS LEU GLN ASP ALA ILE GLU ASN GLY CYS LYS LYS CYS THR GLU ASN GLN GLU LYS GLY ALA TYR ARG VAL ILE GLU HIS LEU ILE LYS ASN GLU ILE GLU ILE TRP ARG GLU LEU THR ALA LYS TYR ASP PRO THR GLY ASN TRP ARG LYS LYS TYR GLU ASP ARG ALA LYS ALA ALA GLY ILE VAL ILE PRO GLU GLU);
$aa_ctr =0;
foreach $aa (@amino_seq) { $aa_ctr++;
  $protein .= &three2one_aa($aa);
}

open (OUTFILE, ">1KX8.fasta"); { 
#print OUTFILE ">1KX8";
print OUTFILE "$protein\n\n$aa_ctr amino acids\n";
} close (OUTFILE);

sub three2one_aa { my($amino_acid) = $_[0]; 
 $amino_acid = uc $amino_acid; 
 my(%conversion_table) = ( 
  'ALA' => 'A', # Alanine
  'ARG' => 'R', # Arginine
  'ASN' => 'N', # Asparagine
  'ASP' => 'D', # Aspartic acid
  'CYS' => 'C', # Cysteine
  'GLU' => 'E', # Glutamic acid
  'GLN' => 'Q', # Glutamine
  'GLY' => 'G', # Glycine
  'HIS' => 'H', # Histidine
  'ILE' => 'I', # Isoleucine
  'LEU' => 'L', # Leucine
  'LYS' => 'K', # Lysine
  'MET' => 'M', # Methionine
  'PHE' => 'F', # Phenylalanine
  'PRO' => 'P', # Proline
  'SER' => 'S', # Serine
  'THR' => 'T', # Threonine
  'TRP' => 'W', # Tryptophan
  'TYR' => 'Y', # Tyrosine
  'VAL' => 'V', # Valine
 );
  if(exists $conversion_table{$amino_acid}) { return $conversion_table{$amino_acid}; 	# returns trueif the key $amino_acid exists in the hash
  } else {  print STDERR "Unusual amino acid \"$amino_acid\"!!\n"; 
	exit; 
  }
}  