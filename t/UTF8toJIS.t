require 'jacode.pl';

while (<>) {
    chop;
    &jcode'convert(*_, 'jis', 'utf8');
    print $_, "\n";
}

1;
__END__
