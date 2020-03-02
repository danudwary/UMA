#GUMA

use Tk;

$mw = new MainWindow;
$mw->title("UMA -  v1.8a-gui");

&reset();

$fb = $mw->Frame(-relief => 'groove',
				 -bd => 2
				 )->pack(-side => 'bottom', -fill => 'y');

$fb->Label(-textvariable => \$messages)->pack(-anchor => 'e');

$fr = $mw->Frame(-relief => 'groove',
				-bd => 2
				)->pack(-side => 'right', -fill => 'y');

$fl = $mw->Frame(-relief => 'groove',
				-bd => 2,
				)->pack(-side => 'right', -fill => 'y');

$fl->Label(-text => 'Alignment file (pir):')->pack(-anchor => 'e');
$fl->Label(-text => 'Secondary structure file:')->pack(-anchor => 'e');
$fl->Label(-text => 'Homology matrix:')->pack(-anchor => 'e');
$fl->Label(-text => 'Gap to gap penalty:')->pack(-anchor => 'e');
$fl->Label(-text => 'Gap to aa penalty:')->pack(-anchor => 'e');
$fl->Label(-text => 'Component averaging (K):')->pack(-anchor => 'e');
$fl->Label(-text => 'Final averaging (gamma):')->pack(-anchor => 'e');
$fl->Label(-text => 'Sim score weight:')->pack(-anchor => 'e');
$fl->Label(-text => 'Struc score weight:')->pack(-anchor => 'e');
$fl->Label(-text => 'Hydro score weight:')->pack(-anchor => 'e');
$fl->Label(-text => 'Output file:')->pack(-anchor => 'e');
$fl->Label(-text => 'Comparative out file:')->pack(-anchor => 'e');
$fl->Label(-text => 'Sequence to chart:')->pack(-anchor => 'e');


#Alignment file
$fr->Entry(-textvariable => \$alnfile)->pack;
#$f->Label(-text => 'pir file:')->pack;

#Secondary structure file
$fr->Entry(-textvariable => \$secfile)->pack;

#Blossum table
$fr->Entry(-textvariable => \$btablefile)->pack;

#Gap penalties
$fr->Entry(-textvariable => \$gaptogap)->pack;
$fr->Entry(-textvariable => \$gaptoseq)->pack;

#Averaging numbers
$fr->Entry(-textvariable => \$kx)->pack;
#Final averaging number
$fr->Entry(-textvariable => \$gamma)->pack;

#Weighting numbers
$fr->Entry(-textvariable => \$qa)->pack;
$fr->Entry(-textvariable => \$qb)->pack;
$fr->Entry(-textvariable => \$qc)->pack;

#Verbose messages checkbutton
#$fr->Checkbutton(-text => "Verbose",
#			    -variable => \$verbose)->pack;

#$b_smatrix = $f->Button(-text => 'Struc Matrix',
#						-command => \&smatrix
#						)->pack(-side => 'left');

#Blosum matrix selection (menu)

#Secondary structure matrix selection (?)
#Output filename
$fr->Entry(-textvariable => \$outfile)->pack;
$fr->Entry(-textvariable => \$compoutfile)->pack;
$fr->Entry(-textvariable => \$oneout)->pack;

#Go, clear, default, quit buttons

#$b_load = $f->Button(-text => 'Load',
#		  	 			-command => \&load_file
#		   				)->pack;

#$b_chart = $f->Button(-text => 'Chart',
#		   				-command => \&graphit
#
$fr->Button(-text => 'Build SS file',
			-command => \&phd2ss
			)->pack;
$b_go = $fr->Button(-text => 'Go !',
				   -command => sub {$messages = "Calculating. Please wait..."; &calculate;}
				   )->pack(-side => 'left');
$b_erase = $fl->Button(-text => '<-Clear chart',
					  -state => 'disabled',
					  -command => \&clearall
					  )->pack(-side => 'left');
$b_default = $fr->Button(-text => 'Default',
						-command => \&reset
						)->pack(-side => 'left');
$b_quit = $fr->Button(-text => 'Quit',
		  	 		 -command => sub {exit}
		   			 )->pack(-side => 'left');

$canvas1 = $mw->Scrolled("Canvas", -background => 'white')->pack(-side => 'left');
$canvas1->configure(-width => 500);
#$canvas1 = $mw->Canvas()->pack(-side => 'left');

MainLoop;

