require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'jis', 'sjis', 'h');
    print $_, "\n";
}

1;
__END__
