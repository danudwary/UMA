##########################
#	UMA2.PL	v1.7	 #
##########################
#Dan Udwary		 #
#dwu1@jhunix.hcf.jhu.edu #
#Johns Hopkins University#
#Chemistry Dept 	 #
##########################

#########################################################
#get filenames and values from input file if available  #
#########################################################
open (VALUES, "input.txt") || print "No input.txt file found\n";
@infilelines=<VALUES>;
close VALUES;
foreach (@infilelines) {
	chomp;
	if (m/=/) {
		#print "found a =\n";
		($_, $property) = split(/=/);
		if (m/gap penalty/) {$gappenalty = $property;}
		if (m/gap similarity/) {$gapgap = $property;}
		if (m/input file/) {$alnfilename = $property;}
		if (m/output file/) {$outfile = $property;}
		if (m/secondary structure file/) {$ssfile = $property;}
		if (m/output one sequence/) {$oneout = $property}
		if (m/ss confidence values/) {$useconf = $property;}
		if (m/bscore smoothing number/) {$smnum = $property;}
		if (m/sscore smoothing number/) {$ssmnum = $property;}
		if (m/hydrophobicity smoothing number/) {$hsmnum = $property;}
		if (m/similarity weighting file/) {$btablefile = $property;}
		if (m/helix to helix/) {$htoh = $property;}
		if (m/helix to sheet/) {$htoe = $property;}
		if (m/helix to loop/) {$htol = $property;}
		if (m/sheet to sheet/) {$etoe = $property;}
		if (m/sheet to loop/) {$etol = $property;}
		if (m/loop to loop/) {$ltol = $property;}
		if (m/helix to none/) {$hton = $property;}
		if (m/sheet to none/) {$eton = $property;}
		if (m/loop to none/) {$lton = $property;}
		if (m/none to none/) {$nton = $property;}
		if (m/helix to dash/) {$htod = $property;}
		if (m/sheet to dash/) {$etod = $property;}
		if (m/loop to dash/) {$ltod = $property;}
		if (m/dash to dash/) {$dtod = $property;}
		if (m/none to dash/) {$ntod = $property;}
		if ((m/verbose/) && ($property=~m/yes/)) {$verbose = 1}
		if (m/final smoothing number/) {$fsmnum = $property;}
		if (m/bscore weighting/) {$bweight=$property;}
		if (m/sscore weighting/) {$sweight=$property;}
		if (m/hscore weighting/) {$hweight=$property;}
		if ((m/normalize/) && ($property =~ m/yes/)) {$normalize=1;}
		if ((m/remove gaps/) && ($property =~ m/yes/)) {$nogaps=1;}
		if ((m/remove negatives/) && ($property =~ m/[yY]es/)) {$nonegs=1; }
		if (m/comparative table/) {$comptablename=$property;}
	}
}


###################################
#open clustal and structure files #
###################################
#open alignment file
if (!$alnfilename) {print "Name of alignment file? (must be pir format)  ";
 $alnfilename=<STDIN>;
 chomp $alnfilename;
 #$alnfilename='aln1.pir';
}
open(ALNFILE, $alnfilename) || die "can't open alnfilename: $!";
@align=<ALNFILE>;
close ALNFILE;
#print @align;

#open secondary structure file
if (!$ssfile) {
 print "Name of secondary structure file?  ";
 $ssfile=<STDIN>;
 chomp $ssfile;
}
open (SSFILE, $ssfile) || die "can't open ssfile: $!";
@sslines = <SSFILE>;
close SSFILE;


###################################################
#verify the pir file, and get number of sequences #
###################################################
 $alnlines = @align;
 #print "\n number of lines in file is $alnlines \n";
 $countstars = 0;
 $countgts = 0;
 $count=0;
 while ($count < $alnlines) {
	#print $count;
	$_=$align[$count];
	if (/>/) {
		$countgts++; 
	}
	if (/\*/) {
		$countstars++; 
	}
	$count++;
 }
 #print "\n$countgts > found.\n";
 #print "$countstars \*s found.\n";
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