sub load_file () {
	if ($verbose) {print "Loading output file for display\n";}
	#Open file and read it in.
	open (UMAFILE, "$outfile") || die "Can't load $outfile :";
	@filetext = <UMAFILE>;
	close (UMAFILE);
	if ($verbose) {print "$outfile loaded for display. Parsing...\n";}

	#Read in the fscores and write to an array
	$end = scalar(@filetext);
	$i=0;
	#Find the start of the data
	until ($filetext[$i]=~m/^0/){
		$i++
	}
	$j=0;
	$max=0;
	$min=0;
	for ($i; $i<($end); $i++) {
		@line=split(/\t/, $filetext[$i]);
		$realvalue[$j]=$line[7];
		#Check for absolute minima and maxima
		if ($realvalue[$j]>$max) {$max = $realvalue[$j];}
		if ($realvalue[$j]<$min) {$min = $realvalue[$j];}
#		print "$realvalue[$j]\n";
		$j++;
	}
	#Convert real values to scaled values
	for ($k=0; $k<$j; $k++) {
		$svalue[$k] = ((($realvalue[$k] - $min)/($max-$min))*-200);
		$spos[$k] = ($k/($j))*500;
		#print "$spos[$k]\t$svalue[$k]\n";
		#print "More...";
		#$dummy = <STDIN>;
	}
	if ($verbose) {print "Output file loaded\n";}
	return ();
}

sub graphit () {
	#$canvas1->delete("waiting");
	if ($verbose) {print "Displaying output for $oneout sequence\n";}
	$numberofcharts++;
	if ($numberofcharts == 1) {$linecolor = "black";}
	if ($numberofcharts == 2) {$linecolor = "red";}
	if ($numberofcharts == 3) {$linecolor = "blue";}
	if ($numberofcharts == 4) {$linecolor = "green";}
	if ($numberofcharts == 5) {$linecolor = "orange";}
	if ($numberofcharts >5 ) {$linecolor = "black";}

#	for ($count=0; $count<($end-27); $count++) {
#
#		$canvas1->create('line', \$x1, \$y1 => \$x2, \$y2);
#	}
	$count =0;
	while ($spos[$count]<499.5) {
		#print "$spos[$count],$svalue[$count]\tto\t$spos[$count+1],$svalue[$count+1]\n";
		$canvas1->create('line', $spos[$count], $svalue[$count] => $spos[$count+1], $svalue[$count+1],
						-tags => "clearme",
						-fill => "$linecolor");
		$count++;
	}
	$canvas1->configure(-scrollregion => [$canvas1->bbox("all")]);
	#$canvas1->move("clearme", 0, 200);
	if ($verbose) {print "Data sent to canvas.\n";}
	$messages = "Ready.";
	$b_erase->configure(-state => 'normal');
	return ();
}

sub clearall () {
	$numberofcharts=0;
	@fsmoothed=0;
	@ssmoothed=0;
	@hsmoothed=0;
	@bsmoothed=0;
	$canvas1->delete("clearme");
	$b_erase->configure(-state => 'disabled');
	return ();
}

sub reset () {
	#Defaults
	$messages = "Ready to begin.";
	$verbose = 1;
	$alnfile = 'pks8.pir';
	$secfile = 'structure.ss';
	$btablefile = 'blosum62.dat';
	$gaptogap = 0;
	$gaptoseq = -4;
	$kx = 5;
	$gamma = 20;
	$qa = 1;
	$qb = 1;
	$qc = 1;
	$outfile = 'out.txt';
	$compoutfile = 'outcomp.txt';
	$oneout = 'AparapksA';
	$htoh = 4;
	$htoe = -15;
	$htol = -4;
	$etoe = 8;
	$etol = -4;
	$ltol = 4;
	$hton = -2;
	$eton = -2;
	$lton = -1;
	$nton = -1;
	$htod = -1;
	$etod = -1;
	$ltod = -1;
	$dtod = -1;
	$ntod = -1;
	$normalize=0;
	$useconf='yes';
	return ();
}

