require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'sjis', 'sjis', 'h');
    print $_, "\n";
}

1;
__END__
