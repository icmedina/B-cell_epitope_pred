#!/usr/bin/perl

# A program that converts a pdf test bank into a examview readable format.
# June 2014, Ice
# don't forget to put EOF line(\d\.\d-)
  open(INPUT,'files\in.txt'); @data=<INPUT>;  close(INPUT);

  print "Processing data... "; 
  &process_data;   print "Done! \n";

sub process_data{
open(FILE, '>files\out.txt');
	$file_len = @data;

    for($line_num = 0; $line_num <= $file_len; $line_num++){
	if ($data[$line_num] =~m/^Multiple-Choice Questions/) 
			{ print FILE "\nMultiple Choice\n";}			

		elsif (($data[$line_num] =~m/^\d\n/) || ($data[$line_num] =~m/^\d\d\n/) || 	# remove page numbers, page ref
			   ($data[$line_num] =~m/^Question ID/))								# remove questionn id
			{   $data[$line_num] = ""; }

		elsif ($data[$line_num] =~m/^Fill-in-the-Blank Questions/) 
			{ print FILE "\n\nCompletion\n";}			
		elsif ($data[$line_num] =~m/^Essay Questions/) 
			{ print FILE "\nEssay\n";}			

		
		elsif ($data[$line_num] =~m/^\d\.\d\-/)					# find questions
			{$data[$line_num] =~s/\n/ /;
			$data[$line_num] =~s/\d\.\d\-//;					# remove chapter number in question number

			$quest_nxt_line = $line_num + 1;					# parse multi-line questions
			unless (($data[$quest_nxt_line] =~m /^a. /) || ($data[$quest_nxt_line] =~m /^Difficulty/))
			{$data[$quest_nxt_line] =~s/\n/ /;
			 $data[$line_num] = $data[$line_num].$data[$quest_nxt_line]; # concatenate prev line with curr line
			} 
			print FILE "\n$data[$line_num]";						

			}				
		
		elsif ($data[$line_num] =~m/^a\. /) 					# parse the choice a 
		{ $data[$line_num] =~s/\n/ /; 
			$a_nxt_line = $line_num + 1;							# parse multi-line choice
			unless ($data[$a_nxt_line] =~m/^b\. /)
			{$data[$a_nxt_line] =~s/\n/ /;
			 $data[$line_num] = $data[$line_num].$data[$a_nxt_line];
			} 
		  print FILE "\n$data[$line_num]";						
		}
		
		elsif ($data[$line_num] =~m/^b\. /) 					# parse the choice b
		{ $data[$line_num] =~s/\n/ /; 
			$b_nxt_line = $line_num + 1;							# parse multi-line choice
			unless ($data[$b_nxt_line] =~m /^c\. /)
			{$data[$b_nxt_line] =~s/\n/ /;
			 $data[$line_num] = $data[$line_num].$data[$b_nxt_line];
			} 
		  print FILE "\n$data[$line_num]";						
		}
		
		elsif ($data[$line_num] =~m/^c\. /) 					# parse the choice c
		{ $data[$line_num] =~s/\n/ /; 
			$c_nxt_line = $line_num + 1;							# parse multi-line choice
			unless ($data[$c_nxt_line] =~m /^d\. /)
			{$data[$c_nxt_line] =~s/\n/ /;
			 $data[$line_num] = $data[$line_num].$data[$c_nxt_line];
			} 
		  print FILE "\n$data[$line_num]";						
		}
		
		elsif ($data[$line_num] =~m/^d\. /) 					# parse the choice d
		{ $data[$line_num] =~s/\n/ /;  
		$d_nxt_line = $line_num + 1;							# parse multi-line choice
			unless ($data[$d_nxt_line] =~m /^e\. /)
			{$data[$d_nxt_line] =~s/\n/ /;
			 $data[$line_num] = $data[$line_num].$data[$d_nxt_line];
			} 
		  print FILE "\n$data[$line_num]";						
		}
		
		elsif ($data[$line_num] =~m/^e\. /) 					# parse the choice e
		{  $data[$line_num] =~s/\n/ /; 
		$e_nxt_line = $line_num + 1;							# parse multi-line choice
			unless ($data[$e_nxt_line] =~m /^Difficulty/)
			{$data[$e_nxt_line] =~s/\n/ /;
			 $data[$line_num] = $data[$line_num].$data[$e_nxt_line];
			} 
		  print FILE "\n$data[$line_num]";						
		}
			
		elsif ($data[$line_num] =~m/Difficulty: /) 				#  convert quanti difficulty to qualitative
			{$data[$line_num] =~s/Difficulty:/DIF:/;
			 $data[$line_num] =~s/1/Easy/;
			 $data[$line_num] =~s/2/Moderate/;
			 $data[$line_num] =~s/3/Difficult/;
			 $data[$line_num] =~s/4/Difficult/;
			 $dif = $data[$line_num];
			 }
	 
		elsif ($data[$line_num] =~m/^Page Ref/) 
			{$data[$line_num] =~s/Page Ref:/REF: page/;
			$ref = $data[$line_num];
			}				

		elsif ($data[$line_num] =~m/Topic:/) 
			{$data[$line_num] =~s/Topic/TOP/;
			$top = $data[$line_num];
			}				
				
		elsif ($data[$line_num] =~m/^Skill:/) 
			{$data[$line_num] =~s/Skill/OBJ: Bloom's Taxonomy/;
			$obj = $data[$line_num];
			}

		elsif (($data[$line_num] =~m/^Answer: \w\./) || ($data[$line_num] =~m/^Answer: \w\:/)) 			# parse answer for MC questions
			{@ans = split /\s/,$data[$line_num];
			$ans[1]=~s/\.//; $ans[1] =~s/\://;
			print FILE uc"\nANS: $ans[1]";
			
			$ratl_nxt_line= $line_num + 1;
			while ($data[$ratl_nxt_line] !~ /^\d\.\d\-/)		# parse multi-line rationale
			{	$data[$ratl_nxt_line] =~s/Rationale: //;
				$data[$ratl_nxt_line] =~s/\n/ /;
				$ratl = $ratl.$data[$ratl_nxt_line];			# concatenate previous line with current line
				$ratl_nxt_line++;
			} print FILE "\n$ratl\n$top$obj$dif$ref";
			  $ratl="";
		}
		
		elsif ($data[$line_num] =~m/^Answer: /) 				# parse multi-line answer for other question types
		{	$data[$line_num] =~s/Answer/ANS/;
			$data[$line_num] =~s/\n/ /;

			$ans_nxt_line= $line_num + 1;
			while ($data[$ans_nxt_line] !~ /^\d\.\d\-/)
			{	$data[$ans_nxt_line] =~s/\n/ /;
				$data[$line_num] = $data[$line_num].$data[$ans_nxt_line];
				$ans_nxt_line++;
			} print FILE "\n$data[$line_num]\n$top$obj$dif$ref";						
		}
   } 
  close(FILE);
}