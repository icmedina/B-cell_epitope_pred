#!/usr/local/bin/perl

use Switch;

# Get input from the user
print "\nInput pdb file: "; $pdbid = <STDIN>; chomp ($pdbid);		# input pdb id
  if ($pdbid =~ /\.pdb/){ @pdb = split /\./,$pdbid; 				# remove .pdb if user input has extension 
   $input = uc($pdb[0]);} else {$input = uc($pdbid);} 				# convert pdb id to uppercase

if (-e $pdbid) {
 	print "\nWhich atoms would you like to include in the\n calculation of average B-factor? "; 
	print "\n\n  [A] all atoms\n  [B] backbone atoms\n  [C] side chain atoms\n\n Select: ";
	$choice = <STDIN>; chomp ($choice); $choice = uc($choice);
 &split_chain ($input,$choice); 
 
} else { print "\nFile doesn't exist!"; }

# split the main chain and side chain into different arrays
sub split_chain { my $input = $_[0]; $choice = $_[1]; my @pdb_input;
 open (PDBXRAY, "$input.pdb"); { @pdb_input = <PDBXRAY>; } close (PDBXRAY);
  @polypeptide; @main_chain; @sidechain;
  foreach my $line (@pdb_input) { if ($line =~ m/^ATOM/){
	push (@polypeptide,$line);										# save atom data to an array (@polypeptide)
	my $atom = substr($line,13,3);										# get atom data from the pdb input
	if ($atom eq "N  " || $atom eq "CA " || $atom eq "C  " || $atom eq "O  "){
	  push (@main_chain,$line);										# save backbone data to an array (@main_chain)
	} else { push (@sidechain,$line);}								# save sidechain data to an array (@sidechain)
   }
  } 
  
  switch ($choice) {
    case 'A' { print "\nALL ATOMS\n"; &bfactor_calc (@polypeptide);}						
    case 'B' { print "\nMAIN CHAIN\n"; &bfactor_calc (@main_chain);}						
    case 'C' { print "\nSIDE CHAIN\n"; &bfactor_calc (@sidechain);}						
	else 	 { print "\nIt's not a valid choice. Please make another selection.\n";}
  } print "\n\nThank you for using this tool!\n";

}

sub bfactor_calc { my @pdb_input = @_;
  my @atoms; my @residues; my @chains; my @b_factors; my @positions;
  open (BFACTR, ">$input\_bfactors.csv"); { 
  print "\nATOM RES C SSEQ B-FCTR\n==== === = ==== ======";print BFACTR "ATOM,RES,C,SSEQ,B-FCTR";
  foreach my $line (@pdb_input) { if ($line =~ m/^ATOM/){
	my $atom = substr($line,13,4); push (@atoms,$atom);
	my $res = substr($line,17,3); push (@residues,$res); 
	my $chain = substr($line,21,1); push (@chains,$chain);
	my $pos = substr($line,23,3); push (@positions,$pos);
	my $b_factor = substr($line,61,5); push (@b_factors,$b_factor);
	print "\n$atom $res $chain  $pos  $b_factor"; print BFACTR "\n$atom,$res,$chain,$pos,$b_factor";
	}   
  } my $pos_atom_ctr = @positions;
  print "\n==== === = ==== ======"; 
  
  print "\n\nAVERAGE B-FACTORS\n\nRES C SSEQ B-FCTR\n=== = ==== ======";print BFACTR "\n\nRES,C,SSEQ,B-FCTR";
 my $sum_bfctr = 0; my $ave_bfctr = 0; my $atom_pos_ctr = 1;
  for (my $ctr = 0; $ctr < $pos_atom_ctr; $ctr++){ $nxt_pos = $ctr+1;
	if ($positions[$ctr] eq $positions[$nxt_pos]) { $atom_pos_ctr++;		# count the number of atoms per residue
#	 print BFACTR "\n $b_factors[$ctr]";
	 $sum_bfctr = $sum_bfctr + $b_factors[$ctr];
	} elsif ($positions[$ctr] ne $positions[$nxt_pos]) {
#	 print BFACTR "\n $b_factors[$ctr]";
	 $sum_bfctr = $sum_bfctr + $b_factors[$ctr];						# get the sum of b-factors per residue
	 $ave_bfctr = ($sum_bfctr/$atom_pos_ctr);
	 $ave_bfctr = sprintf "%.2f", $ave_bfctr;
	 print BFACTR "\n$residues[$ctr],$chains[$ctr],$positions[$ctr],$ave_bfctr"; print "\n$residues[$ctr] $chains[$ctr]  $positions[$ctr]  $ave_bfctr";
	 $sum_bfctr = 0; $atom_pos_ctr = 1;
	}
  } print "\n=== = ==== ======";
 } close (BFACTR); print "\n\nValues saved to $input\_bfactors.csv" 
}

