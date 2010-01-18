require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'jis');
    print $_, "\n";
}

1;
__END__
