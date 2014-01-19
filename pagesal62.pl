########################
# PageSAL.pl
########################
#
# This script reads the output files from pdftotext (0x0C breaks pages)
# and ouputs page number, top line, and info within the page.
# The script will also output the tab delimited file based on the
# data.
#

# Top line example:
# 26 PUBLIC LAWS-CH. 42-MAR. 30, 1949 [63 STAT. 
# (The text files use left and right folios - even page numbers on left).

$infile=shift;
$outfile1=shift;
$outfile2=shift;

if (!$outfile2 || !(-e $infile))
	{
	print "Syntax: PageSal.pl infile outfile\n";
	print "This script reads the text files from pdftotext and outputs\n";
	print "two files. (1) page number, top line, contents and \n";
	print "(2) the tab-delimited control file needed to break SAL files\n";
	exit;
	}

open(IN,$infile);
$outfile1=">".$outfile1;
open(OUT1,$outfile1);
$outfile2=">".$outfile2;
open(OUT2,$outfile2);

$page=1;
$plnum=1;

$linenum=0;
$v=62;
$lastplnum=0;
$statpage1=29;

print OUT2 "<PDFSAL>\n";
print OUT2 "<page number=\"1\">\n";

print OUT1 "vol=62\n";
print OUT1 "statpage1=30\n";

$xp=0;
while (<IN>)
	{
	if ($linenum <5)
		{
		if ($linenum<2)
			{
			if (0) # m|^(\d+)|)
				{
				$statpage=$1;
				$cpage=$page=$statpage1;
				# print OUT2 "<statpage page=\"".$page."\">".$statpage."</statpage>\n";				
				# print OUT1 "statpage=".$statpage." page=".$page." compstat=".$cpage."\n";
				}
			}
		print OUT2 $_;
		}
		
		
	if (m|\x0C|)
		{
		$page++;
		if ($plnum == ($lastplnum))
			{
			print OUT1 "publaw-".$plnum."\t".$statpage."\n";
			$lastplnum=$plnum+1;
			}

		print OUT2 "</page>\n";
		print OUT2 "<page number=\"".$page."\">\n";
		$linenum=0;	
		if ($page>$statpage1)
			{
			$xp=$page-$statpage1;
			print OUT2 "<stat-page>".$xp."</stat-page>\n";
			#print OUT1 "<stat-page>".$xp."</stat-page>\n";			
			}
		
		}
	else
		{
		$linenum++;
		}		

	if (m|$v STAT. (\d+)|)
		{
		$statpage=$1;
		print OUT2 " <statpage>".$statpage."</statpage>\n";
		}

# [Public Law 441]

	if (m@[\[\(]Public Law (\d+)@ && $page>$statpage1)
		{
		$plnum=$1;
		if ($plnum>1000)
			{
			$plnum=int($plnum/10);
			}
		print OUT1 "publaw-".$plnum."\t".$xp."\n";
		print OUT2 "<publaw>publaw-".$plnum."\t".$xp."</publaw>\n";
		
#		print OUT2 " <publaw>".$plyear."-".$plnum."</publaw>\n";
		if ($plnum == ($lastplnum))
			{
	#		print OUT1 "publaw-".$plnum."\t".$xp."\n";
	#		print OUT2 "publaw-".$plnum."\t".$xp."\n";
			$lastplnum=$plnum+1;
			}
		}
		
		
	# if (m|PUBLIC LAW (\d+)–(\d+)—([^ ]+) ([^ ]+) ([^ ]+)|)
		

	NextLine:
	}

	
close(IN);
close(OUT1);
print OUT2 "</page>\n";
print OUT2 "</PDFSAL>";	
close(OUT2);
