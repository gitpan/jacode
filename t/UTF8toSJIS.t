require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'sjis', 'utf8');
    print $_, "\n";
}

1;
__END__
