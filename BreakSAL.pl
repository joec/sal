###################
# BreakSAL.pl
# Given a tab separated file containing "filename" and page number and optional end page, 
# this script creates PDF files from the source PDF file.#
###################

# Syntax: breaksal.pl b##.txt out-directory
#  change $mode to publaw or stat

use PDF::API2;
use File::Path 'rmtree';




$infile=shift;
$outdir=shift;

$mode="publaw";

if (!$outdir)
	{
	print "Need out-dir.  Syntax: breaksal1.pl infile out-dir\n";
	print "infile is a tab separated list of filenames and page numbers.";
	}
$pdfindir="L:/StatsAtLarge/";

$outdir=~s|\\|/|g;
$outdir=~s|/\s*$||;

my $vol;
my @lines=undef;
my $numlines=0;
open(IN,$infile);
print $infile."\n";

while (<IN>)
	{
	$lines[$numlines++]=$_;
	}
close(IN);
my $pdfvol;

$numlines=$#lines;

for (my $j=0;$j<$numlines;$j++)
	{
	my $pageend=0;
	
	if ($lines[$j]=~m|^statpage1=(\d+)|)
		{
		$statpage1=$1;
		}
	
	elsif ($lines[$j]=~m|^vol=(\d+)|)
		{
		$vol=$1;
		my $sfn=sprintf("%03d_statutes_at_large.pdf",$vol);
		my $pdfvolfile=$pdfindir.$sfn;
		$pdfvol = PDF::API2->open($pdfvolfile);
		$outfile=$outdir."/".$vol;
		mkdir($outfile);

		if ($mode=~m|stat|)
			{		
			$statfile=$outdir."/STATUTE-".$vol;
			rmtree($statfile);
			mkdir($statfile);
			$indexfile=">".$statfile."/index.txt";
			open(INDEX,$indexfile);
			}

		
		
		$outfile.="/";
		$statfile.="/";
		print $outfile."\n";
		}
	elsif ($lines[$j]=~m|^([^\t]*?)\t(\d+)\t?(\d+)?\s*$|)
		{
		$fn=$1;
		$pagestart=$2;
		$pageend=$3;
		print "* ".$fn.".pdf from page ".$pagestart."\n";
		$pdf = PDF::API2->new();
	
		$thisoutfile=$outfile.$fn.".pdf";
			
		# import first page.		
		$page = $pdf->importpage($pdfvol, $pagestart, 1);
		if ($pageend)
			{
			$targetpage=1;
			for (my $k=$pagestart+1;$k<=$pageend;$k++)
				{
				$targetpage++;			
				$page = $pdf->importpage($pdfvol, $k, $targetpage);
				}			
			}
		
		elsif ($lines[$j+1]=~m|^([^\t]*?)\t(\d+)\s*$|)
			{
			$nextname=$1;
			$nextpage=$2;
			# if ($nextpage > $startpage) {print "NEXTpage=".$nextpage."\n";}
			$targetpage=1;
			for (my $k=$pagestart+1;$k<=$nextpage;$k++)
				{
				$targetpage++;			
				$page = $pdf->importpage($pdfvol, $k, $targetpage);							
				}
			}
		
		$statpage=$pagestart-$statpage1+1;
		# http://www.gpo.gov/fdsys/pkg/STATUTE-65/pdf/STATUTE-65-Pg3.pdf
		if ($fn=~m|^\*|)
			{
			$fn=~s|^\*||;
			$statfile=$outdir."/STATUTE-".$vol."/STATUTE-".$vol."-".$fn.".pdf";
			}
		else
			{			
			$statfile=$outdir."/STATUTE-".$vol."/STATUTE-".$vol."-Pg".$statpage.".pdf";
			}
		$a="a";
		while (-e $statfile)
			{
			$statfile=~s|[a-z]\.pdf$|.pdf|;
			$statfile=~s|\.pdf$|$a.pdf|;
			$a=chr(ord($a)+1);
			print "setting ".$statfile."\n";
			}
			
		print "saveas=".$statfile."\n";	
		if ($mode=~m|stat|)
			{
			$pdf->saveas($statfile);
			print INDEX $fn." ".$statfile."\n";
			}
		elsif ($mode=~m|publaw|)
			{
			$thisoutfile=~s|\*||;
			$pdf->saveas($thisoutfile);
			}
		} 
		

	}
	
	
close(INDEX);


