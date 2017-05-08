#!/usr/local/bin/perl

#####################################################################################################################################
# Description: 	A perl script that splits an NMR file into individual models then calculates dihedral angles and  circular variances#
# Author: 	   	Isidro C. Medina Jr.																								#
# Date: 	   	2013																												#
# Input: 		pdb id 																												#
# Output: 		file that contains circular variances (pdbid.cv)																	#
#####################################################################################################################################

use Switch;
use Transpose;

# Get input from the user
print "\nInput pdb file: "; $pdbid = <STDIN>; chomp ($pdbid);		# input pdb id
  if ($pdbid =~ /\.pdb/){ @pdb = split /\./,$pdbid; 				# remove .pdb if user input has extension 
   $input = uc($pdb[0]);} else {$input = uc($pdbid);} 				# convert pdb id to uppercase

   
if (-e $pdbid) {
  &identify_expdata ($input); 
} else { print "\nFile doesn't exist!"; }

 
# Identify the type of experimental data then perform calculation based on expt type (local variables ok)
sub identify_expdata { my $input = $_[0]; my @pdb_file;
 open (PDBNMR, "$input.pdb");{ @pdb_file = <PDBNMR>; } close (PDBNMR);
 foreach my $pdbline (@pdb_file) { 			
  if ($pdbline =~ m/EXPDTA/){ 										# identify type of experiment
	my @exptdta = split /    /,$pdbline; my $expt_data = $exptdta[1];
	if ($expt_data =~ m/X-RAY/){ print "\nExperimental Data: $expt_data";
	  &identify_missing_residues($input); 							# identify missing residues if the experimental data is X-Ray
	  print "\nWhich atoms would you like to include in the\n calculation of average B-factor? "; 
	  print "\n\n  [A] all atoms\n  [B] backbone atoms\n  [C] side chain atoms\n\n Select: ";
	  $choice = <STDIN>; chomp ($choice); $choice = uc($choice);
	  &split_chain ($input,$choice); 	 
	} 
	elsif ($expt_data =~ m/NMR/){ print "\nExperimental Data: $expt_data";
	  &nmr_cv_calculator ($input); }								# calculate circular variances if the experimental data is NMR
  }	
 } 
}

# Identify missing residues if the experimental data is X-Ray (local variables ok)
sub identify_missing_residues { my $input = $_[0];	my @pdb_input;	# get input pdb id from the main program
 open (PDBXRAY, "$input.pdb"); { @pdb_input = <PDBXRAY>; } close (PDBXRAY);
  my @missing_residues; my $missing_res_ctr = 0;
  foreach my $line (@pdb_input) { 
    if ($line =~ m/REMARK 465/){ push (@missing_residues, $line); }	# get the missing residues section
  }
  for (my $legend_ln = 0; $legend_ln < 7; $legend_ln++) { 
	shift (@missing_residues);} 									# remove legend lines

 open (MISSING, ">$input\_missing\_res.csv");{  
  print MISSING "MISSING RESIDUES\n\nRES C SSEQ"; print MISSING "\n=== = ===="; 
  print "\n\nMISSING RESIDUES\n\nRES C SSEQ"; print "\n=== = ====";
  foreach my $missing_res (@missing_residues){
	my $residue = substr($missing_res,15,3);						# get missing residues (col 15)
	my $chain = substr($missing_res,19,1); 							# get missing residues chain (col 19)
	my $position = substr($missing_res,23,4); 						# get the position of missing residues (col 23)
	print MISSING "\n$residue $chain  $position"; print "\n$residue $chain  $position";
	$missing_res_ctr++;
   } print MISSING "\n=== = ===="; print  MISSING "\nTotal: $missing_res_ctr\n\n";
     print "\n=== = ===="; print "\nTotal: $missing_res_ctr\n\n";
  } close (MISSING);
}

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
	else 	 { print "\nIt's not a valid choice.";}
  } print "\n\nThank you for using this tool!\n";

}

# Calculate average B-factors based on user selection (@polypeptide || @main_chain || @sidechain)
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

# Perform calculation of circular variances if the experimental data is NMR
sub nmr_cv_calculator  { my $input = $_[0];
  &split_nmr_models($input);
  @dihedral_angles_all = &read_model_dir ($input);
  @all_dihedrals = &transpose_dihed(@dihedral_angles_all);
  &calc_circ_var (@all_dihedrals);									# Values of circular variances saved to: $input.cv
}

