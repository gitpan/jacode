package jcode;
######################################################################
#
# jacode.pl: Perl library for Japanese character code conversion
#
# Copyright (c) 2010 INABA Hitoshi <ina@cpan.org>
#
# The latest version is available here:
#
#   http://search.cpan.org/dist/jacode/
#
# Original version `jcode.pl' is ...
#
# Copyright (c) 1995-2000 Kazumasa Utashiro <utashiro@iij.ad.jp>
# Internet Initiative Japan Inc.
# 3-13 Kanda Nishiki-cho, Chiyoda-ku, Tokyo 101-0054, Japan
#
# Copyright (c) 1992,1993,1994 Kazumasa Utashiro
# Software Research Associates, Inc.
#
# Use and redistribution for ANY PURPOSE are granted as long as all
# copyright notices are retained.  Redistribution with modification
# is allowed provided that you make your modified version obviously
# distinguishable from the original one.  THIS SOFTWARE IS PROVIDED
# BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES ARE
# DISCLAIMED.
#
# Original version was developed under the name of srekcah@sra.co.jp
# February 1992 and it was called kconv.pl at the beginning.  This
# address was a pen name for group of individuals and it is no longer
# valid.
#
# The latest version is available here:
#
#   ftp://ftp.iij.ad.jp/pub/IIJ/dist/utashiro/perl/
#
$rcsid =
q$Id: jacode.pl,v 2.13.4.0 alpha branched from jcode.pl,v 2.13 2000/09/29 16:10:05 utashiro Exp $;

######################################################################
#
# PERL4 INTERFACE:
#
#   &jcode'getcode(*line)
#       Return 'jis', 'sjis', 'euc', 'utf8' or undef according
#       to Japanese character code in $line.  Return 'binary' if
#       the data has non-character code.
#
#       When evaluated in array context, it returns a list
#       contains two items.  First value is the number of
#       characters which matched to the expected code, and
#       second value is the code name.  It is useful if and
#       only if the number is not 0 and the code is undef;
#       that case means it couldn't tell 'euc' or 'sjis'
#       because the evaluation score was exactly same.  This
#       interface is too tricky, though.
#
#       Code detection between euc and sjis is very difficult
#       or sometimes impossible or even lead to wrong result
#       when it includes JIS X0201 KANA characters.
#
#   &jcode'convert(*line, $ocode [, $icode [, $option]])
#       Convert the contents of $line to the specified
#       Japanese code given in the second argument $ocode.
#       $ocode can be any of "jis", "sjis", "euc" or "utf8", or
#       use "noconv" when you don't want the code conversion.
#       Input code is recognized automatically from the line
#       itself when $icode is not supplied.  $icode also can be
#       specified, but xxx2yyy routine is more efficient when
#       both codes are known.
#
#       It returns the code of input string in scalar context,
#       and a list of pointer of convert subroutine and the
#       input code in array context.
#
#       Japanese character code JIS X0201, X0208, X0212 and
#       ASCII code are supported.  JIS X0212 characters can not
#       be represented in sjis or utf8 and they will be replased
#       by "geta" character when converted to sjis.
#       JIS X0213 characters can not be represented in all.
#
#       See next paragraph for $option parameter.
#
#   &jcode'xxx2yyy(*line [, $option])
#       Convert the Japanese code from xxx to yyy.  String xxx
#       and yyy are any convination from "jis", "euc", "sjis"
#       or "utf8". They return *approximate* number of converted
#       bytes.  So return value 0 means the line was not
#       converted at all.
#
#       Optional parameter $option is used to specify optional
#       conversion method.  String "z" is for JIS X0201 KANA
#       to JIS X0208 KANA, and "h" is for reverse.
#
#   $jcode'convf{'xxx', 'yyy'}
#       The value of this associative array is pointer to the
#       subroutine jcode'xxx2yyy().
#
#   &jcode'to($ocode, $line [, $icode [, $option]])
#   &jcode'jis($line [, $icode [, $option]])
#   &jcode'euc($line [, $icode [, $option]])
#   &jcode'sjis($line [, $icode [, $option]])
#   &jcode'utf8($line [, $icode [, $option]])
#       These functions are prepared for easy use of
#       call/return-by-value interface.  You can use these
#       funcitons in s///e operation or any other place for
#       convenience.
#
#   &jcode'jis_inout($in, $out)
#       Set or inquire JIS start and end sequences.  Default
#       is "ESC-$-B" and "ESC-(-B".  If you supplied only one
#       character, "ESC-$" or "ESC-(" is prepended for each
#       character respectively.  Acutually "ESC-(-B" is not a
#       sequence to end JIS code but a sequence to start ASCII
#       code set.  So `in' and `out' are somewhat misleading.
#
#   &jcode'get_inout($string)
#       Get JIS start and end sequences from $string.
#
#   &jcode'cache()
#   &jcode'nocache()
#   &jcode'flushcache()
#       Usually, converted character is cached in memory to
#       avoid same calculations have to be done many times.
#       To disable this caching, call &jcode'nocache().  It
#       can be revived by &jcode'cache() and cache is flushed
#       by calling &jcode'flushcache().  &cache() and &nocache()
#       functions return previous caching state.
#
#   ---------------------------------------------------------------
#
#   &jcode'h2z_xxx(*line)
#       JIS X0201 KANA (so-called Hankaku-KANA) to JIS X0208 KANA
#       (Zenkaku-KANA) code conversion routine.  String xxx is
#       any of "jis", "sjis", "euc" and "utf8".  From the difficulty
#       of recognizing code set from 1-byte KATAKANA string,
#       automatic code recognition is not supported.
#
#   &jcode'z2h_xxx(*line)
#       JIS X0208 to JIS X0201 KANA code conversion routine.
#       String xxx is any of "jis", "sjis", "euc" and "utf8".
#
#   $jcode'z2hf{'xxx'}
#   $jcode'h2zf{'xxx'}
#       These are pointer to the corresponding function just
#       as $jcode'convf.
#
#   ---------------------------------------------------------------
#
#   &jcode'tr(*line, $from, $to [, $option])
#       &jcode'tr emulates tr operator for 2 byte code.  Only 'd'
#       is interpreted as an option.
#
#       Range operator like `A-Z' for 2 byte code is partially
#       supported.  Code must be JIS or EUC, and first byte
#       have to be same on first and last character.
#
#       CAUTION: Handling range operator is a kind of trick
#       and it is not perfect.  So if you need to transfer `-'
#       character, please be sure to put it at the beginning
#       or the end of $from and $to strings.
#
#   &jcode'trans($line, $from, $to [, $option])
#       Same as &jcode'tr but accept string and return string
#       after translation.
#
#   ---------------------------------------------------------------
#
#   &jcode'init()
#       Initialize the variables used in this package.  You
#       don't have to call this when using jocde.pl by `do' or
#       `require' interface.  Call it first if you embedded
#       the jacode.pl at the end of your script.
#
######################################################################
#
# PERL5 INTERFACE:
#
# Current jacode.pl is written in Perl 4 but it is possible to use
# from Perl 5 using `references'.  Fully perl5 capable version is
# future issue.
#
# Since lexical variable is not a subject of typeglob, *string style
# call doesn't work if the variable is declared as `my'.  Same thing
# happens to special variable $_ if the perl is compiled to use
# thread capability.  So using reference is generally recommented to
# avoid the mysterious error.
#
#   jcode::getcode(\$line)
#   jcode::convert(\$line, $ocode [, $icode [, $option]])
#   jcode::xxx2yyy(\$line [, $option])
#   &{$jcode::convf{'xxx', 'yyy'}}(\$line)
#   jcode::to($ocode, $line [, $icode [, $option]])
#   jcode::jis($line [, $icode [, $option]])
#   jcode::euc($line [, $icode [, $option]])
#   jcode::sjis($line [, $icode [, $option]])
#   jcode::utf8($line [, $icode [, $option]])
#   jcode::jis_inout($in, $out)
#   jcode::get_inout($string)
#   jcode::cache()
#   jcode::nocache()
#   jcode::flushcache()
#   jcode::h2z_xxx(\$line)
#   jcode::z2h_xxx(\$line)
#   &{$jcode::z2hf{'xxx'}}(\$line)
#   &{$jcode::h2zf{'xxx'}}(\$line)
#   jcode::tr(\$line, $from, $to [, $option])
#   jcode::trans($line, $from, $to [, $option])
#   jcode::init()
#
######################################################################
#
# SAMPLES
#
# Convert any Kanji code to JIS and print each line with code name.
#
#   # require 'jcode.pl';
#   require 'jacode.pl';
#   while (defined($s = <>)) {
#       $code = &jcode'convert(*s, 'jis');
#       print $code, "\t", $s;
#   }
#
# Convert all lines to JIS according to the first recognized line.
#
#   # require 'jcode.pl';
#   require 'jacode.pl';
#   while (defined($s = <>)) {
#       print, next unless $s =~ /[\033\200-\377]/;
#       (*f, $icode) = &jcode'convert(*s, 'jis');
#       print;
#       defined(&f) || next;
#       while (<>) { &f(*s); print; }
#       last;
#   }
#
# The safest way of JIS conversion.
#
#   # require 'jcode.pl';
#   require 'jacode.pl';
#   while (defined($s = <>)) {
#       ($matched, $icode) = &jcode'getcode(*s);
#       if (@buf == 0 && $matched == 0) {
#           print $s;
#           next;
#       }
#       push(@buf, $s);
#       next unless $icode;
#       while (defined($s = shift(@buf))) {
#           &jcode'convert(*s, 'jis', $icode);
#           print $s;
#       }
#       while (defined($s = <>)) {
#           &jcode'convert(*s, 'jis', $icode);
#           print $s;
#       }
#       last;
#   }
#   print @buf if @buf;
#
######################################################################

#
# Call initialize function if it is not called yet.  This may sound
# strange but it makes easy to embed the jacode.pl at the end of
# script.  Call &jcode'init at the beginning of the script in that
# case.
#
&init unless defined $version;

#
# Initialize variables.
#
sub init {
    $version = $rcsid =~ /,v ([\d.]+)/ ? $1 : 'unknown';

    $re_bin = '[\000-\006\177\377]';

    $re_jis0208_1978 = '\e\$\@';
    $re_jis0208_1983 = '\e\$B';
    $re_jis0208_1990 = '\e&\@\e\$B';
    $re_jis0208      = "$re_jis0208_1978|$re_jis0208_1983|$re_jis0208_1990";
    $re_jis0212      = '\e\$\(D';
    $re_jp           = "$re_jis0208|$re_jis0212";
    $re_asc          = '\e\([BJ]';
    $re_kana         = '\e\(I';

    $esc_0208 = "\e\$B";
    $esc_0212 = "\e\$(D";
    $esc_asc  = "\e(B";
    $esc_kana = "\e(I";

    $re_ascii    = '[\007-\176]';
    $re_odd_kana = '[\241-\337]([\241-\337][\241-\337])*';

    $re_sjis_c    = '[\201-\237\340-\374][\100-\176\200-\374]';
    $re_sjis_kana = '[\241-\337]';
    $re_sjis_ank  = '[\007-\176\241-\337]';

    $re_euc_c    = '[\241-\376][\241-\376]';
    $re_euc_kana = '\216[\241-\337]';
    $re_euc_0212 = '\217[\241-\376][\241-\376]';

    # RFC 3629
    $re_utf8_rfc3629_c =
        '[\xc2-\xdf][\x80-\xbf]'
      . '|[\xe0-\xe0][\xa0-\xbf][\x80-\xbf]'
      . '|[\xe1-\xec][\x80-\xbf][\x80-\xbf]'
      . '|[\xed-\xed][\x80-\x9f][\x80-\xbf]'
      . '|[\xee-\xef][\x80-\xbf][\x80-\xbf]'
      . '|[\xf0-\xf0][\x90-\xbf][\x80-\xbf][\x80-\xbf]'
      . '|[\xf1-\xf3][\x80-\xbf][\x80-\xbf][\x80-\xbf]'
      . '|[\xf4-\xf4][\x80-\x8f][\x80-\xbf][\x80-\xbf]';

    # RFC 2279
    $re_utf8_rfc2279_c =
        '[\xc2-\xdf][\x80-\xbf]'
      . '|[\xe0-\xef][\x80-\xbf][\x80-\xbf]'
      . '|[\xf0-\xf4][\x80-\x8f][\x80-\xbf][\x80-\xbf]';

    $re_utf8_c    = $re_utf8_rfc3629_c;
    $re_utf8_kana = '\xef\xbd[\xa1-\xbf]|\xef\xbe[\x80-\x9f]';
    $re_utf8_voiced_kana =
        '(\xef\xbd[\xb3\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf]'
      . '|\xef\xbe[\x80\x81\x82\x83\x84\x8a\x8b\x8c\x8d\x8e])\xef\xbe\x9e'
      . '|\xef\xbe[\x8a\x8b\x8c\x8d\x8e]\xef\xbe\x9f';

    # Use `geta' for undefined character code
    $undef_sjis = "\x81\xac";
    $undef_euc  = "\xa2\xae";
    $undef_utf8 = "\xe3\x80\x93";

    $cache = 1;

    # JIS X0201 -> JIS X0208 KANA conversion table.  Looks weird?
    # Not that much.  This is simply JIS text without escape sequences.
    ( $h2z_high = $h2z = <<'__TABLE_END__') =~ tr/\041-\176/\241-\376/;
!   !#  $   !"  %   !&  "   !V  #   !W
^   !+  _   !,  0   !<
'   %!  (   %#  )   %%  *   %'  +   %)
,   %c  -   %e  .   %g  /   %C
1   %"  2   %$  3   %&  4   %(  5   %*
6   %+  7   %-  8   %/  9   %1  :   %3
6^  %,  7^  %.  8^  %0  9^  %2  :^  %4
;   %5  <   %7  =   %9  >   %;  ?   %=
;^  %6  <^  %8  =^  %:  >^  %<  ?^  %>
@   %?  A   %A  B   %D  C   %F  D   %H
@^  %@  A^  %B  B^  %E  C^  %G  D^  %I
E   %J  F   %K  G   %L  H   %M  I   %N
J   %O  K   %R  L   %U  M   %X  N   %[
J^  %P  K^  %S  L^  %V  M^  %Y  N^  %\
J_  %Q  K_  %T  L_  %W  M_  %Z  N_  %]
O   %^  P   %_  Q   %`  R   %a  S   %b
T   %d          U   %f          V   %h
W   %i  X   %j  Y   %k  Z   %l  [   %m
\   %o  ]   %s  &   %r  3^  %t
__TABLE_END__

    if ( $h2z ne <<'__TABLE_END__') {
!   !#  $   !"  %   !&  "   !V  #   !W
^   !+  _   !,  0   !<
'   %!  (   %#  )   %%  *   %'  +   %)
,   %c  -   %e  .   %g  /   %C
1   %"  2   %$  3   %&  4   %(  5   %*
6   %+  7   %-  8   %/  9   %1  :   %3
6^  %,  7^  %.  8^  %0  9^  %2  :^  %4
;   %5  <   %7  =   %9  >   %;  ?   %=
;^  %6  <^  %8  =^  %:  >^  %<  ?^  %>
@   %?  A   %A  B   %D  C   %F  D   %H
@^  %@  A^  %B  B^  %E  C^  %G  D^  %I
E   %J  F   %K  G   %L  H   %M  I   %N
J   %O  K   %R  L   %U  M   %X  N   %[
J^  %P  K^  %S  L^  %V  M^  %Y  N^  %\
J_  %Q  K_  %T  L_  %W  M_  %Z  N_  %]
O   %^  P   %_  Q   %`  R   %a  S   %b
T   %d          U   %f          V   %h
W   %i  X   %j  Y   %k  Z   %l  [   %m
\   %o  ]   %s  &   %r  3^  %t
__TABLE_END__
        die "JIS X0201 -> JIS X0208 KANA conversion table is broken.";
    }
    %h2z = split( /\s+/, $h2z . $h2z_high );
    %z2h = reverse %h2z;
    if ( scalar( keys %z2h ) != scalar( keys %h2z ) ) {
        die "scalar(keys %z2h) != scalar(keys %h2z).";
    }

    $convf{ 'jis',  'jis' }  = *jis2jis;
    $convf{ 'jis',  'sjis' } = *jis2sjis;
    $convf{ 'jis',  'euc' }  = *jis2euc;
    $convf{ 'jis',  'utf8' } = *jis2utf8;
    $convf{ 'euc',  'jis' }  = *euc2jis;
    $convf{ 'euc',  'sjis' } = *euc2sjis;
    $convf{ 'euc',  'euc' }  = *euc2euc;
    $convf{ 'euc',  'utf8' } = *euc2utf8;
    $convf{ 'sjis', 'jis' }  = *sjis2jis;
    $convf{ 'sjis', 'sjis' } = *sjis2sjis;
    $convf{ 'sjis', 'euc' }  = *sjis2euc;
    $convf{ 'sjis', 'utf8' } = *sjis2utf8;
    $convf{ 'utf8', 'jis' }  = *utf82jis;
    $convf{ 'utf8', 'sjis' } = *utf82sjis;
    $convf{ 'utf8', 'euc' }  = *utf82euc;
    $convf{ 'utf8', 'utf8' } = *utf82utf8;
    $h2zf{'jis'}  = *h2z_jis;
    $z2hf{'jis'}  = *z2h_jis;
    $h2zf{'euc'}  = *h2z_euc;
    $z2hf{'euc'}  = *z2h_euc;
    $h2zf{'sjis'} = *h2z_sjis;
    $z2hf{'sjis'} = *z2h_sjis;
    $h2zf{'utf8'} = *h2z_utf8;
    $z2hf{'utf8'} = *z2h_utf8;
}

#
# Set escape sequences which should be put before and after Japanese
# (JIS X0208) string.
#
sub jis_inout {
    $esc_0208 = shift || $esc_0208;
    $esc_0208 = "\e\$$esc_0208" if length($esc_0208) == 1;
    $esc_asc = shift || $esc_asc;
    $esc_asc = "\e\($esc_asc" if length($esc_asc) == 1;
    ( $esc_0208, $esc_asc );
}

