require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'jis', 'euc');
    print $_, "\n";
}

1;
__END__