sub split_nmr_models { my $base = $_[0]; mkdir $base;				# create directory named after the pdb id
  open(IN,"<$base.pdb"); { my @pdb_input = <IN>;
  # parse the content of the header section
  my $line_number = 1;
  foreach my $pdb_line(@pdb_input) { if ($pdb_line =~/^MODEL/){ 	# find the start of each MODEL
	$end = $line_number; last;										# assign the start of the model as the end of the header
	} $line_number++;
  } @header = @pdb_input[1..($end-2)];

  # write the model number, header and coordinates of into the output file (${base}_$model_num.pdb)
  my $model_num=0;
  foreach my $line(@pdb_input) { 

  if($line =~ /^MODEL/) {			# find the start of each MODEL
	  ++$model_num;													# pdb model counter
	  my $file="${base}_$model_num.pdb";
	  open(OUT,">$base/$file"); #{ chomp ($pdb_input[$_]);
	  print OUT substr($pdb_input[0],0,70), "MODEL $model_num\n";	# write the model number into the output file
	  print OUT @header;
	next }
	  if($line =~ /^ENDMDL/) { next }								# find the end of each MODEL
	  if($line =~ /^ATOM/ || $line =~ /^HETATM/) {print OUT "$line"}# write the coordinates of each model into the output file

  }
   print "\n\nThere are $model_num models in this NMR ensemble."; 
   print "\n\nModels saved to $base folder as: $base\_1.pdb to $base\_$model_num.pdb\n";
 } close(IN);
}

sub read_model_dir { print "\nCalculating dihedral angles for all models...";
my $dir = $_[0];
opendir(DIR, $dir);{ @models = readdir(DIR); } closedir (DIR);		# open directory of files containing NMR models
  my $model_cnt = @models;
  my $dir_level = 2; $model_1 = $dir_level;							# file 1 = 2, since index 0 & 1 refers to directory level
  my @dihedral_angles_all = ();
  for($model_ctr=$model_1; $model_ctr < $model_cnt; $model_ctr++){	# read directory
	my $model_input = "$dir/$models[$model_ctr]";
	my $dihedrals = &calc_phi_psi($model_ctr,$model_1,$model_input);# pass model counter, model 1 and model content to phi-psi calculator subroutine
    push (@dihedral_angles_all,$dihedrals);
   } print "done."; return (@dihedral_angles_all);
}

sub calc_phi_psi {
my $DSSP = "dssp-2.0.4-win32.exe";									# name of the dssp executable file (phi-psi predictor)
my $modelctr = $_[0]; my $model1 = $_[1]; my $model = $_[2]; 		# values from the calling program

  if(-f $DSSP){														# check if dssp program exists
	#print "\nInput:  $model\nOutput: $model.dssp\n\n";
	@dssp_file = qx/"$DSSP  -i $model"/ or die $?;					# run executable by the system with defined input and output to an array
	#system ("$DSSP  -i $model -o $model.dssp")						# run executable by the system with defined input and output to a file ($file.dssp)
  }
  else { die $?; }
  
  $dssp_file_len = @dssp_file;
  @pos_res_chains = (); @phis = (); @psis = ();
  for ($line_num = 28; $line_num < $dssp_file_len; $line_num++) { 	
	$residue_line = $dssp_file[$line_num];							# get dihedral angle values which begins at line 29 of dssp output 
	$pos = substr($residue_line,7,3); 								# output position from column 7, max of 3 characters
	$chain = substr($residue_line,11,1);							# output chain type from column 11, max of 1 character
	$res = substr($residue_line,13,1); 								# output residue name from column 13, max of 1 character
	$pos_res_chn = $pos.$res.$chain; push (@pos_res_chains,$pos_res_chn); # concatenate position, chain and residue into one string
	$phi = substr($residue_line,103,6); push (@phis,$phi); 			# output phi value from column 103, max of 6 characters
	$psi = substr($residue_line,109,6); push (@psis,$psi);			# output psi value from column 109, max of 6 characters
  }
	$position_residue_chain = join (',', @pos_res_chains);
	$phi_out = join (',', @phis); $psi_out = join (',', @psis);
	$\ = "\n";
	  
	if ($modelctr == $model1){										# output position, chain and residue identifier from first model 
	  $dihedral_vals = $position_residue_chain.$\.$phi_out.$\.$psi_out.$\;
	  return ($dihedral_vals);
	} else { $dihedral_vals = $phi_out.$\.$psi_out.$\;
	return ($dihedral_vals);
	}
}