#########################################
#read data from pir-formatted alignment #
#########################################
$count=0;
$linecount=0;
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

#send the sequences out as fasta 
#for ($i=0; $i<$countstars; $i++) {
#	print ">$sequencename[$i]\n";
#	$aa=0;
#	while ($aa<$alnsize) {
#		print "$sequence[$i][$aa]";
#		$aa++;
#	}
#	print "\n\n";
#}

#print "\n alnsize=$alnsize[0] \n";
for ($i=0; $i<$countstars; $i++) {
	if ($alnsize[0] != $alnsize[$i]) {
		print "\n ERROR! alnsize of $sequencename[0] not equal to $sequencename[$i]\n";
		die;
	}
}
$alnsize=$alnsize[0];

#if you're outputting data for only one sequence, check to make sure the sequence is there
if ($oneout) {
	for ($i=0; $i<$countstars; $i++) {
		if ($sequencename[$i]=~/$oneout/) { $true=1;}
	}
	if (!$true) { die "\n$oneout was not found, so can't generate data for it."; }
}


#####################################
#  Evaluate hydrophobicity	    #
#####################################
#Derived from SOAP program: Jack Kyte and Russell F. Doolittle, J Mol Biol, (1982) 157:105-132
if (!$hsmnum) {
 print "Enter the hydrophobicity smoothing number (Enter to skip):  ";
 $hsmnum = <STDIN>;
 chomp $hsmnum;
}
print "Calculating hydrophobicity profiles...\n";
for ($count=0; $count<$countstars; $count++) {
	for ($pos=0; $pos<$alnsize; $pos++) {
		$hydro[$count][$pos] = aatohy($sequence[$count][$pos]);
	}
}

#now smooth it
if ($hsmnum) {
	print "Smoothing hydrophobicity values by +/-$hsmnum.\n";
	for ($count=0; $count<$countstars; $count++) {
		for ($pos=$hsmnum; $pos<($alnsize-$hsmnum); $pos++) {
			$total=0;
			for ($smpos=($pos-$hsmnum); $smpos<=($pos+$hsmnum); $smpos++) {
				$total = $total + $hydro[$count][$smpos];
			}
			$hsmoothed[$count][$pos] = ($total/(($hsmnum*2)+1));
		}
	}
}


#############################################
#  Read data from secondary structure file  #
#############################################
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
				#if ($verbose) {print "Found secondary structure info for $testname.\n";}
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
}
if ($verbose) {print "Placed $sequencename[$count] structure predictions onto its sequence alignment.\n";}

#check confidence and prediction values
#for ($pos=0; $pos<$alnsize; $pos++) {
#	for ($count=0; $count<$countstars; $count++) {	
#		print "$sequence[$count][$pos] => $structurews[$count][$pos]$confws[$count][$pos]\t";
#	}
#	print "\n";
#}


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
if (!ssmnum) {
 print "Enter the structure smoothing number (Enter to skip):  ";
 $ssmnum = <STDIN>;
 chomp $ssmnum;
}
if ($verbose) {print "Smoothing the structure similarity score by +/-$ssmnum\n"; }
if ($ssmnum) {
	for ($i=0; $i<$countstars; $i++) {
		for ($pos=$ssmnum; $pos<($alnsize-$ssmnum); $pos++) {
			$total=0;
			for ($smpos=($pos-$ssmnum); $smpos<=($pos+$ssmnum); $smpos++) {
			$total = $total + $sscore[$i][$smpos];
			}
		$ssmoothed[$i][$pos] = ($total/(($ssmnum*2)+1));
		}
	}	
}

