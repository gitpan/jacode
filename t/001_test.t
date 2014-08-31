######################################################################
#
# 001_test.t for testing jacode.pl
#
# Copyright (c) 2010, 2011, 2014 INABA Hitoshi <ina@cpan.org>
#
######################################################################

print "1..32\n";
$opt = ($^X =~ /jperl/i) ? '-Llatin' : '';

$tno = 1;

chdir('t');

# han2zen
for $script (split(' ',<<'END')) {
    h2z_jis.pl
    h2z_sjis.pl
    h2z_euc.pl
    h2z_utf8.pl
END
    system(qq{$^X $opt -I.. $script han.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script\n";
    }
    else{
        print "not ok - $tno $script\n";
    }
    $tno++;
}

# zen2han
for $script (split(' ',<<'END')) {
    z2h_jis.pl
    z2h_sjis.pl
    z2h_euc.pl
    z2h_utf8.pl
END
    system(qq{$^X $opt -I.. $script zen.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script\n";
    }
    else{
        print "not ok - $tno $script\n";
    }
    $tno++;
}

# JIS to Any Kanji
for $script (split(' ',<<'END')) {
    JIStoEUC.pl
    JIStoSJIS.pl
    JIStoUTF8.pl
END
    system(qq{$^X $opt -I.. $script jis.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script (Kanji)\n";
    }
    else{
        print "not ok - $tno $script (Kanji)\n";
    }
    $tno++;
}

# SJIS to Any Kanji
for $script (split(' ',<<'END')) {
    SJIStoJIS.pl
    SJIStoEUC.pl
    SJIStoUTF8.pl
END
    system(qq{$^X $opt -I.. $script sjis.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script (Kanji)\n";
    }
    else{
        print "not ok - $tno $script (Kanji)\n";
    }
    $tno++;
}

# EUC to Any Kanji
for $script (split(' ',<<'END')) {
    EUCtoJIS.pl
    EUCtoSJIS.pl
    EUCtoUTF8.pl
END
    system(qq{$^X $opt -I.. $script euc.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script (Kanji)\n";
    }
    else{
        print "not ok - $tno $script (Kanji)\n";
    }
    $tno++;
}

# UTF8 to Any Kanji
for $script (split(' ',<<'END')) {
    UTF8toJIS.pl
    UTF8toSJIS.pl
    UTF8toEUC.pl
END
    system(qq{$^X $opt -I.. $script utf8.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script (Kanji)\n";
    }
    else{
        print "not ok - $tno $script (Kanji)\n";
    }
    $tno++;
}

# JIS to Any Kana
for $script (split(' ',<<'END')) {
    JIStoEUC.pl
    JIStoSJIS.pl
    JIStoUTF8.pl
END
    system(qq{$^X $opt -I.. $script jis.kana.txt > $script.kana.txt});
    if (&filecompare("$script.kana.txt","$script.kana.want")) {
        print "ok - $tno $script (Kana)\n";
    }
    else{
        print "not ok - $tno $script (Kana)\n";
    }
    $tno++;
}

# SJIS to Any Kana
for $script (split(' ',<<'END')) {
    SJIStoJIS.pl
    SJIStoEUC.pl
    SJIStoUTF8.pl
END
    system(qq{$^X $opt -I.. $script sjis.kana.txt > $script.kana.txt});
    if (&filecompare("$script.kana.txt","$script.kana.want")) {
        print "ok - $tno $script (Kana)\n";
    }
    else{
        print "not ok - $tno $script (Kana)\n";
    }
    $tno++;
}

# EUC to Any Kana
for $script (split(' ',<<'END')) {
    EUCtoJIS.pl
    EUCtoSJIS.pl
    EUCtoUTF8.pl
END
    system(qq{$^X $opt -I.. $script euc.kana.txt > $script.kana.txt});
    if (&filecompare("$script.kana.txt","$script.kana.want")) {
        print "ok - $tno $script (Kana)\n";
    }
    else{
        print "not ok - $tno $script (Kana)\n";
    }
    $tno++;
}

# UTF8 to Any Kana
for $script (split(' ',<<'END')) {
    UTF8toJIS.pl
    UTF8toSJIS.pl
    UTF8toEUC.pl
END
    system(qq{$^X $opt -I.. $script utf8.kana.txt > $script.kana.txt});
    if (&filecompare("$script.kana.txt","$script.kana.want")) {
        print "ok - $tno $script (Kana)\n";
    }
    else{
        print "not ok - $tno $script (Kana)\n";
    }
    $tno++;
}

chdir('..');

sub filecompare {
    local ($file1, $file2) = @_;
    open(FILE1, $file1) || die "Can't open file: $file1";
    open(FILE2, $file2) || die "Can't open file: $file2";
    while(<FILE1>){
        $_2 = <FILE2>;
        $_  =~ s/(\r\n|\r|\n)+$//;
        $_2 =~ s/(\r\n|\r|\n)+$//;
        if($_ ne $_2){
            print "file compare:\n";
            if (0) {
                @_1 = $_  =~ /([\x00-\xff][\x00-\xff])/g;
                @_2 = $_2 =~ /([\x00-\xff][\x00-\xff])/g;

                while (@_2) {
                    $_1 = shift @_1;
                    $_2 = shift @_2;
                    if ($_1 ne $_2) {
                        $hex1 = unpack( 'H*', $_1 );
                        $hex2 = unpack( 'H*', $_2 );
                        print "[$_1]$hex1 <=> [$_2]$hex2\n";
                    }
                }
            }
            else {
                print "file1[$_]\n";
                print "file2[$_2]\n";
                close(FILE1);
                close(FILE2);
            }
            return 0;
        }
    }
    if(!eof(FILE1)){
        close(FILE1);
        close(FILE2);
        return 0;
    }
    if(!eof(FILE2)){
        close(FILE1);
        close(FILE2);
        return 0;
    }
    close(FILE1);
    close(FILE2);
    return 1;
}

1;
__END__
