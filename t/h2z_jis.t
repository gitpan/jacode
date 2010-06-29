require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'jis', 'sjis', 'z');
    print $_, "\n";
}

1;
__END__
