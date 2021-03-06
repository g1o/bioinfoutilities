#!/usr/bin/perl
#
#              INGLÊS/ENGLISH
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  http://www.gnu.org/copyleft/gpl.html
#
#
#             PORTUGUÊS/PORTUGUESE
#  Este programa é distribuído na expectativa de ser útil aos seus
#  usuários, porém NÃO TEM NENHUMA GARANTIA, EXPLÍCITAS OU IMPLÍCITAS,
#  COMERCIAIS OU DE ATENDIMENTO A UMA DETERMINADA FINALIDADE.  Consulte
#  a Licença Pública Geral GNU para maiores detalhes.
#  http://www.gnu.org/copyleft/gpl.html
#
#  Copyright (C) 2010  Fundação Hemocentro de Ribeirão Preto
#
#  Laboratório de Genética Molecular e Bioinformática
#  Núcleo de Bioinformática
#  BiT -  Bioinformatics Team
#  Fundação Hemocentro de Ribeirão Preto
#  Rua Tenente Catão Roxo, 2501
#  Ribeirão Preto - São Paulo
#  Brasil
#  CEP 14051-140
#  Fone: 55 16 39639300 Ramal 9603
#
#  Daniel Guariz Pinheiro
#  dgpinheiro@gmail.com
#  http://lgmb.fmrp.usp.br
#
# $Id$

=head1 NAME

    unmerge-ends-fasta.pl - Split sequence "ends" from a fasta file generated by fastx_collapser.

=head1 SYNOPSIS
    
    # Split sequences from PEExp_12.fasta into two files: PEExp_12_1.fasta and PEExp_12_2.fasta. 
    # The sequences and quals are splitted equally in two pieces.

    $ unmerge-ends-fasta.pl   -i PEExp_12.fasta \
    > -o1 PEExp_12_1.fasta -o2 PEExp_12_2.fasta;

=head1 ABSTRACT

=head1 DESCRIPTION
    
    Split sequences from a fasta file generated by fastx_collapser into two fasta files. 

=head1 AUTHOR

Daniel Guariz Pinheiro E<lt>dgpinheiro@gmail.comE<gt>

Copyright (c) 2010 Regional Blood Center of Ribeirão Preto

=head1 LICENSE

GNU General Public License

http://www.gnu.org/copyleft/gpl.html


=cut

use strict;
use warnings;
use Getopt::Long;

my ($outfile1, $outfile2, $infile);

Usage("Too few arguments") if $#ARGV < 0;
GetOptions( "h|?|help"  => sub { &Usage(); },
            "o1|outputfile1=s"=> \$outfile1,
            "o2|outputfile2=s"=> \$outfile2,
            "i|inputfile=s"=> \$infile
) or &Usage();


die "Missing output file 1" unless ($outfile1);

die "Missing output file 2" unless ($outfile2);

die "Missing input file" unless ($infile);
die "Wrong input file" unless (-e $infile);

open(ONEOUT, ">", $outfile1) or die "Cannot open output file 1: $!";
open(TWOOUT, ">", $outfile2) or die "Cannot open output file 2: $!";

open(IN, "<", $infile) or die "Cannot open input file: $!";

my $count = 0;

$| = 1;
my $length;
while(my $seqids = <IN>) {
    chomp($seqids);

    my ($one_seqid,$two_seqid) = ($seqids, $seqids);

    my $seqs = <IN>;
    chomp($seqs);

    $length||=length($seqs);
    
    if (length($seqs) != $length) {
        die "Error: a sequence in file has different lengths";
    }
    
    my ($one_seq) = substr($seqs, 0, ($length/2));
    my ($two_seq) = substr($seqs, 0, ($length/2));

    print ONEOUT $one_seqid,"\n",
                 $one_seq,"\n";
    
    print TWOOUT $two_seqid,"\n",
                 $two_seq,"\n";

    $count++;
    if ($count % 10000 == 0) {
        print STDERR "Records: $count                                                         \r";
    }
}

print STDERR "Records: $count                                                         \n";

close(ONEOUT);
close(TWOOUT);

close(IN);

# Subroutines

sub Usage {
    my ($msg) = @_;
	my $USAGE = <<"END_USAGE";
Daniel Guariz Pinheiro (dgpinheiro\@gmail.com)
(c)2010 Regional Blood Center of Ribeirão Preto

Usage

        $0	[-h/--help] [-i PEExp_12.fasta 
                         -o1 PEExp_12_1.fasta -o2 PEExp_12_2.fasta ]

Argument(s)

        -h      --help          Help
        
        -o1     --outputfile1   Output file 1 (Ordered fasta p1 file - same order as p2)
        -o2     --outputfile2   Output file 2 (Ordered fasta p2 file - same order as p1)

        -i      --inputfile     Input file (from fastx_collapser)

END_USAGE
    print STDERR "\nERR: $msg\n\n" if $msg;
    print STDERR qq[$0  ] . q[$Revision$] . qq[\n];
	print STDERR $USAGE;
    exit(1);
}

