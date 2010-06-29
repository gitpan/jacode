require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'jis', 'sjis');
    print $_, "\n";
}

1;
__END__
