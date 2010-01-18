require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'euc', 'sjis');
    print $_, "\n";
}

1;
__END__