sub calculate () {
	$messages = "Error! Check your inputs and the command line...";
	if ($verbose) {print "****************************\nFight!\n\n";}
	#Check validity of variables and files

		#########################################
		#Verify and load sequence alignment file#
		#########################################
		open(ALNFILE, $alnfile) || die "can't open alnfilename: $!";
		@align=<ALNFILE>;
		close ALNFILE;
	 	$alnlines = @align;
 		$countstars = 0;
 		$countgts = 0;
 		$count=0;
 		while ($count < $alnlines) {
			$_=$align[$count];
			if (/>/) {
				$countgts++;
			}
			if (/\*/) {
				$countstars++;
			}
			$count++;
 		}
 		if ($countgts == $countstars) {
			if ($verbose) {print "$countgts sequences found.\n";}
 		}
 		elsif ($countgts != $countstars) {
			print "Something is wrong with $alnfilename. Not pir format?";
			exit 0;
 		}
 		if (($countgts == 0)&&($countstars==0)) {
			print "No sequences. $alnfilename is not a pir alignment?";
 			exit 0;
 		}
		#read data from pir-formatted alignment #
		$count=0;
		$linecount=0;
		@alnsize=0; $alnsize=0;
		while ($count<$countstars) {
			#get sequence's name
			$_=$align[$linecount];
			if (m/>P1/) {
				chomp;
				($junk, $sequencename[$count]) = split (';');
				if ($verbose) {print "->Found sequence name $sequencename[$count].\n";}
				$linecount=$linecount+2;
				#now get its sequence
				$_=$align[$linecount]; 	chomp;
				while (!m'\*') {
					@temp=split(//,$_);
					#print "Got a line with $temp characters.\n";
					#print @temp;
					#print "+",scalar(@temp);
					$alnsize[$count]=$alnsize[$count]+scalar(@temp);
					$sequence[$count]=[@{$sequence[$count]}, @temp];
					$linecount++;
					$_=$align[$linecount]; chomp;
				}
			}
			if ($verbose) {print "->$sequencename[$count] sequence with $alnsize[$count] characters read.\n";}
			$count++;
			$linecount++;
		}
		for ($i=0; $i<$countstars; $i++) {
			if ($alnsize[0] != $alnsize[$i]) {
				print "\n ERROR! alnsize of $sequencename[0] not equal to $sequencename[$i]\n";
				die;
			}
		}
		$alnsize=$alnsize[0];
		if ($oneout=~/output sequence/) {$oneout='';}
		if ($oneout) {
			for ($i=0; $i<$countstars; $i++) {
				if ($sequencename[$i]=~/$oneout/) { $true=1;}
			}
			if (!$true) { die "\n$oneout was not found, so can't generate data for it."; }
		}

		################################
		#Load and verify structure file#
		################################
		open (SSFILE, $secfile) || die "can't open ssfile: $!";
		@sslines = <SSFILE>;
		close SSFILE;

		#Check to see if there are confidence values and the same number of sequences
		$_= $sslines[2];
		@conftester = split(//);
		if ($conftester[0] =~ m/[0..9]/) { $useconf=1;}

		#  Read data from secondary structure file  #
		#first, read the confidence and prediction for each sequence into an array.
		for ($count=0; $count<$countstars; $count++) {
			for ($spos=0; $spos<(scalar(@sslines)); $spos++) {
				#print "Searching $ssfile for $sequencename[$count]\n";
				if ($sslines[$spos]=~m/>/) {
					#print "Found a header.\n";
					$_=$sslines[$spos];
					($empty, $testname) = split(/>/);
					chomp $testname;
					if ($sequencename[$count]=~m/$testname/) {
						if ($verbose) {print "Found secondary structure info for $testname.\n";}
						$spos++;
						$_=$sslines[$spos]; chomp;
						@temp = split(//);
						if ($useconf=~m/yes/) {
							while (scalar(@temp)) {
								$conf[$count] = [@{$conf[$count]}, @temp];
								$spos++;
								$_=$sslines[$spos];
								chomp;
								@temp = split(//);
							}
							if ($verbose) {print "Read in confidence values for $testname\n";}
							$spos++;
							$_=$sslines[$spos];
							chomp;
							@temp=split(//);

						}
						while (scalar(@temp)) {
							#if ($verbose) {print "@temp\n";}
							$structure[$count] = [@{$structure[$count]}, @temp];
							$spos++;
							$_=$sslines[$spos];
							chomp;
							@temp = split(//);
						}
						if ($verbose) {print "Read in 2ndary structure for $testname.\n";}
						$spos=scalar(@sslines);
					}
				}
			}
		}
		#Now, make a new set of arrays that places spaces where they are found in the sequence alignment
		for ($count=0; $count<$countstars; $count++) {
			$spos=0;
			for ($pos=0; $pos<$alnsize; $pos++) {
				if ($sequence[$count][$pos]=~m/-/) {
					$confws[$count][$pos] = '-';
					$structurews[$count][$pos] = '-';
				}
				else {
					$confws[$count][$pos] = $conf[$count][$spos];
					$structurews[$count][$pos] = $structure[$count][$spos];
					$spos++;
				}
			}
			if ($verbose) {print "Placed $sequencename[$count] structure predictions onto its sequence alignment.\n";}
		}

		#Validate numbers

	#Run UMA and write output file
	&uma_core;
	if ($verbose) {print "\nComplete!\n************************\n\n";}

	#Load the output file
	&load_file;

	#Graph the result
	&graphit;
	return ();
}

sub uma_core() {

	#####################################
	#  Evaluate hydrophobicity	    #
	#####################################
	#Derived from SOAP program: Jack Kyte and Russell F. Doolittle, J Mol Biol, (1982) 157:105-132
	print "Calculating hydrophobicity profiles...\n";
	for ($count=0; $count<$countstars; $count++) {
		for ($pos=0; $pos<$alnsize; $pos++) {
			$hydro[$count][$pos] = aatohy($sequence[$count][$pos]);
		}
	}

	#now smooth it
	if ($kx) {
		print "Smoothing hydrophobicity values by +/-$kx.\n";
		for ($count=0; $count<$countstars; $count++) {
			for ($pos=$kx; $pos<($alnsize-$kx); $pos++) {
				$total=0;
				for ($smpos=($pos-$kx); $smpos<=($pos+$kx); $smpos++) {
					$total = $total + $hydro[$count][$smpos];
				}
				$hsmoothed[$count][$pos] = ($total/(($kx*2)+1));
			}
		}
	}

	#######################################
	# Construct the sscore array	      #
	#######################################
	#build @ssmatrix
	@ssmatrix = (
		[$htoh, $htoe, $htol, $hton, $htod],
		[$htoe, $etoe, $etol, $eton, $etod],
		[$htol, $etol, $ltol, $lton, $ltod],
		[$hton, $eton, $lton, $nton, $ntod],
		[$htod, $etod, $ltod, $ntod, $dtod],
	);

	if ($verbose) {
		print "Using the similarity matrix:\n";
		print "\tH\tE\tL\t.\t-\n";
		print "H\t$htoh\t$htoe\t$htol\t$hton\t$htod\n";
		print "E\t$htoe\t$etoe\t$etol\t$eton\t$etod\n";
		print "L\t$htol\t$etol\t$ltol\t$lton\t$ltod\n";
		print ".\t$hton\t$eton\t$lton\t$nton\t$ntod\n";
		print "-\t$htod\t$etod\t$ltod\t$ntod\t$dtod\n\n";
	}

	$pos=0;
	if ($verbose) {print "Calculating the structure similarity scores.\n";}
	while ($pos<$alnsize) {
		#very similar to bscore generation: get the next column
		for ($i=0; $i<$countstars; $i++) {
			$scolumn[$i] = $structurews[$i][$pos];
			$ccolumn[$i] = $confws[$i][$pos];
		}
		#build sscore (if no confidence values used)
		for ($i=0; $i<$countstars; $i++) {
			$fvalue=0;
			for ($j=1; $j<$countstars; $j++) {
				$x=predtonum($scolumn[0]);
				$y=predtonum($scolumn[$j]);
				$value=$ssmatrix[$x][$y];
				if ($useconf=~m/yes/) {$value = $value*(($ccolumn[$j])/10);}
				#print $value;
				$fvalue+=$value;
			}
			$crap = $scolumn[0];
			shift @scolumn;
			push @scolumn, $crap;
			$sscore[$i][$pos] = $fvalue;
		}
		$pos++;
	}

	################################
	# Smooth the sscore  	       #
	################################
	if ($verbose) {print "Smoothing the structure similarity score by +/-$kx\n"; }
	if ($kx) {
		for ($i=0; $i<$countstars; $i++) {
			for ($pos=$kx; $pos<($alnsize-$kx); $pos++) {
				$total=0;
				for ($smpos=($pos-$kx); $smpos<=($pos+$kx); $smpos++) {
				$total = $total + $sscore[$i][$smpos];
				}
			$ssmoothed[$i][$pos] = ($total/(($kx*2)+1));
			}
		}
	}

	########################################
	# Read in blosum array (build @btable) #
	########################################
	if ($verbose) {print "Reading in similarity table...\n";}
	open (BFILE, $btablefile) || die "can't open bfile.dat:\n$!";
	@breakmeup = <BFILE>;
	close BFILE;
	for ($k=0; $k<20; $k++) {
		$_=@breakmeup[$k]; chomp;
		@yvals=split('\s');
		#print @yvals, "\n";
		$btable[$k] = [@yvals];
	}

	for ($x=0; $x<20; $x++) {
		$btable[$x][20] = $gaptoseq;
		$btable[20][$x] = $gaptoseq;
	}
	$btable[20][20] = $gaptogap;

	#check @btable
	#	for ($l=0; $l<21; $l++) {
	#		$pos=0;
	#		while ($pos<$alnsize) {
	#			print $btable[$l][$pos];
	#		$pos++;
	#		}
	#		print "\n";
	#	}

	#############################
	#calculate bscores  	    #
	#############################
	if ($verbose) {print "Calculating similarity scores...\n";}
	$pos=0;
	$count=0;
	while ($pos<$alnsize) {
		#get the next column
		for ($i=0; $i<$countstars; $i++) {
			$column[$i] = $sequence[$i][$pos];
		}
		#build @bscore
		for ($i=0; $i<$countstars; $i++) {
			$fvalue=0;
			for ($j=1; $j<$countstars; $j++) {
				#do comparison of $column[0] to $column[$j]
				$value=0;
				$x=aatonum($column[0]);
				if ($x==21) {die "aatonum doesn't work:letter not found";}
				$y=aatonum($column[$j]);
				if ($y==21) {die "aatonum doesn't work:letter not found";}
				$value = $btable[$x][$y];
				$fvalue+=$value;
				#shift the array
				$crap=$column[0];
				shift @column;
				push @column, $crap;
			}
			$bscore[$i][$pos] = $fvalue;
		}
		$pos++;
		#$pos = $alnsize;  #to kill early out of loop
	}
	#print "\n column=", @column;

	#output bscore array
	#for ($i=0; $i<$countstars; $i++) {
	#	print ">$sequencename[$i]\n";
	#	$pos=0;
	#	while ($pos<$alnsize) {
	#		print "$bscore[$i][$pos]";
	#		$pos++;
	#	}
	#	print "\n\n";
	#}

	##############################
	# calculate smoothed bscore  #
	##############################
	if ($kx) {
	 if ($verbose) {print "Smoothing similarity data by +/-$kx...\n";}
	 for ($i=0; $i<$countstars; $i++) {
	 	for ($pos=$kx; $pos<($alnsize-$kx); $pos++) {
			$total=0;
			for ($smpos=($pos-$kx); $smpos<=($pos+$kx); $smpos++) {
				#print "in loop 3";
				$total = $total + $bscore[$i][$smpos];
			}
			#print $total;
			$bsmoothed[$i][$pos] = ($total/(($kx*2)+1));
		}
	 }
	}

	###########################
	# Calculate final score   #
	###########################
	for ($count=0; $count<$countstars; $count++) {
		for ($pos=0; $pos<$alnsize; $pos++) {
			$final[$count][$pos]=($qc*$hsmoothed[$count][$pos])
								+($qa*$bsmoothed[$count][$pos])
								+($qb*$ssmoothed[$count][$pos]);
		}
	}
	#smooth the final score
	if ($gamma) {
		if ($verbose) {print "Smoothing final data by +/-$gamma.\n";}
		for ($count=0; $count<$countstars; $count++) {
		 	for ($pos=$gamma; $pos<($alnsize-$gamma); $pos++) {
				$total=0;
				for ($smpos=($pos-$gamma); $smpos<=($pos+$gamma); $smpos++) {
					$total = $total + $final[$count][$smpos];
				}
				$fsmoothed[$count][$pos] = ($total/(($gamma*2)+1));
			}
		}
	}

	############################
	# Write output files       #
	############################

	#open file
	open (TOFILE, ">$outfile") || die "Can't open $outfile: $!";

	#save comparative table, if wanted
	if ($compoutfile) {
	 if ($verbose) {print "Opening comparative table file for output...\n";}
	 open (TOFILEC, ">$compoutfile") || die "Can't open $compoutfile: $!";
	 print TOFILEC "pos\t";
	 for ($count=0; $count<$countstars; $count++) {
		print TOFILEC "$sequencename[$count]\t";
	 }
	 print TOFILEC "AVE\n";
	 for ($pos=0; $pos<$alnsize; $pos++) {
		$total=0;
		$average=0;
		print TOFILEC "$pos\t";
		for ($count=0; $count<$countstars; $count++) {
			print TOFILEC "$fsmoothed[$count][$pos]\t";
			$total+=$fsmoothed[$count][$pos];
		}
		$average=$total/$countstars;
		print TOFILEC "$average\n";
	 }
	 close (TOFILEC);
	 if ($verbose) {print "Comparative table written.\n";}
	}



	# Output settings to start of file
	print TOFILE "\nAlignment file =\t$alnfile";
	print TOFILE "\nStructure file =\t$secfile";
	print TOFILE "\nOutput file =\t$outfile";
	print TOFILE "\nComparative file =\t$compoutfile";
	print TOFILE "\n";
	print TOFILE "\nNumber of sequences =\t$countstars";
	print TOFILE "\nAlignment size =\t$alnsize";
	print TOFILE "\n";
	print TOFILE "\nGap penalty =\t$gaptoseq";
	print TOFILE "\nGap similarity =\t$gaptogap";
	print TOFILE "\nSubscore smoothing number (Kx)=\t$kx";
	print TOFILE "\nFinal smoothing number (gamma)=\t$gamma";
	print TOFILE "\nSimilarity score weight (Qa)=\t$qa";
	print TOFILE "\nStructure score weight (Qb)=\t$qb";
	print TOFILE "\nHydrophobicity score weight (Qc)=\t$qc";
	print TOFILE "\n";
	print TOFILE "\nSimilarity table =\t$btablefile";
	print TOFILE "\nStructure matrix:\n";
	print TOFILE "\tH\tE\tL\t.\t-\n";
	print TOFILE "H\t$htoh\t$htoe\t$htol\t$hton\t$htod\n";
	print TOFILE "E\t$htoe\t$etoe\t$etol\t$eton\t$etod\n";
	print TOFILE "L\t$htol\t$etol\t$ltol\t$lton\t$ltod\n";
	print TOFILE ".\t$hton\t$eton\t$lton\t$nton\t$ntod\n";
	print TOFILE "-\t$htod\t$etod\t$ltod\t$ntod\t$dtod\n\n";



	#print full data for one specified sequence
	if ($oneout) {
	 if ($verbose) {print "Storing data for one sequence: $oneout\n";}
	 for ($count=0; $count<$countstars; $count++) {
		$aanum=0;
		if ($oneout=~m/$sequencename[$count]/) {
			print TOFILE "$sequencename[$count]\n";
			print TOFILE "ALNPOS\tAANUM\tAA\tPRED\tHYDRO\tSIM\tSTRUCT\tFINAL\t";
			if ($normalize) {Print TOFILE "NORM\n"; }
			else {print TOFILE "\n";}
			for ($pos=0; $pos<$alnsize; $pos++) {
				print TOFILE "$pos\t";
				if ($sequence[$count][$pos]=~/\w/) {
					$aanum++;
					print TOFILE "$aanum\t";
				}
				else {print TOFILE "-\t";}
				print TOFILE "$sequence[$count][$pos]\t";
				print TOFILE "$structurews[$count][$pos] $confws[$count][$pos]\t";
				if ($kx) {print TOFILE "$hsmoothed[$count][$pos]\t";}
				else {print TOFILE "$hydro[$count][$pos]\t"; }
				if ($kx) {print TOFILE "$bsmoothed[$count][$pos]\t";}
				else {print TOFILE "$bscore[$count][$pos]\t";}
				if ($kx) {print TOFILE "$ssmoothed[$count][$pos]\t";}
				else {print TOFILE "$sscore[$count][$pos]\t";}
				if ($gamma) {print TOFILE "$fsmoothed[$count][$pos]\t";}
				else {print TOFILE "$final[$count][$pos]\n";}
				if ($normalize) {print TOFILE "$fnorm[$count][$pos]\n";}
				else {print TOFILE "\n";}
			}
		}
	 }
	}

	#If one isn't specified, print them all out
	if (!$oneout) {
	 if ($verbose) {print "Storing data for all sequences.\n";}
	 for ($count=0; $count<$countstars; $count++) {
		$aanum=0;
		print TOFILE "$sequencename[$count]\n";
		print TOFILE "ALNPOS\tAANUM\tAA\tPRED\tHYDRO\tSIM\tSTRUCT\tFINAL\t";
		if ($normalize) {print TOFILE "NORM\n";}
		else {print TOFILE "\n";}
		for ($pos=0; $pos<$alnsize; $pos++) {
			print TOFILE "$pos\t";
			if ($sequence[$count][$pos]=~/\w/) {
				$aanum++;
				print TOFILE "$aanum\t";
			}
			else {print TOFILE "-\t";}
			print TOFILE "$sequence[$count][$pos]\t";
			print TOFILE "$structurews[$count][$pos] $confws[$count][$pos]\t";
			if ($kx) {print TOFILE "$hsmoothed[$count][$pos]\t";}
			else {print TOFILE "$hydro[$count][$pos]\t"; }
			if ($kx) {print TOFILE "$bsmoothed[$count][$pos]\t";}
			else {print TOFILE "$bscore[$count][$pos]\t";}
			if ($kx) {print TOFILE "$ssmoothed[$count][$pos]\t";}
			else {print TOFILE "$sscore[$count][$pos]\t";}
			if ($gamma) {print TOFILE "$fsmoothed[$count][$pos]\t";}
			else {print TOFILE "$final[$count][$pos]\n";}
			if ($normalize) {print TOFILE "$fnorm[$count][$pos]\n";}
			else {print TOFILE "\n";}
		}
		print TOFILE "\n";
	 }
	}
	close (TOFILE);
	if ($verbose) {print "Data stored to $outfile.\n";}



	return ();
}

sub aatonum {
	$_ = @_[0];
	#print "Looking for $aa1\n";
	$aatonumval=21;
	#change aa letter to number
	if (m/-/) {$aatonumval = 20;}
	if (m/A/) {$aatonumval = 0;} #there must be a better way to do this
	if (m/C/) {$aatonumval = 1;}
	if (m/D/) {$aatonumval = 2;}
	if (m/E/) {$aatonumval = 3;}
	if (m/F/) {$aatonumval = 4;}
	if (m/G/) {$aatonumval = 5;}
	if (m/H/) {$aatonumval = 6;}
	if (m/I/) {$aatonumval = 7;}
	if (m/K/) {$aatonumval = 8;}
	if (m/L/) {$aatonumval = 9;}
	if (m/M/) {$aatonumval = 10;}
	if (m/N/) {$aatonumval = 11;}
	if (m/P/) {$aatonumval = 12;}
	if (m/Q/) {$aatonumval = 13;}
	if (m/R/) {$aatonumval = 14;}
	if (m/S/) {$aatonumval = 15;}
	if (m/T/) {$aatonumval = 16;}
	if (m/V/) {$aatonumval = 17;}
	if (m/W/) {$aatonumval = 18;}
	if (m/Y/) {$aatonumval = 19;}
	#print "$_ is number $aatonumval\n";
	if ($aatonumval==21) {die "dead in aatonum.";}
	return $aatonumval;
}

sub predtonum {
	$_ = @_[0];
	$predtonumval=21;
	if (m/H/) {$predtonumval=0};
	if (m/E/) {$predtonumval=1};
	if (m/L/) {$predtonumval=2};
	if (m/\./) {$predtonumval=3};
	if (m/-/) {$predtonumval=4};
	if ($predtonumval==21) {die "unable to identify secondary structure prediction: \"$_\" ";}
	return $predtonumval;
}

sub aatohy {
	$_ = @_[0];
	#print "Looking for $aa1\n";
	$aatohyval=21;
	#change aa letter to number
	if (m/-/) {$aatohyval = 0;}
	if (m/A/) {$aatohyval = 1.8;} #there must be a better way to do this
	if (m/C/) {$aatohyval = 2.5;}
	if (m/D/) {$aatohyval = -3.5;}
	if (m/E/) {$aatohyval = -3.5;}
	if (m/F/) {$aatohyval = 2.8;}
	if (m/G/) {$aatohyval = -0.4;}
	if (m/H/) {$aatohyval = -3.2;}
	if (m/I/) {$aatohyval = 4.5;}
	if (m/K/) {$aatohyval = -3.9;}
	if (m/L/) {$aatohyval = 3.8;}
	if (m/M/) {$aatohyval = 1.9;}
	if (m/N/) {$aatohyval = -3.5;}
	if (m/P/) {$aatohyval = -1.6;}
	if (m/Q/) {$aatohyval = -3.5;}
	if (m/R/) {$aatohyval = -4.5;}
	if (m/S/) {$aatohyval = -0.8;}
	if (m/T/) {$aatohyval = -0.7;}
	if (m/V/) {$aatohyval = 4.2;}
	if (m/W/) {$aatohyval = -0.9;}
	if (m/Y/) {$aatohyval = -1.3;}
	#print "$_ is number $aatohyval\n";
	if ($aatohyval==21) {die "dead in aatohy. Can't identify aa:$_";}
	return ($aatohyval*10);
}

sub phd2ss() {

	# Open or create builder.cfg
	open (BUILDER, ">builder.cfg");

	# Create a list of all .htm or .html files in a directory
	@htmfiles=glob('*.htm');
	#$count=0;
	#foreach (@htmfiles) {
	#	print "$_\n";
	#	$count++;
	#}
	$count=scalar(@htmfiles);
	print "$count files found.\n";


	# Read in each htm(l) file and convert (crudely) to plain text, store in memory
	foreach (@htmfiles) {
		# Read the name from the html file
		$oldfile=$_;
		#print "Started process for $oldfile\n";
		open (HFILE, "$oldfile") || die "No $oldfile found!\n";
		@htmtext=<HFILE>;
		close (HFILE);
		#print "Read data from $oldfile\n";

		#Find the name of the sequence
		OUTER: foreach (@htmtext) {
			#print "In OUTER\n";
			if (m/description=/) {
				($crap, $name) = split(/description=/, $_);
				chomp $name;
				print "Found name $name\n";
				last OUTER;
			}
		}
		#print "Out of OUTER loop.\n";
		$newname = "$name\.tmp";

		print "Converting $oldfile to $newname.....";
		open (TMPFILE, ">>$newname") || die "Can't open $newname\n";
		foreach (@htmtext) {
			s/<p>/\n/g;
			s/<P>/\n/g;
			s/<[-\w\s="#\/]+>//g;
		}
		foreach (@htmtext) {print TMPFILE "$_\n";}
		close TMPFILE;
		print "Converted!\n";

		#Write the name and filename line to builder.cfg
		print BUILDER "$name prediction=${name}.tmp\n";
	}
	print BUILDER "\noutput file=$secfile\noverwrite=yes\n";
	close (BUILDER);
	#print "builder.cfg written\n";



	print "Running builder...\n";


	#Open the input file
	open(INPUT, "builder.cfg") || die "Can't open builder.cfg: $!";
	@in=<INPUT>;
	close INPUT;

	#Read input file data
	$i=0;
	foreach (@in) {
		chomp;
		if (m/prediction=/) {
			($sequencename[$numseq], $filename[$numseq]) = split(/ prediction=/);
			$numseq++;
		}
		if (m/output file/) {
			($crap, $ssfilename) = split(/=/);
		}
		if (m/overwrite/) {
			($crap, $overwrite) = split(/=/);
		}
	}

	#print "Number of sequences is $numseq\n";

	while ($i<$numseq) {
		open(DATAIN, "$filename[$i]" || die "Can't open $filename[$i]");
		#print "Opened $filename[$i]\n";
		@data=<DATAIN>;
		close DATAIN;
		$j=@data;
		#print $j;
		for ($k=0; $k<$j; $k++) {
			#print "Got in\n";
			#print $data[$k];
			if ($data[$k]=~m/PHD results \(normal\)/) {
				#print "Found PHD results!\n";
				while (!($data[$k]=~m/END of results /)) {
					$k++;
					if ($k>1000000) {print "\nWarning: PHD file may be incomplete!!\n";
							 die; }
					chomp $data[$k];
					if ($data[$k]=~/Rel_sec/) {
						#print "Found some confidence values for $sequencename[$i]\n";
						($empty, $tempconf) = split(/Rel_sec    /, $data[$k]);
						@temp=split(//,$tempconf);
						$conf[$i]=[@{$conf[$i]}, @temp];
					}
					if ($data[$k]=~/SUB_sec/) {
						($empty, $tempstr) = split(/SUB_sec    /, $data[$k]);
						@temp=split(//,$tempstr);
						$str[$i]=[@{$str[$i]}, @temp];
					}
				}
			}
		}
		$i++;
		close DATAIN;
	}
	#print "Finished loading data\n";

	#output

	if ($overwrite=~/no/) {open (TOFILE, ">>$ssfilename") || die "Can't open output file: $!";}
	elsif ($overwrite=~/yes/) {open (TOFILE, ">$ssfilename") || die "Can't open output file: $!";}
	#print "opened for output\n";

	for ($count=0; $count<$numseq; $count++) {
		print "Writing predictions for $sequencename[$count]\n";
		#print scalar(@{$conf[$count]});
		print TOFILE ">$sequencename[$count]\n";
		for ($pos=0; $pos<(scalar(@{$conf[$count]})); $pos++) {
			print TOFILE $conf[$count][$pos];
		}
		print TOFILE "\n\n";
		for ($pos=0; $pos<(scalar(@{$str[$count]})); $pos++) {
			print TOFILE $str[$count][$pos];
		}
		print TOFILE "\n\n";
	}

	close TOFILE;


	print "Cleaning up...\n";
	#DOS
	system ("del *.tmp");
	system ("del builder.cfg");

	#UNIX
	system ("rm *.tmp");
	system ("rm builder.cfg");

	print "Done.\n";
	$messages = "Built the SS file $secfile";
}
