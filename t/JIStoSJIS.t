require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'sjis');
    print $_, "\n";
}

1;
__END__
