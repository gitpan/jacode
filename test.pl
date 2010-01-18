# han2zen
for $script (qw(
    h2z_jis.t
    h2z_sjis.t
    h2z_euc.t
    h2z_utf8.t
)) {
    system(qq{perl t\\$script t\\han.txt > t\\$script.txt});
}

# zen2han
for $script (qw(
    z2h_jis.t
    z2h_sjis.t
    z2h_euc.t
    z2h_utf8.t
)) {
    system(qq{perl t\\$script t\\zen.txt > t\\$script.txt});
}

# JIS to Any
for $script (qw(
    JIStoEUC.t
    JIStoSJIS.t
    JIStoUTF8.t
)) {
    system(qq{perl t\\$script t\\jis.txt > t\\$script.txt});
}

# SJIS to Any
for $script (qw(
    SJIStoJIS.t
    SJIStoEUC.t
    SJIStoUTF8.t
)) {
    system(qq{perl t\\$script t\\sjis.txt > t\\$script.txt});
}

# EUC to Any
for $script (qw(
    EUCtoJIS.t
    EUCtoSJIS.t
    EUCtoUTF8.t
)) {
    system(qq{perl t\\$script t\\euc.txt > t\\$script.txt});
}

# UTF8 to Any
for $script (qw(
    UTF8toJIS.t
    UTF8toSJIS.t
    UTF8toEUC.t
)) {
    system(qq{perl t\\$script t\\utf8.txt > t\\$script.txt});
}

1;
__END__
