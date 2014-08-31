require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'euc', 'utf8');
    print $_, "\n";
}

1;
__END__
