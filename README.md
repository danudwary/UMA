# UMA
Software for detection of protein domains from sequence alone. 

THIS SOFTWARE IS NO LONGER MAINTAINED. Provided for historical purposes only!
This work was created and published in 2002, and there are almost certainly better ways to identify protein domains, now.


Original 2002 readme follows:
----------
UMA is a Perl script which utilizes a multiple sequence alignment and secondary structure assignments to predict the locations of "linker' regions between domains in multidomain proteins. A thorough description of the principles and validation of this algorithm can be found in:
Journal of Molecular Biology (2002) 323, 585-598.
This article should be referenced when reporting any predictions made by this program.


These instructions refer to the Perl/Tk implementation of UMA (version 1.8). An older command line version (1.7) is also included in the folder "Commandline version", which may be necessary if your OS does not have a Perl/Tk interpreter (ie MacOS 9). Instructions for the command line version of UMA are included in that directory. Both versions should produce identical output when given the same input.


Please be aware that this is the first release version of UMA. It almost certainly contains several bugs and has not been exhaustively tested. Your feedback can help us to improve the program. Direct all suggestions, bug reports, etc to the address above.



FILES
----------------------------------------------------------------

The UMA package should contain the following files:
readme.txt	This file.
uma18.pl 	The UMA PerlTk implementation.
history.txt	A log of changes made to the UMA program
LICENSE.txt	The licensing and copyright notice for UMA
blosum30.dat	BLOSUM tables readable by UMA.
blosum45.dat
blosum62.dat	
blosum80.dat
htmler.pl	Overlays structure prediction onto a sequence alignment, creating a
		color-coded html file. This often helps in interpreting anomalous UMA
		results.
LICENSE.txt	License and copyright notice.

commandline version/UMA2v17.pl		The command line version of UMA. 
commandline version/input.txt		A configuration file for UMA's variables
commandline version/uma17-readme.txt	Instructions for the commandline version of UMA
commandline version/PHD2SS.pl		A script for extracting data from PHDsec predictions 
					and building a structure.ss file

example/	This directory contains files useful for a test of the program. 


In addition, you will need several pieces of data before you begin an analysis. 

0) You need to install a Perl interpreter with the Tk module, since the programs are Perl scripts that utilize the Tk extensions to Perl. If you are using a UNIX X-windows based machine this is probably already enabled by default. If not talk to your system administrator. If you are using a DOS or Windows machine we recommend the ActivePerl package available from ActiveState (www.activestate.com). This is a free download and is very easy to install. A PerlTk interpreter is not, as far as we know, available for classic MacOS (9 or lower). In this case you should use the command line version of UMA with MacPerl (www.MacPerl.com).

1) A sequence alignment in .pir format. We have used ClustalX 1.81 with good results. This is the most important piece of data for UMA. If the alignment is no good, or the sequences are dissimilar, then an accurate prediction will not be made. ** The program is highly dependent on a sequence alignment with homologous sequences, and a proper, accurate alignment is essential. **

2) Secondary structure predictions for each sequence in your alignment file. UMA was initially designed to work with the format of the output from the secondary structure prediction portion (PHDsec) of the Predict Protein server at 
http://maple.bioc.columbia.edu/predictprotein/predictprotein.html
This server makes reportedly highly accurate secondary structure predictions using a neural net. PSIPRED is reported to be slightly more accurate, but does not do predictions on large proteins. You may certainly use other prediction programs, or crystal structure data if you like, but the structure file must be in the proper format: similar to FASTA, where the amino acid sequence is replaced by secondary structure: H for helix, E for beta sheet, L for a loop, or . for no prediction. 




BRIEF INSTRUCTIONS
----------------------------------------------

	- Identify sequences homologous to your target by BLAST or other methods. It is recommended that only sequences homologus over the entire length of your target protein be used. Finding such sequences is often the greatest hurdle.
	- Prepare a multiple sequence alignment. This MSA must be in NBRF/PIR format, which is an output option available in ClustalX and some other sequence alignment programs. 
	- Identify secondary structure for each protein sequence, and build the secondary structure file. Because few crystal structures exist for multidomain proteins, we have made use of structure prediction routines. UMA can convert the output from one such method, PHDsec, into a secondary structure file readable by UMA. Submit each sequence to the PredictProtein server, and save the html file returned to you. Note that the names of the sequences submitted for prediction and in the MSA should be identical.
	- Copy the html structure files, .pir-formatted MSA, uma18.pl, and the desired blosum (or other) matrix and any other files you may need into one folder and start the uma18.pl script. A new PerlTK window should appear.
	- Be sure that the Alignment file, and Secondary Structure file are named properly in their corresponding text boxes.
	- Build your secondary structure file by clicking the "Build SS file" button. A new file will appear in the folder with the name given in the "Secondary Structure file" text box. (If crystal structure or other hand entered data is required, quit from UMA and edit this file now, then start uma18.pl again.)
	- Again verify the names of all files and check all variables. Enter the name of one of your sequences in the "Sequence to chart" textbox. The results of the calculation will appear in the chart window, and will be stored in the file designated by the "Output file" textbox. The results for each sequence will be stored in the file designated by the "Comparative out file" textbox. 
	- Press "Go!". The output files will be created and the result will appear in the chart window. Calculations may take some time, depending on the number and size of the sequences being compared. 
	- Further refine the prediction by repeating the calculations and manipulating the variables described below. As described in the Journal of Molecular Biology paper, regions with low scores should correspond to "linker" regions between protein domains.


** Sample files for the MetH protein are included in the "example" directory. You may wish to run through these to be sure the installation was correct and to practice with UMA **



VARIABLES
----------------------------------------------

Homology matrix - (Default=blosum62.dat). Four homology matrices have been provided with the UMA package. For more distantly homologous sequences, blosum30 or 45 may be used, and blosum80 for very closely homologous sequences. Blosum62 is known to be the most robust of these matrices, and is most commonly used.

Gap to gap penalty - (Default=0) This value, as well as "gap to aa penalty" are extra values not given by the homology matrix, but needed for UMA. In the sequence comparison, when a gap is compared to a gap, this value is returned. Vary this value from approximately 2 to -5, with larger negative numbers more heavily penalizing nonhomologous regions of sequence.

Gap to aa penalty - (Default=-4) In the sequence comparison, when a gap is compared to an amino acid (or vice versa), this value is returned. Vary this value from approximately 0 to -10, with larger negative numbers more heavily penalizing nonhomologous regions of sequence.

Component averaging (K) - (Default=5) Used to reduce noise in the structure, sequence, and hydrophobicity components of the UMA score. Adjust this value to alter the signal-to-noise ratio. Recommended values range from 1-10.

Final averaging (gamma) - (Default=20) Used to directly reduce noise in the final UMA score. Adjust this value to alter the signal-to-noise ratio. Recommended values range from 10-50.

Sim score weight - (Default=1) The sequence similarity component of the UMA score will be multiplied by this amount. If this is greater than the other weights, then the sequence similarity comparison will contribute more to the final UMA score.

Struc score weight - (Default=1) The structure similarity component of the UMA score will be multiplied by this amount. If this is greater than the other weights, then the structure similarity comparison will contribute more to the final UMA score.

Hydro score weight - (Default=1) The hydrophobicity component of the UMA score will be multiplied by this amount. If this is greater than the other weights, then the hydrophobicity score will contribute more to the final UMA score.
