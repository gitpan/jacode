require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'utf8', 'euc');
    print $_, "\n";
}

1;
__END__