########################################
# Read in blosum array (build @btable) #
########################################
if (!$btablefile) {
 print "Name of blossum/similarity table?  ";
 $btablefile = <STDIN>; chomp $btablefile;
}
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
	$btable[$x][20] = $gappenalty;
	$btable[20][$x] = $gappenalty;
}
$btable[20][20] = $gapgap;

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
if (!$smnum) {
 print "Enter the similarity smoothing number (Enter to skip):  ";
 $smnum = <STDIN>; chomp $smnum;
}
if ($smnum) {
 if ($verbose) {print "Smoothing similarity data by +/-$smnum...\n";}
 for ($i=0; $i<$countstars; $i++) {
 	for ($pos=$smnum; $pos<($alnsize-$smnum); $pos++) {
		$total=0;
		for ($smpos=($pos-$smnum); $smpos<=($pos+$smnum); $smpos++) {
			#print "in loop 3";
			$total = $total + $bscore[$i][$smpos];
		}
		#print $total;
		$bsmoothed[$i][$pos] = ($total/(($smnum*2)+1));
	}
 }
}

###########################
# Calculate final score   #
###########################
for ($count=0; $count<$countstars; $count++) {
	for ($pos=0; $pos<$alnsize; $pos++) {
		$sum=0;
		if ($hsmnum) {$sum+=($hweight*$hsmoothed[$count][$pos]);}
		else {$sum+=($hweight*$hydro[$count][$pos]);}
		if ($smnum) {$sum+=($bweight*$bsmoothed[$count][$pos]); }
		else {$sum+=($bweight*$bscore[$count][$pos]);}
		if ($ssmnum) {$sum+=($sweight*$ssmoothed[$count][$pos]); }
		else {$sum+=($sweight*$sscore[$count][$pos]);}
		$final[$count][$pos] = $sum;
	}
}

#Remove negatives if called for
if ($nonegs) {
 print "Removing negative values.\n";
 for ($count=0; $count<$countstars; $count++) {
	for ($pos=0; $pos<$alnsize; $pos++) {
		if ($final[$count][$pos] < 0) {
			$final[$count][$pos] = 0;
		}
	}
 }
}


#smooth the final score
if (!$fsmnum) {
 print "Enter the final score smoothing number (Enter to skip):  ";
 $fsmnum = <STDIN>;
 chomp $fsmnum;
}
if ($fsmnum) {
	if ($verbose) {print "Smoothing final data by +/-$fsmnum.\n";}
	for ($count=0; $count<$countstars; $count++) {
	 	for ($pos=$fsmnum; $pos<($alnsize-$fsmnum); $pos++) {
			$total=0;
			for ($smpos=($pos-$fsmnum); $smpos<=($pos+$fsmnum); $smpos++) {
				$total = $total + $final[$count][$smpos];
			}
			$fsmoothed[$count][$pos] = ($total/(($fsmnum*2)+1));
		}
	}
}



################################
#  Normalize final data        #
################################

#First, find the highs and lows
if ($normalize) {
 print "Normalizing data.";
 for ($count=0; $count<$countstars; $count++) {
	print " .";
	#What's a reasonable number to start the comparison?
	$high=$countstars/2;
	$low=$countstars/2;
	for ($pos=0; $pos<$alnsize; $pos++) {
		if ($fsmoothed[$count][$pos] > $high) {
			$high = $fsmoothed[$count][$pos];
		}
		if ($fsmoothed[$count][$pos] < $low) {
			$low = $fsmoothed[$count][$pos];
		}
	}
	#Normalize - sequence specific normalize, not comparative
	for ($pos=0; $pos<$alnsize; $pos++) {
		$fnorm[$count][$pos] = ($fsmoothed[$count][$pos] - $low)/($high - $low);
	}
 }
}
print "\n";

##############################
# Remove gaps in final data  #(unimplemented)
##############################
if ($nogaps) {
 $newcount=0;
 $newpos=0;
 for ($count=0; $count<$countstars; $count++) {
	for ($pos=0; $pos<$alnsize; $pos++) {
		if ($sequence[$count][$pos] =~ m/-/) {
		}
	}
 }
}



