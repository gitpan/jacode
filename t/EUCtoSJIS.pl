require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'sjis', 'euc');
    print $_, "\n";
}

1;
__END__
