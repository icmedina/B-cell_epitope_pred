#!/usr/bin/perl
print "\nType the filename you want to process: ";
$inputfile = <STDIN>;
  open(INPUT,$inputfile);
    @data=<INPUT>;
  close(INPUT);
&outfile;

sub outfile{
  open(OUT, '>protein.txt');
$size=@data;
 chomp($data);
    print OUT "MUTASES\n\n";
    for ($line_num=0;$line_num < $size; $line_num++) {
      if ($data[$line_num] =~/mutase/g) {
      @new = split /\s/, $data[$line_num];
      $line=$line_num+1;
      print OUT $line, " ";
      print OUT $new[1];
      print OUT "\n";
      }
    }  
  close(OUT);
}