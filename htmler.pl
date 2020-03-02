#########################
# some dumb name here   #
#########################
#Dan Udwary		 #
#dwu1@jhunix.hcf.jhu.edu #
#Johns Hopkins University#
#Chemistry Dept 	 #
##########################
# Takes the ss output file from builder and overlays it onto 
# the multiple sequence alignment file, outputting in pretty html.
# Will probably be integrated into builder.pl at some point.

#Read in files
##################################
print "Name of alignment file? (pir format)  ";
$alnfilename=<STDIN>; chomp $alnfilename;
open(ALNFILE, $alnfilename) || die "can't open alnfilename: $!";
@align=<ALNFILE>;
close ALNFILE;

print "Name of secondary structure file?  ";
$ssfile=<STDIN>; chomp $ssfile;
open (SSFILE, $ssfile) || die "can't open ssfile: $!";
@sslines = <SSFILE>;
close SSFILE;


$verbose=0;
###################################################
#Get sequence and structure data into arrays      #
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


#print "\n alnsize=$alnsize[0] \n";
for ($i=0; $i<$countstars; $i++) {
	if ($alnsize[0] != $alnsize[$i]) {
		print "\n ERROR! alnsize of $sequencename[0] not equal to $sequencename[$i]\n";
		die;
	}
}
$alnsize=$alnsize[0];

$useconf='yes';
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



#Open and prep an output file
#####################################
print "Name of output file?  ";
$outfilename=<STDIN>; chomp $outfilename;
open (TOFILE, ">$outfilename") || die "Can't open output file!: $!";

#Add the header and css to the html file
print TOFILE "<STYLE type=text/css>\n";
print TOFILE "FONT.helix {BACKGROUND-COLOR: FFA07A}\n";
print TOFILE "FONT.sheet {BACKGROUND-COLOR: ADD8E6}\n";
print TOFILE "FONT.loop {BACKGROUND-COLOR: C0C0C0}\n";
print TOFILE "FONT.A {COLOR: blue}\n";
print TOFILE "FONT.C {COLOR: cyan}\n";
print TOFILE "FONT.D {COLOR: purple}\n";
print TOFILE "FONT.E {COLOR: purple}\n";
print TOFILE "FONT.F {COLOR: blue}\n";
print TOFILE "FONT.G {COLOR: brown}\n";
print TOFILE "FONT.H {COLOR: cyan}\n";
print TOFILE "FONT.I {COLOR: blue}\n";
print TOFILE "FONT.K {COLOR: red}\n";
print TOFILE "FONT.L {COLOR: blue}\n";
print TOFILE "FONT.M {COLOR: blue}\n";
print TOFILE "FONT.N {COLOR: green}\n";
print TOFILE "FONT.P {COLOR: yellow}\n";
print TOFILE "FONT.Q {COLOR: green}\n";
print TOFILE "FONT.R {COLOR: red}\n";
print TOFILE "FONT.S {COLOR: green}\n";
print TOFILE "FONT.T {COLOR: green}\n";
print TOFILE "FONT.V {COLOR: blue}\n";
print TOFILE "FONT.W {COLOR: blue}\n";
print TOFILE "FONT.Y {COLOR: green}\n";
print TOFILE "</STYLE>\n";
print TOFILE "Generated by some damn program by Dan Udwary. <p>\n";
print TOFILE "<PRE>\n";
print TOFILE "<FONT class=helix> helix </FONT>\n";
print TOFILE "<FONT class=sheet> sheet </FONT>\n";
print TOFILE "<FONT class=loop> loop </FONT>\n";
print TOFILE "\n\n";

for ($count=0; $count<$countstars; $count++) {
	$num=$count+1;
	print TOFILE "$num . . .\t$sequencename[$count]\n";
}
print TOFILE "\n";


#for ($pos=0; $pos<$alnsize; $pos++) {
#	print "$structurews[0][$pos]";
#}



#Print html data to the output file
#######################################
$columnsize=61;
$pos=0;
until ($pos>$alnsize) {
	$check+=($columnsize-1);
	for ($count=0; $count<$countstars; $count++) {
		$num=$count+1;
		print TOFILE "$num\t";		
		$pos++;
		until ($pos>$check) {
			$pos--;
			if (!($sequence[$count][$pos]=~/-/)) {print TOFILE "<FONT class=$sequence[$count][$pos]>";}
			if ($structurews[$count][$pos]=~/H/) {print TOFILE "<FONT class=helix>";}
			if ($structurews[$count][$pos]=~/E/) {print TOFILE "<FONT class=sheet>";}
			if ($structurews[$count][$pos]=~/L/) {print TOFILE "<FONT class=loop>";}
			print TOFILE $sequence[$count][$pos];
			if (!($sequence[$count][$pos]=~/-/)) {print TOFILE "</FONT>";}
			if (!($structurews[$count][$pos]=~/\./)) {print TOFILE "</FONT>";}
			$pos+=2;
		}
		#$pos=$pos-1;
		$pos=$pos-($columnsize);
		print TOFILE "\n";
	}
	$pos=$pos+($columnsize-1);
	print TOFILE "<p>\n\n\t$pos\n";
}


#Close file
###############################
close (TOFILE);
print "Data stored to output file specified.\n";