#################################
#output data to file		#
#################################

#open file
if (!$outfile) {
 print "Name of the output file? (Enter=out.txt) ";
 $outfile = <STDIN>; chomp $outfile;
}
if (!$outfile) {$outfile = "out.txt"};
open (TOFILE, ">>$outfile") || die "Can't open $outfile: $!";

#save comparative table, if wanted
if ($comptablename) {
 if ($verbose) {print "Opening comparative table file for output...\n";}
 open (TOFILEC, ">>$comptablename") || die "Can't open $comptablename: $!";
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
print TOFILE "\nAlignment file =\t$alnfilename";
print TOFILE "\nStructure file =\t$ssfile";
print TOFILE "\nOutput file =\t$outfile";
print TOFILE "\nComparative file =\t$comptablename";
print TOFILE "\n";
print TOFILE "\nNumber of sequences =\t$countstars";
print TOFILE "\nGap penalty =\t$gappenalty";
print TOFILE "\nGap similarity =\t$gapgap";
print TOFILE "\nAlignment size =\t$alnsize";
print TOFILE "\nSimilarity smoothing number =\t$smnum";
print TOFILE "\nStructure smoothing number =\t$ssmnum";
print TOFILE "\nHydrophobivity smoothing number =\t$hsmnum";
print TOFILE "\nFinal data smoothing number =\t$fsmnum";
print TOFILE "\nSimilarity score weight =\t$bweight";
print TOFILE "\nStructure score weight =\t$sweight";
print TOFILE "\nHydrophobicity score weight =\t$hweight";
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
 for ($count=0; $count<$countstars; $count++) {
	$aanum=0;
	if ($oneout=~/$sequencename[$count]/) {
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
			if ($hsmnum) {print TOFILE "$hsmoothed[$count][$pos]\t";}
			else {print TOFILE "$hydro[$count][$pos]\t"; }
			if ($smnum) {print TOFILE "$bsmoothed[$count][$pos]\t";}
			else {print TOFILE "$bscore[$count][$pos]\t";}
			if ($ssmnum) {print TOFILE "$ssmoothed[$count][$pos]\t";}
			else {print TOFILE "$sscore[$count][$pos]\t";}
			if ($fsmnum) {print TOFILE "$fsmoothed[$count][$pos]\t";}
			else {print TOFILE "$final[$count][$pos]\n";}
			if ($normalize) {print TOFILE "$fnorm[$count][$pos]\n";}
			else {print TOFILE "\n";}
		}
	}
 }
}

#If one isn't specified, print them all out
if (!$oneout) {
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
		if ($hsmnum) {print TOFILE "$hsmoothed[$count][$pos]\t";}
		else {print TOFILE "$hydro[$count][$pos]\t"; }
		if ($smnum) {print TOFILE "$bsmoothed[$count][$pos]\t";}
		else {print TOFILE "$bscore[$count][$pos]\t";}
		if ($ssmnum) {print TOFILE "$ssmoothed[$count][$pos]\t";}
		else {print TOFILE "$sscore[$count][$pos]\t";}
		if ($fsmnum) {print TOFILE "$fsmoothed[$count][$pos]\t";}
		else {print TOFILE "$final[$count][$pos]\n";}
		if ($normalize) {print TOFILE "$fnorm[$count][$pos]\n";}
		else {print TOFILE "\n";}
	}
	print TOFILE "\n";
 }
}



close (TOFILE);
if ($verbose) {print "Data stored to $outfile.\n";}



#################################
#  subroutines			#
#################################
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
	#$predtonumval=21;
	if (m/H/) {$predtonumval=0};
	if (m/E/) {$predtonumval=1};
	if (m/L/) {$predtonumval=2};
	if (m/\./) {$predtonumval=3};
	if (m/-/) {$predtonumval=4};
	#if ($predtonumval==21) {die "unable to identify secondary structure prediction: \"$_\" ";}
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


