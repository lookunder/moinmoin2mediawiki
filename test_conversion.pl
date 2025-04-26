use strict;
use warnings;

use Test::More tests => 27;

use lib 'lib';
require Convert;

ok( Convert::markup('[[BR]]') eq "<br>", 'Convert line breaks.' );

# Testing smiley conversions
is( Convert::smileys("{OK}"), "<span style=\"font-size: large\">&#x1f44d;<\/span>", 'Convert OK to thumbs-up smiley.' );

is( Convert::smileys("|-)")
  , "<span style=\"font-size: large\">&#x1f611;<\/span>"
  , 'Convert |-) to expressionless face smiley.' );

is( Convert::smileys("{X}")
  , "<span style=\"font-size: large; color: red; font-weight: bold;\">&#x2BBE;<\/span>"
  , 'Convert {X} to a Circled X utf-8 character.' );

is( Convert::smileys("/!\\")
  , "<span style=\"font-size: large; font-weight:bold; background:yellow;\">&#9888;<\/span>"
  , 'Convert /!\\ to a utf-8 character.' );

is( Convert::smileys("{NOTREADY}")
  , "<span style=\"font-size: 5vw;\">&#128679;<\/span>"
  , 'Convert {NOTREADY} to a utf-8 character.' );


# Testing interwiki conversions
my %interwikilinks;
is( Convert::links("[wiki:sItE:UrL TeXt]", "", \%interwikilinks), "[[wikisite:UrL|TeXt]]", 'Convert interwiki links with nice text.' );
ok( exists $interwikilinks{"wiki:sItE"}, "Wikilink added.");
is( Convert::links("[wiki:sItE:UrL]", "", \%interwikilinks), "[[wikisite:UrL]]", 'Convert interwiki links.' );
is( Convert::links("wiki:sItE:UrL<br>", "", \%interwikilinks), "[[wikisite:UrL]]<br>", 'Convert interwiki links without square brackets.' );
is( Convert::links("/SubPage","ParentUrl", \%interwikilinks), "/SubPage", 'Convert subpages starting with /.' );
is( Convert::links(" /SubPage ","ParentUrl", \%interwikilinks), "[[ParentUrl/SubPage|SubPage]]", 'Convert subpages starting with /.');
is( Convert::links(" text / text ","ParentUrl", \%interwikilinks), " text / text ", 'A / followed by a space is not a subpage.');
is( Convert::links(" /!\\ ","ParentUrl", \%interwikilinks), " /!\\ ", 'A / should only be followed by word characters.');

# Testing link conversions
is( Convert::links("|| a || [http://test.com/cgi-bin/rev.cgi?item_no=1234567	1234567] || c ||")
  , "|| a || [http://test.com/cgi-bin/rev.cgi?item_no=1234567	1234567] || c ||"
  , "Testing links within tables.");

# Testing table conversions
is( Convert::table_row("|| a || [http://test.com/cgi-bin/rev.cgi?item_no=1234567	1234567] || c ||")
  , "|  a \n|  [http://test.com/cgi-bin/rev.cgi?item_no=1234567	1234567] \n|  c \n"
  , "Converting a table row.");

my $tabledepth = 1;
is( Convert::table_row_in_context("|| a || [http://test.com/cgi-bin/rev.cgi?item_no=1234567	1234567] || c ||",\$tabledepth)
  , "|-\n|  a \n|  [http://test.com/cgi-bin/rev.cgi?item_no=1234567	1234567] \n|  c \n"
  , "Converting a table row in context.");


is( Convert::links("|| a || [http://test.com/cgi-bin/rev.cgi?item_no=1234567	1234567] || c ||")
  , "|| a || [http://test.com/cgi-bin/rev.cgi?item_no=1234567	1234567] || c ||"
  , "Testing links within tables.");


# Testing attachement conversions
is( Convert::embeddings("See attachment:sample.csv for details.", "ParentUrl")
  , "See [[:File:ParentUrl\$sample.csv|sample.csv]] for details."
  , "Conversion of attachment embedded in a string.");

is( Convert::embeddings("See attachment:sample.csv for details.", "Parent/Url")
  , "See [[:File:Parent\$\$Url\$sample.csv|sample.csv]] for details."
  , "Conversion of attachment with a parent url containing a '/'.");

# Testing footnotes
my $footnote = 0;
my $toc = 0;
is( Convert::embeddings(Convert::macros( "* Text before[[FootNote(attachment:test.jpg  [[BR]][[BR]](text within).)]]. Text after", \$toc, \$footnote), "ParentUrl")
  , "* Text before<ref>[[Image:ParentUrl\$test.jpg|test.jpg]]  [[BR]][[BR]](text within).</ref>. Text after"
  , "Testing footnote conversions.");

# Testing Code Blocks
is( Convert::codeblocks( "{{{", 0, 0), "\n<pre><nowiki>",   "Testing multiline opening codeblock with no indent.");
is( Convert::codeblocks( "}}}", 0, 0), "</nowiki></pre>",   "Testing multiline closing codeblock with no indent.");
is( Convert::codeblocks( "}}}", 2, 1), "#:</nowiki></pre>", "Testing multiline codeblock with list.");
is( Convert::codeblocks( "{{{", 2, 1), "\n#:<pre><nowiki>", "Testing multiline codeblock with list.");

# Testing Replicate
is( Convert::replicate( ":", 4), "::::", "Testing character replication.");
