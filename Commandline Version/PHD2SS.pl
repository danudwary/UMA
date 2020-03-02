#################################
# PHD2SS.pl 	   	            #
#################################
# Dan Udwary			        #
# c/o Prof. Craig Townsend      #
# ctownsend@jhu.edu             #
# Chemistry Dept, Remsen Hall	#
# Johns Hopkins University	    #
# 3400 N Charles St		        #
# Baltimore, MD 21218		    #
#################################
#


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
		if (m/single protein sequence description/) {
			($crap, $name) = split(/=/, $_);
			chomp $name;
			#print "Found name $name\n";
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
print BUILDER "\noutput file=structure.ss\noverwrite=yes\n";
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
		($crap, $outfile) = split(/=/);
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

if ($overwrite=~/no/) {open (TOFILE, ">>$outfile") || die "Can't open output file: $!";}
elsif ($overwrite=~/yes/) {open (TOFILE, ">$outfile") || die "Can't open output file: $!";}
#print "opened $outfile for output\n";

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

