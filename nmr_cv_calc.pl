#!/usr/local/bin/perl

#####################################################################################################################################
# Description: A perl script that splits an NMR file into individual models then calculates dihedral angles and  circular variance	#
# Author: 	   Isidro C. Medina Jr.																									#
# Date: 	   2013																													#
#####################################################################################################################################

use Transpose;

# Global Variable(s)
$input = "1K19";													# input PDB ID
  
#&split_nmr_models($input);
@dihedral_angles_all = &read_dir ($input);
@all_dihedrals = &transpose_dihed(@dihedral_angles_all);
&calc_circ_var (@all_dihedrals);									# Values of circular variances saved to: $input.cv

sub split_nmr_models {
  my $base = $_[0]; mkdir $base;									# create directory named after the PDB ID
  print "\nInput:\t$base.pdb","\t" ;				
  															
  open(IN,"<$base.pdb"); { my @pdb_input = <IN>;
  # parse the content of the header section
  my $line_number = 1;
	foreach my $pdb_line(@pdb_input) {
	  if ($pdb_line =~/^MODEL/){ 									# find the start of each MODEL
		$end = $line_number; last;									# assign the start of the model as the end of the header
	  } $line_number++;
	} @header = @pdb_input[1..($end-2)];

  # write the model number, header and coordinates of into the output file (${base}_$model_num.pdb)
	my $model_num=0;
	foreach my $line(@pdb_input) {
	  if($line =~ /^MODEL/) {										# find the start of each MODEL
	  ++$model_num;													# pdb model counter
		my $file="${base}_$model_num.pdb";
		open(OUT,">$base/$file");										
		chomp ($pdb_input[$_]);
		print OUT substr($pdb_input[0],0,70), "MODEL $model_num\n";	# write the model number into the output file
		print OUT @header;
		next}
	  if($line =~ /^ENDMDL/) { next }								# find the end of each MODEL
	  if($line =~ /^ATOM/ || $line =~ /^HETATM/) {print OUT "$line"}# write the coordinates of each model into the output file
	}
   print "\n\nThere are $model_num models in this NMR ensemble."; 
   print "\n\nModels saved to $base folder as: $base\_1.pdb to $base\_$model_num.pdb\n";
  } close(IN);
}

sub read_dir{ print "\nCalculating dihedral angles for all models...";
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
  print CIRC_VAR "Residue\tCirc Variance"; print CIRC_VAR "======= =============";	
  
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

		$phi_ctr = $phi_ctr+2; $psi_ctr = $psi_ctr+2; 						# increment ctr by 2 since phi & psi are alternating in the table
	  }

  # calculation of dihedral circular variance (2-D)
    $R_sqrd = 0.5*(($sum_cos_phi**2) + ($sum_sine_phi**2) + ($sum_cos_psi**2) + ($sum_sine_psi**2));	# R squared
	$R_ave = (sqrt($R_sqrd))/$n;											# R average, $n = # of models 
    $circ_var = 1 - $R_ave;													# circular variance
    $rounded_cv = sprintf "%.3f", $circ_var;								# round-off to 3 decimal places
 	print CIRC_VAR "$values[0]\t$rounded_cv";
   } 
  } close (CIRC_VAR);
	print "\n\nValues of circular variances saved to: $input.cv\n";
}