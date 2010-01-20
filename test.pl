######################################################################
#
# test.pl for testing jacode.pl
#
# Copyright (c) 2010 INABA Hitoshi <ina@cpan.org>
#
######################################################################

if ($^X =~ /jperl/i) {
    $opt = '-Llatin';
}

print STDERR "Running on $^X $]\n";

$tno = 1;

chdir('t');

# han2zen
for $script (split(' ',<<'END')) {
    h2z_jis.t
    h2z_sjis.t
    h2z_euc.t
    h2z_utf8.t
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
    z2h_jis.t
    z2h_sjis.t
    z2h_euc.t
    z2h_utf8.t
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

# JIS to Any
for $script (split(' ',<<'END')) {
    JIStoEUC.t
    JIStoSJIS.t
    JIStoUTF8.t
END
    system(qq{$^X $opt -I.. $script jis.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script\n";
    }
    else{
        print "not ok - $tno $script\n";
    }
    $tno++;
}

# SJIS to Any
for $script (split(' ',<<'END')) {
    SJIStoJIS.t
    SJIStoEUC.t
    SJIStoUTF8.t
END
    system(qq{$^X $opt -I.. $script sjis.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script\n";
    }
    else{
        print "not ok - $tno $script\n";
    }
    $tno++;
}

# EUC to Any
for $script (split(' ',<<'END')) {
    EUCtoJIS.t
    EUCtoSJIS.t
    EUCtoUTF8.t
END
    system(qq{$^X $opt -I.. $script euc.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script\n";
    }
    else{
        print "not ok - $tno $script\n";
    }
    $tno++;
}

# UTF8 to Any
for $script (split(' ',<<'END')) {
    UTF8toJIS.t
    UTF8toSJIS.t
    UTF8toEUC.t
END
    system(qq{$^X $opt -I.. $script utf8.txt > $script.txt});
    if (&filecompare("$script.txt","$script.want")) {
        print "ok - $tno $script\n";
    }
    else{
        print "not ok - $tno $script\n";
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
                @_  = $_  =~ /([\x00-\xff][\x00-\xff])/g;
                @_2 = $_2 =~ /([\x00-\xff][\x00-\xff])/g;
                while (@_) {
                    $_ = shift @_;
                    $_2 = shift @_2;
                    if ($_ ne $_2) {
                        $hex1 = unpack( 'H*', $_ );
                        $hex2 = unpack( 'H*', $_2 );
                        print "[$_]$hex1 <=> [$_2]$hex2\n";
                    }
                }
            }
            else {
                print "file1[$_]\n";
                print "file2[$_2]\n";
                close(FILE1);
                close(FILE2);
                return 0;
            }
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
