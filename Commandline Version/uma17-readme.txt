
UMA v1.7 readme file.
Dan Udwary
dwu1@jhunix.hcf.jhu.edu

***Please read the license agreement and copyright notice that should be contained with the package as "LICENSE.txt".***


UMA is designed to locate structural subunits in large multifunctional proteins. There should be at least 4 files associated with the program: 

>UMA2v17.pl - this is the core program

>input.txt - This is the configuration file. All of the variables and file names to be used as input for uma2 are placed here. In many cases, if a value or filename isn't specified uma2 will ask you for it, but not always (further revisions and bug fixes should correct that). 

>PHD2SS.pl - This quick program takes in plain text PHDsec predictions, and contructs a plain text structure file (.ss) by first converting the html to plain text (with the included html2txt.exe) and then extracting the relevant information. The resulting file format is very similar to FASTA, except there are two blocks of text, the first being confidence values given by PHD, and the second block is the actual prediction. 


You will need several pieces of data before you begin. 

0) You need to install a Perl interpreter, since the programs are Perl scripts. If you are using a UNIX based machine this is probably already enabled by default. If not talk to your system administrator. If you are using a DOS or Windows machine I recommend the ActivePerl package available from ActiveState (www.activestate.com). This is a free download and is very easy to install. A common MacOS implementation is MacPerl (www.macperl.com).

1) A sequence alignment in .pir format. I've been using ClustalX 1.81 to do my alignments, but as long as the alignment is in .pir format it should work. This is the most important piece of data for uma2. If the alignment is no good, or the sequences are dissimilar, then your output will be garbage. Again - the program is highly dependent on a sequence alignment with homologous sequences - the more homologous the better. Note that you may also align partial sequences, but I haven't worked out a way for the program to understand when you're doing this, so take care to really look at the data you're going to get out, as I haven't fully investigated this. 

2) Secondary structure predictions for each sequence in your alignment file. uma2 is designed to work with the format of the output from the secondary structure prediction portion (PHDsec) of the Predict Protein server at 
http://maple.bioc.columbia.edu/predictprotein/predictprotein.html
This server makes reportedly highly accurate secondary structure predictions using a neural net. PSIPRED is supposed to be slightly more accurate, but it doesn't do predictions on large proteins, so I haven't used it much. You may certainly use other prediction programs, or even crystal structure data if you like, you just need to have a structure file in the proper format, similar to FASTA, where the amino acid sequence is replaced by secondary structure: H for helix, E for beta sheet, L for a loop, or . for no prediction. 

3) A similarity matrix data file. ie blosum62. The file format is simply a 20x20 table, space delimited. (Several blosum tables are included.)



Here are some simplified step-by-step instructions for using UMA2v17.
1. Perform a BLAST search of the protein of interest. If you didn't get any homologous sequences from your BLAST search then don't bother going any further. Sequences which are homologous over the length of the protein of interest are preferred. 

2. Construct a sequence alignment of your protein of interest with other homologous sequences. Spend some time on this: make sure there are no obvious gaps or poor alignments. Big proteins aren't handled particularly well by most multiple sequence alignment programs, so take a good hard look at what you're getting and think about whether or not it makes sense.

3. Submit each sequence to the Predict Protein server. You may run the default prediction set, or select "PHDsec only" to get back a slightly smaller file. Also, be sure that the file is returned as "HTML format for printout." You will (eventually) be sent back an html file, or a link to an html file. Save these, then run the script "PHD2SS.pl" in the directory where the files were saved, and the required secondary structure file (structure.ss) will be created.

4. Edit "input.txt", the uma2 configuration file with the necessary names of the sequence alignment file, structure file, and weighting and smoothing numbers, as well as any other variables desired. A default "input.txt" file is provided. 

5. Run the UMA program by typing "perl uma2v17.pl". 

6. The output should be a tab-delimited text file readable by MS Excel or other data handling programs. 


Any questions or comments should be sent to Dan Udwary (dwu1@jhunix.hcf.jhu.edu) or Craig Townsend (ctownsend@jhu.edu). 
