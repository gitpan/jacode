require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'utf8', 'sjis', 'z');
    print $_, "\n";
}

1;
__END__
