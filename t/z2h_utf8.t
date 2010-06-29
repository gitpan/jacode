require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'utf8', 'sjis', 'h');
    print $_, "\n";
}

1;
__END__