#
# Get JIS in and out sequences from the string.
#
sub get_inout {
    local ( $esc_0208, $esc_asc );
    $_[$[] =~ /($re_jis0208)/o && ( $esc_0208 = $1 );
    $_[$[] =~ /($re_asc)/o     && ( $esc_asc  = $1 );
    ( $esc_0208, $esc_asc );
}

#
# Recognize character code.
#
sub getcode {
    local (*s) = @_;
    local ( $matched, $code );

    if ( $s !~ /[\e\200-\377]/ ) {    # not Japanese
        $matched = 0;
        $code    = undef;
    }
    elsif ( $s =~ /$re_jp|$re_asc|$re_kana/o ) {    # 'jis'
        $matched = 1;
        $code    = 'jis';
    }
    elsif ( $s =~ /$re_bin/o ) {                    # 'binary'
        $matched = 0;
        $code    = 'binary';
    }

    # Id: getcode.pl,v 0.01 1998/03/17 gama Exp
    # http://www2d.biglobe.ne.jp/~gama/cgi/list.cgi?bbs-ex2/getcode.pl

    elsif (/(^|[\000-\177])$re_odd_kana($|[\000-\177])/go) {    # odd katakana
        $matched = 1;
        $code    = 'sjis';
    }

    else {    # should be 'euc' or 'sjis' or 'utf8'
        local ( $sjis, $euc, $utf8 ) = ( 0, 0, 0 );

        # Id: getcode.pl,v 0.01 1998/03/17 gama Exp
        # http://www2d.biglobe.ne.jp/~gama/cgi/list.cgi?bbs-ex2/getcode.pl

        while ( $s =~ /(($re_sjis_c|$re_sjis_ank)+)/go ) {
            $sjis += length($1);
        }
        while ( $s =~ /(($re_euc_c|$re_euc_kana|$re_ascii|$re_euc_0212)+)/go ) {
            $euc += length($1);
        }
        while ( $s =~ /(($re_utf8_c)+)/go ) {
            $utf8 += length($1);
        }

        if ( $sjis > $euc ) {
            if ( $sjis > $utf8 ) {
                $matched = $sjis;
                $code    = 'sjis';
            }
            elsif ( $sjis == $utf8 ) {
                $matched = $sjis;
                if ( ( length($s) >= 30 ) && ( $matched >= 15 ) ) {
                    $code = 'utf8';
                }
                else {
                    $code = undef;
                }
            }
            else {
                $matched = $utf8;
                $code    = 'utf8';
            }
        }
        elsif ( $sjis == $euc ) {
            if ( $sjis > $utf8 ) {
                $matched = $sjis;

                # jcodeg.diff
                # http://www.vector.co.jp/soft/win95/prog/se347514.html

                if ( $s =~ /[\200-\237]/ ) {
                    $code = 'sjis';
                }
                elsif ( $s =~ /\216[^\241-\337]/ ) {
                    $code = 'sjis';
                }
                elsif ( $s =~ /\217[^\241-\376]/ ) {
                    $code = 'sjis';
                }
                elsif ( $s =~ /\217[\241-\376][^\241-\376]/ ) {
                    $code = 'sjis';
                }

                # Perl memo by OHZAKI Hiroki
                # http://www.din.or.jp/~ohzaki/perl.htm#JP_Code

                elsif ( $s =~
/^([\201-\237\340-\374][\100-\176\200-\374]|[\241-\337]|[\x00-\x7F])*$/
                  )
                {
                    if ( $s !~
/^([\241-\376][\241-\376]|\216[\241-\337]|\217[\241-\376][\241-\376]|[\x00-\x7F])*$/
                      )
                    {
                        $code = 'sjis';
                    }
                    else {
                        $code = 'euc';
                    }
                }
                else {
                    $code = 'euc';
                }
            }
            elsif ( $sjis == $utf8 ) {
                $matched = $sjis;
                $code    = undef;
            }
            else {
                $matched = $utf8;
                $code    = 'utf8';
            }
        }
        else {
            if ( $euc > $utf8 ) {
                $matched = $euc;
                $code    = 'euc';
            }
            elsif ( $euc == $utf8 ) {
                $matched = $euc;
                if ( ( length($s) >= 30 ) && ( $matched >= 15 ) ) {
                    $code = 'utf8';
                }
                else {
                    $code = undef;
                }
            }
            else {
                $matched = $utf8;
                $code    = 'utf8';
            }
        }
    }
    wantarray ? ( $matched, $code ) : $code;
}

#
# Convert any code to specified code.
#
sub convert {
    local ( *s, $ocode, $icode, $opt ) = @_;
    return ( undef, undef ) unless $icode = $icode || &getcode(*s);
    return ( undef, $icode ) if $icode eq 'binary';
    $ocode = 'jis' unless $ocode;
    $ocode = $icode if $ocode eq 'noconv';
    local (*f) = $convf{ $icode, $ocode };
    &f( *s, $opt );
    wantarray ? ( *f, $icode ) : $icode;
}

#
# Easy return-by-value interfaces.
#
sub jis  { &to( 'jis',  @_ ); }
sub euc  { &to( 'euc',  @_ ); }
sub sjis { &to( 'sjis', @_ ); }
sub utf8 { &to( 'utf8', @_ ); }

sub to {
    local ( $ocode, $s, $icode, $opt ) = @_;
    &convert( *s, $ocode, $icode, $opt );
    $s;
}

sub what {
    local ($s) = @_;
    &getcode(*s);
}

sub trans {
    local ($s) = shift;
    &tr( *s, @_ );
    $s;
}

#
# SJIS to JIS
#
sub sjis2jis {
    local ( *s, $opt, $n ) = @_;
    &sjis2sjis( *s, $opt ) if $opt;
    $s =~ s/(($re_sjis_c|$re_sjis_kana)+)/&_sjis2jis($1).$esc_asc/geo;
    $n;
}

sub _sjis2jis {
    local ($s) = shift;
    $s =~ s/(($re_sjis_c)+|($re_sjis_kana)+)/&__sjis2jis($1)/geo;
    $s;
}

sub __sjis2jis {
    local ($s) = shift;
    if ( $s =~ /^$re_sjis_kana/o ) {
        $n += $s =~ tr/\241-\337/\041-\137/;
        $esc_kana . $s;
    }
    else {
        $n += $s =~ s/($re_sjis_c)/$s2e{$1}||&s2e($1)/geo;
        $s =~ tr/\241-\376/\041-\176/;
        $esc_0208 . $s;
    }
}

#
# EUC to JIS
#
sub euc2jis {
    local ( *s, $opt, $n ) = @_;
    &euc2euc( *s, $opt ) if $opt;
    $s =~ s/(($re_euc_c|$re_euc_kana|$re_euc_0212)+)/&_euc2jis($1).$esc_asc/geo;
    $n;
}

sub _euc2jis {
    local ($s) = shift;
    $s =~ s/(($re_euc_c)+|($re_euc_kana)+|($re_euc_0212)+)/&__euc2jis($1)/geo;
    $s;
}

sub __euc2jis {
    local ($s) = shift;
    local ($esc);
    if ( $s =~ tr/\216//d ) {
        $esc = $esc_kana;
        $n += length($s);
    }
    elsif ( $s =~ tr/\217//d ) {
        $esc = $esc_0212;
        $n += length($s) / 2;
    }
    else {
        $esc = $esc_0208;
        $n += length($s) / 2;
    }
    $s =~ tr/\241-\376/\041-\176/;
    $esc . $s;
}

#
# JIS to EUC
#
sub jis2euc {
    local ( *s, $opt, $n ) = @_;
    $s =~ s/($re_jp|$re_asc|$re_kana)([^\e]*)/&_jis2euc($1,$2)/geo;
    &euc2euc( *s, $opt ) if $opt;
    $n;
}

sub _jis2euc {
    local ( $esc, $s ) = @_;
    if ( $esc !~ /^$re_asc/o ) {
        $s =~ tr/\041-\176/\241-\376/;
        if ( $esc =~ /^$re_kana/o ) {
            $n += $s =~ s/([\241-\337])/\216$1/g;
        }
        elsif ( $esc =~ /^$re_jis0212/o ) {
            $n += $s =~ s/([\241-\376][\241-\376])/\217$1/g;
        }
    }
    $s;
}

#
# JIS to SJIS
#
sub jis2sjis {
    local ( *s, $opt, $n ) = @_;
    &jis2jis( *s, $opt ) if $opt;
    $s =~ s/($re_jp|$re_asc|$re_kana)([^\e]*)/&_jis2sjis($1,$2)/geo;
    $n;
}

sub _jis2sjis {
    local ( $esc, $s ) = @_;
    if ( $esc =~ /^$re_jis0212/o ) {
        $n += $s =~ s/[\x00-\xff][\x00-\xff]/$undef_sjis/g;
    }
    elsif ( $esc !~ /^$re_asc/o ) {
        $s =~ tr/\041-\176/\241-\376/;
        if ( $esc =~ /^$re_jp/o ) {
            $n += $s =~ s/($re_euc_c)/$e2s{$1}||&e2s($1)/geo;
        }
    }
    $s;
}

#
# SJIS to EUC
#
sub sjis2euc {
    local ( *s, $opt, $n ) = @_;
    $n = $s =~ s/($re_sjis_c|$re_sjis_kana)/$s2e{$1}||&s2e($1)/geo;
    &euc2euc( *s, $opt ) if $opt;
    $n;
}

sub s2e {
    local ( $c1, $c2, $code );
    ( $c1, $c2 ) = unpack( 'CC', $code = shift );
    if ( $code gt "\xea\xa4" ) {
        $undef_euc;
    }
    else {
        if ( 0xa1 <= $c1 && $c1 <= 0xdf ) {
            $c2 = $c1;
            $c1 = 0x8e;
        }
        elsif ( 0x9f <= $c2 ) {
            $c1 = $c1 * 2 - ( $c1 >= 0xe0 ? 0xe0 : 0x60 );
            $c2 += 2;
        }
        else {
            $c1 = $c1 * 2 - ( $c1 >= 0xe0 ? 0xe1 : 0x61 );
            $c2 += 0x60 + ( $c2 < 0x7f );
        }
        if ($cache) {
            $s2e{$code} = pack( 'CC', $c1, $c2 );
        }
        else {
            pack( 'CC', $c1, $c2 );
        }
    }
}

#
# EUC to SJIS
#
sub euc2sjis {
    local ( *s, $opt, $n ) = @_;
    &euc2euc( *s, $opt ) if $opt;
    $n = $s =~ s/($re_euc_c|$re_euc_kana|$re_euc_0212)/$e2s{$1}||&e2s($1)/geo;
}

sub e2s {
    local ( $c1, $c2, $code );
    ( $c1, $c2 ) = unpack( 'CC', $code = shift );
    if ( $c1 == 0x8e ) {    # SS2
        return substr( $code, 1, 1 );
    }
    elsif ( $c1 == 0x8f ) {    # SS3
        return $undef_sjis;
    }
    elsif ( $c1 % 2 ) {
        $c1 = ( $c1 >> 1 ) + ( $c1 < 0xdf ? 0x31 : 0x71 );
        $c2 -= 0x60 + ( $c2 < 0xe0 );
    }
    else {
        $c1 = ( $c1 >> 1 ) + ( $c1 < 0xdf ? 0x30 : 0x70 );
        $c2 -= 2;
    }
    if ($cache) {
        $e2s{$code} = pack( 'CC', $c1, $c2 );
    }
    else {
        pack( 'CC', $c1, $c2 );
    }
}

#
# UTF8 to JIS
#
sub utf82jis {
    local ( *u, $opt, $n ) = @_;
    &utf82utf8( *u, $opt ) if $opt;
    $u =~ s/(($re_utf8_kana)+|($re_utf8_c)+)/&_utf82jis($1) . $esc_asc/geo;
    $n;
}

sub _utf82jis {
    local ($u) = shift;
    if ( $u =~ /^($re_utf8_kana)/o ) {
        &init_u2k unless defined %u2k;
        $n += $u =~ s/($re_utf8_kana)/$u2k{$1}/geo;
        $u =~ tr/\241-\376/\041-\176/;
        $esc_kana . $u;
    }
    else {
        $n += $u =~ s/($re_utf8_c)/$u2e{$1}||&u2e($1)/geo;
        $u =~ tr/\241-\376/\041-\176/;
        $esc_0208 . $u;
    }
}

#
# UTF8 to EUC
#
sub utf82euc {
    local ( *u, $opt, $n ) = @_;
    $u =~ s/(($re_utf8_kana)+|($re_utf8_c)+)/&_utf82euc($1)/geo;
    &euc2euc( *u, $opt ) if $opt;
    $n;
}

sub _utf82euc {
    local ($u) = shift;
    if ( $u =~ /^($re_utf8_kana)/o ) {
        &init_u2k unless defined %u2k;
        $n += $u =~ s/($re_utf8_kana)/"\216".$u2k{$1}/geo;
    }
    else {
        $n += $u =~ s/($re_utf8_c)/$u2e{$1}||&u2e($1)/geo;
    }
    $u;
}

sub u2e {
    local ($code) = shift;
    if ($cache) {
        $u2e{$code} = $s2e{ $u2s{$code} || &u2s($code) }
          || &s2e( $u2s{$code} || &u2s($code) );
    }
    else {
        $s2e{ $u2s{$code} || &u2s($code) }
          || &s2e( $u2s{$code} || &u2s($code) );
    }
}

#
# UTF8 to SJIS
#
sub utf82sjis {
    local ( *u, $opt, $n ) = @_;
    &utf82utf8( *u, $opt ) if $opt;
    $u =~ s/(($re_utf8_kana)+|($re_utf8_c)+)/&_utf82sjis($1)/geo;
    $n;
}

sub _utf82sjis {
    local ($u) = shift;
    if ( $u =~ /^($re_utf8_kana)$/o ) {
        &init_u2k unless defined %u2k;
        $n += $u =~ s/($re_utf8_kana)/$u2k{$1}/geo;
    }
    else {
        $n += $u =~ s/($re_utf8_c)/$u2s{$1}||&u2s($1)/geo;
    }
    $u;
}

sub u2s {
    local ($utf8);
    local ($code) = shift;
    &init_utf82sjis unless defined %utf82sjis;
    $utf8 = uc unpack 'H*', $code;
    if ( defined $utf82sjis{$utf8} ) {
        if ($cache) {
            $u2s{$code} = pack 'H*', $utf82sjis{$utf8};
        }
        else {
            pack 'H*', $utf82sjis{$utf8};
        }
    }
    else {
        $undef_sjis;
    }
}

#
# JIS to UTF8
#
sub jis2utf8 {
    local ( *u, $opt, $n ) = @_;
    $u =~ s/($re_jp|$re_asc|$re_kana)([^\e]*)/&_jis2utf8($1,$2)/geo;
    &utf82utf8( *s, $opt ) if $opt;
    $n;
}

sub _jis2utf8 {
    local ( $esc, $s ) = @_;
    if ( $esc =~ /^$re_jis0212/o ) {
        $n += $s =~ s/[\x00-\xff][\x00-\xff]/$undef_utf8/g;
    }
    elsif ( $esc =~ /^$re_kana/o ) {
        &init_k2u unless defined %k2u;
        $n += $s =~ tr/\041-\176/\241-\376/;
        $s =~ s/([\x00-\xff])/$k2u{$1}/ge;
    }
    elsif ( $esc !~ /^$re_asc/o ) {
        $n += $s =~ tr/\041-\176/\241-\376/;
        if ( $esc =~ /^$re_jp/o ) {
            $s =~ s/($re_euc_c)/$e2u{$1}||&e2u($1)/geo;
        }
    }
    $s;
}

#
# EUC to UTF8
#
sub euc2utf8 {
    local ( *u, $opt, $n ) = @_;
    &euc2euc( *u, $opt ) if $opt;
    $u =~ s/(($re_euc_c)+|($re_euc_kana)+|($re_euc_0212)+)/&_euc2utf8($1)/geo;
    $n;
}

sub _euc2utf8 {
    local ($s) = @_;
    if ( $s =~ /^$re_euc_0212/o ) {
        $n += $s =~ s/[\x00-\xff][\x00-\xff]/$undef_utf8/g;
    }
    elsif ( $s =~ /^$re_euc_kana/o ) {
        &init_k2u unless defined %k2u;
        $n += $s =~ s/\216([\x00-\xff])/$k2u{$1}/ge;
    }
    else {
        $n += $s =~ s/($re_euc_c)/$e2u{$1}||&e2u($1)/geo;
    }
    $s;
}

sub e2u {
    local ($code) = shift;
    if ($cache) {
        $e2u{$code} = $s2u{ $e2s{$code} || &e2s($code) }
          || &s2u( $e2s{$code} || &e2s($code) );
    }
    else {
        $s2u{ $e2s{$code} || &e2s($code) }
          || &s2u( $e2s{$code} || &e2s($code) );
    }
}

#
# SJIS to UTF8
#
sub sjis2utf8 {
    local ( *s, $opt, $n ) = @_;
    $n = $s =~ s/(($re_sjis_c)+|($re_sjis_kana)+)/&_sjis2utf8($1)/geo;
    &utf82utf8( *s, $opt ) if $opt;
    $n;
}

sub _sjis2utf8 {
    local ($s) = @_;
    if ( $s =~ /^$re_sjis_kana/o ) {
        &init_k2u unless defined %k2u;
        $n += $s =~ s/([\x00-\xff])/$k2u{$1}/ge;
    }
    else {
        $n += $s =~ s/($re_sjis_c)/$s2u{$1}||&s2u($1)/geo;
    }
    $s;
}

sub s2u {
    local ($sjis);
    local ($code) = shift;
    &init_sjis2utf8 unless defined %sjis2utf8;
    $sjis = uc unpack 'H*', $code;
    if ( defined $sjis2utf8{$sjis} ) {
        if ($cache) {
            $s2u{$code} = pack 'H*', $sjis2utf8{$sjis};
        }
        else {
            pack 'H*', $sjis2utf8{$sjis};
        }
    }
    else {
        $undef_utf8;
    }
}

#
# JIS to JIS, SJIS to SJIS, EUC to EUC, UTF8 to UTF8
#
sub jis2jis {
    local ( *s, $opt ) = @_;
    $s =~ s/$re_jis0208/$esc_0208/go;
    $s =~ s/$re_asc/$esc_asc/go;
    &h2z_jis(*s) if $opt =~ /z/;
    &z2h_jis(*s) if $opt =~ /h/;
}

sub sjis2sjis {
    local ( *s, $opt ) = @_;
    &h2z_sjis(*s) if $opt =~ /z/;
    &z2h_sjis(*s) if $opt =~ /h/;
}

sub euc2euc {
    local ( *s, $opt ) = @_;
    &h2z_euc(*s) if $opt =~ /z/;
    &z2h_euc(*s) if $opt =~ /h/;
}

sub utf82utf8 {
    local ( *s, $opt ) = @_;
    &h2z_utf8(*s) if $opt =~ /z/;
    &z2h_utf8(*s) if $opt =~ /h/;
}

#
# Cache control functions
#
sub cache {
    ( $cache, $cache = 1 )[$[];
}

sub nocache {
    ( $cache, $cache = 0 )[$[];
}

sub flushcache {
    undef %e2s;
    undef %s2e;
    undef %e2u;
    undef %u2e;
    undef %s2u;
    undef %u2s;
}

#
# JIS X0201 -> JIS X0208 KANA conversion routine
#
sub h2z_jis {
    local ( *s, $n ) = @_;
    if ( $s =~ s/$re_kana([^\e]*)/$esc_0208 . &_h2z_jis($1)/geo ) {
        1 while $s =~ s/(($re_jis0208)[^\e]*)($re_jis0208)/$1/o;
    }
    $n;
}

sub _h2z_jis {
    local ($s) = @_;
    $n += $s =~ s/(([\041-\137])([\136\137])?)/
    $h2z{$1} || $h2z{$2} . $h2z{$3}
    /ge;
    $s;
}

# Ad hoc patch for reduce waring on h2z_euc
# http://white.niu.ne.jp/yapw/yapw.cgi/jcode.pl%A4%CE%A5%A8%A5%E9%A1%BC%CD%DE%C0%A9
# by NAKATA Yoshinori

sub h2z_euc {
    local ( *s, $n ) = @_;
    $s =~ s/\216([\241-\337])(\216([\336\337]))?/
    ($n++, defined($3) ? ($h2z{"$1$3"} || $h2z{$1} . $h2z{$3}) : $h2z{$1})
    /ge;
    $n;
}

sub h2z_sjis {
    local ( *s, $n ) = @_;
    $s =~ s/(($re_sjis_c)+)|(([\241-\337])([\336\337])?)/
    $1 || ($n++, $h2z{$3} ? $e2s{$h2z{$3}} || &e2s($h2z{$3})
                  : &e2s($h2z{$4}) . ($5 && &e2s($h2z{$5})))
    /geo;
    $n;
}

sub h2z_utf8 {
    local ( *s, $n ) = @_;
    &init_h2z_utf8 unless defined %h2z_utf8;
    $s =~
s/($re_utf8_voiced_kana|$re_utf8_c)/$h2z_utf8{$1} ? ($n++, $h2z_utf8{$1}) : $1/geo;
    $n;
}

#
# JIS X0208 -> JIS X0201 KANA conversion routine
#
sub z2h_jis {
    local ( *s, $n ) = @_;
    $s =~ s/($re_jis0208)([^\e]+)/&_z2h_jis($2)/geo;
    $n;
}

sub _z2h_jis {
    local ($s) = @_;
    $s =~ s/((\%[!-~]|![\#\"&VW+,<])+|([^!%][!-~]|![^\#\"&VW+,<])+)/
    &__z2h_jis($1)
    /ge;
    $s;
}

sub __z2h_jis {
    local ($s) = @_;
    return $esc_0208 . $s unless $s =~ /^%/ || $s =~ /^![\#\"&VW+,<]/;
    $n += length($s) / 2;
    $s =~ s/([\x00-\xff][\x00-\xff])/$z2h{$1}/g;
    $esc_kana . $s;
}

sub z2h_euc {
    local ( *s, $n ) = @_;
    &init_z2h_euc unless defined %z2h_euc;
    $s =~ s/($re_euc_c|$re_euc_kana)/
    $z2h_euc{$1} ? ($n++, $z2h_euc{$1}) : $1
    /geo;
    $n;
}

sub z2h_sjis {
    local ( *s, $n ) = @_;
    &init_z2h_sjis unless defined %z2h_sjis;
    $s =~ s/($re_sjis_c)/$z2h_sjis{$1} ? ($n++, $z2h_sjis{$1}) : $1/geo;
    $n;
}

sub z2h_utf8 {
    local ( *s, $n ) = @_;
    &init_z2h_utf8 unless defined %z2h_utf8;
    $s =~ s/($re_utf8_c)/$z2h_utf8{$1} ? ($n++, $z2h_utf8{$1}) : $1/geo;
    $n;
}

#
# Initializing JIS X0208 to JIS X0201 KANA table for EUC and SJIS
# and UTF8.
# This can be done in &init but it's not worth doing.  Similarly,
# precalculated table is not worth to occupy the file space and
# reduce the readability.  The author personnaly discourages to use
# JIS X0201 Kana character in the any situation.
#
sub init_z2h_euc {
    local ( $k, $s );
    while ( ( $k, $s ) = each %z2h ) {
        $s =~ s/([\241-\337])/\216$1/g && ( $z2h_euc{$k} = $s );
    }
}

sub init_z2h_sjis {
    local ( $s, $v );
    while ( ( $s, $v ) = each %z2h ) {
        $s =~ /[\200-\377]/ && ( $z2h_sjis{ &e2s($s) } = $v );
    }
}

%_z2h_utf8 = (
    qw(
      E38082 EFBDA1
      E3808C EFBDA2
      E3808D EFBDA3
      E38081 EFBDA4
      E383BB EFBDA5
      E383B2 EFBDA6
      E382A1 EFBDA7
      E382A3 EFBDA8
      E382A5 EFBDA9
      E382A7 EFBDAA
      E382A9 EFBDAB
      E383A3 EFBDAC
      E383A5 EFBDAD
      E383A7 EFBDAE
      E38383 EFBDAF
      E383BC EFBDB0
      E382A2 EFBDB1
      E382A4 EFBDB2
      E382A6 EFBDB3
      E382A8 EFBDB4
      E382AA EFBDB5
      E382AB EFBDB6
      E382AD EFBDB7
      E382AF EFBDB8
      E382B1 EFBDB9
      E382B3 EFBDBA
      E382B5 EFBDBB
      E382B7 EFBDBC
      E382B9 EFBDBD
      E382BB EFBDBE
      E382BD EFBDBF
      E382BF EFBE80
      E38381 EFBE81
      E38384 EFBE82
      E38386 EFBE83
      E38388 EFBE84
      E3838A EFBE85
      E3838B EFBE86
      E3838C EFBE87
      E3838D EFBE88
      E3838E EFBE89
      E3838F EFBE8A
      E38392 EFBE8B
      E38395 EFBE8C
      E38398 EFBE8D
      E3839B EFBE8E
      E3839E EFBE8F
      E3839F EFBE90
      E383A0 EFBE91
      E383A1 EFBE92
      E383A2 EFBE93
      E383A4 EFBE94
      E383A6 EFBE95
      E383A8 EFBE96
      E383A9 EFBE97
      E383AA EFBE98
      E383AB EFBE99
      E383AC EFBE9A
      E383AD EFBE9B
      E383AF EFBE9C
      E383B3 EFBE9D
      E3829B EFBE9E
      E3829C EFBE9F
      E383B4 EFBDB3EFBE9E
      E382AC EFBDB6EFBE9E
      E382AE EFBDB7EFBE9E
      E382B0 EFBDB8EFBE9E
      E382B2 EFBDB9EFBE9E
      E382B4 EFBDBAEFBE9E
      E382B6 EFBDBBEFBE9E
      E382B8 EFBDBCEFBE9E
      E382BA EFBDBDEFBE9E
      E382BC EFBDBEEFBE9E
      E382BE EFBDBFEFBE9E
      E38380 EFBE80EFBE9E
      E38382 EFBE81EFBE9E
      E38385 EFBE82EFBE9E
      E38387 EFBE83EFBE9E
      E38389 EFBE84EFBE9E
      E38390 EFBE8AEFBE9E
      E38393 EFBE8BEFBE9E
      E38396 EFBE8CEFBE9E
      E38399 EFBE8DEFBE9E
      E3839C EFBE8EEFBE9E
      E38391 EFBE8AEFBE9F
      E38394 EFBE8BEFBE9F
      E38397 EFBE8CEFBE9F
      E3839A EFBE8DEFBE9F
      E3839D EFBE8EEFBE9F
      )
);

sub init_z2h_utf8 {
    if ( defined %h2z_utf8 ) {
        %z2h_utf8 = reverse %h2z_utf8;
        if ( scalar( keys %z2h_utf8 ) != scalar( keys %h2z_utf8 ) ) {
            die "scalar(keys %z2h_utf8) != scalar(keys %h2z_utf8).";
        }
    }
    else {
        local ( $z, $h );
        while ( ( $z, $h ) = each %_z2h_utf8 ) {
            $z2h_utf8{ pack 'H*', $z } = pack 'H*', $h;
        }
    }
}

sub init_h2z_utf8 {
    if ( defined %z2h_utf8 ) {
        %h2z_utf8 = reverse %z2h_utf8;
        if ( scalar( keys %h2z_utf8 ) != scalar( keys %z2h_utf8 ) ) {
            die "scalar(keys %h2z_utf8) != scalar(keys %z2h_utf8).";
        }
    }
    else {
        local ( $z, $h );
        while ( ( $z, $h ) = each %_z2h_utf8 ) {
            $h2z_utf8{ pack 'H*', $h } = pack 'H*', $z;
        }
    }
}

# JP170559 CodePage 932 : 398 non-round-trip mappings
# http://support.microsoft.com/kb/170559/ja

%JP170559 = (
    qw(
      81E0 E28992
      81DF E289A1
      81E7 E288AB
      81E3 E2889A
      81DB E28AA5
      81DA E288A0
      81E6 E288B5
      81BF E288A9
      81BE E288AA
      FA5C E7BA8A
      FA5D E8A49C
      FA5E E98D88
      FA5F E98A88
      FA60 E8939C
      FA61 E4BF89
      FA62 E782BB
      FA63 E698B1
      FA64 E6A388
      FA65 E98BB9
      FA66 E69BBB
      FA67 E5BD85
      FA68 E4B8A8
      FA69 E4BBA1
      FA6A E4BBBC
      FA6B E4BC80
      FA6C E4BC83
      FA6D E4BCB9
      FA6E E4BD96
      FA6F E4BE92
      FA70 E4BE8A
      FA71 E4BE9A
      FA72 E4BE94
      FA73 E4BF8D
      FA74 E58180
      FA75 E580A2
      FA76 E4BFBF
      FA77 E5809E
      FA78 E58186
      FA79 E581B0
      FA7A E58182
      FA7B E58294
      FA7C E583B4
      FA7D E58398
      FA7E E5858A
      FA80 E585A4
      FA81 E5869D
      FA82 E586BE
      FA83 E587AC
      FA84 E58895
      FA85 E58A9C
      FA86 E58AA6
      FA87 E58B80
      FA88 E58B9B
      FA89 E58C80
      FA8A E58C87
      FA8B E58CA4
      FA8C E58DB2
      FA8D E58E93
      FA8E E58EB2
      FA8F E58F9D
      FA90 EFA88E
      FA91 E5929C
      FA92 E5928A
      FA93 E592A9
      FA94 E593BF
      FA95 E59686
      FA96 E59D99
      FA97 E59DA5
      FA98 E59EAC
      FA99 E59F88
      FA9A E59F87
      FA9B EFA88F
      FA9C EFA890
      FA9D E5A29E
      FA9E E5A2B2
      FA9F E5A48B
      FAA0 E5A593
      FAA1 E5A59B
      FAA2 E5A59D
      FAA3 E5A5A3
      FAA4 E5A6A4
      FAA5 E5A6BA
      FAA6 E5AD96
      FAA7 E5AF80
      FAA8 E794AF
      FAA9 E5AF98
      FAAA E5AFAC
      FAAB E5B09E
      FAAC E5B2A6
      FAAD E5B2BA
      FAAE E5B3B5
      FAAF E5B4A7
      FAB0 E5B593
      FAB1 EFA891
      FAB2 E5B582
      FAB3 E5B5AD
      FAB4 E5B6B8
      FAB5 E5B6B9
      FAB6 E5B790
      FAB7 E5BCA1
      FAB8 E5BCB4
      FAB9 E5BDA7
      FABA E5BEB7
      FABB E5BF9E
      FABC E6819D
      FABD E68285
      FABE E6828A
      FABF E6839E
      FAC0 E68395
      FAC1 E684A0
      FAC2 E683B2
      FAC3 E68491
      FAC4 E684B7
      FAC5 E684B0
      FAC6 E68698
      FAC7 E68893
      FAC8 E68AA6
      FAC9 E68FB5
      FACA E691A0
      FACB E6929D
      FACC E6938E
      FACD E6958E
      FACE E69880
      FACF E69895
      FAD0 E698BB
      FAD1 E69889
      FAD2 E698AE
      FAD3 E6989E
      FAD4 E698A4
      FAD5 E699A5
      FAD6 E69997
      FAD7 E69999
      FAD8 EFA892
      FAD9 E699B3
      FADA E69A99
      FADB E69AA0
      FADC E69AB2
      FADD E69ABF
      FADE E69BBA
      FADF E69C8E
      FAE0 EFA4A9
      FAE1 E69DA6
      FAE2 E69EBB
      FAE3 E6A192
      FAE4 E69F80
      FAE5 E6A081
      FAE6 E6A184
      FAE7 E6A38F
      FAE8 EFA893
      FAE9 E6A5A8
      FAEA EFA894
      FAEB E6A698
      FAEC E6A7A2
      FAED E6A8B0
      FAEE E6A9AB
      FAEF E6A986
      FAF0 E6A9B3
      FAF1 E6A9BE
      FAF2 E6ABA2
      FAF3 E6ABA4
      FAF4 E6AF96
      FAF5 E6B0BF
      FAF6 E6B19C
      FAF7 E6B286
      FAF8 E6B1AF
      FAF9 E6B39A
      FAFA E6B484
      FAFB E6B687
      FAFC E6B5AF
      FB40 E6B696
      FB41 E6B6AC
      FB42 E6B78F
      FB43 E6B7B8
      FB44 E6B7B2
      FB45 E6B7BC
      FB46 E6B8B9
      FB47 E6B99C
      FB48 E6B8A7
      FB49 E6B8BC
      FB4A E6BABF
      FB4B E6BE88
      FB4C E6BEB5
      FB4D E6BFB5
      FB4E E78085
      FB4F E78087
      FB50 E780A8
      FB51 E78285
      FB52 E782AB
      FB53 E7848F
      FB54 E78484
      FB55 E7859C
      FB56 E78586
      FB57 E78587
      FB58 EFA895
      FB59 E78781
      FB5A E787BE
      FB5B E78AB1
      FB5C E78ABE
      FB5D E78CA4
      FB5E EFA896
      FB5F E78DB7
      FB60 E78EBD
      FB61 E78F89
      FB62 E78F96
      FB63 E78FA3
      FB64 E78F92
      FB65 E79087
      FB66 E78FB5
      FB67 E790A6
      FB68 E790AA
      FB69 E790A9
      FB6A E790AE
      FB6B E791A2
      FB6C E79289
      FB6D E7929F
      FB6E E79481
      FB6F E795AF
      FB70 E79A82
      FB71 E79A9C
      FB72 E79A9E
      FB73 E79A9B
      FB74 E79AA6
      FB75 EFA897
      FB76 E79D86
      FB77 E58AAF
      FB78 E7A0A1
      FB79 E7A18E
      FB7A E7A1A4
      FB7B E7A1BA
      FB7C E7A4B0
      FB7D EFA898
      FB7E EFA899
      FB80 EFA89A
      FB81 E7A694
      FB82 EFA89B
      FB83 E7A69B
      FB84 E7AB91
      FB85 E7ABA7
      FB86 EFA89C
      FB87 E7ABAB
      FB88 E7AE9E
      FB89 EFA89D
      FB8A E7B588
      FB8B E7B59C
      FB8C E7B6B7
      FB8D E7B6A0
      FB8E E7B796
      FB8F E7B992
      FB90 E7BD87
      FB91 E7BEA1
      FB92 EFA89E
      FB93 E88C81
      FB94 E88DA2
      FB95 E88DBF
      FB96 E88F87
      FB97 E88FB6
      FB98 E89188
      FB99 E892B4
      FB9A E89593
      FB9B E89599
      FB9C E895AB
      FB9D EFA89F
      FB9E E896B0
      FB9F EFA8A0
      FBA0 EFA8A1
      FBA1 E8A087
      FBA2 E8A3B5
      FBA3 E8A892
      FBA4 E8A8B7
      FBA5 E8A9B9
      FBA6 E8AAA7
      FBA7 E8AABE
      FBA8 E8AB9F
      FBA9 EFA8A2
      FBAA E8ABB6
      FBAB E8AD93
      FBAC E8ADBF
      FBAD E8B3B0
      FBAE E8B3B4
      FBAF E8B492
      FBB0 E8B5B6
      FBB1 EFA8A3
      FBB2 E8BB8F
      FBB3 EFA8A4
      FBB4 EFA8A5
      FBB5 E981A7
      FBB6 E9839E
      FBB7 EFA8A6
      FBB8 E98495
      FBB9 E984A7
      FBBA E9879A
      FBBB E98797
      FBBC E9879E
      FBBD E987AD
      FBBE E987AE
      FBBF E987A4
      FBC0 E987A5
      FBC1 E98886
      FBC2 E98890
      FBC3 E9888A
      FBC4 E988BA
      FBC5 E98980
      FBC6 E988BC
      FBC7 E9898E
      FBC8 E98999
      FBC9 E98991
      FBCA E988B9
      FBCB E989A7
      FBCC E98AA7
      FBCD E989B7
      FBCE E989B8
      FBCF E98BA7
      FBD0 E98B97
      FBD1 E98B99
      FBD2 E98B90
      FBD3 EFA8A7
      FBD4 E98B95
      FBD5 E98BA0
      FBD6 E98B93
      FBD7 E98CA5
      FBD8 E98CA1
      FBD9 E98BBB
      FBDA EFA8A8
      FBDB E98C9E
      FBDC E98BBF
      FBDD E98C9D
      FBDE E98C82
      FBDF E98DB0
      FBE0 E98D97
      FBE1 E98EA4
      FBE2 E98F86
      FBE3 E98F9E
      FBE4 E98FB8
      FBE5 E990B1
      FBE6 E99185
      FBE7 E99188
      FBE8 E99692
      FBE9 EFA79C
      FBEA EFA8A9
      FBEB E99A9D
      FBEC E99AAF
      FBED E99CB3
      FBEE E99CBB
      FBEF E99D83
      FBF0 E99D8D
      FBF1 E99D8F
      FBF2 E99D91
      FBF3 E99D95
      FBF4 E9A197
      FBF5 E9A1A5
      FBF6 EFA8AA
      FBF7 EFA8AB
      FBF8 E9A4A7
      FBF9 EFA8AC
      FBFA E9A69E
      FBFB E9A98E
      FBFC E9AB99
      FC40 E9AB9C
      FC41 E9ADB5
      FC42 E9ADB2
      FC43 E9AE8F
      FC44 E9AEB1
      FC45 E9AEBB
      FC46 E9B080
      FC47 E9B5B0
      FC48 E9B5AB
      FC49 EFA8AD
      FC4A E9B899
      FC4B E9BB91
      FA40 E285B0
      FA41 E285B1
      FA42 E285B2
      FA43 E285B3
      FA44 E285B4
      FA45 E285B5
      FA46 E285B6
      FA47 E285B7
      FA48 E285B8
      FA49 E285B9
      81CA EFBFA2
      FA55 EFBFA4
      FA56 EFBC87
      FA57 EFBC82
      8754 E285A0
      8755 E285A1
      8756 E285A2
      8757 E285A3
      8758 E285A4
      8759 E285A5
      875A E285A6
      875B E285A7
      875C E285A8
      875D E285A9
      81CA EFBFA2
      878A E388B1
      8782 E28496
      8784 E284A1
      81E6 E288B5
      )
);

sub init_sjis2utf8 {
    local $/ = undef;
    %sjis2utf8 = split /\s+/, <DATA>;
}

sub init_utf82sjis {
    &init_sjis2utf8 unless defined %sjis2utf8;
    %utf82sjis = reverse %sjis2utf8;
    @utf82sjis{ values %JP170559 } = keys %JP170559;
}

%kana2utf8 = (
    qw(
      A1 EFBDA1
      A2 EFBDA2
      A3 EFBDA3
      A4 EFBDA4
      A5 EFBDA5
      A6 EFBDA6
      A7 EFBDA7
      A8 EFBDA8
      A9 EFBDA9
      AA EFBDAA
      AB EFBDAB
      AC EFBDAC
      AD EFBDAD
      AE EFBDAE
      AF EFBDAF
      B0 EFBDB0
      B1 EFBDB1
      B2 EFBDB2
      B3 EFBDB3
      B4 EFBDB4
      B5 EFBDB5
      B6 EFBDB6
      B7 EFBDB7
      B8 EFBDB8
      B9 EFBDB9
      BA EFBDBA
      BB EFBDBB
      BC EFBDBC
      BD EFBDBD
      BE EFBDBE
      BF EFBDBF
      C0 EFBE80
      C1 EFBE81
      C2 EFBE82
      C3 EFBE83
      C4 EFBE84
      C5 EFBE85
      C6 EFBE86
      C7 EFBE87
      C8 EFBE88
      C9 EFBE89
      CA EFBE8A
      CB EFBE8B
      CC EFBE8C
      CD EFBE8D
      CE EFBE8E
      CF EFBE8F
      D0 EFBE90
      D1 EFBE91
      D2 EFBE92
      D3 EFBE93
      D4 EFBE94
      D5 EFBE95
      D6 EFBE96
      D7 EFBE97
      D8 EFBE98
      D9 EFBE99
      DA EFBE9A
      DB EFBE9B
      DC EFBE9C
      DD EFBE9D
      DE EFBE9E
      DF EFBE9F
      )
);

sub init_k2u {
    if ( defined %u2k ) {
        %k2u = reverse %u2k;
        if ( scalar( keys %k2u ) != scalar( keys %u2k ) ) {
            die "scalar(keys %k2u) != scalar(keys %u2k).";
        }
    }
    else {
        local ( $k, $u );
        while ( ( $k, $u ) = each %kana2utf8 ) {
            $k2u{ pack 'H*', $k } = pack 'H*', $u;
        }
    }
}

sub init_u2k {
    if ( defined %k2u ) {
        %u2k = reverse %k2u;
        if ( scalar( keys %u2k ) != scalar( keys %k2u ) ) {
            die "scalar(keys %u2k) != scalar(keys %k2u).";
        }
    }
    else {
        local ( $k, $u );
        while ( ( $k, $u ) = each %kana2utf8 ) {
            $u2k{ pack 'H*', $u } = pack 'H*', $k;
        }
    }
}

#
# TR function for 2-byte code
#
sub tr {

    # $prev_from, $prev_to, %table are persistent variables
    local ( *s, $from, $to, $opt ) = @_;
    local ( @from, @to );
    local ( $jis, $n ) = ( 0, 0 );

    $jis++, &jis2euc(*s) if $s =~ /$re_jp|$re_asc|$re_kana/o;
    $jis++ if $to =~ /$re_jp|$re_asc|$re_kana/o;

    # jcodeg.diff
    # http://www.vector.co.jp/soft/win95/prog/se347514.html

    if (   !defined($prev_from)
        || $from ne $prev_from
        || $to   ne $prev_to
        || $opt  ne $prev_opt )
    {
        ( $prev_from, $prev_to, $prev_opt ) = ( $from, $to, $opt );
        undef %table;
        &_maketable;
    }

    $s =~ s/([\200-\377][\000-\377]|[\000-\377])/
    defined($table{$1}) && ++$n ? $table{$1} : $1
    /ge;

    &euc2jis(*s) if $jis;

    $n;
}

sub _maketable {
    local ($ascii) = '(\\\\[\\-\\\\]|[\0-\133\135-\177])';

    &jis2euc(*to)   if $to   =~ /$re_jp|$re_asc|$re_kana/o;
    &jis2euc(*from) if $from =~ /$re_jp|$re_asc|$re_kana/o;

    grep( s/(([\200-\377])[\200-\377]-\2[\200-\377])/&_expnd2($1)/ge,
        $from, $to );
    grep( s/($ascii-$ascii)/&_expnd1($1)/geo, $from, $to );

    @to   = $to   =~ /[\200-\377][\000-\377]|[\000-\377]/g;
    @from = $from =~ /[\200-\377][\000-\377]|[\000-\377]/g;
    push( @to, ( $opt =~ /d/ ? '' : $to[$#to] ) x ( @from - @to ) )
      if @to < @from;
    @table{@from} = @to;
}

sub _expnd1 {
    local ($s) = @_;
    $s =~ s/\\([\x00-\xff])/$1/g;
    local ( $c1, $c2 ) = unpack( 'CxC', $s );
    if ( $c1 <= $c2 ) {
        for ( $s = '' ; $c1 <= $c2 ; $c1++ ) {
            $s .= pack( 'C', $c1 );
        }
    }
    $s;
}

sub _expnd2 {
    local ($s) = @_;
    local ( $c1, $c2, $c3, $c4 ) = unpack( 'CCxCC', $s );
    if ( $c1 == $c3 && $c2 <= $c4 ) {
        for ( $s = '' ; $c2 <= $c4 ; $c2++ ) {
            $s .= pack( 'CC', $c1, $c2 );
        }
    }
    $s;
}

1;

# http://unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/CP932.TXT
#
#    Name:     cp932 to Unicode table
#    Unicode version: 2.0
#    Table version: 2.01
#    Table format:  Format A
#    Date:          04/15/98
#
#    Contact:       Shawn.Steele@microsoft.com
#
#    General notes: none
#
#    Format: Three tab-separated columns
#        Column #1 is the cp932 code (in hex)
#        Column #2 is the Unicode (in hex as 0xXXXX)
#        Column #3 is the Unicode name (follows a comment sign, '#')
#
#    The entries are in cp932 order
#

__DATA__
8140 E38080
8141 E38081
8142 E38082
8143 EFBC8C
8144 EFBC8E
8145 E383BB
8146 EFBC9A
8147 EFBC9B
8148 EFBC9F
8149 EFBC81
814A E3829B
814B E3829C
814C C2B4
814D EFBD80
814E C2A8
814F EFBCBE
8150 EFBFA3
8151 EFBCBF
8152 E383BD
8153 E383BE
8154 E3829D
8155 E3829E
8156 E38083
8157 E4BB9D
8158 E38085
8159 E38086
815A E38087
815B E383BC
815C E28095
815D E28090
815E EFBC8F
815F EFBCBC
8160 EFBD9E
8161 E288A5
8162 EFBD9C
8163 E280A6
8164 E280A5
8165 E28098
8166 E28099
8167 E2809C
8168 E2809D
8169 EFBC88
816A EFBC89
816B E38094
816C E38095
816D EFBCBB
816E EFBCBD
816F EFBD9B
8170 EFBD9D
8171 E38088
8172 E38089
8173 E3808A
8174 E3808B
8175 E3808C
8176 E3808D
8177 E3808E
8178 E3808F
8179 E38090
817A E38091
817B EFBC8B
817C EFBC8D
817D C2B1
817E C397
8180 C3B7
8181 EFBC9D
8182 E289A0
8183 EFBC9C
8184 EFBC9E
8185 E289A6
8186 E289A7
8187 E2889E
8188 E288B4
8189 E29982
818A E29980
818B C2B0
818C E280B2
818D E280B3
818E E28483
818F EFBFA5
8190 EFBC84
8191 EFBFA0
8192 EFBFA1
8193 EFBC85
8194 EFBC83
8195 EFBC86
8196 EFBC8A
8197 EFBCA0
8198 C2A7
8199 E29886
819A E29885
819B E2978B
819C E2978F
819D E2978E
819E E29787
819F E29786
81A0 E296A1
81A1 E296A0
81A2 E296B3
81A3 E296B2
81A4 E296BD
81A5 E296BC
81A6 E280BB
81A7 E38092
81A8 E28692
81A9 E28690
81AA E28691
81AB E28693
81AC E38093
81B8 E28888
81B9 E2888B
81BA E28A86
81BB E28A87
81BC E28A82
81BD E28A83
81BE E288AA
81BF E288A9
81C8 E288A7
81C9 E288A8
81CA EFBFA2
81CB E28792
81CC E28794
81CD E28880
81CE E28883
81DA E288A0
81DB E28AA5
81DC E28C92
81DD E28882
81DE E28887
81DF E289A1
81E0 E28992
81E1 E289AA
81E2 E289AB
81E3 E2889A
81E4 E288BD
81E5 E2889D
81E6 E288B5
81E7 E288AB
81E8 E288AC
81F0 E284AB
81F1 E280B0
81F2 E299AF
81F3 E299AD
81F4 E299AA
81F5 E280A0
81F6 E280A1
81F7 C2B6
81FC E297AF
824F EFBC90
8250 EFBC91
8251 EFBC92
8252 EFBC93
8253 EFBC94
8254 EFBC95
8255 EFBC96
8256 EFBC97
8257 EFBC98
8258 EFBC99
8260 EFBCA1
8261 EFBCA2
8262 EFBCA3
8263 EFBCA4
8264 EFBCA5
8265 EFBCA6
8266 EFBCA7
8267 EFBCA8
8268 EFBCA9
8269 EFBCAA
826A EFBCAB
826B EFBCAC
826C EFBCAD
826D EFBCAE
826E EFBCAF
826F EFBCB0
8270 EFBCB1
8271 EFBCB2
8272 EFBCB3
8273 EFBCB4
8274 EFBCB5
8275 EFBCB6
8276 EFBCB7
8277 EFBCB8
8278 EFBCB9
8279 EFBCBA
8281 EFBD81
8282 EFBD82
8283 EFBD83
8284 EFBD84
8285 EFBD85
8286 EFBD86
8287 EFBD87
8288 EFBD88
8289 EFBD89
828A EFBD8A
828B EFBD8B
828C EFBD8C
828D EFBD8D
828E EFBD8E
828F EFBD8F
8290 EFBD90
8291 EFBD91
8292 EFBD92
8293 EFBD93
8294 EFBD94
8295 EFBD95
8296 EFBD96
8297 EFBD97
8298 EFBD98
8299 EFBD99
829A EFBD9A
829F E38181
82A0 E38182
82A1 E38183
82A2 E38184
82A3 E38185
82A4 E38186
82A5 E38187
82A6 E38188
82A7 E38189
82A8 E3818A
82A9 E3818B
82AA E3818C
82AB E3818D
82AC E3818E
82AD E3818F
82AE E38190
82AF E38191
82B0 E38192
82B1 E38193
82B2 E38194
82B3 E38195
82B4 E38196
82B5 E38197
82B6 E38198
82B7 E38199
82B8 E3819A
82B9 E3819B
82BA E3819C
82BB E3819D
82BC E3819E
82BD E3819F
82BE E381A0
82BF E381A1
82C0 E381A2
82C1 E381A3
82C2 E381A4
82C3 E381A5
82C4 E381A6
82C5 E381A7
82C6 E381A8
82C7 E381A9
82C8 E381AA
82C9 E381AB
82CA E381AC
82CB E381AD
82CC E381AE
82CD E381AF
82CE E381B0
82CF E381B1
82D0 E381B2
82D1 E381B3
82D2 E381B4
82D3 E381B5
82D4 E381B6
82D5 E381B7
82D6 E381B8
82D7 E381B9
82D8 E381BA
82D9 E381BB
82DA E381BC
82DB E381BD
82DC E381BE
82DD E381BF
82DE E38280
82DF E38281
82E0 E38282
82E1 E38283
82E2 E38284
82E3 E38285
82E4 E38286
82E5 E38287
82E6 E38288
82E7 E38289
82E8 E3828A
82E9 E3828B
82EA E3828C
82EB E3828D
82EC E3828E
82ED E3828F
82EE E38290
82EF E38291
82F0 E38292
82F1 E38293
8340 E382A1
8341 E382A2
8342 E382A3
8343 E382A4
8344 E382A5
8345 E382A6
8346 E382A7
8347 E382A8
8348 E382A9
8349 E382AA
834A E382AB
834B E382AC
834C E382AD
834D E382AE
834E E382AF
834F E382B0
8350 E382B1
8351 E382B2
8352 E382B3
8353 E382B4
8354 E382B5
8355 E382B6
8356 E382B7
8357 E382B8
8358 E382B9
8359 E382BA
835A E382BB
835B E382BC
835C E382BD
835D E382BE
835E E382BF
835F E38380
8360 E38381
8361 E38382
8362 E38383
8363 E38384
8364 E38385
8365 E38386
8366 E38387
8367 E38388
8368 E38389
8369 E3838A
836A E3838B
836B E3838C
836C E3838D
836D E3838E
836E E3838F
836F E38390
8370 E38391
8371 E38392
8372 E38393
8373 E38394
8374 E38395
8375 E38396
8376 E38397
8377 E38398
8378 E38399
8379 E3839A
837A E3839B
837B E3839C
837C E3839D
837D E3839E
837E E3839F
8380 E383A0
8381 E383A1
8382 E383A2
8383 E383A3
8384 E383A4
8385 E383A5
8386 E383A6
8387 E383A7
8388 E383A8
8389 E383A9
838A E383AA
838B E383AB
838C E383AC
838D E383AD
838E E383AE
838F E383AF
8390 E383B0
8391 E383B1
8392 E383B2
8393 E383B3
8394 E383B4
8395 E383B5
8396 E383B6
839F CE91
83A0 CE92
83A1 CE93
83A2 CE94
83A3 CE95
83A4 CE96
83A5 CE97
83A6 CE98
83A7 CE99
83A8 CE9A
83A9 CE9B
83AA CE9C
83AB CE9D
83AC CE9E
83AD CE9F
83AE CEA0
83AF CEA1
83B0 CEA3
83B1 CEA4
83B2 CEA5
83B3 CEA6
83B4 CEA7
83B5 CEA8
83B6 CEA9
83BF CEB1
83C0 CEB2
83C1 CEB3
83C2 CEB4
83C3 CEB5
83C4 CEB6
83C5 CEB7
83C6 CEB8
83C7 CEB9
83C8 CEBA
83C9 CEBB
83CA CEBC
83CB CEBD
83CC CEBE
83CD CEBF
83CE CF80
83CF CF81
83D0 CF83
83D1 CF84
83D2 CF85
83D3 CF86
83D4 CF87
83D5 CF88
83D6 CF89
8440 D090
8441 D091
8442 D092
8443 D093
8444 D094
8445 D095
8446 D081
8447 D096
8448 D097
8449 D098
844A D099
844B D09A
844C D09B
844D D09C
844E D09D
844F D09E
8450 D09F
8451 D0A0
8452 D0A1
8453 D0A2
8454 D0A3
8455 D0A4
8456 D0A5
8457 D0A6
8458 D0A7
8459 D0A8
845A D0A9
845B D0AA
845C D0AB
845D D0AC
845E D0AD
845F D0AE
8460 D0AF
8470 D0B0
8471 D0B1
8472 D0B2
8473 D0B3
8474 D0B4
8475 D0B5
8476 D191
8477 D0B6
8478 D0B7
8479 D0B8
847A D0B9
847B D0BA
847C D0BB
847D D0BC
847E D0BD
8480 D0BE
8481 D0BF
8482 D180
8483 D181
8484 D182
8485 D183
8486 D184
8487 D185
8488 D186
8489 D187
848A D188
848B D189
848C D18A
848D D18B
848E D18C
848F D18D
8490 D18E
8491 D18F
849F E29480
84A0 E29482
84A1 E2948C
84A2 E29490
84A3 E29498
84A4 E29494
84A5 E2949C
84A6 E294AC
84A7 E294A4
84A8 E294B4
84A9 E294BC
84AA E29481
84AB E29483
84AC E2948F
84AD E29493
84AE E2949B
84AF E29497
84B0 E294A3
84B1 E294B3
84B2 E294AB
84B3 E294BB
84B4 E2958B
84B5 E294A0
84B6 E294AF
84B7 E294A8
84B8 E294B7
84B9 E294BF
84BA E2949D
84BB E294B0
84BC E294A5
84BD E294B8
84BE E29582
8740 E291A0
8741 E291A1
8742 E291A2
8743 E291A3
8744 E291A4
8745 E291A5
8746 E291A6
8747 E291A7
8748 E291A8
8749 E291A9
874A E291AA
874B E291AB
874C E291AC
874D E291AD
874E E291AE
874F E291AF
8750 E291B0
8751 E291B1
8752 E291B2
8753 E291B3
8754 E285A0
8755 E285A1
8756 E285A2
8757 E285A3
8758 E285A4
8759 E285A5
875A E285A6
875B E285A7
875C E285A8
875D E285A9
875F E38D89
8760 E38C94
8761 E38CA2
8762 E38D8D
8763 E38C98
8764 E38CA7
8765 E38C83
8766 E38CB6
8767 E38D91
8768 E38D97
8769 E38C8D
876A E38CA6
876B E38CA3
876C E38CAB
876D E38D8A
876E E38CBB
876F E38E9C
8770 E38E9D
8771 E38E9E
8772 E38E8E
8773 E38E8F
8774 E38F84
8775 E38EA1
877E E38DBB
8780 E3809D
8781 E3809F
8782 E28496
8783 E38F8D
8784 E284A1
8785 E38AA4
8786 E38AA5
8787 E38AA6
8788 E38AA7
8789 E38AA8
878A E388B1
878B E388B2
878C E388B9
878D E38DBE
878E E38DBD
878F E38DBC
8790 E28992
8791 E289A1
8792 E288AB
8793 E288AE
8794 E28891
8795 E2889A
8796 E28AA5
8797 E288A0
8798 E2889F
8799 E28ABF
879A E288B5
879B E288A9
879C E288AA
889F E4BA9C
88A0 E59496
88A1 E5A883
88A2 E998BF
88A3 E59380
88A4 E6849B
88A5 E68CA8
88A6 E5A7B6
88A7 E980A2
88A8 E891B5
88A9 E88C9C
88AA E7A990
88AB E682AA
88AC E68FA1
88AD E6B8A5
88AE E697AD
88AF E891A6
88B0 E88AA6
88B1 E9AFB5
88B2 E6A293
88B3 E59CA7
88B4 E696A1
88B5 E689B1
88B6 E5AE9B
88B7 E5A790
88B8 E899BB
88B9 E9A3B4
88BA E7B5A2
88BB E7B6BE
88BC E9AE8E
88BD E68896
88BE E7B29F
88BF E8A2B7
88C0 E5AE89
88C1 E5BAB5
88C2 E68C89
88C3 E69A97
88C4 E6A188
88C5 E99787
88C6 E99E8D
88C7 E69D8F
88C8 E4BBA5
88C9 E4BC8A
88CA E4BD8D
88CB E4BE9D
88CC E58189
88CD E59BB2
88CE E5A4B7
88CF E5A794
88D0 E5A881
88D1 E5B089
88D2 E6839F
88D3 E6848F
88D4 E685B0
88D5 E69893
88D6 E6A485
88D7 E782BA
88D8 E7958F
88D9 E795B0
88DA E7A7BB
88DB E7B6AD
88DC E7B7AF
88DD E88383
88DE E8908E
88DF E8A1A3
88E0 E8AC82
88E1 E98195
88E2 E981BA
88E3 E58CBB
88E4 E4BA95
88E5 E4BAA5
88E6 E59F9F
88E7 E882B2
88E8 E98381
88E9 E7A3AF
88EA E4B880
88EB E5A3B1
88EC E6BAA2
88ED E980B8
88EE E7A8B2
88EF E88CA8
88F0 E88A8B
88F1 E9B0AF
88F2 E58581
88F3 E58DB0
88F4 E592BD
88F5 E593A1
88F6 E59BA0
88F7 E5A7BB
88F8 E5BC95
88F9 E9A3B2
88FA E6B7AB
88FB E883A4
88FC E894AD
8940 E999A2
8941 E999B0
8942 E99AA0
8943 E99FBB
8944 E5908B
8945 E58FB3
8946 E5AE87
8947 E7838F
8948 E7BEBD
8949 E8BF82
894A E99BA8
894B E58DAF
894C E9B59C
894D E7AABA
894E E4B891
894F E7A293
8950 E887BC
8951 E6B8A6
8952 E59898
8953 E59484
8954 E6AC9D
8955 E8949A
8956 E9B0BB
8957 E5A7A5
8958 E58EA9
8959 E6B5A6
895A E7939C
895B E9968F
895C E59982
895D E4BA91
895E E9818B
895F E99BB2
8960 E88D8F
8961 E9A48C
8962 E58FA1
8963 E596B6
8964 E5ACB0
8965 E5BDB1
8966 E698A0
8967 E69BB3
8968 E6A084
8969 E6B0B8
896A E6B3B3
896B E6B4A9
896C E7919B
896D E79B88
896E E7A98E
896F E9A0B4
8970 E88BB1
8971 E8A19B
8972 E8A9A0
8973 E98BAD
8974 E6B6B2
8975 E796AB
8976 E79B8A
8977 E9A785
8978 E682A6
8979 E8AC81
897A E8B68A
897B E996B2
897C E6A68E
897D E58EAD
897E E58686
8980 E59C92
8981 E5A0B0
8982 E5A584
8983 E5AEB4
8984 E5BBB6
8985 E680A8
8986 E68EA9
8987 E68FB4
8988 E6B2BF
8989 E6BC94
898A E7828E
898B E78494
898C E78599
898D E78795
898E E78CBF
898F E7B881
8990 E889B6
8991 E88B91
8992 E89697
8993 E981A0
8994 E9899B
8995 E9B49B
8996 E5A1A9
8997 E696BC
8998 E6B19A
8999 E794A5
899A E587B9
899B E5A4AE
899C E5A5A5
899D E5BE80
899E E5BF9C
899F E68ABC
89A0 E697BA
89A1 E6A8AA
89A2 E6ACA7
89A3 E6AEB4
89A4 E78E8B
89A5 E7BF81
89A6 E8A596
89A7 E9B4AC
89A8 E9B48E
89A9 E9BB84
89AA E5B2A1
89AB E6B296
89AC E88DBB
89AD E58484
89AE E5B18B
89AF E686B6
89B0 E88786
89B1 E6A1B6
89B2 E789A1
89B3 E4B999
89B4 E4BFBA
89B5 E58DB8
89B6 E681A9
89B7 E6B8A9
89B8 E7A98F
89B9 E99FB3
89BA E4B88B
89BB E58C96
89BC E4BBAE
89BD E4BD95
89BE E4BCBD
89BF E4BEA1
89C0 E4BDB3
89C1 E58AA0
89C2 E58FAF
89C3 E59889
89C4 E5A48F
89C5 E5AB81
89C6 E5AEB6
89C7 E5AFA1
89C8 E7A791
89C9 E69A87
89CA E69E9C
89CB E69EB6
89CC E6AD8C
89CD E6B2B3
89CE E781AB
89CF E78F82
89D0 E7A68D
89D1 E7A6BE
89D2 E7A8BC
89D3 E7AE87
89D4 E88AB1
89D5 E88B9B
89D6 E88C84
89D7 E88DB7
89D8 E88FAF
89D9 E88F93
89DA E89DA6
89DB E8AAB2
89DC E598A9
89DD E8B2A8
89DE E8BFA6
89DF E9818E
89E0 E99C9E
89E1 E89A8A
89E2 E4BF84
89E3 E5B3A8
89E4 E68891
89E5 E78999
89E6 E794BB
89E7 E887A5
89E8 E88ABD
89E9 E89BBE
89EA E8B380
89EB E99B85
89EC E9A493
89ED E9A795
89EE E4BB8B
89EF E4BC9A
89F0 E8A7A3
89F1 E59B9E
89F2 E5A18A
89F3 E5A38A
89F4 E5BBBB
89F5 E5BFAB
89F6 E680AA
89F7 E68294
89F8 E681A2
89F9 E68790
89FA E68892
89FB E68B90
89FC E694B9
8A40 E9AD81
8A41 E699A6
8A42 E6A2B0
8A43 E6B5B7
8A44 E781B0
8A45 E7958C
8A46 E79A86
8A47 E7B5B5
8A48 E88AA5
8A49 E89FB9
8A4A E9968B
8A4B E99A8E
8A4C E8B29D
8A4D E587B1
8A4E E58ABE
8A4F E5A496
8A50 E592B3
8A51 E5AEB3
8A52 E5B496
8A53 E685A8
8A54 E6A682
8A55 E6B6AF
8A56 E7A28D
8A57 E8938B
8A58 E8A197
8A59 E8A9B2
8A5A E98EA7
8A5B E9AAB8
8A5C E6B5AC
8A5D E9A6A8
8A5E E89B99
8A5F E59EA3
8A60 E69FBF
8A61 E89B8E
8A62 E9888E
8A63 E58A83
8A64 E59A87
8A65 E59084
8A66 E5BB93
8A67 E68BA1
8A68 E692B9
8A69 E6A0BC
8A6A E6A0B8
8A6B E6AEBB
8A6C E78DB2
8A6D E7A2BA
8A6E E7A9AB
8A6F E8A69A
8A70 E8A792
8A71 E8B5AB
8A72 E8BC83
8A73 E983AD
8A74 E996A3
8A75 E99A94
8A76 E99DA9
8A77 E5ADA6
8A78 E5B2B3
8A79 E6A5BD
8A7A E9A18D
8A7B E9A18E
8A7C E68E9B
8A7D E7ACA0
8A7E E6A8AB
8A80 E6A9BF
8A81 E6A2B6
8A82 E9B08D
8A83 E6BD9F
8A84 E589B2
8A85 E5969D
8A86 E681B0
8A87 E68BAC
8A88 E6B4BB
8A89 E6B887
8A8A E6BB91
8A8B E8919B
8A8C E8A490
8A8D E8BD84
8A8E E4B894
8A8F E9B0B9
8A90 E58FB6
8A91 E6A49B
8A92 E6A8BA
8A93 E99E84
8A94 E6A0AA
8A95 E5859C
8A96 E7AB83
8A97 E892B2
8A98 E9879C
8A99 E98E8C
8A9A E5999B
8A9B E9B4A8
8A9C E6A0A2
8A9D E88C85
8A9E E890B1
8A9F E7B2A5
8AA0 E58888
8AA1 E88B85
8AA2 E793A6
8AA3 E4B9BE
8AA4 E4BE83
8AA5 E586A0
8AA6 E5AF92
8AA7 E5888A
8AA8 E58B98
8AA9 E58BA7
8AAA E5B7BB
8AAB E5969A
8AAC E5A0AA
8AAD E5A7A6
8AAE E5AE8C
8AAF E5AE98
8AB0 E5AF9B
8AB1 E5B9B2
8AB2 E5B9B9
8AB3 E682A3
8AB4 E6849F
8AB5 E685A3
8AB6 E686BE
8AB7 E68F9B
8AB8 E695A2
8AB9 E69F91
8ABA E6A193
8ABB E6A3BA
8ABC E6ACBE
8ABD E6AD93
8ABE E6B197
8ABF E6BCA2
8AC0 E6BE97
8AC1 E6BD85
8AC2 E792B0
8AC3 E79498
8AC4 E79BA3
8AC5 E79C8B
8AC6 E7ABBF
8AC7 E7AEA1
8AC8 E7B0A1
8AC9 E7B7A9
8ACA E7BCB6
8ACB E7BFB0
8ACC E8829D
8ACD E889A6
8ACE E88E9E
8ACF E8A6B3
8AD0 E8AB8C
8AD1 E8B2AB
8AD2 E98284
8AD3 E99191
8AD4 E99693
8AD5 E99691
8AD6 E996A2
8AD7 E999A5
8AD8 E99F93
8AD9 E9A4A8
8ADA E88898
8ADB E4B8B8
8ADC E590AB
8ADD E5B2B8
8ADE E5B78C
8ADF E78EA9
8AE0 E7998C
8AE1 E79CBC
8AE2 E5B2A9
8AE3 E7BFAB
8AE4 E8B48B
8AE5 E99B81
8AE6 E9A091
8AE7 E9A194
8AE8 E9A198
8AE9 E4BC81
8AEA E4BC8E
8AEB E58DB1
8AEC E5969C
8AED E599A8
8AEE E59FBA
8AEF E5A587
8AF0 E5AC89
8AF1 E5AF84
8AF2 E5B290
8AF3 E5B88C
8AF4 E5B9BE
8AF5 E5BF8C
8AF6 E68FAE
8AF7 E69CBA
8AF8 E69797
8AF9 E697A2
8AFA E69C9F
8AFB E6A38B
8AFC E6A384
8B40 E6A99F
8B41 E5B8B0
8B42 E6AF85
8B43 E6B097
8B44 E6B1BD
8B45 E795BF
8B46 E7A588
8B47 E5ADA3
8B48 E7A880
8B49 E7B480
8B4A E5BEBD
8B4B E8A68F
8B4C E8A898
8B4D E8B2B4
8B4E E8B5B7
8B4F E8BB8C
8B50 E8BC9D
8B51 E9A3A2
8B52 E9A88E
8B53 E9ACBC
8B54 E4BA80
8B55 E581BD
8B56 E58480
8B57 E5A693
8B58 E5AE9C
8B59 E688AF
8B5A E68A80
8B5B E693AC
8B5C E6ACBA
8B5D E78AA0
8B5E E79691
8B5F E7A587
8B60 E7BEA9
8B61 E89FBB
8B62 E8AABC
8B63 E8ADB0
8B64 E68EAC
8B65 E88F8A
8B66 E99EA0
8B67 E59089
8B68 E59083
8B69 E596AB
8B6A E6A194
8B6B E6A998
8B6C E8A9B0
8B6D E7A0A7
8B6E E69DB5
8B6F E9BB8D
8B70 E58DB4
8B71 E5AEA2
8B72 E8849A
8B73 E89990
8B74 E98086
8B75 E4B898
8B76 E4B985
8B77 E4BB87
8B78 E4BC91
8B79 E58F8A
8B7A E590B8
8B7B E5AEAE
8B7C E5BC93
8B7D E680A5
8B7E E69591
8B80 E69CBD
8B81 E6B182
8B82 E6B1B2
8B83 E6B3A3
8B84 E781B8
8B85 E79083
8B86 E7A9B6
8B87 E7AAAE
8B88 E7AC88
8B89 E7B49A
8B8A E7B3BE
8B8B E7B5A6
8B8C E697A7
8B8D E7899B
8B8E E58EBB
8B8F E5B185
8B90 E5B7A8
8B91 E68B92
8B92 E68BA0
8B93 E68C99
8B94 E6B8A0
8B95 E8999A
8B96 E8A8B1
8B97 E8B79D
8B98 E98BB8
8B99 E6BC81
8B9A E7A6A6
8B9B E9AD9A
8B9C E4BAA8
8B9D E4BAAB
8B9E E4BAAC
8B9F E4BE9B
8BA0 E4BEA0
8BA1 E58391
8BA2 E58587
8BA3 E7ABB6
8BA4 E585B1
8BA5 E587B6
8BA6 E58D94
8BA7 E58CA1
8BA8 E58DBF
8BA9 E58FAB
8BAA E596AC
8BAB E5A283
8BAC E5B3A1
8BAD E5BCB7
8BAE E5BD8A
8BAF E680AF
8BB0 E68190
8BB1 E681AD
8BB2 E68C9F
8BB3 E69599
8BB4 E6A98B
8BB5 E6B381
8BB6 E78B82
8BB7 E78BAD
8BB8 E79FAF
8BB9 E883B8
8BBA E88485
8BBB E88888
8BBC E8958E
8BBD E983B7
8BBE E98FA1
8BBF E99FBF
8BC0 E9A597
8BC1 E9A99A
8BC2 E4BBB0
8BC3 E5879D
8BC4 E5B0AD
8BC5 E69A81
8BC6 E6A5AD
8BC7 E5B180
8BC8 E69BB2
8BC9 E6A5B5
8BCA E78E89
8BCB E6A190
8BCC E7B281
8BCD E58385
8BCE E58BA4
8BCF E59D87
8BD0 E5B7BE
8BD1 E98CA6
8BD2 E696A4
8BD3 E6ACA3
8BD4 E6ACBD
8BD5 E790B4
8BD6 E7A681
8BD7 E7A6BD
8BD8 E7AD8B
8BD9 E7B78A
8BDA E88AB9
8BDB E88F8C
8BDC E8A1BF
8BDD E8A59F
8BDE E8ACB9
8BDF E8BF91
8BE0 E98791
8BE1 E5909F
8BE2 E98A80
8BE3 E4B99D
8BE4 E580B6
8BE5 E58FA5
8BE6 E58CBA
8BE7 E78B97
8BE8 E78E96
8BE9 E79FA9
8BEA E88BA6
8BEB E8BAAF
8BEC E9A786
8BED E9A788
8BEE E9A792
8BEF E585B7
8BF0 E6849A
8BF1 E8999E
8BF2 E596B0
8BF3 E7A9BA
8BF4 E581B6
8BF5 E5AF93
8BF6 E98187
8BF7 E99A85
8BF8 E4B8B2
8BF9 E6AB9B
8BFA E987A7
8BFB E5B191
8BFC E5B188
8C40 E68E98
8C41 E7AA9F
8C42 E6B293
8C43 E99DB4
8C44 E8BDA1
8C45 E7AAAA
8C46 E7868A
8C47 E99A88
8C48 E7B282
8C49 E6A097
8C4A E7B9B0
8C4B E6A191
8C4C E98DAC
8C4D E58BB2
8C4E E5909B
8C4F E896AB
8C50 E8A893
8C51 E7BEA4
8C52 E8BB8D
8C53 E983A1
8C54 E58DA6
8C55 E8A288
8C56 E7A581
8C57 E4BF82
8C58 E582BE
8C59 E58891
8C5A E58584
8C5B E59593
8C5C E59CAD
8C5D E78FAA
8C5E E59E8B
8C5F E5A591
8C60 E5BDA2
8C61 E5BE84
8C62 E681B5
8C63 E685B6
8C64 E685A7
8C65 E686A9
8C66 E68EB2
8C67 E690BA
8C68 E695AC
8C69 E699AF
8C6A E6A182
8C6B E6B893
8C6C E795A6
8C6D E7A8BD
8C6E E7B3BB
8C6F E7B58C
8C70 E7B699
8C71 E7B98B
8C72 E7BDAB
8C73 E88C8E
8C74 E88D8A
8C75 E89B8D
8C76 E8A888
8C77 E8A9A3
8C78 E8ADA6
8C79 E8BBBD
8C7A E9A09A
8C7B E9B68F
8C7C E88AB8
8C7D E8BF8E
8C7E E9AFA8
8C80 E58A87
8C81 E6889F
8C82 E69283
8C83 E6BF80
8C84 E99A99
8C85 E6A181
8C86 E58291
8C87 E6ACA0
8C88 E6B1BA
8C89 E6BD94
8C8A E7A9B4
8C8B E7B590
8C8C E8A180
8C8D E8A8A3
8C8E E69C88
8C8F E4BBB6
8C90 E580B9
8C91 E580A6
8C92 E581A5
8C93 E585BC
8C94 E588B8
8C95 E589A3
8C96 E596A7
8C97 E59C8F
8C98 E5A085
8C99 E5AB8C
8C9A E5BBBA
8C9B E686B2
8C9C E687B8
8C9D E68BB3
8C9E E68DB2
8C9F E6A49C
8CA0 E6A8A9
8CA1 E789BD
8CA2 E78AAC
8CA3 E78CAE
8CA4 E7A094
8CA5 E7A1AF
8CA6 E7B5B9
8CA7 E79C8C
8CA8 E882A9
8CA9 E8A68B
8CAA E8AC99
8CAB E8B3A2
8CAC E8BB92
8CAD E981A3
8CAE E98DB5
8CAF E999BA
8CB0 E9A195
8CB1 E9A893
8CB2 E9B9B8
8CB3 E58583
8CB4 E58E9F
8CB5 E58EB3
8CB6 E5B9BB
8CB7 E5BCA6
8CB8 E6B89B
8CB9 E6BA90
8CBA E78E84
8CBB E78FBE
8CBC E7B583
8CBD E888B7
8CBE E8A880
8CBF E8ABBA
8CC0 E99990
8CC1 E4B98E
8CC2 E5808B
8CC3 E58FA4
8CC4 E591BC
8CC5 E59BBA
8CC6 E5A791
8CC7 E5ADA4
8CC8 E5B7B1
8CC9 E5BAAB
8CCA E5BCA7
8CCB E688B8
8CCC E69585
8CCD E69EAF
8CCE E6B996
8CCF E78B90
8CD0 E7B38A
8CD1 E8A2B4
8CD2 E882A1
8CD3 E883A1
8CD4 E88FB0
8CD5 E8998E
8CD6 E8AA87
8CD7 E8B7A8
8CD8 E988B7
8CD9 E99B87
8CDA E9A1A7
8CDB E9BC93
8CDC E4BA94
8CDD E4BA92
8CDE E4BC8D
8CDF E58D88
8CE0 E59189
8CE1 E590BE
8CE2 E5A8AF
8CE3 E5BE8C
8CE4 E5BEA1
8CE5 E6829F
8CE6 E6A2A7
8CE7 E6AA8E
8CE8 E7919A
8CE9 E7A281
8CEA E8AA9E
8CEB E8AAA4
8CEC E8ADB7
8CED E98690
8CEE E4B99E
8CEF E9AF89
8CF0 E4BAA4
8CF1 E4BDBC
8CF2 E4BEAF
8CF3 E58099
8CF4 E58096
8CF5 E58589
8CF6 E585AC
8CF7 E58A9F
8CF8 E58AB9
8CF9 E58BBE
8CFA E58E9A
8CFB E58FA3
8CFC E59091
8D40 E5908E
8D41 E59689
8D42 E59D91
8D43 E59EA2
8D44 E5A5BD
8D45 E5AD94
8D46 E5AD9D
8D47 E5AE8F
8D48 E5B7A5
8D49 E5B7A7
8D4A E5B7B7
8D4B E5B9B8
8D4C E5BA83
8D4D E5BA9A
8D4E E5BAB7
8D4F E5BC98
8D50 E68192
8D51 E6858C
8D52 E68A97
8D53 E68B98
8D54 E68EA7
8D55 E694BB
8D56 E69882
8D57 E69983
8D58 E69BB4
8D59 E69DAD
8D5A E6A0A1
8D5B E6A297
8D5C E6A78B
8D5D E6B19F
8D5E E6B4AA
8D5F E6B5A9
8D60 E6B8AF
8D61 E6BA9D
8D62 E794B2
8D63 E79A87
8D64 E7A1AC
8D65 E7A8BF
8D66 E7B3A0
8D67 E7B485
8D68 E7B498
8D69 E7B59E
8D6A E7B6B1
8D6B E88095
8D6C E88083
8D6D E882AF
8D6E E882B1
8D6F E88594
8D70 E8868F
8D71 E888AA
8D72 E88D92
8D73 E8A18C
8D74 E8A1A1
8D75 E8AC9B
8D76 E8B2A2
8D77 E8B3BC
8D78 E9838A
8D79 E985B5
8D7A E989B1
8D7B E7A0BF
8D7C E98BBC
8D7D E996A4
8D7E E9998D
8D80 E9A085
8D81 E9A699
8D82 E9AB98
8D83 E9B4BB
8D84 E5899B
8D85 E58AAB
8D86 E58FB7
8D87 E59088
8D88 E5A395
8D89 E68BB7
8D8A E6BFA0
8D8B E8B1AA
8D8C E8BD9F
8D8D E9BAB9
8D8E E5858B
8D8F E588BB
8D90 E5918A
8D91 E59BBD
8D92 E7A980
8D93 E985B7
8D94 E9B5A0
8D95 E9BB92
8D96 E78D84
8D97 E6BC89
8D98 E885B0
8D99 E79491
8D9A E5BFBD
8D9B E6839A
8D9C E9AAA8
8D9D E78B9B
8D9E E8BEBC
8D9F E6ADA4
8DA0 E9A083
8DA1 E4BB8A
8DA2 E59BB0
8DA3 E59DA4
8DA4 E5A2BE
8DA5 E5A99A
8DA6 E681A8
8DA7 E68787
8DA8 E6988F
8DA9 E69886
8DAA E6A0B9
8DAB E6A2B1
8DAC E6B7B7
8DAD E79795
8DAE E7B4BA
8DAF E889AE
8DB0 E9AD82
8DB1 E4BA9B
8DB2 E4BD90
8DB3 E58F89
8DB4 E59486
8DB5 E5B5AF
8DB6 E5B7A6
8DB7 E5B7AE
8DB8 E69FBB
8DB9 E6B299
8DBA E791B3
8DBB E7A082
8DBC E8A990
8DBD E98E96
8DBE E8A39F
8DBF E59D90
8DC0 E5BAA7
8DC1 E68CAB
8DC2 E582B5
8DC3 E582AC
8DC4 E5868D
8DC5 E69C80
8DC6 E59389
8DC7 E5A19E
8DC8 E5A6BB
8DC9 E5AEB0
8DCA E5BDA9
8DCB E6898D
8DCC E68EA1
8DCD E6A0BD
8DCE E6ADB3
8DCF E6B888
8DD0 E781BD
8DD1 E98787
8DD2 E78A80
8DD3 E7A095
8DD4 E7A0A6
8DD5 E7A5AD
8DD6 E6968E
8DD7 E7B4B0
8DD8 E88F9C
8DD9 E8A381
8DDA E8BC89
8DDB E99A9B
8DDC E589A4
8DDD E59CA8
8DDE E69D90
8DDF E7BDAA
8DE0 E8B2A1
8DE1 E586B4
8DE2 E59D82
8DE3 E998AA
8DE4 E5A0BA
8DE5 E6A68A
8DE6 E882B4
8DE7 E592B2
8DE8 E5B48E
8DE9 E59FBC
8DEA E7A295
8DEB E9B7BA
8DEC E4BD9C
8DED E5898A
8DEE E5928B
8DEF E690BE
8DF0 E698A8
8DF1 E69C94
8DF2 E69FB5
8DF3 E7AA84
8DF4 E7AD96
8DF5 E7B4A2
8DF6 E98CAF
8DF7 E6A19C
8DF8 E9AEAD
8DF9 E7ACB9
8DFA E58C99
8DFB E5868A
8DFC E588B7
8E40 E5AF9F
8E41 E68BB6
8E42 E692AE
8E43 E693A6
8E44 E69CAD
8E45 E6AEBA
8E46 E896A9
8E47 E99B91
8E48 E79A90
8E49 E9AF96
8E4A E68D8C
8E4B E98C86
8E4C E9AEAB
8E4D E79ABF
8E4E E69992
8E4F E4B889
8E50 E58298
8E51 E58F82
8E52 E5B1B1
8E53 E683A8
8E54 E69292
8E55 E695A3
8E56 E6A19F
8E57 E787A6
8E58 E78F8A
8E59 E794A3
8E5A E7AE97
8E5B E7BA82
8E5C E89A95
8E5D E8AE83
8E5E E8B39B
8E5F E985B8
8E60 E9A490
8E61 E696AC
8E62 E69AAB
8E63 E6AE8B
8E64 E4BB95
8E65 E4BB94
8E66 E4BCBA
8E67 E4BDBF
8E68 E588BA
8E69 E58FB8
8E6A E58FB2
8E6B E597A3
8E6C E59B9B
8E6D E5A3AB
8E6E E5A78B
8E6F E5A789
8E70 E5A7BF
8E71 E5AD90
8E72 E5B18D
8E73 E5B882
8E74 E5B8AB
8E75 E5BF97
8E76 E6809D
8E77 E68C87
8E78 E694AF
8E79 E5AD9C
8E7A E696AF
8E7B E696BD
8E7C E697A8
8E7D E69E9D
8E7E E6ADA2
8E80 E6ADBB
8E81 E6B08F
8E82 E78D85
8E83 E7A589
8E84 E7A781
8E85 E7B3B8
8E86 E7B499
8E87 E7B4AB
8E88 E882A2
8E89 E88482
8E8A E887B3
8E8B E8A696
8E8C E8A99E
8E8D E8A9A9
8E8E E8A9A6
8E8F E8AA8C
8E90 E8ABAE
8E91 E8B387
8E92 E8B39C
8E93 E99B8C
8E94 E9A3BC
8E95 E6ADAF
8E96 E4BA8B
8E97 E4BCBC
8E98 E4BE8D
8E99 E58590
8E9A E5AD97
8E9B E5AFBA
8E9C E68588
8E9D E68C81
8E9E E69982
8E9F E6ACA1
8EA0 E6BB8B
8EA1 E6B2BB
8EA2 E788BE
8EA3 E792BD
8EA4 E79794
8EA5 E7A381
8EA6 E7A4BA
8EA7 E8808C
8EA8 E880B3
8EA9 E887AA
8EAA E89294
8EAB E8BE9E
8EAC E6B190
8EAD E9B9BF
8EAE E5BC8F
8EAF E8AD98
8EB0 E9B4AB
8EB1 E7ABBA
8EB2 E8BBB8
8EB3 E5AE8D
8EB4 E99BAB
8EB5 E4B883
8EB6 E58FB1
8EB7 E59FB7
8EB8 E5A4B1
8EB9 E5AB89
8EBA E5AEA4
8EBB E68289
8EBC E6B9BF
8EBD E6BC86
8EBE E796BE
8EBF E8B3AA
8EC0 E5AE9F
8EC1 E89480
8EC2 E7AFA0
8EC3 E581B2
8EC4 E69FB4
8EC5 E88A9D
8EC6 E5B1A1
8EC7 E8958A
8EC8 E7B89E
8EC9 E8888E
8ECA E58699
8ECB E5B084
8ECC E68DA8
8ECD E8B5A6
8ECE E6969C
8ECF E785AE
8ED0 E7A4BE
8ED1 E7B497
8ED2 E88085
8ED3 E8AC9D
8ED4 E8BB8A
8ED5 E981AE
8ED6 E89B87
8ED7 E982AA
8ED8 E5809F
8ED9 E58BBA
8EDA E5B0BA
8EDB E69D93
8EDC E781BC
8EDD E788B5
8EDE E9858C
8EDF E98788
8EE0 E98CAB
8EE1 E88BA5
8EE2 E5AF82
8EE3 E5BCB1
8EE4 E683B9
8EE5 E4B8BB
8EE6 E58F96
8EE7 E5AE88
8EE8 E6898B
8EE9 E69CB1
8EEA E6AE8A
8EEB E78BA9
8EEC E78FA0
8EED E7A8AE
8EEE E885AB
8EEF E8B6A3
8EF0 E98592
8EF1 E9A696
8EF2 E58492
8EF3 E58F97
8EF4 E591AA
8EF5 E5AFBF
8EF6 E68E88
8EF7 E6A8B9
8EF8 E7B6AC
8EF9 E99C80
8EFA E59B9A
8EFB E58F8E
8EFC E591A8
8F40 E5AE97
8F41 E5B0B1
8F42 E5B79E
8F43 E4BFAE
8F44 E68481
8F45 E68BBE
8F46 E6B4B2
8F47 E7A780
8F48 E7A78B
8F49 E7B582
8F4A E7B98D
8F4B E7BF92
8F4C E887AD
8F4D E8889F
8F4E E89290
8F4F E8A186
8F50 E8A5B2
8F51 E8AE90
8F52 E8B9B4
8F53 E8BCAF
8F54 E980B1
8F55 E9858B
8F56 E985AC
8F57 E99B86
8F58 E9869C
8F59 E4BB80
8F5A E4BD8F
8F5B E58585
8F5C E58D81
8F5D E5BE93
8F5E E6888E
8F5F E69F94
8F60 E6B181
8F61 E6B88B
8F62 E78DA3
8F63 E7B8A6
8F64 E9878D
8F65 E98A83
8F66 E58F94
8F67 E5A499
8F68 E5AEBF
8F69 E6B791
8F6A E7A59D
8F6B E7B8AE
8F6C E7B29B
8F6D E5A1BE
8F6E E7869F
8F6F E587BA
8F70 E8A193
8F71 E8BFB0
8F72 E4BF8A
8F73 E5B3BB
8F74 E698A5
8F75 E79EAC
8F76 E7ABA3
8F77 E8889C
8F78 E9A7BF
8F79 E58786
8F7A E5BEAA
8F7B E697AC
8F7C E6A5AF
8F7D E6AE89
8F7E E6B7B3
8F80 E6BA96
8F81 E6BDA4
8F82 E79BBE
8F83 E7B494
8F84 E5B7A1
8F85 E981B5
8F86 E98687
8F87 E9A086
8F88 E587A6
8F89 E5889D
8F8A E68980
8F8B E69A91
8F8C E69B99
8F8D E6B89A
8F8E E5BAB6
8F8F E7B792
8F90 E7BDB2
8F91 E69BB8
8F92 E896AF
8F93 E897B7
8F94 E8ABB8
8F95 E58AA9
8F96 E58F99
8F97 E5A5B3
8F98 E5BA8F
8F99 E5BE90
8F9A E68195
8F9B E98BA4
8F9C E999A4
8F9D E582B7
8F9E E5849F
8F9F E58B9D
8FA0 E58CA0
8FA1 E58D87
8FA2 E58FAC
8FA3 E593A8
8FA4 E59586
8FA5 E594B1
8FA6 E59897
8FA7 E5A5A8
8FA8 E5A6BE
8FA9 E5A8BC
8FAA E5AEB5
8FAB E5B086
8FAC E5B08F
8FAD E5B091
8FAE E5B09A
8FAF E5BA84
8FB0 E5BA8A
8FB1 E5BBA0
8FB2 E5BDB0
8FB3 E689BF
8FB4 E68A84
8FB5 E68B9B
8FB6 E68E8C
8FB7 E68DB7
8FB8 E69887
8FB9 E6988C
8FBA E698AD
8FBB E699B6
8FBC E69DBE
8FBD E6A2A2
8FBE E6A89F
8FBF E6A8B5
8FC0 E6B2BC
8FC1 E6B688
8FC2 E6B889
8FC3 E6B998
8FC4 E784BC
8FC5 E784A6
8FC6 E785A7
8FC7 E79787
8FC8 E79C81
8FC9 E7A19D
8FCA E7A481
8FCB E7A5A5
8FCC E7A7B0
8FCD E7ABA0
8FCE E7AC91
8FCF E7B2A7
8FD0 E7B4B9
8FD1 E88296
8FD2 E88F96
8FD3 E8928B
8FD4 E89589
8FD5 E8A19D
8FD6 E8A3B3
8FD7 E8A89F
8FD8 E8A8BC
8FD9 E8A994
8FDA E8A9B3
8FDB E8B1A1
8FDC E8B39E
8FDD E986A4
8FDE E989A6
8FDF E98DBE
8FE0 E99098
8FE1 E99A9C
8FE2 E99E98
8FE3 E4B88A
8FE4 E4B888
8FE5 E4B89E
8FE6 E4B997
8FE7 E58697
8FE8 E589B0
8FE9 E59F8E
8FEA E5A0B4
8FEB E5A38C
8FEC E5ACA2
8FED E5B8B8
8FEE E68385
8FEF E693BE
8FF0 E69DA1
8FF1 E69D96
8FF2 E6B584
8FF3 E78AB6
8FF4 E795B3
8FF5 E7A9A3
8FF6 E892B8
8FF7 E8ADB2
8FF8 E986B8
8FF9 E98CA0
8FFA E598B1
8FFB E59FB4
8FFC E9A3BE
9040 E68BAD
9041 E6A48D
9042 E6AE96
9043 E787AD
9044 E7B994
9045 E881B7
9046 E889B2
9047 E8A7A6
9048 E9A39F
9049 E89D95
904A E8BEB1
904B E5B0BB
904C E4BCB8
904D E4BFA1
904E E4BEB5
904F E59487
9050 E5A8A0
9051 E5AF9D
9052 E5AFA9
9053 E5BF83
9054 E6858E
9055 E68CAF
9056 E696B0
9057 E6998B
9058 E6A3AE
9059 E6A69B
905A E6B5B8
905B E6B7B1
905C E794B3
905D E796B9
905E E79C9F
905F E7A59E
9060 E7A7A6
9061 E7B4B3
9062 E887A3
9063 E88AAF
9064 E896AA
9065 E8A6AA
9066 E8A8BA
9067 E8BAAB
9068 E8BE9B
9069 E980B2
906A E9879D
906B E99C87
906C E4BABA
906D E4BB81
906E E58883
906F E5A1B5
9070 E5A3AC
9071 E5B08B
9072 E7949A
9073 E5B0BD
9074 E8858E
9075 E8A88A
9076 E8BF85
9077 E999A3
9078 E99DAD
9079 E7ACA5
907A E8AB8F
907B E9A088
907C E985A2
907D E59BB3
907E E58EA8
9080 E98097
9081 E590B9
9082 E59E82
9083 E5B8A5
9084 E68EA8
9085 E6B0B4
9086 E7828A
9087 E79DA1
9088 E7B28B
9089 E7BFA0
908A E8A1B0
908B E98182
908C E98594
908D E98C90
908E E98C98
908F E99A8F
9090 E7919E
9091 E9AB84
9092 E5B487
9093 E5B5A9
9094 E695B0
9095 E69EA2
9096 E8B6A8
9097 E99B9B
9098 E68DAE
9099 E69D89
909A E6A499
909B E88F85
909C E9A097
909D E99B80
909E E8A3BE
909F E6BE84
90A0 E691BA
90A1 E5AFB8
90A2 E4B896
90A3 E780AC
90A4 E7959D
90A5 E698AF
90A6 E58784
90A7 E588B6
90A8 E58BA2
90A9 E5A793
90AA E5BE81
90AB E680A7
90AC E68890
90AD E694BF
90AE E695B4
90AF E6989F
90B0 E699B4
90B1 E6A3B2
90B2 E6A096
90B3 E6ADA3
90B4 E6B885
90B5 E789B2
90B6 E7949F
90B7 E79B9B
90B8 E7B2BE
90B9 E88196
90BA E5A3B0
90BB E8A3BD
90BC E8A5BF
90BD E8AAA0
90BE E8AA93
90BF E8AB8B
90C0 E9809D
90C1 E98692
90C2 E99D92
90C3 E99D99
90C4 E69689
90C5 E7A88E
90C6 E88486
90C7 E99ABB
90C8 E5B8AD
90C9 E6839C
90CA E6889A
90CB E696A5
90CC E69894
90CD E69E90
90CE E79FB3
90CF E7A98D
90D0 E7B18D
90D1 E7B8BE
90D2 E8848A
90D3 E8B2AC
90D4 E8B5A4
90D5 E8B7A1
90D6 E8B99F
90D7 E7A2A9
90D8 E58887
90D9 E68B99
90DA E68EA5
90DB E69182
90DC E68A98
90DD E8A8AD
90DE E7AA83
90DF E7AF80
90E0 E8AAAC
90E1 E99BAA
90E2 E7B5B6
90E3 E8888C
90E4 E89D89
90E5 E4BB99
90E6 E58588
90E7 E58D83
90E8 E58DA0
90E9 E5AEA3
90EA E5B082
90EB E5B096
90EC E5B79D
90ED E688A6
90EE E68987
90EF E692B0
90F0 E6A093
90F1 E6A0B4
90F2 E6B389
90F3 E6B585
90F4 E6B497
90F5 E69F93
90F6 E6BD9C
90F7 E7858E
90F8 E785BD
90F9 E6978B
90FA E7A9BF
90FB E7AEAD
90FC E7B79A
9140 E7B98A
9141 E7BEA8
9142 E885BA
9143 E8889B
9144 E888B9
9145 E896A6
9146 E8A9AE
9147 E8B38E
9148 E8B7B5
9149 E981B8
914A E981B7
914B E98AAD
914C E98A91
914D E99683
914E E9AEAE
914F E5898D
9150 E59684
9151 E6BCB8
9152 E784B6
9153 E585A8
9154 E7A685
9155 E7B995
9156 E886B3
9157 E7B38E
9158 E5998C
9159 E5A191
915A E5B2A8
915B E68EAA
915C E69BBE
915D E69BBD
915E E6A59A
915F E78B99
9160 E7968F
9161 E7968E
9162 E7A48E
9163 E7A596
9164 E7A79F
9165 E7B297
9166 E7B4A0
9167 E7B584
9168 E89887
9169 E8A8B4
916A E998BB
916B E981A1
916C E9BCA0
916D E583A7
916E E589B5
916F E58F8C
9170 E58FA2
9171 E58089
9172 E596AA
9173 E5A3AE
9174 E5A58F
9175 E788BD
9176 E5AE8B
9177 E5B1A4
9178 E58C9D
9179 E683A3
917A E683B3
917B E68D9C
917C E68E83
917D E68CBF
917E E68EBB
9180 E6938D
9181 E697A9
9182 E69BB9
9183 E5B7A3
9184 E6A78D
9185 E6A7BD
9186 E6BC95
9187 E787A5
9188 E4BA89
9189 E797A9
918A E79BB8
918B E7AA93
918C E7B39F
918D E7B78F
918E E7B69C
918F E881A1
9190 E88D89
9191 E88D98
9192 E891AC
9193 E892BC
9194 E897BB
9195 E8A385
9196 E8B5B0
9197 E98081
9198 E981AD
9199 E98E97
919A E99C9C
919B E9A892
919C E5838F
919D E5A297
919E E6868E
919F E88793
91A0 E894B5
91A1 E8B488
91A2 E980A0
91A3 E4BF83
91A4 E581B4
91A5 E58987
91A6 E58DB3
91A7 E681AF
91A8 E68D89
91A9 E69D9F
91AA E6B8AC
91AB E8B6B3
91AC E9809F
91AD E4BF97
91AE E5B19E
91AF E8B38A
91B0 E6978F
91B1 E7B69A
91B2 E58D92
91B3 E8A296
91B4 E585B6
91B5 E68F83
91B6 E5AD98
91B7 E5ADAB
91B8 E5B08A
91B9 E6908D
91BA E69D91
91BB E9819C
91BC E4BB96
91BD E5A49A
91BE E5A4AA
91BF E6B1B0
91C0 E8A991
91C1 E594BE
91C2 E5A095
91C3 E5A6A5
91C4 E683B0
91C5 E68993
91C6 E69F81
91C7 E888B5
91C8 E6A595
91C9 E99980
91CA E9A784
91CB E9A8A8
91CC E4BD93
91CD E5A086
91CE E5AFBE
91CF E88090
91D0 E5B2B1
91D1 E5B8AF
91D2 E5BE85
91D3 E680A0
91D4 E6858B
91D5 E688B4
91D6 E69BBF
91D7 E6B3B0
91D8 E6BB9E
91D9 E8838E
91DA E885BF
91DB E88B94
91DC E8A28B
91DD E8B2B8
91DE E98080
91DF E980AE
91E0 E99A8A
91E1 E9BB9B
91E2 E9AF9B
91E3 E4BBA3
91E4 E58FB0
91E5 E5A4A7
91E6 E7ACAC
91E7 E9868D
91E8 E9A18C
91E9 E9B7B9
91EA E6BB9D
91EB E780A7
91EC E58D93
91ED E59584
91EE E5AE85
91EF E68998
91F0 E68A9E
91F1 E68B93
91F2 E6B2A2
91F3 E6BFAF
91F4 E790A2
91F5 E8A897
91F6 E990B8
91F7 E6BF81
91F8 E8ABBE
91F9 E88CB8
91FA E587A7
91FB E89BB8
91FC E58FAA
9240 E58FA9
9241 E4BD86
9242 E98194
9243 E8BEB0
9244 E5A5AA
9245 E884B1
9246 E5B7BD
9247 E7ABAA
9248 E8BEBF
9249 E6A39A
924A E8B0B7
924B E78BB8
924C E9B188
924D E6A8BD
924E E8AAB0
924F E4B8B9
9250 E58D98
9251 E59886
9252 E59DA6
9253 E68B85
9254 E68EA2
9255 E697A6
9256 E6AD8E
9257 E6B7A1
9258 E6B99B
9259 E782AD
925A E79FAD
925B E7ABAF
925C E7AEAA
925D E7B6BB
925E E880BD
925F E88386
9260 E89B8B
9261 E8AA95
9262 E98D9B
9263 E59BA3
9264 E5A387
9265 E5BCBE
9266 E696AD
9267 E69A96
9268 E6AA80
9269 E6AEB5
926A E794B7
926B E8AB87
926C E580A4
926D E79FA5
926E E59CB0
926F E5BC9B
9270 E681A5
9271 E699BA
9272 E6B1A0
9273 E797B4
9274 E7A89A
9275 E7BDAE
9276 E887B4
9277 E89C98
9278 E98185
9279 E9A6B3
927A E7AF89
927B E7959C
927C E7ABB9
927D E7AD91
927E E89384
9280 E98090
9281 E7A7A9
9282 E7AA92
9283 E88CB6
9284 E5ABA1
9285 E79D80
9286 E4B8AD
9287 E4BBB2
9288 E5AE99
9289 E5BFA0
928A E68ABD
928B E698BC
928C E69FB1
928D E6B3A8
928E E899AB
928F E8A1B7
9290 E8A8BB
9291 E9858E
9292 E98BB3
9293 E9A790
9294 E6A897
9295 E780A6
9296 E78CAA
9297 E88BA7
9298 E89197
9299 E8B2AF
929A E4B881
929B E58586
929C E5878B
929D E5968B
929E E5AFB5
929F E5B896
92A0 E5B8B3
92A1 E5BA81
92A2 E5BC94
92A3 E5BCB5
92A4 E5BDAB
92A5 E5BEB4
92A6 E687B2
92A7 E68C91
92A8 E69AA2
92A9 E69C9D
92AA E6BDAE
92AB E78992
92AC E794BA
92AD E79CBA
92AE E881B4
92AF E884B9
92B0 E885B8
92B1 E89DB6
92B2 E8AABF
92B3 E8AB9C
92B4 E8B685
92B5 E8B7B3
92B6 E98A9A
92B7 E995B7
92B8 E9A082
92B9 E9B3A5
92BA E58B85
92BB E68D97
92BC E79BB4
92BD E69C95
92BE E6B288
92BF E78F8D
92C0 E8B383
92C1 E98EAE
92C2 E999B3
92C3 E6B4A5
92C4 E5A29C
92C5 E6A48E
92C6 E6A78C
92C7 E8BFBD
92C8 E98E9A
92C9 E7979B
92CA E9809A
92CB E5A19A
92CC E6A082
92CD E68EB4
92CE E6A7BB
92CF E4BD83
92D0 E6BCAC
92D1 E69F98
92D2 E8BEBB
92D3 E894A6
92D4 E7B6B4
92D5 E98D94
92D6 E6A4BF
92D7 E6BDB0
92D8 E59DAA
92D9 E5A3B7
92DA E5ACAC
92DB E7B4AC
92DC E788AA
92DD E5908A
92DE E987A3
92DF E9B6B4
92E0 E4BAAD
92E1 E4BD8E
92E2 E5819C
92E3 E581B5
92E4 E58983
92E5 E8B29E
92E6 E59188
92E7 E5A0A4
92E8 E5AE9A
92E9 E5B89D
92EA E5BA95
92EB E5BAAD
92EC E5BBB7
92ED E5BC9F
92EE E6828C
92EF E68AB5
92F0 E68CBA
92F1 E68F90
92F2 E6A2AF
92F3 E6B180
92F4 E7A287
92F5 E7A68E
92F6 E7A88B
92F7 E7B7A0
92F8 E88987
92F9 E8A882
92FA E8ABA6
92FB E8B984
92FC E98093
9340 E982B8
9341 E984AD
9342 E98798
9343 E9BC8E
9344 E6B3A5
9345 E69198
9346 E693A2
9347 E695B5
9348 E6BBB4
9349 E79A84
934A E7AC9B
934B E981A9
934C E98F91
934D E6BABA
934E E593B2
934F E5BEB9
9350 E692A4
9351 E8BD8D
9352 E8BFAD
9353 E98984
9354 E585B8
9355 E5A1AB
9356 E5A4A9
9357 E5B195
9358 E5BA97
9359 E6B7BB
935A E7BA8F
935B E7949C
935C E8B2BC
935D E8BBA2
935E E9A19B
935F E782B9
9360 E4BC9D
9361 E6AEBF
9362 E6BEB1
9363 E794B0
9364 E99BBB
9365 E5858E
9366 E59090
9367 E5A0B5
9368 E5A197
9369 E5A6AC
936A E5B1A0
936B E5BE92
936C E69697
936D E69D9C
936E E6B8A1
936F E799BB
9370 E88F9F
9371 E8B3AD
9372 E98094
9373 E983BD
9374 E98D8D
9375 E7A0A5
9376 E7A0BA
9377 E58AAA
9378 E5BAA6
9379 E59C9F
937A E5A5B4
937B E68092
937C E58092
937D E5859A
937E E586AC
9380 E5878D
9381 E58880
9382 E59490
9383 E5A194
9384 E5A198
9385 E5A597
9386 E5AE95
9387 E5B3B6
9388 E5B68B
9389 E682BC
938A E68A95
938B E690AD
938C E69DB1
938D E6A183
938E E6A2BC
938F E6A39F
9390 E79B97
9391 E6B798
9392 E6B9AF
9393 E6B69B
9394 E781AF
9395 E78788
9396 E5BD93
9397 E79798
9398 E7A5B7
9399 E7AD89
939A E7AD94
939B E7AD92
939C E7B396
939D E7B5B1
939E E588B0
939F E891A3
93A0 E895A9
93A1 E897A4
93A2 E8A88E
93A3 E8AC84
93A4 E8B186
93A5 E8B88F
93A6 E98083
93A7 E9808F
93A8 E99099
93A9 E999B6
93AA E9A0AD
93AB E9A8B0
93AC E99798
93AD E5838D
93AE E58B95
93AF E5908C
93B0 E5A082
93B1 E5B08E
93B2 E686A7
93B3 E6929E
93B4 E6B49E
93B5 E79EB3
93B6 E7ABA5
93B7 E883B4
93B8 E89084
93B9 E98193
93BA E98A85
93BB E5B3A0
93BC E9B487
93BD E58CBF
93BE E5BE97
93BF E5BEB3
93C0 E6B69C
93C1 E789B9
93C2 E79DA3
93C3 E7A6BF
93C4 E7AFA4
93C5 E6AF92
93C6 E78BAC
93C7 E8AAAD
93C8 E6A083
93C9 E6A9A1
93CA E587B8
93CB E7AA81
93CC E6A4B4
93CD E5B18A
93CE E9B3B6
93CF E88BAB
93D0 E5AF85
93D1 E98589
93D2 E7809E
93D3 E599B8
93D4 E5B1AF
93D5 E68387
93D6 E695A6
93D7 E6B28C
93D8 E8B19A
93D9 E98181
93DA E9A093
93DB E59191
93DC E69B87
93DD E9888D
93DE E5A588
93DF E982A3
93E0 E58685
93E1 E4B98D
93E2 E587AA
93E3 E89699
93E4 E8AC8E
93E5 E78198
93E6 E68DBA
93E7 E98D8B
93E8 E6A5A2
93E9 E9A6B4
93EA E7B884
93EB E795B7
93EC E58D97
93ED E6A5A0
93EE E8BB9F
93EF E99BA3
93F0 E6B19D
93F1 E4BA8C
93F2 E5B0BC
93F3 E5BC90
93F4 E8BFA9
93F5 E58C82
93F6 E8B391
93F7 E88289
93F8 E899B9
93F9 E5BBBF
93FA E697A5
93FB E4B9B3
93FC E585A5
9440 E5A682
9441 E5B0BF
9442 E99FAE
9443 E4BBBB
9444 E5A68A
9445 E5BF8D
9446 E8AA8D
9447 E6BFA1
9448 E7A6B0
9449 E7A5A2
944A E5AFA7
944B E891B1
944C E78CAB
944D E786B1
944E E5B9B4
944F E5BFB5
9450 E68DBB
9451 E6929A
9452 E78783
9453 E7B298
9454 E4B983
9455 E5BBBC
9456 E4B98B
9457 E59F9C
9458 E59AA2
9459 E682A9
945A E6BF83
945B E7B48D
945C E883BD
945D E884B3
945E E886BF
945F E8BEB2
9460 E8A697
9461 E89AA4
9462 E5B7B4
9463 E68A8A
9464 E692AD
9465 E8A687
9466 E69DB7
9467 E6B3A2
9468 E6B4BE
9469 E790B6
946A E7A0B4
946B E5A986
946C E7BDB5
946D E88AAD
946E E9A6AC
946F E4BFB3
9470 E5BB83
9471 E68B9D
9472 E68E92
9473 E69597
9474 E69DAF
9475 E79B83
9476 E7898C
9477 E8838C
9478 E882BA
9479 E8BCA9
947A E9858D
947B E5808D
947C E59FB9
947D E5AA92
947E E6A285
9480 E6A5B3
9481 E785A4
9482 E78BBD
9483 E8B2B7
9484 E5A3B2
9485 E8B3A0
9486 E999AA
9487 E98099
9488 E89DBF
9489 E7A7A4
948A E79FA7
948B E890A9
948C E4BCAF
948D E589A5
948E E58D9A
948F E68B8D
9490 E69F8F
9491 E6B38A
9492 E799BD
9493 E7AE94
9494 E7B295
9495 E888B6
9496 E89684
9497 E8BFAB
9498 E69B9D
9499 E6BCA0
949A E78886
949B E7B89B
949C E88EAB
949D E9A781
949E E9BAA6
949F E587BD
94A0 E7AEB1
94A1 E7A1B2
94A2 E7AEB8
94A3 E88287
94A4 E7AD88
94A5 E6ABA8
94A6 E5B9A1
94A7 E8828C
94A8 E79591
94A9 E795A0
94AA E585AB
94AB E989A2
94AC E6BA8C
94AD E799BA
94AE E98697
94AF E9ABAA
94B0 E4BC90
94B1 E7BDB0
94B2 E68A9C
94B3 E7AD8F
94B4 E996A5
94B5 E9B3A9
94B6 E599BA
94B7 E5A199
94B8 E89BA4
94B9 E99ABC
94BA E4BCB4
94BB E588A4
94BC E58D8A
94BD E58F8D
94BE E58F9B
94BF E5B886
94C0 E690AC
94C1 E69691
94C2 E69DBF
94C3 E6B0BE
94C4 E6B18E
94C5 E78988
94C6 E78AAF
94C7 E78FAD
94C8 E79594
94C9 E7B981
94CA E888AC
94CB E897A9
94CC E8B2A9
94CD E7AF84
94CE E98786
94CF E785A9
94D0 E9A092
94D1 E9A3AF
94D2 E68CBD
94D3 E699A9
94D4 E795AA
94D5 E79BA4
94D6 E7A390
94D7 E89583
94D8 E89BAE
94D9 E58CAA
94DA E58D91
94DB E590A6
94DC E5A683
94DD E5BA87
94DE E5BDBC
94DF E682B2
94E0 E68989
94E1 E689B9
94E2 E68AAB
94E3 E69690
94E4 E6AF94
94E5 E6B38C
94E6 E796B2
94E7 E79AAE
94E8 E7A291
94E9 E7A798
94EA E7B78B
94EB E7BDB7
94EC E882A5
94ED E8A2AB
94EE E8AAB9
94EF E8B2BB
94F0 E981BF
94F1 E99D9E
94F2 E9A39B
94F3 E6A88B
94F4 E7B0B8
94F5 E58299
94F6 E5B0BE
94F7 E5BEAE
94F8 E69E87
94F9 E6AF98
94FA E790B5
94FB E79C89
94FC E7BE8E
9540 E9BCBB
9541 E69F8A
9542 E7A897
9543 E58CB9
9544 E7968B
9545 E9ABAD
9546 E5BDA6
9547 E8869D
9548 E88FB1
9549 E88298
954A E5BCBC
954B E5BF85
954C E795A2
954D E7AD86
954E E980BC
954F E6A1A7
9550 E5A7AB
9551 E5AA9B
9552 E7B490
9553 E799BE
9554 E8ACAC
9555 E4BFB5
9556 E5BDAA
9557 E6A899
9558 E6B0B7
9559 E6BC82
955A E793A2
955B E7A5A8
955C E8A1A8
955D E8A995
955E E8B1B9
955F E5BB9F
9560 E68F8F
9561 E79785
9562 E7A792
9563 E88B97
9564 E98CA8
9565 E98BB2
9566 E8929C
9567 E89BAD
9568 E9B0AD
9569 E59381
956A E5BDAC
956B E6968C
956C E6B59C
956D E78095
956E E8B2A7
956F E8B393
9570 E9A0BB
9571 E6958F
9572 E793B6
9573 E4B88D
9574 E4BB98
9575 E59FA0
9576 E5A4AB
9577 E5A9A6
9578 E5AF8C
9579 E586A8
957A E5B883
957B E5BA9C
957C E68096
957D E689B6
957E E695B7
9580 E696A7
9581 E699AE
9582 E6B5AE
9583 E788B6
9584 E7ACA6
9585 E88590
9586 E8869A
9587 E88A99
9588 E8AD9C
9589 E8B2A0
958A E8B3A6
958B E8B5B4
958C E9989C
958D E99984
958E E4BEAE
958F E692AB
9590 E6ADA6
9591 E8889E
9592 E891A1
9593 E895AA
9594 E983A8
9595 E5B081
9596 E6A593
9597 E9A2A8
9598 E891BA
9599 E89597
959A E4BC8F
959B E589AF
959C E5BEA9
959D E5B985
959E E69C8D
959F E7A68F
95A0 E885B9
95A1 E8A487
95A2 E8A686
95A3 E6B7B5
95A4 E5BC97
95A5 E68995
95A6 E6B2B8
95A7 E4BB8F
95A8 E789A9
95A9 E9AE92
95AA E58886
95AB E590BB
95AC E599B4
95AD E5A2B3
95AE E686A4
95AF E689AE
95B0 E7849A
95B1 E5A5AE
95B2 E7B289
95B3 E7B39E
95B4 E7B49B
95B5 E99BB0
95B6 E69687
95B7 E8819E
95B8 E4B899
95B9 E4BDB5
95BA E585B5
95BB E5A180
95BC E5B9A3
95BD E5B9B3
95BE E5BC8A
95BF E69F84
95C0 E4B8A6
95C1 E894BD
95C2 E99689
95C3 E9999B
95C4 E7B1B3
95C5 E9A081
95C6 E583BB
95C7 E5A381
95C8 E79996
95C9 E7A2A7
95CA E588A5
95CB E79EA5
95CC E89491
95CD E7AE86
95CE E5818F
95CF E5A489
95D0 E78987
95D1 E7AF87
95D2 E7B7A8
95D3 E8BEBA
95D4 E8BF94
95D5 E9818D
95D6 E4BEBF
95D7 E58B89
95D8 E5A8A9
95D9 E5BC81
95DA E99EAD
95DB E4BF9D
95DC E88897
95DD E98BAA
95DE E59C83
95DF E68D95
95E0 E6ADA9
95E1 E794AB
95E2 E8A39C
95E3 E8BC94
95E4 E7A982
95E5 E58B9F
95E6 E5A293
95E7 E68595
95E8 E6888A
95E9 E69AAE
95EA E6AF8D
95EB E7B0BF
95EC E88FA9
95ED E580A3
95EE E4BFB8
95EF E58C85
95F0 E59186
95F1 E5A0B1
95F2 E5A589
95F3 E5AE9D
95F4 E5B3B0
95F5 E5B3AF
95F6 E5B4A9
95F7 E5BA96
95F8 E68AB1
95F9 E68DA7
95FA E694BE
95FB E696B9
95FC E69C8B
9640 E6B395
9641 E6B3A1
9642 E783B9
9643 E7A0B2
9644 E7B8AB
9645 E8839E
9646 E88AB3
9647 E8908C
9648 E893AC
9649 E89C82
964A E8A492
964B E8A8AA
964C E8B18A
964D E982A6
964E E98B92
964F E9A3BD
9650 E9B3B3
9651 E9B5AC
9652 E4B98F
9653 E4BAA1
9654 E5828D
9655 E58996
9656 E59D8A
9657 E5A6A8
9658 E5B8BD
9659 E5BF98
965A E5BF99
965B E688BF
965C E69AB4
965D E69C9B
965E E69F90
965F E6A392
9660 E58692
9661 E7B4A1
9662 E882AA
9663 E886A8
9664 E8AC80
9665 E8B28C
9666 E8B2BF
9667 E989BE
9668 E998B2
9669 E590A0
966A E9A0AC
966B E58C97
966C E58395
966D E58D9C
966E E5A2A8
966F E692B2
9670 E69CB4
9671 E789A7
9672 E79DA6
9673 E7A986
9674 E987A6
9675 E58B83
9676 E6B2A1
9677 E6AE86
9678 E5A080
9679 E5B98C
967A E5A594
967B E69CAC
967C E7BFBB
967D E587A1
967E E79B86
9680 E691A9
9681 E7A3A8
9682 E9AD94
9683 E9BABB
9684 E59F8B
9685 E5A6B9
9686 E698A7
9687 E69E9A
9688 E6AF8E
9689 E593A9
968A E6A799
968B E5B995
968C E8869C
968D E69E95
968E E9AEAA
968F E69FBE
9690 E9B192
9691 E6A19D
9692 E4BAA6
9693 E4BFA3
9694 E58F88
9695 E68AB9
9696 E69CAB
9697 E6B2AB
9698 E8BF84
9699 E4BEAD
969A E7B9AD
969B E9BABF
969C E4B887
969D E685A2
969E E6BA80
969F E6BCAB
96A0 E89493
96A1 E591B3
96A2 E69CAA
96A3 E9AD85
96A4 E5B7B3
96A5 E7AE95
96A6 E5B2AC
96A7 E5AF86
96A8 E89C9C
96A9 E6B98A
96AA E89391
96AB E7A894
96AC E88488
96AD E5A699
96AE E7B28D
96AF E6B091
96B0 E79CA0
96B1 E58B99
96B2 E5A4A2
96B3 E784A1
96B4 E7899F
96B5 E79F9B
96B6 E99CA7
96B7 E9B5A1
96B8 E6A48B
96B9 E5A9BF
96BA E5A898
96BB E586A5
96BC E5908D
96BD E591BD
96BE E6988E
96BF E79B9F
96C0 E8BFB7
96C1 E98A98
96C2 E9B3B4
96C3 E5A7AA
96C4 E7899D
96C5 E6BB85
96C6 E5858D
96C7 E6A389
96C8 E7B6BF
96C9 E7B7AC
96CA E99DA2
96CB E9BABA
96CC E691B8
96CD E6A8A1
96CE E88C82
96CF E5A684
96D0 E5AD9F
96D1 E6AF9B
96D2 E78C9B
96D3 E79BB2
96D4 E7B6B2
96D5 E88097
96D6 E89299
96D7 E584B2
96D8 E69CA8
96D9 E9BB99
96DA E79BAE
96DB E69DA2
96DC E58BBF
96DD E9A485
96DE E5B0A4
96DF E688BB
96E0 E7B1BE
96E1 E8B2B0
96E2 E5958F
96E3 E682B6
96E4 E7B48B
96E5 E99680
96E6 E58C81
96E7 E4B99F
96E8 E586B6
96E9 E5A49C
96EA E788BA
96EB E880B6
96EC E9878E
96ED E5BCA5
96EE E79FA2
96EF E58E84
96F0 E5BDB9
96F1 E7B484
96F2 E896AC
96F3 E8A8B3
96F4 E8BA8D
96F5 E99D96
96F6 E69FB3
96F7 E896AE
96F8 E99193
96F9 E68489
96FA E68488
96FB E6B2B9
96FC E79992
9740 E8ABAD
9741 E8BCB8
9742 E594AF
9743 E4BD91
9744 E584AA
9745 E58B87
9746 E58F8B
9747 E5AEA5
9748 E5B9BD
9749 E682A0
974A E68682
974B E68F96
974C E69C89
974D E69F9A
974E E6B9A7
974F E6B68C
9750 E78CB6
9751 E78CB7
9752 E794B1
9753 E7A590
9754 E8A395
9755 E8AA98
9756 E9818A
9757 E98291
9758 E983B5
9759 E99B84
975A E89E8D
975B E5A495
975C E4BA88
975D E4BD99
975E E4B88E
975F E8AA89
9760 E8BCBF
9761 E9A090
9762 E582AD
9763 E5B9BC
9764 E5A696
9765 E5AEB9
9766 E5BAB8
9767 E68F9A
9768 E68FBA
9769 E69381
976A E69B9C
976B E6A58A
976C E6A798
976D E6B48B
976E E6BAB6
976F E78694
9770 E794A8
9771 E7AAAF
9772 E7BE8A
9773 E88080
9774 E89189
9775 E89389
9776 E8A681
9777 E8ACA1
9778 E8B88A
9779 E981A5
977A E999BD
977B E9A48A
977C E685BE
977D E68A91
977E E6ACB2
9780 E6B283
9781 E6B5B4
9782 E7BF8C
9783 E7BFBC
9784 E6B780
9785 E7BE85
9786 E89EBA
9787 E8A3B8
9788 E69DA5
9789 E88EB1
978A E9A0BC
978B E99BB7
978C E6B49B
978D E7B5A1
978E E890BD
978F E985AA
9790 E4B9B1
9791 E58DB5
9792 E5B590
9793 E6AC84
9794 E6BFAB
9795 E8978D
9796 E898AD
9797 E8A6A7
9798 E588A9
9799 E5908F
979A E5B1A5
979B E69D8E
979C E6A2A8
979D E79086
979E E79283
979F E797A2
97A0 E8A38F
97A1 E8A3A1
97A2 E9878C
97A3 E99BA2
97A4 E999B8
97A5 E5BE8B
97A6 E78E87
97A7 E7AB8B
97A8 E8918E
97A9 E68EA0
97AA E795A5
97AB E58A89
97AC E6B581
97AD E6BA9C
97AE E79089
97AF E79599
97B0 E7A1AB
97B1 E7B292
97B2 E99A86
97B3 E7AB9C
97B4 E9BE8D
97B5 E4BEB6
97B6 E685AE
97B7 E69785
97B8 E8999C
97B9 E4BA86
97BA E4BAAE
97BB E5839A
97BC E4B8A1
97BD E5878C
97BE E5AFAE
97BF E69699
97C0 E6A281
97C1 E6B6BC
97C2 E78C9F
97C3 E79982
97C4 E79EAD
97C5 E7A89C
97C6 E7B3A7
97C7 E889AF
97C8 E8AB92
97C9 E981BC
97CA E9878F
97CB E999B5
97CC E9A098
97CD E58A9B
97CE E7B791
97CF E580AB
97D0 E58E98
97D1 E69E97
97D2 E6B78B
97D3 E78790
97D4 E790B3
97D5 E887A8
97D6 E8BCAA
97D7 E99AA3
97D8 E9B197
97D9 E9BA9F
97DA E791A0
97DB E5A181
97DC E6B699
97DD E7B4AF
97DE E9A19E
97DF E4BBA4
97E0 E4BCB6
97E1 E4BE8B
97E2 E586B7
97E3 E58AB1
97E4 E5B6BA
97E5 E6809C
97E6 E78EB2
97E7 E7A4BC
97E8 E88B93
97E9 E988B4
97EA E99AB7
97EB E99BB6
97EC E99C8A
97ED E9BA97
97EE E9BDA2
97EF E69AA6
97F0 E6ADB4
97F1 E58897
97F2 E58AA3
97F3 E78388
97F4 E8A382
97F5 E5BB89
97F6 E6818B
97F7 E68690
97F8 E6BCA3
97F9 E78589
97FA E7B0BE
97FB E7B7B4
97FC E881AF
9840 E893AE
9841 E980A3
9842 E98CAC
9843 E59182
9844 E9ADAF
9845 E6AB93
9846 E78289
9847 E8B382
9848 E8B7AF
9849 E99CB2
984A E58AB4
984B E5A981
984C E5BB8A
984D E5BC84
984E E69C97
984F E6A5BC
9850 E6A694
9851 E6B5AA
9852 E6BC8F
9853 E789A2
9854 E78BBC
9855 E7AFAD
9856 E88081
9857 E881BE
9858 E89D8B
9859 E9838E
985A E585AD
985B E9BA93
985C E7A684
985D E8828B
985E E98CB2
985F E8AB96
9860 E580AD
9861 E5928C
9862 E8A9B1
9863 E6ADAA
9864 E8B384
9865 E88487
9866 E68391
9867 E69EA0
9868 E9B7B2
9869 E4BA99
986A E4BA98
986B E9B090
986C E8A9AB
986D E89781
986E E895A8
986F E6A480
9870 E6B9BE
9871 E7A297
9872 E88595
989F E5BC8C
98A0 E4B890
98A1 E4B895
98A2 E4B8AA
98A3 E4B8B1
98A4 E4B8B6
98A5 E4B8BC
98A6 E4B8BF
98A7 E4B982
98A8 E4B996
98A9 E4B998
98AA E4BA82
98AB E4BA85
98AC E8B1AB
98AD E4BA8A
98AE E88892
98AF E5BC8D
98B0 E4BA8E
98B1 E4BA9E
98B2 E4BA9F
98B3 E4BAA0
98B4 E4BAA2
98B5 E4BAB0
98B6 E4BAB3
98B7 E4BAB6
98B8 E4BB8E
98B9 E4BB8D
98BA E4BB84
98BB E4BB86
98BC E4BB82
98BD E4BB97
98BE E4BB9E
98BF E4BBAD
98C0 E4BB9F
98C1 E4BBB7
98C2 E4BC89
98C3 E4BD9A
98C4 E4BCB0
98C5 E4BD9B
98C6 E4BD9D
98C7 E4BD97
98C8 E4BD87
98C9 E4BDB6
98CA E4BE88
98CB E4BE8F
98CC E4BE98
98CD E4BDBB
98CE E4BDA9
98CF E4BDB0
98D0 E4BE91
98D1 E4BDAF
98D2 E4BE86
98D3 E4BE96
98D4 E58498
98D5 E4BF94
98D6 E4BF9F
98D7 E4BF8E
98D8 E4BF98
98D9 E4BF9B
98DA E4BF91
98DB E4BF9A
98DC E4BF90
98DD E4BFA4
98DE E4BFA5
98DF E5809A
98E0 E580A8
98E1 E58094
98E2 E580AA
98E3 E580A5
98E4 E58085
98E5 E4BC9C
98E6 E4BFB6
98E7 E580A1
98E8 E580A9
98E9 E580AC
98EA E4BFBE
98EB E4BFAF
98EC E58091
98ED E58086
98EE E58183
98EF E58187
98F0 E69C83
98F1 E58195
98F2 E58190
98F3 E58188
98F4 E5819A
98F5 E58196
98F6 E581AC
98F7 E581B8
98F8 E58280
98F9 E5829A
98FA E58285
98FB E582B4
98FC E582B2
9940 E58389
9941 E5838A
9942 E582B3
9943 E58382
9944 E58396
9945 E5839E
9946 E583A5
9947 E583AD
9948 E583A3
9949 E583AE
994A E583B9
994B E583B5
994C E58489
994D E58481
994E E58482
994F E58496
9950 E58495
9951 E58494
9952 E5849A
9953 E584A1
9954 E584BA
9955 E584B7
9956 E584BC
9957 E584BB
9958 E584BF
9959 E58580
995A E58592
995B E5858C
995C E58594
995D E585A2
995E E7ABB8
995F E585A9
9960 E585AA
9961 E585AE
9962 E58680
9963 E58682
9964 E59B98
9965 E5868C
9966 E58689
9967 E5868F
9968 E58691
9969 E58693
996A E58695
996B E58696
996C E586A4
996D E586A6
996E E586A2
996F E586A9
9970 E586AA
9971 E586AB
9972 E586B3
9973 E586B1
9974 E586B2
9975 E586B0
9976 E586B5
9977 E586BD
9978 E58785
9979 E58789
997A E5879B
997B E587A0
997C E89995
997D E587A9
997E E587AD
9980 E587B0
9981 E587B5
9982 E587BE
9983 E58884
9984 E5888B
9985 E58894
9986 E5888E
9987 E588A7
9988 E588AA
9989 E588AE
998A E588B3
998B E588B9
998C E5898F
998D E58984
998E E5898B
998F E5898C
9990 E5899E
9991 E58994
9992 E589AA
9993 E589B4
9994 E589A9
9995 E589B3
9996 E589BF
9997 E589BD
9998 E58A8D
9999 E58A94
999A E58A92
999B E589B1
999C E58A88
999D E58A91
999E E8BEA8
999F E8BEA7
99A0 E58AAC
99A1 E58AAD
99A2 E58ABC
99A3 E58AB5
99A4 E58B81
99A5 E58B8D
99A6 E58B97
99A7 E58B9E
99A8 E58BA3
99A9 E58BA6
99AA E9A3AD
99AB E58BA0
99AC E58BB3
99AD E58BB5
99AE E58BB8
99AF E58BB9
99B0 E58C86
99B1 E58C88
99B2 E794B8
99B3 E58C8D
99B4 E58C90
99B5 E58C8F
99B6 E58C95
99B7 E58C9A
99B8 E58CA3
99B9 E58CAF
99BA E58CB1
99BB E58CB3
99BC E58CB8
99BD E58D80
99BE E58D86
99BF E58D85
99C0 E4B897
99C1 E58D89
99C2 E58D8D
99C3 E58796
99C4 E58D9E
99C5 E58DA9
99C6 E58DAE
99C7 E5A498
99C8 E58DBB
99C9 E58DB7
99CA E58E82
99CB E58E96
99CC E58EA0
99CD E58EA6
99CE E58EA5
99CF E58EAE
99D0 E58EB0
99D1 E58EB6
99D2 E58F83
99D3 E7B092
99D4 E99B99
99D5 E58F9F
99D6 E69BBC
99D7 E787AE
99D8 E58FAE
99D9 E58FA8
99DA E58FAD
99DB E58FBA
99DC E59081
99DD E590BD
99DE E59180
99DF E590AC
99E0 E590AD
99E1 E590BC
99E2 E590AE
99E3 E590B6
99E4 E590A9
99E5 E5909D
99E6 E5918E
99E7 E5928F
99E8 E591B5
99E9 E5928E
99EA E5919F
99EB E591B1
99EC E591B7
99ED E591B0
99EE E59292
99EF E591BB
99F0 E59280
99F1 E591B6
99F2 E59284
99F3 E59290
99F4 E59286
99F5 E59387
99F6 E592A2
99F7 E592B8
99F8 E592A5
99F9 E592AC
99FA E59384
99FB E59388
99FC E592A8
9A40 E592AB
9A41 E59382
9A42 E592A4
9A43 E592BE
9A44 E592BC
9A45 E59398
9A46 E593A5
9A47 E593A6
9A48 E5948F
9A49 E59494
9A4A E593BD
9A4B E593AE
9A4C E593AD
9A4D E593BA
9A4E E593A2
9A4F E594B9
9A50 E59580
9A51 E595A3
9A52 E5958C
9A53 E594AE
9A54 E5959C
9A55 E59585
9A56 E59596
9A57 E59597
9A58 E594B8
9A59 E594B3
9A5A E5959D
9A5B E59699
9A5C E59680
9A5D E592AF
9A5E E5968A
9A5F E5969F
9A60 E595BB
9A61 E595BE
9A62 E59698
9A63 E5969E
9A64 E596AE
9A65 E595BC
9A66 E59683
9A67 E596A9
9A68 E59687
9A69 E596A8
9A6A E5979A
9A6B E59785
9A6C E5979F
9A6D E59784
9A6E E5979C
9A6F E597A4
9A70 E59794
9A71 E59894
9A72 E597B7
9A73 E59896
9A74 E597BE
9A75 E597BD
9A76 E5989B
9A77 E597B9
9A78 E5998E
9A79 E59990
9A7A E7879F
9A7B E598B4
9A7C E598B6
9A7D E598B2
9A7E E598B8
9A80 E599AB
9A81 E599A4
9A82 E598AF
9A83 E599AC
9A84 E599AA
9A85 E59A86
9A86 E59A80
9A87 E59A8A
9A88 E59AA0
9A89 E59A94
9A8A E59A8F
9A8B E59AA5
9A8C E59AAE
9A8D E59AB6
9A8E E59AB4
9A8F E59B82
9A90 E59ABC
9A91 E59B81
9A92 E59B83
9A93 E59B80
9A94 E59B88
9A95 E59B8E
9A96 E59B91
9A97 E59B93
9A98 E59B97
9A99 E59BAE
9A9A E59BB9
9A9B E59C80
9A9C E59BBF
9A9D E59C84
9A9E E59C89
9A9F E59C88
9AA0 E59C8B
9AA1 E59C8D
9AA2 E59C93
9AA3 E59C98
9AA4 E59C96
9AA5 E59787
9AA6 E59C9C
9AA7 E59CA6
9AA8 E59CB7
9AA9 E59CB8
9AAA E59D8E
9AAB E59CBB
9AAC E59D80
9AAD E59D8F
9AAE E59DA9
9AAF E59F80
9AB0 E59E88
9AB1 E59DA1
9AB2 E59DBF
9AB3 E59E89
9AB4 E59E93
9AB5 E59EA0
9AB6 E59EB3
9AB7 E59EA4
9AB8 E59EAA
9AB9 E59EB0
9ABA E59F83
9ABB E59F86
9ABC E59F94
9ABD E59F92
9ABE E59F93
9ABF E5A08A
9AC0 E59F96
9AC1 E59FA3
9AC2 E5A08B
9AC3 E5A099
9AC4 E5A09D
9AC5 E5A1B2
9AC6 E5A0A1
9AC7 E5A1A2
9AC8 E5A18B
9AC9 E5A1B0
9ACA E6AF80
9ACB E5A192
9ACC E5A0BD
9ACD E5A1B9
9ACE E5A285
9ACF E5A2B9
9AD0 E5A29F
9AD1 E5A2AB
9AD2 E5A2BA
9AD3 E5A39E
9AD4 E5A2BB
9AD5 E5A2B8
9AD6 E5A2AE
9AD7 E5A385
9AD8 E5A393
9AD9 E5A391
9ADA E5A397
9ADB E5A399
9ADC E5A398
9ADD E5A3A5
9ADE E5A39C
9ADF E5A3A4
9AE0 E5A39F
9AE1 E5A3AF
9AE2 E5A3BA
9AE3 E5A3B9
9AE4 E5A3BB
9AE5 E5A3BC
9AE6 E5A3BD
9AE7 E5A482
9AE8 E5A48A
9AE9 E5A490
9AEA E5A49B
9AEB E6A2A6
9AEC E5A4A5
9AED E5A4AC
9AEE E5A4AD
9AEF E5A4B2
9AF0 E5A4B8
9AF1 E5A4BE
9AF2 E7AB92
9AF3 E5A595
9AF4 E5A590
9AF5 E5A58E
9AF6 E5A59A
9AF7 E5A598
9AF8 E5A5A2
9AF9 E5A5A0
9AFA E5A5A7
9AFB E5A5AC
9AFC E5A5A9
9B40 E5A5B8
9B41 E5A681
9B42 E5A69D
9B43 E4BD9E
9B44 E4BEAB
9B45 E5A6A3
9B46 E5A6B2
9B47 E5A786
9B48 E5A7A8
9B49 E5A79C
9B4A E5A68D
9B4B E5A799
9B4C E5A79A
9B4D E5A8A5
9B4E E5A89F
9B4F E5A891
9B50 E5A89C
9B51 E5A889
9B52 E5A89A
9B53 E5A980
9B54 E5A9AC
9B55 E5A989
9B56 E5A8B5
9B57 E5A8B6
9B58 E5A9A2
9B59 E5A9AA
9B5A E5AA9A
9B5B E5AABC
9B5C E5AABE
9B5D E5AB8B
9B5E E5AB82
9B5F E5AABD
9B60 E5ABA3
9B61 E5AB97
9B62 E5ABA6
9B63 E5ABA9
9B64 E5AB96
9B65 E5ABBA
9B66 E5ABBB
9B67 E5AC8C
9B68 E5AC8B
9B69 E5AC96
9B6A E5ACB2
9B6B E5AB90
9B6C E5ACAA
9B6D E5ACB6
9B6E E5ACBE
9B6F E5AD83
9B70 E5AD85
9B71 E5AD80
9B72 E5AD91
9B73 E5AD95
9B74 E5AD9A
9B75 E5AD9B
9B76 E5ADA5
9B77 E5ADA9
9B78 E5ADB0
9B79 E5ADB3
9B7A E5ADB5
9B7B E5ADB8
9B7C E69688
9B7D E5ADBA
9B7E E5AE80
9B80 E5AE83
9B81 E5AEA6
9B82 E5AEB8
9B83 E5AF83
9B84 E5AF87
9B85 E5AF89
9B86 E5AF94
9B87 E5AF90
9B88 E5AFA4
9B89 E5AFA6
9B8A E5AFA2
9B8B E5AF9E
9B8C E5AFA5
9B8D E5AFAB
9B8E E5AFB0
9B8F E5AFB6
9B90 E5AFB3
9B91 E5B085
9B92 E5B087
9B93 E5B088
9B94 E5B08D
9B95 E5B093
9B96 E5B0A0
9B97 E5B0A2
9B98 E5B0A8
9B99 E5B0B8
9B9A E5B0B9
9B9B E5B181
9B9C E5B186
9B9D E5B18E
9B9E E5B193
9B9F E5B190
9BA0 E5B18F
9BA1 E5ADB1
9BA2 E5B1AC
9BA3 E5B1AE
9BA4 E4B9A2
9BA5 E5B1B6
9BA6 E5B1B9
9BA7 E5B28C
9BA8 E5B291
9BA9 E5B294
9BAA E5A69B
9BAB E5B2AB
9BAC E5B2BB
9BAD E5B2B6
9BAE E5B2BC
9BAF E5B2B7
9BB0 E5B385
9BB1 E5B2BE
9BB2 E5B387
9BB3 E5B399
9BB4 E5B3A9
9BB5 E5B3BD
9BB6 E5B3BA
9BB7 E5B3AD
9BB8 E5B68C
9BB9 E5B3AA
9BBA E5B48B
9BBB E5B495
9BBC E5B497
9BBD E5B59C
9BBE E5B49F
9BBF E5B49B
9BC0 E5B491
9BC1 E5B494
9BC2 E5B4A2
9BC3 E5B49A
9BC4 E5B499
9BC5 E5B498
9BC6 E5B58C
9BC7 E5B592
9BC8 E5B58E
9BC9 E5B58B
9BCA E5B5AC
9BCB E5B5B3
9BCC E5B5B6
9BCD E5B687
9BCE E5B684
9BCF E5B682
9BD0 E5B6A2
9BD1 E5B69D
9BD2 E5B6AC
9BD3 E5B6AE
9BD4 E5B6BD
9BD5 E5B690
9BD6 E5B6B7
9BD7 E5B6BC
9BD8 E5B789
9BD9 E5B78D
9BDA E5B793
9BDB E5B792
9BDC E5B796
9BDD E5B79B
9BDE E5B7AB
9BDF E5B7B2
9BE0 E5B7B5
9BE1 E5B88B
9BE2 E5B89A
9BE3 E5B899
9BE4 E5B891
9BE5 E5B89B
9BE6 E5B8B6
9BE7 E5B8B7
9BE8 E5B984
9BE9 E5B983
9BEA E5B980
9BEB E5B98E
9BEC E5B997
9BED E5B994
9BEE E5B99F
9BEF E5B9A2
9BF0 E5B9A4
9BF1 E5B987
9BF2 E5B9B5
9BF3 E5B9B6
9BF4 E5B9BA
9BF5 E9BABC
9BF6 E5B9BF
9BF7 E5BAA0
9BF8 E5BB81
9BF9 E5BB82
9BFA E5BB88
9BFB E5BB90
9BFC E5BB8F
9C40 E5BB96
9C41 E5BBA3
9C42 E5BB9D
9C43 E5BB9A
9C44 E5BB9B
9C45 E5BBA2
9C46 E5BBA1
9C47 E5BBA8
9C48 E5BBA9
9C49 E5BBAC
9C4A E5BBB1
9C4B E5BBB3
9C4C E5BBB0
9C4D E5BBB4
9C4E E5BBB8
9C4F E5BBBE
9C50 E5BC83
9C51 E5BC89
9C52 E5BD9D
9C53 E5BD9C
9C54 E5BC8B
9C55 E5BC91
9C56 E5BC96
9C57 E5BCA9
9C58 E5BCAD
9C59 E5BCB8
9C5A E5BD81
9C5B E5BD88
9C5C E5BD8C
9C5D E5BD8E
9C5E E5BCAF
9C5F E5BD91
9C60 E5BD96
9C61 E5BD97
9C62 E5BD99
9C63 E5BDA1
9C64 E5BDAD
9C65 E5BDB3
9C66 E5BDB7
9C67 E5BE83
9C68 E5BE82
9C69 E5BDBF
9C6A E5BE8A
9C6B E5BE88
9C6C E5BE91
9C6D E5BE87
9C6E E5BE9E
9C6F E5BE99
9C70 E5BE98
9C71 E5BEA0
9C72 E5BEA8
9C73 E5BEAD
9C74 E5BEBC
9C75 E5BF96
9C76 E5BFBB
9C77 E5BFA4
9C78 E5BFB8
9C79 E5BFB1
9C7A E5BF9D
9C7B E682B3
9C7C E5BFBF
9C7D E680A1
9C7E E681A0
9C80 E68099
9C81 E68090
9C82 E680A9
9C83 E6808E
9C84 E680B1
9C85 E6809B
9C86 E68095
9C87 E680AB
9C88 E680A6
9C89 E6808F
9C8A E680BA
9C8B E6819A
9C8C E68181
9C8D E681AA
9C8E E681B7
9C8F E6819F
9C90 E6818A
9C91 E68186
9C92 E6818D
9C93 E681A3
9C94 E68183
9C95 E681A4
9C96 E68182
9C97 E681AC
9C98 E681AB
9C99 E68199
9C9A E68281
9C9B E6828D
9C9C E683A7
9C9D E68283
9C9E E6829A
9C9F E68284
9CA0 E6829B
9CA1 E68296
9CA2 E68297
9CA3 E68292
9CA4 E682A7
9CA5 E6828B
9CA6 E683A1
9CA7 E682B8
9CA8 E683A0
9CA9 E68393
9CAA E682B4
9CAB E5BFB0
9CAC E682BD
9CAD E68386
9CAE E682B5
9CAF E68398
9CB0 E6858D
9CB1 E68495
9CB2 E68486
9CB3 E683B6
9CB4 E683B7
9CB5 E68480
9CB6 E683B4
9CB7 E683BA
9CB8 E68483
9CB9 E684A1
9CBA E683BB
9CBB E683B1
9CBC E6848D
9CBD E6848E
9CBE E68587
9CBF E684BE
9CC0 E684A8
9CC1 E684A7
9CC2 E6858A
9CC3 E684BF
9CC4 E684BC
9CC5 E684AC
9CC6 E684B4
9CC7 E684BD
9CC8 E68582
9CC9 E68584
9CCA E685B3
9CCB E685B7
9CCC E68598
9CCD E68599
9CCE E6859A
9CCF E685AB
9CD0 E685B4
9CD1 E685AF
9CD2 E685A5
9CD3 E685B1
9CD4 E6859F
9CD5 E6859D
9CD6 E68593
9CD7 E685B5
9CD8 E68699
9CD9 E68696
9CDA E68687
9CDB E686AC
9CDC E68694
9CDD E6869A
9CDE E6868A
9CDF E68691
9CE0 E686AB
9CE1 E686AE
9CE2 E6878C
9CE3 E6878A
9CE4 E68789
9CE5 E687B7
9CE6 E68788
9CE7 E68783
9CE8 E68786
9CE9 E686BA
9CEA E6878B
9CEB E7BDB9
9CEC E6878D
9CED E687A6
9CEE E687A3
9CEF E687B6
9CF0 E687BA
9CF1 E687B4
9CF2 E687BF
9CF3 E687BD
9CF4 E687BC
9CF5 E687BE
9CF6 E68880
9CF7 E68888
9CF8 E68889
9CF9 E6888D
9CFA E6888C
9CFB E68894
9CFC E6889B
9D40 E6889E
9D41 E688A1
9D42 E688AA
9D43 E688AE
9D44 E688B0
9D45 E688B2
9D46 E688B3
9D47 E68981
9D48 E6898E
9D49 E6899E
9D4A E689A3
9D4B E6899B
9D4C E689A0
9D4D E689A8
9D4E E689BC
9D4F E68A82
9D50 E68A89
9D51 E689BE
9D52 E68A92
9D53 E68A93
9D54 E68A96
9D55 E68B94
9D56 E68A83
9D57 E68A94
9D58 E68B97
9D59 E68B91
9D5A E68ABB
9D5B E68B8F
9D5C E68BBF
9D5D E68B86
9D5E E69394
9D5F E68B88
9D60 E68B9C
9D61 E68B8C
9D62 E68B8A
9D63 E68B82
9D64 E68B87
9D65 E68A9B
9D66 E68B89
9D67 E68C8C
9D68 E68BAE
9D69 E68BB1
9D6A E68CA7
9D6B E68C82
9D6C E68C88
9D6D E68BAF
9D6E E68BB5
9D6F E68D90
9D70 E68CBE
9D71 E68D8D
9D72 E6909C
9D73 E68D8F
9D74 E68E96
9D75 E68E8E
9D76 E68E80
9D77 E68EAB
9D78 E68DB6
9D79 E68EA3
9D7A E68E8F
9D7B E68E89
9D7C E68E9F
9D7D E68EB5
9D7E E68DAB
9D80 E68DA9
9D81 E68EBE
9D82 E68FA9
9D83 E68F80
9D84 E68F86
9D85 E68FA3
9D86 E68F89
9D87 E68F92
9D88 E68FB6
9D89 E68F84
9D8A E69096
9D8B E690B4
9D8C E69086
9D8D E69093
9D8E E690A6
9D8F E690B6
9D90 E6949D
9D91 E69097
9D92 E690A8
9D93 E6908F
9D94 E691A7
9D95 E691AF
9D96 E691B6
9D97 E6918E
9D98 E694AA
9D99 E69295
9D9A E69293
9D9B E692A5
9D9C E692A9
9D9D E69288
9D9E E692BC
9D9F E6939A
9DA0 E69392
9DA1 E69385
9DA2 E69387
9DA3 E692BB
9DA4 E69398
9DA5 E69382
9DA6 E693B1
9DA7 E693A7
9DA8 E88889
9DA9 E693A0
9DAA E693A1
9DAB E68AAC
9DAC E693A3
9DAD E693AF
9DAE E694AC
9DAF E693B6
9DB0 E693B4
9DB1 E693B2
9DB2 E693BA
9DB3 E69480
9DB4 E693BD
9DB5 E69498
9DB6 E6949C
9DB7 E69485
9DB8 E694A4
9DB9 E694A3
9DBA E694AB
9DBB E694B4
9DBC E694B5
9DBD E694B7
9DBE E694B6
9DBF E694B8
9DC0 E7958B
9DC1 E69588
9DC2 E69596
9DC3 E69595
9DC4 E6958D
9DC5 E69598
9DC6 E6959E
9DC7 E6959D
9DC8 E695B2
9DC9 E695B8
9DCA E69682
9DCB E69683
9DCC E8AE8A
9DCD E6969B
9DCE E6969F
9DCF E696AB
9DD0 E696B7
9DD1 E69783
9DD2 E69786
9DD3 E69781
9DD4 E69784
9DD5 E6978C
9DD6 E69792
9DD7 E6979B
9DD8 E69799
9DD9 E697A0
9DDA E697A1
9DDB E697B1
9DDC E69DB2
9DDD E6988A
9DDE E69883
9DDF E697BB
9DE0 E69DB3
9DE1 E698B5
9DE2 E698B6
9DE3 E698B4
9DE4 E6989C
9DE5 E6998F
9DE6 E69984
9DE7 E69989
9DE8 E69981
9DE9 E6999E
9DEA E6999D
9DEB E699A4
9DEC E699A7
9DED E699A8
9DEE E6999F
9DEF E699A2
9DF0 E699B0
9DF1 E69A83
9DF2 E69A88
9DF3 E69A8E
9DF4 E69A89
9DF5 E69A84
9DF6 E69A98
9DF7 E69A9D
9DF8 E69B81
9DF9 E69AB9
9DFA E69B89
9DFB E69ABE
9DFC E69ABC
9E40 E69B84
9E41 E69AB8
9E42 E69B96
9E43 E69B9A
9E44 E69BA0
9E45 E698BF
9E46 E69BA6
9E47 E69BA9
9E48 E69BB0
9E49 E69BB5
9E4A E69BB7
9E4B E69C8F
9E4C E69C96
9E4D E69C9E
9E4E E69CA6
9E4F E69CA7
9E50 E99CB8
9E51 E69CAE
9E52 E69CBF
9E53 E69CB6
9E54 E69D81
9E55 E69CB8
9E56 E69CB7
9E57 E69D86
9E58 E69D9E
9E59 E69DA0
9E5A E69D99
9E5B E69DA3
9E5C E69DA4
9E5D E69E89
9E5E E69DB0
9E5F E69EA9
9E60 E69DBC
9E61 E69DAA
9E62 E69E8C
9E63 E69E8B
9E64 E69EA6
9E65 E69EA1
9E66 E69E85
9E67 E69EB7
9E68 E69FAF
9E69 E69EB4
9E6A E69FAC
9E6B E69EB3
9E6C E69FA9
9E6D E69EB8
9E6E E69FA4
9E6F E69F9E
9E70 E69F9D
9E71 E69FA2
9E72 E69FAE
9E73 E69EB9
9E74 E69F8E
9E75 E69F86
9E76 E69FA7
9E77 E6AA9C
9E78 E6A09E
9E79 E6A186
9E7A E6A0A9
9E7B E6A180
9E7C E6A18D
9E7D E6A0B2
9E7E E6A18E
9E80 E6A2B3
9E81 E6A0AB
9E82 E6A199
9E83 E6A1A3
9E84 E6A1B7
9E85 E6A1BF
9E86 E6A29F
9E87 E6A28F
9E88 E6A2AD
9E89 E6A294
9E8A E6A29D
9E8B E6A29B
9E8C E6A283
9E8D E6AAAE
9E8E E6A2B9
9E8F E6A1B4
9E90 E6A2B5
9E91 E6A2A0
9E92 E6A2BA
9E93 E6A48F
9E94 E6A28D
9E95 E6A1BE
9E96 E6A481
9E97 E6A38A
9E98 E6A488
9E99 E6A398
9E9A E6A4A2
9E9B E6A4A6
9E9C E6A3A1
9E9D E6A48C
9E9E E6A38D
9E9F E6A394
9EA0 E6A3A7
9EA1 E6A395
9EA2 E6A4B6
9EA3 E6A492
9EA4 E6A484
9EA5 E6A397
9EA6 E6A3A3
9EA7 E6A4A5
9EA8 E6A3B9
9EA9 E6A3A0
9EAA E6A3AF
9EAB E6A4A8
9EAC E6A4AA
9EAD E6A49A
9EAE E6A4A3
9EAF E6A4A1
9EB0 E6A386
9EB1 E6A5B9
9EB2 E6A5B7
9EB3 E6A59C
9EB4 E6A5B8
9EB5 E6A5AB
9EB6 E6A594
9EB7 E6A5BE
9EB8 E6A5AE
9EB9 E6A4B9
9EBA E6A5B4
9EBB E6A4BD
9EBC E6A599
9EBD E6A4B0
9EBE E6A5A1
9EBF E6A59E
9EC0 E6A59D
9EC1 E6A681
9EC2 E6A5AA
9EC3 E6A6B2
9EC4 E6A6AE
9EC5 E6A790
9EC6 E6A6BF
9EC7 E6A781
9EC8 E6A793
9EC9 E6A6BE
9ECA E6A78E
9ECB E5AFA8
9ECC E6A78A
9ECD E6A79D
9ECE E6A6BB
9ECF E6A783
9ED0 E6A6A7
9ED1 E6A8AE
9ED2 E6A691
9ED3 E6A6A0
9ED4 E6A69C
9ED5 E6A695
9ED6 E6A6B4
9ED7 E6A79E
9ED8 E6A7A8
9ED9 E6A882
9EDA E6A89B
9EDB E6A7BF
9EDC E6AC8A
9EDD E6A7B9
9EDE E6A7B2
9EDF E6A7A7
9EE0 E6A885
9EE1 E6A6B1
9EE2 E6A89E
9EE3 E6A7AD
9EE4 E6A894
9EE5 E6A7AB
9EE6 E6A88A
9EE7 E6A892
9EE8 E6AB81
9EE9 E6A8A3
9EEA E6A893
9EEB E6A984
9EEC E6A88C
9EED E6A9B2
9EEE E6A8B6
9EEF E6A9B8
9EF0 E6A987
9EF1 E6A9A2
9EF2 E6A999
9EF3 E6A9A6
9EF4 E6A988
9EF5 E6A8B8
9EF6 E6A8A2
9EF7 E6AA90
9EF8 E6AA8D
9EF9 E6AAA0
9EFA E6AA84
9EFB E6AAA2
9EFC E6AAA3
9F40 E6AA97
9F41 E89897
9F42 E6AABB
9F43 E6AB83
9F44 E6AB82
9F45 E6AAB8
9F46 E6AAB3
9F47 E6AAAC
9F48 E6AB9E
9F49 E6AB91
9F4A E6AB9F
9F4B E6AAAA
9F4C E6AB9A
9F4D E6ABAA
9F4E E6ABBB
9F4F E6AC85
9F50 E89896
9F51 E6ABBA
9F52 E6AC92
9F53 E6AC96
9F54 E9ACB1
9F55 E6AC9F
9F56 E6ACB8
9F57 E6ACB7
9F58 E79B9C
9F59 E6ACB9
9F5A E9A3AE
9F5B E6AD87
9F5C E6AD83
9F5D E6AD89
9F5E E6AD90
9F5F E6AD99
9F60 E6AD94
9F61 E6AD9B
9F62 E6AD9F
9F63 E6ADA1
9F64 E6ADB8
9F65 E6ADB9
9F66 E6ADBF
9F67 E6AE80
9F68 E6AE84
9F69 E6AE83
9F6A E6AE8D
9F6B E6AE98
9F6C E6AE95
9F6D E6AE9E
9F6E E6AEA4
9F6F E6AEAA
9F70 E6AEAB
9F71 E6AEAF
9F72 E6AEB2
9F73 E6AEB1
9F74 E6AEB3
9F75 E6AEB7
9F76 E6AEBC
9F77 E6AF86
9F78 E6AF8B
9F79 E6AF93
9F7A E6AF9F
9F7B E6AFAC
9F7C E6AFAB
9F7D E6AFB3
9F7E E6AFAF
9F80 E9BABE
9F81 E6B088
9F82 E6B093
9F83 E6B094
9F84 E6B09B
9F85 E6B0A4
9F86 E6B0A3
9F87 E6B19E
9F88 E6B195
9F89 E6B1A2
9F8A E6B1AA
9F8B E6B282
9F8C E6B28D
9F8D E6B29A
9F8E E6B281
9F8F E6B29B
9F90 E6B1BE
9F91 E6B1A8
9F92 E6B1B3
9F93 E6B292
9F94 E6B290
9F95 E6B384
9F96 E6B3B1
9F97 E6B393
9F98 E6B2BD
9F99 E6B397
9F9A E6B385
9F9B E6B39D
9F9C E6B2AE
9F9D E6B2B1
9F9E E6B2BE
9F9F E6B2BA
9FA0 E6B39B
9FA1 E6B3AF
9FA2 E6B399
9FA3 E6B3AA
9FA4 E6B49F
9FA5 E8A18D
9FA6 E6B4B6
9FA7 E6B4AB
9FA8 E6B4BD
9FA9 E6B4B8
9FAA E6B499
9FAB E6B4B5
9FAC E6B4B3
9FAD E6B492
9FAE E6B48C
9FAF E6B5A3
9FB0 E6B693
9FB1 E6B5A4
9FB2 E6B59A
9FB3 E6B5B9
9FB4 E6B599
9FB5 E6B68E
9FB6 E6B695
9FB7 E6BFA4
9FB8 E6B685
9FB9 E6B7B9
9FBA E6B895
9FBB E6B88A
9FBC E6B6B5
9FBD E6B787
9FBE E6B7A6
9FBF E6B6B8
9FC0 E6B786
9FC1 E6B7AC
9FC2 E6B79E
9FC3 E6B78C
9FC4 E6B7A8
9FC5 E6B792
9FC6 E6B785
9FC7 E6B7BA
9FC8 E6B799
9FC9 E6B7A4
9FCA E6B795
9FCB E6B7AA
9FCC E6B7AE
9FCD E6B8AD
9FCE E6B9AE
9FCF E6B8AE
9FD0 E6B899
9FD1 E6B9B2
9FD2 E6B99F
9FD3 E6B8BE
9FD4 E6B8A3
9FD5 E6B9AB
9FD6 E6B8AB
9FD7 E6B9B6
9FD8 E6B98D
9FD9 E6B89F
9FDA E6B983
9FDB E6B8BA
9FDC E6B98E
9FDD E6B8A4
9FDE E6BBBF
9FDF E6B89D
9FE0 E6B8B8
9FE1 E6BA82
9FE2 E6BAAA
9FE3 E6BA98
9FE4 E6BB89
9FE5 E6BAB7
9FE6 E6BB93
9FE7 E6BABD
9FE8 E6BAAF
9FE9 E6BB84
9FEA E6BAB2
9FEB E6BB94
9FEC E6BB95
9FED E6BA8F
9FEE E6BAA5
9FEF E6BB82
9FF0 E6BA9F
9FF1 E6BD81
9FF2 E6BC91
9FF3 E7818C
9FF4 E6BBAC
9FF5 E6BBB8
9FF6 E6BBBE
9FF7 E6BCBF
9FF8 E6BBB2
9FF9 E6BCB1
9FFA E6BBAF
9FFB E6BCB2
9FFC E6BB8C
E040 E6BCBE
E041 E6BC93
E042 E6BBB7
E043 E6BE86
E044 E6BDBA
E045 E6BDB8
E046 E6BE81
E047 E6BE80
E048 E6BDAF
E049 E6BD9B
E04A E6BFB3
E04B E6BDAD
E04C E6BE82
E04D E6BDBC
E04E E6BD98
E04F E6BE8E
E050 E6BE91
E051 E6BF82
E052 E6BDA6
E053 E6BEB3
E054 E6BEA3
E055 E6BEA1
E056 E6BEA4
E057 E6BEB9
E058 E6BF86
E059 E6BEAA
E05A E6BF9F
E05B E6BF95
E05C E6BFAC
E05D E6BF94
E05E E6BF98
E05F E6BFB1
E060 E6BFAE
E061 E6BF9B
E062 E78089
E063 E7808B
E064 E6BFBA
E065 E78091
E066 E78081
E067 E7808F
E068 E6BFBE
E069 E7809B
E06A E7809A
E06B E6BDB4
E06C E7809D
E06D E78098
E06E E7809F
E06F E780B0
E070 E780BE
E071 E780B2
E072 E78191
E073 E781A3
E074 E78299
E075 E78292
E076 E782AF
E077 E783B1
E078 E782AC
E079 E782B8
E07A E782B3
E07B E782AE
E07C E7839F
E07D E7838B
E07E E7839D
E080 E78399
E081 E78489
E082 E783BD
E083 E7849C
E084 E78499
E085 E785A5
E086 E78595
E087 E78688
E088 E785A6
E089 E785A2
E08A E7858C
E08B E78596
E08C E785AC
E08D E7868F
E08E E787BB
E08F E78684
E090 E78695
E091 E786A8
E092 E786AC
E093 E78797
E094 E786B9
E095 E786BE
E096 E78792
E097 E78789
E098 E78794
E099 E7878E
E09A E787A0
E09B E787AC
E09C E787A7
E09D E787B5
E09E E787BC
E09F E787B9
E0A0 E787BF
E0A1 E7888D
E0A2 E78890
E0A3 E7889B
E0A4 E788A8
E0A5 E788AD
E0A6 E788AC
E0A7 E788B0
E0A8 E788B2
E0A9 E788BB
E0AA E788BC
E0AB E788BF
E0AC E78980
E0AD E78986
E0AE E7898B
E0AF E78998
E0B0 E789B4
E0B1 E789BE
E0B2 E78A82
E0B3 E78A81
E0B4 E78A87
E0B5 E78A92
E0B6 E78A96
E0B7 E78AA2
E0B8 E78AA7
E0B9 E78AB9
E0BA E78AB2
E0BB E78B83
E0BC E78B86
E0BD E78B84
E0BE E78B8E
E0BF E78B92
E0C0 E78BA2
E0C1 E78BA0
E0C2 E78BA1
E0C3 E78BB9
E0C4 E78BB7
E0C5 E5808F
E0C6 E78C97
E0C7 E78C8A
E0C8 E78C9C
E0C9 E78C96
E0CA E78C9D
E0CB E78CB4
E0CC E78CAF
E0CD E78CA9
E0CE E78CA5
E0CF E78CBE
E0D0 E78D8E
E0D1 E78D8F
E0D2 E9BB98
E0D3 E78D97
E0D4 E78DAA
E0D5 E78DA8
E0D6 E78DB0
E0D7 E78DB8
E0D8 E78DB5
E0D9 E78DBB
E0DA E78DBA
E0DB E78F88
E0DC E78EB3
E0DD E78F8E
E0DE E78EBB
E0DF E78F80
E0E0 E78FA5
E0E1 E78FAE
E0E2 E78F9E
E0E3 E792A2
E0E4 E79085
E0E5 E791AF
E0E6 E790A5
E0E7 E78FB8
E0E8 E790B2
E0E9 E790BA
E0EA E79195
E0EB E790BF
E0EC E7919F
E0ED E79199
E0EE E79181
E0EF E7919C
E0F0 E791A9
E0F1 E791B0
E0F2 E791A3
E0F3 E791AA
E0F4 E791B6
E0F5 E791BE
E0F6 E7928B
E0F7 E7929E
E0F8 E792A7
E0F9 E7938A
E0FA E7938F
E0FB E79394
E0FC E78FB1
E140 E793A0
E141 E793A3
E142 E793A7
E143 E793A9
E144 E793AE
E145 E793B2
E146 E793B0
E147 E793B1
E148 E793B8
E149 E793B7
E14A E79484
E14B E79483
E14C E79485
E14D E7948C
E14E E7948E
E14F E7948D
E150 E79495
E151 E79493
E152 E7949E
E153 E794A6
E154 E794AC
E155 E794BC
E156 E79584
E157 E7958D
E158 E7958A
E159 E79589
E15A E7959B
E15B E79586
E15C E7959A
E15D E795A9
E15E E795A4
E15F E795A7
E160 E795AB
E161 E795AD
E162 E795B8
E163 E795B6
E164 E79686
E165 E79687
E166 E795B4
E167 E7968A
E168 E79689
E169 E79682
E16A E79694
E16B E7969A
E16C E7969D
E16D E796A5
E16E E796A3
E16F E79782
E170 E796B3
E171 E79783
E172 E796B5
E173 E796BD
E174 E796B8
E175 E796BC
E176 E796B1
E177 E7978D
E178 E7978A
E179 E79792
E17A E79799
E17B E797A3
E17C E7979E
E17D E797BE
E17E E797BF
E180 E797BC
E181 E79881
E182 E797B0
E183 E797BA
E184 E797B2
E185 E797B3
E186 E7988B
E187 E7988D
E188 E79889
E189 E7989F
E18A E798A7
E18B E798A0
E18C E798A1
E18D E798A2
E18E E798A4
E18F E798B4
E190 E798B0
E191 E798BB
E192 E79987
E193 E79988
E194 E79986
E195 E7999C
E196 E79998
E197 E799A1
E198 E799A2
E199 E799A8
E19A E799A9
E19B E799AA
E19C E799A7
E19D E799AC
E19E E799B0
E19F E799B2
E1A0 E799B6
E1A1 E799B8
E1A2 E799BC
E1A3 E79A80
E1A4 E79A83
E1A5 E79A88
E1A6 E79A8B
E1A7 E79A8E
E1A8 E79A96
E1A9 E79A93
E1AA E79A99
E1AB E79A9A
E1AC E79AB0
E1AD E79AB4
E1AE E79AB8
E1AF E79AB9
E1B0 E79ABA
E1B1 E79B82
E1B2 E79B8D
E1B3 E79B96
E1B4 E79B92
E1B5 E79B9E
E1B6 E79BA1
E1B7 E79BA5
E1B8 E79BA7
E1B9 E79BAA
E1BA E898AF
E1BB E79BBB
E1BC E79C88
E1BD E79C87
E1BE E79C84
E1BF E79CA9
E1C0 E79CA4
E1C1 E79C9E
E1C2 E79CA5
E1C3 E79CA6
E1C4 E79C9B
E1C5 E79CB7
E1C6 E79CB8
E1C7 E79D87
E1C8 E79D9A
E1C9 E79DA8
E1CA E79DAB
E1CB E79D9B
E1CC E79DA5
E1CD E79DBF
E1CE E79DBE
E1CF E79DB9
E1D0 E79E8E
E1D1 E79E8B
E1D2 E79E91
E1D3 E79EA0
E1D4 E79E9E
E1D5 E79EB0
E1D6 E79EB6
E1D7 E79EB9
E1D8 E79EBF
E1D9 E79EBC
E1DA E79EBD
E1DB E79EBB
E1DC E79F87
E1DD E79F8D
E1DE E79F97
E1DF E79F9A
E1E0 E79F9C
E1E1 E79FA3
E1E2 E79FAE
E1E3 E79FBC
E1E4 E7A08C
E1E5 E7A092
E1E6 E7A4A6
E1E7 E7A0A0
E1E8 E7A4AA
E1E9 E7A185
E1EA E7A28E
E1EB E7A1B4
E1EC E7A286
E1ED E7A1BC
E1EE E7A29A
E1EF E7A28C
E1F0 E7A2A3
E1F1 E7A2B5
E1F2 E7A2AA
E1F3 E7A2AF
E1F4 E7A391
E1F5 E7A386
E1F6 E7A38B
E1F7 E7A394
E1F8 E7A2BE
E1F9 E7A2BC
E1FA E7A385
E1FB E7A38A
E1FC E7A3AC
E240 E7A3A7
E241 E7A39A
E242 E7A3BD
E243 E7A3B4
E244 E7A487
E245 E7A492
E246 E7A491
E247 E7A499
E248 E7A4AC
E249 E7A4AB
E24A E7A580
E24B E7A5A0
E24C E7A597
E24D E7A59F
E24E E7A59A
E24F E7A595
E250 E7A593
E251 E7A5BA
E252 E7A5BF
E253 E7A68A
E254 E7A69D
E255 E7A6A7
E256 E9BD8B
E257 E7A6AA
E258 E7A6AE
E259 E7A6B3
E25A E7A6B9
E25B E7A6BA
E25C E7A789
E25D E7A795
E25E E7A7A7
E25F E7A7AC
E260 E7A7A1
E261 E7A7A3
E262 E7A888
E263 E7A88D
E264 E7A898
E265 E7A899
E266 E7A8A0
E267 E7A89F
E268 E7A680
E269 E7A8B1
E26A E7A8BB
E26B E7A8BE
E26C E7A8B7
E26D E7A983
E26E E7A997
E26F E7A989
E270 E7A9A1
E271 E7A9A2
E272 E7A9A9
E273 E9BE9D
E274 E7A9B0
E275 E7A9B9
E276 E7A9BD
E277 E7AA88
E278 E7AA97
E279 E7AA95
E27A E7AA98
E27B E7AA96
E27C E7AAA9
E27D E7AB88
E27E E7AAB0
E280 E7AAB6
E281 E7AB85
E282 E7AB84
E283 E7AABF
E284 E98283
E285 E7AB87
E286 E7AB8A
E287 E7AB8D
E288 E7AB8F
E289 E7AB95
E28A E7AB93
E28B E7AB99
E28C E7AB9A
E28D E7AB9D
E28E E7ABA1
E28F E7ABA2
E290 E7ABA6
E291 E7ABAD
E292 E7ABB0
E293 E7AC82
E294 E7AC8F
E295 E7AC8A
E296 E7AC86
E297 E7ACB3
E298 E7AC98
E299 E7AC99
E29A E7AC9E
E29B E7ACB5
E29C E7ACA8
E29D E7ACB6
E29E E7AD90
E29F E7ADBA
E2A0 E7AC84
E2A1 E7AD8D
E2A2 E7AC8B
E2A3 E7AD8C
E2A4 E7AD85
E2A5 E7ADB5
E2A6 E7ADA5
E2A7 E7ADB4
E2A8 E7ADA7
E2A9 E7ADB0
E2AA E7ADB1
E2AB E7ADAC
E2AC E7ADAE
E2AD E7AE9D
E2AE E7AE98
E2AF E7AE9F
E2B0 E7AE8D
E2B1 E7AE9C
E2B2 E7AE9A
E2B3 E7AE8B
E2B4 E7AE92
E2B5 E7AE8F
E2B6 E7AD9D
E2B7 E7AE99
E2B8 E7AF8B
E2B9 E7AF81
E2BA E7AF8C
E2BB E7AF8F
E2BC E7AEB4
E2BD E7AF86
E2BE E7AF9D
E2BF E7AFA9
E2C0 E7B091
E2C1 E7B094
E2C2 E7AFA6
E2C3 E7AFA5
E2C4 E7B1A0
E2C5 E7B080
E2C6 E7B087
E2C7 E7B093
E2C8 E7AFB3
E2C9 E7AFB7
E2CA E7B097
E2CB E7B08D
E2CC E7AFB6
E2CD E7B0A3
E2CE E7B0A7
E2CF E7B0AA
E2D0 E7B09F
E2D1 E7B0B7
E2D2 E7B0AB
E2D3 E7B0BD
E2D4 E7B18C
E2D5 E7B183
E2D6 E7B194
E2D7 E7B18F
E2D8 E7B180
E2D9 E7B190
E2DA E7B198
E2DB E7B19F
E2DC E7B1A4
E2DD E7B196
E2DE E7B1A5
E2DF E7B1AC
E2E0 E7B1B5
E2E1 E7B283
E2E2 E7B290
E2E3 E7B2A4
E2E4 E7B2AD
E2E5 E7B2A2
E2E6 E7B2AB
E2E7 E7B2A1
E2E8 E7B2A8
E2E9 E7B2B3
E2EA E7B2B2
E2EB E7B2B1
E2EC E7B2AE
E2ED E7B2B9
E2EE E7B2BD
E2EF E7B380
E2F0 E7B385
E2F1 E7B382
E2F2 E7B398
E2F3 E7B392
E2F4 E7B39C
E2F5 E7B3A2
E2F6 E9ACBB
E2F7 E7B3AF
E2F8 E7B3B2
E2F9 E7B3B4
E2FA E7B3B6
E2FB E7B3BA
E2FC E7B486
E340 E7B482
E341 E7B49C
E342 E7B495
E343 E7B48A
E344 E7B585
E345 E7B58B
E346 E7B4AE
E347 E7B4B2
E348 E7B4BF
E349 E7B4B5
E34A E7B586
E34B E7B5B3
E34C E7B596
E34D E7B58E
E34E E7B5B2
E34F E7B5A8
E350 E7B5AE
E351 E7B58F
E352 E7B5A3
E353 E7B693
E354 E7B689
E355 E7B59B
E356 E7B68F
E357 E7B5BD
E358 E7B69B
E359 E7B6BA
E35A E7B6AE
E35B E7B6A3
E35C E7B6B5
E35D E7B787
E35E E7B6BD
E35F E7B6AB
E360 E7B8BD
E361 E7B6A2
E362 E7B6AF
E363 E7B79C
E364 E7B6B8
E365 E7B69F
E366 E7B6B0
E367 E7B798
E368 E7B79D
E369 E7B7A4
E36A E7B79E
E36B E7B7BB
E36C E7B7B2
E36D E7B7A1
E36E E7B885
E36F E7B88A
E370 E7B8A3
E371 E7B8A1
E372 E7B892
E373 E7B8B1
E374 E7B89F
E375 E7B889
E376 E7B88B
E377 E7B8A2
E378 E7B986
E379 E7B9A6
E37A E7B8BB
E37B E7B8B5
E37C E7B8B9
E37D E7B983
E37E E7B8B7
E380 E7B8B2
E381 E7B8BA
E382 E7B9A7
E383 E7B99D
E384 E7B996
E385 E7B99E
E386 E7B999
E387 E7B99A
E388 E7B9B9
E389 E7B9AA
E38A E7B9A9
E38B E7B9BC
E38C E7B9BB
E38D E7BA83
E38E E7B795
E38F E7B9BD
E390 E8BEAE
E391 E7B9BF
E392 E7BA88
E393 E7BA89
E394 E7BA8C
E395 E7BA92
E396 E7BA90
E397 E7BA93
E398 E7BA94
E399 E7BA96
E39A E7BA8E
E39B E7BA9B
E39C E7BA9C
E39D E7BCB8
E39E E7BCBA
E39F E7BD85
E3A0 E7BD8C
E3A1 E7BD8D
E3A2 E7BD8E
E3A3 E7BD90
E3A4 E7BD91
E3A5 E7BD95
E3A6 E7BD94
E3A7 E7BD98
E3A8 E7BD9F
E3A9 E7BDA0
E3AA E7BDA8
E3AB E7BDA9
E3AC E7BDA7
E3AD E7BDB8
E3AE E7BE82
E3AF E7BE86
E3B0 E7BE83
E3B1 E7BE88
E3B2 E7BE87
E3B3 E7BE8C
E3B4 E7BE94
E3B5 E7BE9E
E3B6 E7BE9D
E3B7 E7BE9A
E3B8 E7BEA3
E3B9 E7BEAF
E3BA E7BEB2
E3BB E7BEB9
E3BC E7BEAE
E3BD E7BEB6
E3BE E7BEB8
E3BF E8ADB1
E3C0 E7BF85
E3C1 E7BF86
E3C2 E7BF8A
E3C3 E7BF95
E3C4 E7BF94
E3C5 E7BFA1
E3C6 E7BFA6
E3C7 E7BFA9
E3C8 E7BFB3
E3C9 E7BFB9
E3CA E9A39C
E3CB E88086
E3CC E88084
E3CD E8808B
E3CE E88092
E3CF E88098
E3D0 E88099
E3D1 E8809C
E3D2 E880A1
E3D3 E880A8
E3D4 E880BF
E3D5 E880BB
E3D6 E8818A
E3D7 E88186
E3D8 E88192
E3D9 E88198
E3DA E8819A
E3DB E8819F
E3DC E881A2
E3DD E881A8
E3DE E881B3
E3DF E881B2
E3E0 E881B0
E3E1 E881B6
E3E2 E881B9
E3E3 E881BD
E3E4 E881BF
E3E5 E88284
E3E6 E88286
E3E7 E88285
E3E8 E8829B
E3E9 E88293
E3EA E8829A
E3EB E882AD
E3EC E58690
E3ED E882AC
E3EE E8839B
E3EF E883A5
E3F0 E88399
E3F1 E8839D
E3F2 E88384
E3F3 E8839A
E3F4 E88396
E3F5 E88489
E3F6 E883AF
E3F7 E883B1
E3F8 E8849B
E3F9 E884A9
E3FA E884A3
E3FB E884AF
E3FC E8858B
E440 E99A8B
E441 E88586
E442 E884BE
E443 E88593
E444 E88591
E445 E883BC
E446 E885B1
E447 E885AE
E448 E885A5
E449 E885A6
E44A E885B4
E44B E88683
E44C E88688
E44D E8868A
E44E E88680
E44F E88682
E450 E886A0
E451 E88695
E452 E886A4
E453 E886A3
E454 E8859F
E455 E88693
E456 E886A9
E457 E886B0
E458 E886B5
E459 E886BE
E45A E886B8
E45B E886BD
E45C E88780
E45D E88782
E45E E886BA
E45F E88789
E460 E8878D
E461 E88791
E462 E88799
E463 E88798
E464 E88788
E465 E8879A
E466 E8879F
E467 E887A0
E468 E887A7
E469 E887BA
E46A E887BB
E46B E887BE
E46C E88881
E46D E88882
E46E E88885
E46F E88887
E470 E8888A
E471 E8888D
E472 E88890
E473 E88896
E474 E888A9
E475 E888AB
E476 E888B8
E477 E888B3
E478 E88980
E479 E88999
E47A E88998
E47B E8899D
E47C E8899A
E47D E8899F
E47E E889A4
E480 E889A2
E481 E889A8
E482 E889AA
E483 E889AB
E484 E888AE
E485 E889B1
E486 E889B7
E487 E889B8
E488 E889BE
E489 E88A8D
E48A E88A92
E48B E88AAB
E48C E88A9F
E48D E88ABB
E48E E88AAC
E48F E88BA1
E490 E88BA3
E491 E88B9F
E492 E88B92
E493 E88BB4
E494 E88BB3
E495 E88BBA
E496 E88E93
E497 E88C83
E498 E88BBB
E499 E88BB9
E49A E88B9E
E49B E88C86
E49C E88B9C
E49D E88C89
E49E E88B99
E49F E88CB5
E4A0 E88CB4
E4A1 E88C96
E4A2 E88CB2
E4A3 E88CB1
E4A4 E88D80
E4A5 E88CB9
E4A6 E88D90
E4A7 E88D85
E4A8 E88CAF
E4A9 E88CAB
E4AA E88C97
E4AB E88C98
E4AC E88E85
E4AD E88E9A
E4AE E88EAA
E4AF E88E9F
E4B0 E88EA2
E4B1 E88E96
E4B2 E88CA3
E4B3 E88E8E
E4B4 E88E87
E4B5 E88E8A
E4B6 E88DBC
E4B7 E88EB5
E4B8 E88DB3
E4B9 E88DB5
E4BA E88EA0
E4BB E88E89
E4BC E88EA8
E4BD E88FB4
E4BE E89093
E4BF E88FAB
E4C0 E88F8E
E4C1 E88FBD
E4C2 E89083
E4C3 E88F98
E4C4 E8908B
E4C5 E88F81
E4C6 E88FB7
E4C7 E89087
E4C8 E88FA0
E4C9 E88FB2
E4CA E8908D
E4CB E890A2
E4CC E890A0
E4CD E88EBD
E4CE E890B8
E4CF E89486
E4D0 E88FBB
E4D1 E891AD
E4D2 E890AA
E4D3 E890BC
E4D4 E8959A
E4D5 E89284
E4D6 E891B7
E4D7 E891AB
E4D8 E892AD
E4D9 E891AE
E4DA E89282
E4DB E891A9
E4DC E89186
E4DD E890AC
E4DE E891AF
E4DF E891B9
E4E0 E890B5
E4E1 E8938A
E4E2 E891A2
E4E3 E892B9
E4E4 E892BF
E4E5 E8929F
E4E6 E89399
E4E7 E8938D
E4E8 E892BB
E4E9 E8939A
E4EA E89390
E4EB E89381
E4EC E89386
E4ED E89396
E4EE E892A1
E4EF E894A1
E4F0 E893BF
E4F1 E893B4
E4F2 E89497
E4F3 E89498
E4F4 E894AC
E4F5 E8949F
E4F6 E89495
E4F7 E89494
E4F8 E893BC
E4F9 E89580
E4FA E895A3
E4FB E89598
E4FC E89588
E540 E89581
E541 E89882
E542 E8958B
E543 E89595
E544 E89680
E545 E896A4
E546 E89688
E547 E89691
E548 E8968A
E549 E896A8
E54A E895AD
E54B E89694
E54C E8969B
E54D E897AA
E54E E89687
E54F E8969C
E550 E895B7
E551 E895BE
E552 E89690
E553 E89789
E554 E896BA
E555 E8978F
E556 E896B9
E557 E89790
E558 E89795
E559 E8979D
E55A E897A5
E55B E8979C
E55C E897B9
E55D E8988A
E55E E89893
E55F E8988B
E560 E897BE
E561 E897BA
E562 E89886
E563 E898A2
E564 E8989A
E565 E898B0
E566 E898BF
E567 E8998D
E568 E4B995
E569 E89994
E56A E8999F
E56B E899A7
E56C E899B1
E56D E89A93
E56E E89AA3
E56F E89AA9
E570 E89AAA
E571 E89A8B
E572 E89A8C
E573 E89AB6
E574 E89AAF
E575 E89B84
E576 E89B86
E577 E89AB0
E578 E89B89
E579 E8A0A3
E57A E89AAB
E57B E89B94
E57C E89B9E
E57D E89BA9
E57E E89BAC
E580 E89B9F
E581 E89B9B
E582 E89BAF
E583 E89C92
E584 E89C86
E585 E89C88
E586 E89C80
E587 E89C83
E588 E89BBB
E589 E89C91
E58A E89C89
E58B E89C8D
E58C E89BB9
E58D E89C8A
E58E E89CB4
E58F E89CBF
E590 E89CB7
E591 E89CBB
E592 E89CA5
E593 E89CA9
E594 E89C9A
E595 E89DA0
E596 E89D9F
E597 E89DB8
E598 E89D8C
E599 E89D8E
E59A E89DB4
E59B E89D97
E59C E89DA8
E59D E89DAE
E59E E89D99
E59F E89D93
E5A0 E89DA3
E5A1 E89DAA
E5A2 E8A085
E5A3 E89EA2
E5A4 E89E9F
E5A5 E89E82
E5A6 E89EAF
E5A7 E89F8B
E5A8 E89EBD
E5A9 E89F80
E5AA E89F90
E5AB E99B96
E5AC E89EAB
E5AD E89F84
E5AE E89EB3
E5AF E89F87
E5B0 E89F86
E5B1 E89EBB
E5B2 E89FAF
E5B3 E89FB2
E5B4 E89FA0
E5B5 E8A08F
E5B6 E8A08D
E5B7 E89FBE
E5B8 E89FB6
E5B9 E89FB7
E5BA E8A08E
E5BB E89F92
E5BC E8A091
E5BD E8A096
E5BE E8A095
E5BF E8A0A2
E5C0 E8A0A1
E5C1 E8A0B1
E5C2 E8A0B6
E5C3 E8A0B9
E5C4 E8A0A7
E5C5 E8A0BB
E5C6 E8A184
E5C7 E8A182
E5C8 E8A192
E5C9 E8A199
E5CA E8A19E
E5CB E8A1A2
E5CC E8A1AB
E5CD E8A281
E5CE E8A1BE
E5CF E8A29E
E5D0 E8A1B5
E5D1 E8A1BD
E5D2 E8A2B5
E5D3 E8A1B2
E5D4 E8A282
E5D5 E8A297
E5D6 E8A292
E5D7 E8A2AE
E5D8 E8A299
E5D9 E8A2A2
E5DA E8A28D
E5DB E8A2A4
E5DC E8A2B0
E5DD E8A2BF
E5DE E8A2B1
E5DF E8A383
E5E0 E8A384
E5E1 E8A394
E5E2 E8A398
E5E3 E8A399
E5E4 E8A39D
E5E5 E8A3B9
E5E6 E8A482
E5E7 E8A3BC
E5E8 E8A3B4
E5E9 E8A3A8
E5EA E8A3B2
E5EB E8A484
E5EC E8A48C
E5ED E8A48A
E5EE E8A493
E5EF E8A583
E5F0 E8A49E
E5F1 E8A4A5
E5F2 E8A4AA
E5F3 E8A4AB
E5F4 E8A581
E5F5 E8A584
E5F6 E8A4BB
E5F7 E8A4B6
E5F8 E8A4B8
E5F9 E8A58C
E5FA E8A49D
E5FB E8A5A0
E5FC E8A59E
E640 E8A5A6
E641 E8A5A4
E642 E8A5AD
E643 E8A5AA
E644 E8A5AF
E645 E8A5B4
E646 E8A5B7
E647 E8A5BE
E648 E8A683
E649 E8A688
E64A E8A68A
E64B E8A693
E64C E8A698
E64D E8A6A1
E64E E8A6A9
E64F E8A6A6
E650 E8A6AC
E651 E8A6AF
E652 E8A6B2
E653 E8A6BA
E654 E8A6BD
E655 E8A6BF
E656 E8A780
E657 E8A79A
E658 E8A79C
E659 E8A79D
E65A E8A7A7
E65B E8A7B4
E65C E8A7B8
E65D E8A883
E65E E8A896
E65F E8A890
E660 E8A88C
E661 E8A89B
E662 E8A89D
E663 E8A8A5
E664 E8A8B6
E665 E8A981
E666 E8A99B
E667 E8A992
E668 E8A986
E669 E8A988
E66A E8A9BC
E66B E8A9AD
E66C E8A9AC
E66D E8A9A2
E66E E8AA85
E66F E8AA82
E670 E8AA84
E671 E8AAA8
E672 E8AAA1
E673 E8AA91
E674 E8AAA5
E675 E8AAA6
E676 E8AA9A
E677 E8AAA3
E678 E8AB84
E679 E8AB8D
E67A E8AB82
E67B E8AB9A
E67C E8ABAB
E67D E8ABB3
E67E E8ABA7
E680 E8ABA4
E681 E8ABB1
E682 E8AC94
E683 E8ABA0
E684 E8ABA2
E685 E8ABB7
E686 E8AB9E
E687 E8AB9B
E688 E8AC8C
E689 E8AC87
E68A E8AC9A
E68B E8ABA1
E68C E8AC96
E68D E8AC90
E68E E8AC97
E68F E8ACA0
E690 E8ACB3
E691 E99EAB
E692 E8ACA6
E693 E8ACAB
E694 E8ACBE
E695 E8ACA8
E696 E8AD81
E697 E8AD8C
E698 E8AD8F
E699 E8AD8E
E69A E8AD89
E69B E8AD96
E69C E8AD9B
E69D E8AD9A
E69E E8ADAB
E69F E8AD9F
E6A0 E8ADAC
E6A1 E8ADAF
E6A2 E8ADB4
E6A3 E8ADBD
E6A4 E8AE80
E6A5 E8AE8C
E6A6 E8AE8E
E6A7 E8AE92
E6A8 E8AE93
E6A9 E8AE96
E6AA E8AE99
E6AB E8AE9A
E6AC E8B0BA
E6AD E8B181
E6AE E8B0BF
E6AF E8B188
E6B0 E8B18C
E6B1 E8B18E
E6B2 E8B190
E6B3 E8B195
E6B4 E8B1A2
E6B5 E8B1AC
E6B6 E8B1B8
E6B7 E8B1BA
E6B8 E8B282
E6B9 E8B289
E6BA E8B285
E6BB E8B28A
E6BC E8B28D
E6BD E8B28E
E6BE E8B294
E6BF E8B1BC
E6C0 E8B298
E6C1 E6889D
E6C2 E8B2AD
E6C3 E8B2AA
E6C4 E8B2BD
E6C5 E8B2B2
E6C6 E8B2B3
E6C7 E8B2AE
E6C8 E8B2B6
E6C9 E8B388
E6CA E8B381
E6CB E8B3A4
E6CC E8B3A3
E6CD E8B39A
E6CE E8B3BD
E6CF E8B3BA
E6D0 E8B3BB
E6D1 E8B484
E6D2 E8B485
E6D3 E8B48A
E6D4 E8B487
E6D5 E8B48F
E6D6 E8B48D
E6D7 E8B490
E6D8 E9BD8E
E6D9 E8B493
E6DA E8B38D
E6DB E8B494
E6DC E8B496
E6DD E8B5A7
E6DE E8B5AD
E6DF E8B5B1
E6E0 E8B5B3
E6E1 E8B681
E6E2 E8B699
E6E3 E8B782
E6E4 E8B6BE
E6E5 E8B6BA
E6E6 E8B78F
E6E7 E8B79A
E6E8 E8B796
E6E9 E8B78C
E6EA E8B79B
E6EB E8B78B
E6EC E8B7AA
E6ED E8B7AB
E6EE E8B79F
E6EF E8B7A3
E6F0 E8B7BC
E6F1 E8B888
E6F2 E8B889
E6F3 E8B7BF
E6F4 E8B89D
E6F5 E8B89E
E6F6 E8B890
E6F7 E8B89F
E6F8 E8B982
E6F9 E8B8B5
E6FA E8B8B0
E6FB E8B8B4
E6FC E8B98A
E740 E8B987
E741 E8B989
E742 E8B98C
E743 E8B990
E744 E8B988
E745 E8B999
E746 E8B9A4
E747 E8B9A0
E748 E8B8AA
E749 E8B9A3
E74A E8B995
E74B E8B9B6
E74C E8B9B2
E74D E8B9BC
E74E E8BA81
E74F E8BA87
E750 E8BA85
E751 E8BA84
E752 E8BA8B
E753 E8BA8A
E754 E8BA93
E755 E8BA91
E756 E8BA94
E757 E8BA99
E758 E8BAAA
E759 E8BAA1
E75A E8BAAC
E75B E8BAB0
E75C E8BB86
E75D E8BAB1
E75E E8BABE
E75F E8BB85
E760 E8BB88
E761 E8BB8B
E762 E8BB9B
E763 E8BBA3
E764 E8BBBC
E765 E8BBBB
E766 E8BBAB
E767 E8BBBE
E768 E8BC8A
E769 E8BC85
E76A E8BC95
E76B E8BC92
E76C E8BC99
E76D E8BC93
E76E E8BC9C
E76F E8BC9F
E770 E8BC9B
E771 E8BC8C
E772 E8BCA6
E773 E8BCB3
E774 E8BCBB
E775 E8BCB9
E776 E8BD85
E777 E8BD82
E778 E8BCBE
E779 E8BD8C
E77A E8BD89
E77B E8BD86
E77C E8BD8E
E77D E8BD97
E77E E8BD9C
E780 E8BDA2
E781 E8BDA3
E782 E8BDA4
E783 E8BE9C
E784 E8BE9F
E785 E8BEA3
E786 E8BEAD
E787 E8BEAF
E788 E8BEB7
E789 E8BF9A
E78A E8BFA5
E78B E8BFA2
E78C E8BFAA
E78D E8BFAF
E78E E98287
E78F E8BFB4
E790 E98085
E791 E8BFB9
E792 E8BFBA
E793 E98091
E794 E98095
E795 E980A1
E796 E9808D
E797 E9809E
E798 E98096
E799 E9808B
E79A E980A7
E79B E980B6
E79C E980B5
E79D E980B9
E79E E8BFB8
E79F E9818F
E7A0 E98190
E7A1 E98191
E7A2 E98192
E7A3 E9808E
E7A4 E98189
E7A5 E980BE
E7A6 E98196
E7A7 E98198
E7A8 E9819E
E7A9 E981A8
E7AA E981AF
E7AB E981B6
E7AC E99AA8
E7AD E981B2
E7AE E98282
E7AF E981BD
E7B0 E98281
E7B1 E98280
E7B2 E9828A
E7B3 E98289
E7B4 E9828F
E7B5 E982A8
E7B6 E982AF
E7B7 E982B1
E7B8 E982B5
E7B9 E983A2
E7BA E983A4
E7BB E68988
E7BC E9839B
E7BD E98482
E7BE E98492
E7BF E98499
E7C0 E984B2
E7C1 E984B0
E7C2 E9858A
E7C3 E98596
E7C4 E98598
E7C5 E985A3
E7C6 E985A5
E7C7 E985A9
E7C8 E985B3
E7C9 E985B2
E7CA E9868B
E7CB E98689
E7CC E98682
E7CD E986A2
E7CE E986AB
E7CF E986AF
E7D0 E986AA
E7D1 E986B5
E7D2 E986B4
E7D3 E986BA
E7D4 E98780
E7D5 E98781
E7D6 E98789
E7D7 E9878B
E7D8 E98790
E7D9 E98796
E7DA E9879F
E7DB E987A1
E7DC E9879B
E7DD E987BC
E7DE E987B5
E7DF E987B6
E7E0 E9889E
E7E1 E987BF
E7E2 E98894
E7E3 E988AC
E7E4 E98895
E7E5 E98891
E7E6 E9899E
E7E7 E98997
E7E8 E98985
E7E9 E98989
E7EA E989A4
E7EB E98988
E7EC E98A95
E7ED E988BF
E7EE E9898B
E7EF E98990
E7F0 E98A9C
E7F1 E98A96
E7F2 E98A93
E7F3 E98A9B
E7F4 E9899A
E7F5 E98B8F
E7F6 E98AB9
E7F7 E98AB7
E7F8 E98BA9
E7F9 E98C8F
E7FA E98BBA
E7FB E98D84
E7FC E98CAE
E840 E98C99
E841 E98CA2
E842 E98C9A
E843 E98CA3
E844 E98CBA
E845 E98CB5
E846 E98CBB
E847 E98D9C
E848 E98DA0
E849 E98DBC
E84A E98DAE
E84B E98D96
E84C E98EB0
E84D E98EAC
E84E E98EAD
E84F E98E94
E850 E98EB9
E851 E98F96
E852 E98F97
E853 E98FA8
E854 E98FA5
E855 E98F98
E856 E98F83
E857 E98F9D
E858 E98F90
E859 E98F88
E85A E98FA4
E85B E9909A
E85C E99094
E85D E99093
E85E E99083
E85F E99087
E860 E99090
E861 E990B6
E862 E990AB
E863 E990B5
E864 E990A1
E865 E990BA
E866 E99181
E867 E99192
E868 E99184
E869 E9919B
E86A E991A0
E86B E991A2
E86C E9919E
E86D E991AA
E86E E988A9
E86F E991B0
E870 E991B5
E871 E991B7
E872 E991BD
E873 E9919A
E874 E991BC
E875 E991BE
E876 E99281
E877 E991BF
E878 E99682
E879 E99687
E87A E9968A
E87B E99694
E87C E99696
E87D E99698
E87E E99699
E880 E996A0
E881 E996A8
E882 E996A7
E883 E996AD
E884 E996BC
E885 E996BB
E886 E996B9
E887 E996BE
E888 E9978A
E889 E6BFB6
E88A E99783
E88B E9978D
E88C E9978C
E88D E99795
E88E E99794
E88F E99796
E890 E9979C
E891 E997A1
E892 E997A5
E893 E997A2
E894 E998A1
E895 E998A8
E896 E998AE
E897 E998AF
E898 E99982
E899 E9998C
E89A E9998F
E89B E9998B
E89C E999B7
E89D E9999C
E89E E9999E
E89F E9999D
E8A0 E9999F
E8A1 E999A6
E8A2 E999B2
E8A3 E999AC
E8A4 E99A8D
E8A5 E99A98
E8A6 E99A95
E8A7 E99A97
E8A8 E99AAA
E8A9 E99AA7
E8AA E99AB1
E8AB E99AB2
E8AC E99AB0
E8AD E99AB4
E8AE E99AB6
E8AF E99AB8
E8B0 E99AB9
E8B1 E99B8E
E8B2 E99B8B
E8B3 E99B89
E8B4 E99B8D
E8B5 E8A58D
E8B6 E99B9C
E8B7 E99C8D
E8B8 E99B95
E8B9 E99BB9
E8BA E99C84
E8BB E99C86
E8BC E99C88
E8BD E99C93
E8BE E99C8E
E8BF E99C91
E8C0 E99C8F
E8C1 E99C96
E8C2 E99C99
E8C3 E99CA4
E8C4 E99CAA
E8C5 E99CB0
E8C6 E99CB9
E8C7 E99CBD
E8C8 E99CBE
E8C9 E99D84
E8CA E99D86
E8CB E99D88
E8CC E99D82
E8CD E99D89
E8CE E99D9C
E8CF E99DA0
E8D0 E99DA4
E8D1 E99DA6
E8D2 E99DA8
E8D3 E58B92
E8D4 E99DAB
E8D5 E99DB1
E8D6 E99DB9
E8D7 E99E85
E8D8 E99DBC
E8D9 E99E81
E8DA E99DBA
E8DB E99E86
E8DC E99E8B
E8DD E99E8F
E8DE E99E90
E8DF E99E9C
E8E0 E99EA8
E8E1 E99EA6
E8E2 E99EA3
E8E3 E99EB3
E8E4 E99EB4
E8E5 E99F83
E8E6 E99F86
E8E7 E99F88
E8E8 E99F8B
E8E9 E99F9C
E8EA E99FAD
E8EB E9BD8F
E8EC E99FB2
E8ED E7AB9F
E8EE E99FB6
E8EF E99FB5
E8F0 E9A08F
E8F1 E9A08C
E8F2 E9A0B8
E8F3 E9A0A4
E8F4 E9A0A1
E8F5 E9A0B7
E8F6 E9A0BD
E8F7 E9A186
E8F8 E9A18F
E8F9 E9A18B
E8FA E9A1AB
E8FB E9A1AF
E8FC E9A1B0
E940 E9A1B1
E941 E9A1B4
E942 E9A1B3
E943 E9A2AA
E944 E9A2AF
E945 E9A2B1
E946 E9A2B6
E947 E9A384
E948 E9A383
E949 E9A386
E94A E9A3A9
E94B E9A3AB
E94C E9A483
E94D E9A489
E94E E9A492
E94F E9A494
E950 E9A498
E951 E9A4A1
E952 E9A49D
E953 E9A49E
E954 E9A4A4
E955 E9A4A0
E956 E9A4AC
E957 E9A4AE
E958 E9A4BD
E959 E9A4BE
E95A E9A582
E95B E9A589
E95C E9A585
E95D E9A590
E95E E9A58B
E95F E9A591
E960 E9A592
E961 E9A58C
E962 E9A595
E963 E9A697
E964 E9A698
E965 E9A6A5
E966 E9A6AD
E967 E9A6AE
E968 E9A6BC
E969 E9A79F
E96A E9A79B
E96B E9A79D
E96C E9A798
E96D E9A791
E96E E9A7AD
E96F E9A7AE
E970 E9A7B1
E971 E9A7B2
E972 E9A7BB
E973 E9A7B8
E974 E9A881
E975 E9A88F
E976 E9A885
E977 E9A7A2
E978 E9A899
E979 E9A8AB
E97A E9A8B7
E97B E9A985
E97C E9A982
E97D E9A980
E97E E9A983
E980 E9A8BE
E981 E9A995
E982 E9A98D
E983 E9A99B
E984 E9A997
E985 E9A99F
E986 E9A9A2
E987 E9A9A5
E988 E9A9A4
E989 E9A9A9
E98A E9A9AB
E98B E9A9AA
E98C E9AAAD
E98D E9AAB0
E98E E9AABC
E98F E9AB80
E990 E9AB8F
E991 E9AB91
E992 E9AB93
E993 E9AB94
E994 E9AB9E
E995 E9AB9F
E996 E9ABA2
E997 E9ABA3
E998 E9ABA6
E999 E9ABAF
E99A E9ABAB
E99B E9ABAE
E99C E9ABB4
E99D E9ABB1
E99E E9ABB7
E99F E9ABBB
E9A0 E9AC86
E9A1 E9AC98
E9A2 E9AC9A
E9A3 E9AC9F
E9A4 E9ACA2
E9A5 E9ACA3
E9A6 E9ACA5
E9A7 E9ACA7
E9A8 E9ACA8
E9A9 E9ACA9
E9AA E9ACAA
E9AB E9ACAE
E9AC E9ACAF
E9AD E9ACB2
E9AE E9AD84
E9AF E9AD83
E9B0 E9AD8F
E9B1 E9AD8D
E9B2 E9AD8E
E9B3 E9AD91
E9B4 E9AD98
E9B5 E9ADB4
E9B6 E9AE93
E9B7 E9AE83
E9B8 E9AE91
E9B9 E9AE96
E9BA E9AE97
E9BB E9AE9F
E9BC E9AEA0
E9BD E9AEA8
E9BE E9AEB4
E9BF E9AF80
E9C0 E9AF8A
E9C1 E9AEB9
E9C2 E9AF86
E9C3 E9AF8F
E9C4 E9AF91
E9C5 E9AF92
E9C6 E9AFA3
E9C7 E9AFA2
E9C8 E9AFA4
E9C9 E9AF94
E9CA E9AFA1
E9CB E9B0BA
E9CC E9AFB2
E9CD E9AFB1
E9CE E9AFB0
E9CF E9B095
E9D0 E9B094
E9D1 E9B089
E9D2 E9B093
E9D3 E9B08C
E9D4 E9B086
E9D5 E9B088
E9D6 E9B092
E9D7 E9B08A
E9D8 E9B084
E9D9 E9B0AE
E9DA E9B09B
E9DB E9B0A5
E9DC E9B0A4
E9DD E9B0A1
E9DE E9B0B0
E9DF E9B187
E9E0 E9B0B2
E9E1 E9B186
E9E2 E9B0BE
E9E3 E9B19A
E9E4 E9B1A0
E9E5 E9B1A7
E9E6 E9B1B6
E9E7 E9B1B8
E9E8 E9B3A7
E9E9 E9B3AC
E9EA E9B3B0
E9EB E9B489
E9EC E9B488
E9ED E9B3AB
E9EE E9B483
E9EF E9B486
E9F0 E9B4AA
E9F1 E9B4A6
E9F2 E9B6AF
E9F3 E9B4A3
E9F4 E9B49F
E9F5 E9B584
E9F6 E9B495
E9F7 E9B492
E9F8 E9B581
E9F9 E9B4BF
E9FA E9B4BE
E9FB E9B586
E9FC E9B588
EA40 E9B59D
EA41 E9B59E
EA42 E9B5A4
EA43 E9B591
EA44 E9B590
EA45 E9B599
EA46 E9B5B2
EA47 E9B689
EA48 E9B687
EA49 E9B6AB
EA4A E9B5AF
EA4B E9B5BA
EA4C E9B69A
EA4D E9B6A4
EA4E E9B6A9
EA4F E9B6B2
EA50 E9B784
EA51 E9B781
EA52 E9B6BB
EA53 E9B6B8
EA54 E9B6BA
EA55 E9B786
EA56 E9B78F
EA57 E9B782
EA58 E9B799
EA59 E9B793
EA5A E9B7B8
EA5B E9B7A6
EA5C E9B7AD
EA5D E9B7AF
EA5E E9B7BD
EA5F E9B89A
EA60 E9B89B
EA61 E9B89E
EA62 E9B9B5
EA63 E9B9B9
EA64 E9B9BD
EA65 E9BA81
EA66 E9BA88
EA67 E9BA8B
EA68 E9BA8C
EA69 E9BA92
EA6A E9BA95
EA6B E9BA91
EA6C E9BA9D
EA6D E9BAA5
EA6E E9BAA9
EA6F E9BAB8
EA70 E9BAAA
EA71 E9BAAD
EA72 E99DA1
EA73 E9BB8C
EA74 E9BB8E
EA75 E9BB8F
EA76 E9BB90
EA77 E9BB94
EA78 E9BB9C
EA79 E9BB9E
EA7A E9BB9D
EA7B E9BBA0
EA7C E9BBA5
EA7D E9BBA8
EA7E E9BBAF
EA80 E9BBB4
EA81 E9BBB6
EA82 E9BBB7
EA83 E9BBB9
EA84 E9BBBB
EA85 E9BBBC
EA86 E9BBBD
EA87 E9BC87
EA88 E9BC88
EA89 E79AB7
EA8A E9BC95
EA8B E9BCA1
EA8C E9BCAC
EA8D E9BCBE
EA8E E9BD8A
EA8F E9BD92
EA90 E9BD94
EA91 E9BDA3
EA92 E9BD9F
EA93 E9BDA0
EA94 E9BDA1
EA95 E9BDA6
EA96 E9BDA7
EA97 E9BDAC
EA98 E9BDAA
EA99 E9BDB7
EA9A E9BDB2
EA9B E9BDB6
EA9C E9BE95
EA9D E9BE9C
EA9E E9BEA0
EA9F E5A0AF
EAA0 E6A787
EAA1 E98199
EAA2 E791A4
EAA3 E5879C
EAA4 E78699
ED40 E7BA8A
ED41 E8A49C
ED42 E98D88
ED43 E98A88
ED44 E8939C
ED45 E4BF89
ED46 E782BB
ED47 E698B1
ED48 E6A388
ED49 E98BB9
ED4A E69BBB
ED4B E5BD85
ED4C E4B8A8
ED4D E4BBA1
ED4E E4BBBC
ED4F E4BC80
ED50 E4BC83
ED51 E4BCB9
ED52 E4BD96
ED53 E4BE92
ED54 E4BE8A
ED55 E4BE9A
ED56 E4BE94
ED57 E4BF8D
ED58 E58180
ED59 E580A2
ED5A E4BFBF
ED5B E5809E
ED5C E58186
ED5D E581B0
ED5E E58182
ED5F E58294
ED60 E583B4
ED61 E58398
ED62 E5858A
ED63 E585A4
ED64 E5869D
ED65 E586BE
ED66 E587AC
ED67 E58895
ED68 E58A9C
ED69 E58AA6
ED6A E58B80
ED6B E58B9B
ED6C E58C80
ED6D E58C87
ED6E E58CA4
ED6F E58DB2
ED70 E58E93
ED71 E58EB2
ED72 E58F9D
ED73 EFA88E
ED74 E5929C
ED75 E5928A
ED76 E592A9
ED77 E593BF
ED78 E59686
ED79 E59D99
ED7A E59DA5
ED7B E59EAC
ED7C E59F88
ED7D E59F87
ED7E EFA88F
ED80 EFA890
ED81 E5A29E
ED82 E5A2B2
ED83 E5A48B
ED84 E5A593
ED85 E5A59B
ED86 E5A59D
ED87 E5A5A3
ED88 E5A6A4
ED89 E5A6BA
ED8A E5AD96
ED8B E5AF80
ED8C E794AF
ED8D E5AF98
ED8E E5AFAC
ED8F E5B09E
ED90 E5B2A6
ED91 E5B2BA
ED92 E5B3B5
ED93 E5B4A7
ED94 E5B593
ED95 EFA891
ED96 E5B582
ED97 E5B5AD
ED98 E5B6B8
ED99 E5B6B9
ED9A E5B790
ED9B E5BCA1
ED9C E5BCB4
ED9D E5BDA7
ED9E E5BEB7
ED9F E5BF9E
EDA0 E6819D
EDA1 E68285
EDA2 E6828A
EDA3 E6839E
EDA4 E68395
EDA5 E684A0
EDA6 E683B2
EDA7 E68491
EDA8 E684B7
EDA9 E684B0
EDAA E68698
EDAB E68893
EDAC E68AA6
EDAD E68FB5
EDAE E691A0
EDAF E6929D
EDB0 E6938E
EDB1 E6958E
EDB2 E69880
EDB3 E69895
EDB4 E698BB
EDB5 E69889
EDB6 E698AE
EDB7 E6989E
EDB8 E698A4
EDB9 E699A5
EDBA E69997
EDBB E69999
EDBC EFA892
EDBD E699B3
EDBE E69A99
EDBF E69AA0
EDC0 E69AB2
EDC1 E69ABF
EDC2 E69BBA
EDC3 E69C8E
EDC4 EFA4A9
EDC5 E69DA6
EDC6 E69EBB
EDC7 E6A192
EDC8 E69F80
EDC9 E6A081
EDCA E6A184
EDCB E6A38F
EDCC EFA893
EDCD E6A5A8
EDCE EFA894
EDCF E6A698
EDD0 E6A7A2
EDD1 E6A8B0
EDD2 E6A9AB
EDD3 E6A986
EDD4 E6A9B3
EDD5 E6A9BE
EDD6 E6ABA2
EDD7 E6ABA4
EDD8 E6AF96
EDD9 E6B0BF
EDDA E6B19C
EDDB E6B286
EDDC E6B1AF
EDDD E6B39A
EDDE E6B484
EDDF E6B687
EDE0 E6B5AF
EDE1 E6B696
EDE2 E6B6AC
EDE3 E6B78F
EDE4 E6B7B8
EDE5 E6B7B2
EDE6 E6B7BC
EDE7 E6B8B9
EDE8 E6B99C
EDE9 E6B8A7
EDEA E6B8BC
EDEB E6BABF
EDEC E6BE88
EDED E6BEB5
EDEE E6BFB5
EDEF E78085
EDF0 E78087
EDF1 E780A8
EDF2 E78285
EDF3 E782AB
EDF4 E7848F
EDF5 E78484
EDF6 E7859C
EDF7 E78586
EDF8 E78587
EDF9 EFA895
EDFA E78781
EDFB E787BE
EDFC E78AB1
EE40 E78ABE
EE41 E78CA4
EE42 EFA896
EE43 E78DB7
EE44 E78EBD
EE45 E78F89
EE46 E78F96
EE47 E78FA3
EE48 E78F92
EE49 E79087
EE4A E78FB5
EE4B E790A6
EE4C E790AA
EE4D E790A9
EE4E E790AE
EE4F E791A2
EE50 E79289
EE51 E7929F
EE52 E79481
EE53 E795AF
EE54 E79A82
EE55 E79A9C
EE56 E79A9E
EE57 E79A9B
EE58 E79AA6
EE59 EFA897
EE5A E79D86
EE5B E58AAF
EE5C E7A0A1
EE5D E7A18E
EE5E E7A1A4
EE5F E7A1BA
EE60 E7A4B0
EE61 EFA898
EE62 EFA899
EE63 EFA89A
EE64 E7A694
EE65 EFA89B
EE66 E7A69B
EE67 E7AB91
EE68 E7ABA7
EE69 EFA89C
EE6A E7ABAB
EE6B E7AE9E
EE6C EFA89D
EE6D E7B588
EE6E E7B59C
EE6F E7B6B7
EE70 E7B6A0
EE71 E7B796
EE72 E7B992
EE73 E7BD87
EE74 E7BEA1
EE75 EFA89E
EE76 E88C81
EE77 E88DA2
EE78 E88DBF
EE79 E88F87
EE7A E88FB6
EE7B E89188
EE7C E892B4
EE7D E89593
EE7E E89599
EE80 E895AB
EE81 EFA89F
EE82 E896B0
EE83 EFA8A0
EE84 EFA8A1
EE85 E8A087
EE86 E8A3B5
EE87 E8A892
EE88 E8A8B7
EE89 E8A9B9
EE8A E8AAA7
EE8B E8AABE
EE8C E8AB9F
EE8D EFA8A2
EE8E E8ABB6
EE8F E8AD93
EE90 E8ADBF
EE91 E8B3B0
EE92 E8B3B4
EE93 E8B492
EE94 E8B5B6
EE95 EFA8A3
EE96 E8BB8F
EE97 EFA8A4
EE98 EFA8A5
EE99 E981A7
EE9A E9839E
EE9B EFA8A6
EE9C E98495
EE9D E984A7
EE9E E9879A
EE9F E98797
EEA0 E9879E
EEA1 E987AD
EEA2 E987AE
EEA3 E987A4
EEA4 E987A5
EEA5 E98886
EEA6 E98890
EEA7 E9888A
EEA8 E988BA
EEA9 E98980
EEAA E988BC
EEAB E9898E
EEAC E98999
EEAD E98991
EEAE E988B9
EEAF E989A7
EEB0 E98AA7
EEB1 E989B7
EEB2 E989B8
EEB3 E98BA7
EEB4 E98B97
EEB5 E98B99
EEB6 E98B90
EEB7 EFA8A7
EEB8 E98B95
EEB9 E98BA0
EEBA E98B93
EEBB E98CA5
EEBC E98CA1
EEBD E98BBB
EEBE EFA8A8
EEBF E98C9E
EEC0 E98BBF
EEC1 E98C9D
EEC2 E98C82
EEC3 E98DB0
EEC4 E98D97
EEC5 E98EA4
EEC6 E98F86
EEC7 E98F9E
EEC8 E98FB8
EEC9 E990B1
EECA E99185
EECB E99188
EECC E99692
EECD EFA79C
EECE EFA8A9
EECF E99A9D
EED0 E99AAF
EED1 E99CB3
EED2 E99CBB
EED3 E99D83
EED4 E99D8D
EED5 E99D8F
EED6 E99D91
EED7 E99D95
EED8 E9A197
EED9 E9A1A5
EEDA EFA8AA
EEDB EFA8AB
EEDC E9A4A7
EEDD EFA8AC
EEDE E9A69E
EEDF E9A98E
EEE0 E9AB99
EEE1 E9AB9C
EEE2 E9ADB5
EEE3 E9ADB2
EEE4 E9AE8F
EEE5 E9AEB1
EEE6 E9AEBB
EEE7 E9B080
EEE8 E9B5B0
EEE9 E9B5AB
EEEA EFA8AD
EEEB E9B899
EEEC E9BB91
EEEF E285B0
EEF0 E285B1
EEF1 E285B2
EEF2 E285B3
EEF3 E285B4
EEF4 E285B5
EEF5 E285B6
EEF6 E285B7
EEF7 E285B8
EEF8 E285B9
EEF9 EFBFA2
EEFA EFBFA4
EEFB EFBC87
EEFC EFBC82
FA40 E285B0
FA41 E285B1
FA42 E285B2
FA43 E285B3
FA44 E285B4
FA45 E285B5
FA46 E285B6
FA47 E285B7
FA48 E285B8
FA49 E285B9
FA4A E285A0
FA4B E285A1
FA4C E285A2
FA4D E285A3
FA4E E285A4
FA4F E285A5
FA50 E285A6
FA51 E285A7
FA52 E285A8
FA53 E285A9
FA54 EFBFA2
FA55 EFBFA4
FA56 EFBC87
FA57 EFBC82
FA58 E388B1
FA59 E28496
FA5A E284A1
FA5B E288B5
FA5C E7BA8A
FA5D E8A49C
FA5E E98D88
FA5F E98A88
FA60 E8939C
FA61 E4BF89
FA62 E782BB
FA63 E698B1
FA64 E6A388
FA65 E98BB9
FA66 E69BBB
FA67 E5BD85
FA68 E4B8A8
FA69 E4BBA1
FA6A E4BBBC
FA6B E4BC80
FA6C E4BC83
FA6D E4BCB9
FA6E E4BD96
FA6F E4BE92
FA70 E4BE8A
FA71 E4BE9A
FA72 E4BE94
FA73 E4BF8D
FA74 E58180
FA75 E580A2
FA76 E4BFBF
FA77 E5809E
FA78 E58186
FA79 E581B0
FA7A E58182
FA7B E58294
FA7C E583B4
FA7D E58398
FA7E E5858A
FA80 E585A4
FA81 E5869D
FA82 E586BE
FA83 E587AC
FA84 E58895
FA85 E58A9C
FA86 E58AA6
FA87 E58B80
FA88 E58B9B
FA89 E58C80
FA8A E58C87
FA8B E58CA4
FA8C E58DB2
FA8D E58E93
FA8E E58EB2
FA8F E58F9D
FA90 EFA88E
FA91 E5929C
FA92 E5928A
FA93 E592A9
FA94 E593BF
FA95 E59686
FA96 E59D99
FA97 E59DA5
FA98 E59EAC
FA99 E59F88
FA9A E59F87
FA9B EFA88F
FA9C EFA890
FA9D E5A29E
FA9E E5A2B2
FA9F E5A48B
FAA0 E5A593
FAA1 E5A59B
FAA2 E5A59D
FAA3 E5A5A3
FAA4 E5A6A4
FAA5 E5A6BA
FAA6 E5AD96
FAA7 E5AF80
FAA8 E794AF
FAA9 E5AF98
FAAA E5AFAC
FAAB E5B09E
FAAC E5B2A6
FAAD E5B2BA
FAAE E5B3B5
FAAF E5B4A7
FAB0 E5B593
FAB1 EFA891
FAB2 E5B582
FAB3 E5B5AD
FAB4 E5B6B8
FAB5 E5B6B9
FAB6 E5B790
FAB7 E5BCA1
FAB8 E5BCB4
FAB9 E5BDA7
FABA E5BEB7
FABB E5BF9E
FABC E6819D
FABD E68285
FABE E6828A
FABF E6839E
FAC0 E68395
FAC1 E684A0
FAC2 E683B2
FAC3 E68491
FAC4 E684B7
FAC5 E684B0
FAC6 E68698
FAC7 E68893
FAC8 E68AA6
FAC9 E68FB5
FACA E691A0
FACB E6929D
FACC E6938E
FACD E6958E
FACE E69880
FACF E69895
FAD0 E698BB
FAD1 E69889
FAD2 E698AE
FAD3 E6989E
FAD4 E698A4
FAD5 E699A5
FAD6 E69997
FAD7 E69999
FAD8 EFA892
FAD9 E699B3
FADA E69A99
FADB E69AA0
FADC E69AB2
FADD E69ABF
FADE E69BBA
FADF E69C8E
FAE0 EFA4A9
FAE1 E69DA6
FAE2 E69EBB
FAE3 E6A192
FAE4 E69F80
FAE5 E6A081
FAE6 E6A184
FAE7 E6A38F
FAE8 EFA893
FAE9 E6A5A8
FAEA EFA894
FAEB E6A698
FAEC E6A7A2
FAED E6A8B0
FAEE E6A9AB
FAEF E6A986
FAF0 E6A9B3
FAF1 E6A9BE
FAF2 E6ABA2
FAF3 E6ABA4
FAF4 E6AF96
FAF5 E6B0BF
FAF6 E6B19C
FAF7 E6B286
FAF8 E6B1AF
FAF9 E6B39A
FAFA E6B484
FAFB E6B687
FAFC E6B5AF
FB40 E6B696
FB41 E6B6AC
FB42 E6B78F
FB43 E6B7B8
FB44 E6B7B2
FB45 E6B7BC
FB46 E6B8B9
FB47 E6B99C
FB48 E6B8A7
FB49 E6B8BC
FB4A E6BABF
FB4B E6BE88
FB4C E6BEB5
FB4D E6BFB5
FB4E E78085
FB4F E78087
FB50 E780A8
FB51 E78285
FB52 E782AB
FB53 E7848F
FB54 E78484
FB55 E7859C
FB56 E78586
FB57 E78587
FB58 EFA895
FB59 E78781
FB5A E787BE
FB5B E78AB1
FB5C E78ABE
FB5D E78CA4
FB5E EFA896
FB5F E78DB7
FB60 E78EBD
FB61 E78F89
FB62 E78F96
FB63 E78FA3
FB64 E78F92
FB65 E79087
FB66 E78FB5
FB67 E790A6
FB68 E790AA
FB69 E790A9
FB6A E790AE
FB6B E791A2
FB6C E79289
FB6D E7929F
FB6E E79481
FB6F E795AF
FB70 E79A82
FB71 E79A9C
FB72 E79A9E
FB73 E79A9B
FB74 E79AA6
FB75 EFA897
FB76 E79D86
FB77 E58AAF
FB78 E7A0A1
FB79 E7A18E
FB7A E7A1A4
FB7B E7A1BA
FB7C E7A4B0
FB7D EFA898
FB7E EFA899
FB80 EFA89A
FB81 E7A694
FB82 EFA89B
FB83 E7A69B
FB84 E7AB91
FB85 E7ABA7
FB86 EFA89C
FB87 E7ABAB
FB88 E7AE9E
FB89 EFA89D
FB8A E7B588
FB8B E7B59C
FB8C E7B6B7
FB8D E7B6A0
FB8E E7B796
FB8F E7B992
FB90 E7BD87
FB91 E7BEA1
FB92 EFA89E
FB93 E88C81
FB94 E88DA2
FB95 E88DBF
FB96 E88F87
FB97 E88FB6
FB98 E89188
FB99 E892B4
FB9A E89593
FB9B E89599
FB9C E895AB
FB9D EFA89F
FB9E E896B0
FB9F EFA8A0
FBA0 EFA8A1
FBA1 E8A087
FBA2 E8A3B5
FBA3 E8A892
FBA4 E8A8B7
FBA5 E8A9B9
FBA6 E8AAA7
FBA7 E8AABE
FBA8 E8AB9F
FBA9 EFA8A2
FBAA E8ABB6
FBAB E8AD93
FBAC E8ADBF
FBAD E8B3B0
FBAE E8B3B4
FBAF E8B492
FBB0 E8B5B6
FBB1 EFA8A3
FBB2 E8BB8F
FBB3 EFA8A4
FBB4 EFA8A5
FBB5 E981A7
FBB6 E9839E
FBB7 EFA8A6
FBB8 E98495
FBB9 E984A7
FBBA E9879A
FBBB E98797
FBBC E9879E
FBBD E987AD
FBBE E987AE
FBBF E987A4
FBC0 E987A5
FBC1 E98886
FBC2 E98890
FBC3 E9888A
FBC4 E988BA
FBC5 E98980
FBC6 E988BC
FBC7 E9898E
FBC8 E98999
FBC9 E98991
FBCA E988B9
FBCB E989A7
FBCC E98AA7
FBCD E989B7
FBCE E989B8
FBCF E98BA7
FBD0 E98B97
FBD1 E98B99
FBD2 E98B90
FBD3 EFA8A7
FBD4 E98B95
FBD5 E98BA0
FBD6 E98B93
FBD7 E98CA5
FBD8 E98CA1
FBD9 E98BBB
FBDA EFA8A8
FBDB E98C9E
FBDC E98BBF
FBDD E98C9D
FBDE E98C82
FBDF E98DB0
FBE0 E98D97
FBE1 E98EA4
FBE2 E98F86
FBE3 E98F9E
FBE4 E98FB8
FBE5 E990B1
FBE6 E99185
FBE7 E99188
FBE8 E99692
FBE9 EFA79C
FBEA EFA8A9
FBEB E99A9D
FBEC E99AAF
FBED E99CB3
FBEE E99CBB
FBEF E99D83
FBF0 E99D8D
FBF1 E99D8F
FBF2 E99D91
FBF3 E99D95
FBF4 E9A197
FBF5 E9A1A5
FBF6 EFA8AA
FBF7 EFA8AB
FBF8 E9A4A7
FBF9 EFA8AC
FBFA E9A69E
FBFB E9A98E
FBFC E9AB99
FC40 E9AB9C
FC41 E9ADB5
FC42 E9ADB2
FC43 E9AE8F
FC44 E9AEB1
FC45 E9AEBB
FC46 E9B080
FC47 E9B5B0
FC48 E9B5AB
FC49 EFA8AD
FC4A E9B899
FC4B E9BB91