sub transpose_dihed {  my @dihedral_angles = @_;
  open (TEMP, ">$input.tmp");{	print  TEMP @dihedral_angles;  } close (TEMP); # create a temporary file
  open (DIHED, "<$input.tmp");{ @temp = <DIHED>; $model_cntr = (@temp-2)/2;
	open (DIHED_OUT, ">$input.dhd");{
	  my @all_dihedrals = Transpose::transpose(@temp);
	  my $row_1 ="\tResid";
	  for ($ctr=1; $ctr <=$model_cntr; $ctr++){
	    $phi_psi_crt = "\tphi_$ctr\tpsi_$ctr"; 
		$row_1 .= $phi_psi_crt;										# create phi psi label according to model number
	  } $\ = "\n"; $row_1= $row_1.$\;
	    unshift (@all_dihedrals,$row_1); 							# output row label
		print DIHED_OUT @all_dihedrals; return (@all_dihedrals);	# output dihedral angle values 
	} close (DIHED_OUT);
  } close (DIHED); 
}

sub calc_circ_var { @dihed_in = @_;  my $pi = 4*atan2(1,1);			# gives the value of pi
  foreach my $line (@dihed_in) {$line =~s/^\t//;}					# remove leading tabs from the input
  my $dihed_out_len = @dihed_in;
  #print "\nInput file: $input.dhd\n\nLegend: res = amino acid residue; c = chain; var = circular variance\n";

  open (CIRC_VAR, ">$input.cv");{
  print CIRC_VAR "ResChn\tCVphi\tCVpsi\tCVdhed";print CIRC_VAR "======\t=====\t=====\t======";	
  print "\nResChn\tCVphi\tCVpsi\tCVdhed"; print "======\t=====\t=====\t======";	
  # start $line_num at 1 to exclude the row label from calculation of circular variance
  @values = split /\t/,$dihed_in[1]; $col_num = @values;   $n = ($col_num-1)/2;# get the column number (models, $n)
   
  for ($line_num = 1;  $line_num < $dihed_out_len; $line_num++){	 # start at line 1 to exclude row labels
	@values = split /\t/,$dihed_in[$line_num];
	$sum_cos_phi=0; $sum_sine_phi=0; $sum_cos_psi=0; $sum_sine_psi=0;# declare arrays for the summation of phi and psi
	$phi_ctr = 1;$psi_ctr = 2;
	  for ($ctr=0; $ctr < $n; $ctr++){
		$sum_cos_phi = $sum_cos_phi + cos(($values[$phi_ctr]/180) * $pi );	# summation of cosine phi 
		$sum_sine_phi = $sum_sine_phi + sin(($values[$phi_ctr]/180) * $pi );# summation of sine phi 		
		$sum_cos_psi = $sum_cos_psi + cos(($values[$psi_ctr]/180) * $pi );	# summation of cosine phi 
		$sum_sine_psi = $sum_sine_psi + sin(($values[$psi_ctr]/180) * $pi );# summation of sine phi 		

		$phi_ctr = $phi_ctr+2; $psi_ctr = $psi_ctr+2; 				# increment ctr by 2 since phi & psi are alternating in the table
	  }

  # calculation of phi circular variance
    $R_sqrd_phi = ($sum_cos_phi**2) + ($sum_sine_phi**2);			# R squared of phi
	$R_ave_phi = (sqrt($R_sqrd_phi))/$n;							# R average, $n = # of models 
    $circ_var_phi = 1 - $R_ave_phi;									# circular variance of phi
	$rnd_cv_phi = sprintf "%.3f", $circ_var_phi;					# round-off to 3 decimal places

 # calculation of psi circular variance
	$R_sqrd_psi = ($sum_cos_psi**2) + ($sum_sine_psi**2);			# R squared of psi
	$R_ave_psi = (sqrt($R_sqrd_psi))/$n;
	$circ_var_psi = 1 - $R_ave_psi;									# circular variance of psi
 	$rnd_cv_psi = sprintf "%.3f", $circ_var_psi;

 # calculation of dihedral circular variance (2-D)
	$R_sqrd_dihed = ($R_sqrd_phi + $R_sqrd_psi)/2;					# R squared	of dihedral
	$R_ave_dihed = (sqrt($R_sqrd_dihed))/$n;
	$circ_var_dihed = 1 - $R_ave_dihed;								# circular variance of dihedral
	$rnd_cv_dihed = sprintf "%.3f", $circ_var_dihed;
	
	print CIRC_VAR "$values[0]\t$rnd_cv_phi\t$rnd_cv_psi\t$rnd_cv_dihed";
	print "$values[0]\t$rnd_cv_phi\t$rnd_cv_psi\t$rnd_cv_dihed";
   } print CIRC_VAR "======\t=====\t=====\t======"; print "======\t=====\t=====\t======"; 
  } close (CIRC_VAR);
	print "\nValues of circular variances saved to: $input.cv\n";
}