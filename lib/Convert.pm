#!/usr/bin/perl

use strict;
use warnings;

package Convert;


sub markup {
 my ($line) = @_;

   # Markup conversion (when on a single line)
 $line =~ s/\^(.*?)\^/\<sup\>$1\<\/sup\>/g;        # ^ * ^     ->  <sup> * </sup>
 $line =~ s/\,\,(.*?)\,\,/\<sub\>$1\<\/sub\>/g;    # ,, * ,,   ->  <sub> * </sub>
 $line =~ s/__(.*?)__/\<u\>$1\<\/u\>/g;            # __ * __   ->  <u> * </u>
 $line =~ s/--\((.*?)\)--/\<s\>$1\<\/s\>/g;        # --( * )-- ->  <s> * </s>
 # Mediawiki seems to understand ''', '' and '''''
 #$line =~ s/'''(.*?)'''/\<b\>$1\<\/b\>/g;                        # ''' * ''' ->  <b> * </b>
 #$line =~ s/''(.*?)''/\<i\>$1\<\/i\>/g;                          # '' * ''   ->  <i> * </i>
 $line =~ s/~\+(.*?)\+~/\<span style="font-size: larger"\>$1\<\/span\>/g;     # ~+xxx+~  ->  <span style="font-size: larger">xxx</span>
 $line =~ s/~-(.*?)-~/\<span style="font-size: smaller"\>$1\<\/span\>/g;      # ~-xxx-~  ->  <span style="font-size: smaller">xxx</span>
 $line =~ s/^ (.*?):: (.*)$/; $1 : $2/;                          # x:: y     ->  ; x : y
 $line =~ s/\[\[BR\]\]/\<br\>/g;                                 # [[BR]]    ->  <br>
 $line =~ s/\[\[BR\]/\<br\>/g;

 return $line;  
}


sub smileys {
 my ($line) = @_;
 $line =~ s/<!>/<span style="font-size: x-large; color: red">!<\/span>/g;             # <!>  ->  <span style="font-size: x-large; color: red">!</span>
 $line =~ s/\{\*\}/<span style="font-size: large;">&#x2B50;<\/span>/g;       # {*}  ->  <span style="font-size: x-large; color: orange">*</span>
 $line =~ s/\{o\}/<span style="font-size: x-large; color: grey">&starf;<\/span>/g;   # {o}  ->  <span style="font-size: x-large; color: cyan">&curren;</span>
 $line =~ s/\{X\}/<span>&#x274C;<\/span>/g;  # {OK} -> red triangle with a exclamation mark in it. 
 # To Do : the rest of the smileys

 # Using UTF-8 for smileys conversion
 $line =~ s/\/!\\/<span style="font-size: large; font-weight:bold; background:yellow;">&#9888;<\/span>/g;
 $line =~ s/\(.\/\)/<span style="font-size: large; color: green">&#10004;<\/span>/g;
 $line =~ s/\{i\}/<span style="font-size: large; color: blue">&#128712;<\/span>/g;
 $line =~ s/\{1\}/<span style="font-size: large; color: orange">&#9312;<\/span>/g;
 $line =~ s/\{2\}/<span style="font-size: large; color: blue">&#9313;<\/span>/g;
 $line =~ s/\{3\}/<span style="font-size: large; color: green">&#9314;<\/span>/g;
 $line =~ s/\{\|1\|\}/<span style="font-size: large; color: orange">&#9312;<\/span>/g;
 $line =~ s/\{\|2\|\}/<span style="font-size: large; color: blue">&#9313;<\/span>/g;
 $line =~ s/\{\|3\|\}/<span style="font-size: large; color: green">&#9314;<\/span>/g;
 $line =~ s/\{\|\>\}/<span style="font-size: large;">&#128681;<\/span>/g;
 $line =~ s/\(\!\)/<span style="font-size: large">&#128161;<\/span>/g;  #Lightbulb
 $line =~ s/\{\?\}/<span style="font-size: large;">&#10067;<\/span>/g;
 $line =~ s/:-\(/<span style="font-size: large">&#128530;<\/span>/g;
 $line =~ s/:\(/<span style="font-size: large">&#128530;<\/span>/g;
 $line =~ s/\|-\)/<span style="font-size: large">&#x1f611;<\/span>/g;
 $line =~ s/\{OK\}/<span style="font-size: large">&#x1f44d;<\/span>/g;
 $line =~ s/\{NOTOK\}/<span style="font-size: large">&#x1f44e;<\/span>/g;
 $line =~ s/\{NOTREADY\}/<span style="font-size: 5vw;">&#128679;<\/span>/g;

 return $line;
}


sub links {
  my ($line, $mwname_, $interwikilinks) = @_;

  if( $line =~ m/^\s*=+[^=]+=+$/) { return $line; } # No links in Moin Moin headings

  # Link conversion
  ## comment these out as MoinMoin link syntax has changed since 1.5
  ## see http://moinmo.in/HelpOnLinking
  $line =~ s/\[\#([^\s|]+)[\s|]+([^\]]+)\]/\[\[\#$1|$2\]\]/g;     # [#Foo bar]   ->  [[#Foo|bar]]
  $line =~ s/(?<!\[)\[\#([^\s:]+)\]/\[\[\#$1\]\]/g;               # [# * ]   ->  [[ * ]]
  $line =~ s/\[\"\/(\w+?)\"\]/[[$mwname_\/$1|$1]]/g;              # ["/subpage"]   ->  [[parent/subpage|subpage]]

  my $fixCamelCase = 1;
  if($line =~ m/ \/(\w+?) /)
  {
    $fixCamelCase = 0;
  }

  $line =~ s/ \/(\w+?) /[[$mwname_\/$1|$1]]/g;                    # /subpage    ->  [[parent/subpage|subpage]]

  $line =~ s/\[\"(.*?)\"\]/\[\[$1\]\]/g;                          # [" * "]  ->  [[ * ]]    (This may be covered by Free Link below)
  $line =~ s/\[:([^:\]]+):([^\]]+)\]/[[$1|$2]]/g;                 # [:HTML/AddedElementEmbed:embed] -> [[HTML/AddedElementEmbed|embed]]
  $line =~ s/\[\:(.*?)\:\]/[[$1]]/g;                              # [: * :]  ->  [[ * ]]
  $line =~ s/\[\:(.*?)\]/\[\[$1\]\]/g;                            # [: * ]   ->  [[ * ]]
  
  if ($line =~ m/\[[a-zA-Z]+:[a-zA-Z]+:.*\]/) {
    my $tmp = $line;
    $tmp =~ s/.*\[([a-zA-Z]+:[a-zA-Z]+):.*\].*/$1/g;
    if($tmp !~ m/wiki:Self\n/){ $interwikilinks->{$tmp} = ();}
  }
  
  $line =~ s/\[wiki:Self:(.*?) (.*?)\]/[[$1|$2]]/g;             # [wiki:Self:URL text] ->  [[URL|text]]
  $line =~ s/\[wiki:(.*?):(.*?) (.*?)\]/[[wiki\L$1\E:$2|$3]]/g; # [wiki:site:URL text] ->  [[wikisite:URL|test]]
  $line =~ s/\[wiki:(.*?):(.*?)\]/[[wiki\L$1\E:$2]]/g;          # [wiki:site:URL]      ->  [[wikisite:URL]]
  $line =~ s/wiki:(\w+):(\w+)/[[wiki\L$1:\E$2]]/g;              #  wiki:site:URL       ->  [[wikisite:URL]]
   
  # Images
  $line =~ s/\binline:(\S+\.(png|jpg|gif))/[[Image:$1]]/g;      # inline:mypic.png  ->  [[Image:mypic.png]]

  # Wiki links
  ## comment these out as MoinMoin link syntax has changed since 1.5
  ## see http://moinmo.in/HelpOnLinking
  # s/\/CommentPage/???/g;                               # To Do
  #$line =~ s/((?<!)[A-Z][a-z]+[A-Z][a-z]+[A-Za-z]*)([^`])/[[$1]]$2/g;  #`# CamelCaseWord -> [[CamelCaseWord]]
  #$line =~ s/((?<!\w)[A-Z]\w*[a-z]\w*[A-Z]\w+)/[[$&]]/g;
  #$line =~ s/\[(http:[^\|]+)\|([^\]]+)\]\]/[$1 $2]/g;
  #$line =~ s/\[(https:[^\|]+)\|([^\]]+)\]\]/[$1 $2]/g;
  $line =~ s/\[(http:[^\s]+)\]/[$1 $1]/g;                          # [url] -> [url url]
  $line =~ s/\[(https:[^\s]+)\]/[$1 $1]/g;                         # [url] -> [url url]
  
  $line =~ s/\[\[(http:[^\|]+)\|([^\]]+)\]\]/[$1 $2]/g;
  $line =~ s/\[\[(https:[^\|]+)\|([^\]]+)\]\]/[$1 $2]/g;
  $line =~ s/\[\[(http:[^\|]+)\]\]/$1/g;
  $line =~ s/\[\[(https:[^\|]+)\]\]/$1/g;

  if( $fixCamelCase )
  {
      $line =~ s/(?<![\&!\/#])\b([A-Z][a-z0-9]+){2,}(\/([A-Z][a-z0-9]+){2,})*\b/[[$&]]/g;                   #`# CamelCaseWord -> [[CamelCaseWord]]
  }

  $line =~ s/!([A-Z][a-z]+[A-Z][a-z]+[A-Za-z]*)([^`])/$1$2/g;     #`# !CamelCaseWord -> CamelCaseWord
  $line =~ s/\[\[\[(\w+)\]\]\s+(.+?)\]/[[$1|$2]]/g;               # [[[WikiPageName]] words] -> [[WikiPageName|words]]
  $line =~ s/\[([^\]]+)\[\[(.*?)\]\](.*?)\]/[$1$2$3]/g;           # [...[[...]]...]   ->  [.........]  repair accidental [[CamelCasing]]

  return $line;
}


sub boilerplate_phrases {
  my ($line) = @_;

  # Boilerplate Phrases
  $line =~ s/This wiki is powered by \[\[MoinMoin\]\]//g;
  $line =~ s/<<FindPage>>/[[Special:Search|FindPage]]/g;
  $line =~ s/(<<SyntaxReference>>)/(\[http:\/\/meta.wikimedia.org\/wiki\/Help:Editing SyntaxReference\])/g;
  $line =~ s/<<SiteNavigation>>/\[\[Special:Specialpages|SiteNavigation\]\]/g;
  $line =~ s/<<RecentChanges>>/\[\[Special:Recentchanges|RecentChanges\]\]/g;

  # Final tidy
  $line =~ s/``//g;   # NonLinkCamel``CaseWord  ->  NonLinkCamelCaseWord

  return $line;
}


sub table_row_in_context { # Params: line, tabledepth
 my ($line, $tabledepth) = @_;

 if ($$tabledepth == 0) { # are we outside a table?
   if ($line =~ m/^\s*\|\|/) { # and are we starting a new table?
     $$tabledepth++; # yes, we are now in a new table

     my $tablewidth = "";
     #Check if we have a tablewith in the first cell
     if($line =~ m/tablewidth="(\d+%)"/)
   {
       $tablewidth = "width=\"$1\"";
     $line =~ s/tablewidth="(\d+%)"//g; #Remove it 
   }
   
     $line = "{| border=\"1\" cellpadding=\"2\" cellspacing=\"0\" $tablewidth \n" . table_row($line);
   }
 }
 else { # we are possibly in the middle of a table
   if ($line !~ m/^\s*\|\|/) { # no more table markup, so we are exiting the table
     $line = "|}\n" . $line;
     $$tabledepth--;
   }
   else { # we are continuing to another row of the table
     $line = "|-\n" . table_row($line);
   }
 }

 return $line;
}


# This converts a MoinMoin table row into a MediaWiki table row
# See: http://www.w3.org/2005/MWI/DDWG/wiki/SyntaxReference
# See: http://www.mediawiki.org/wiki/Help:Tables
sub table_row {
 chomp(my $mmtr = shift);
 #my $x;
 my $style;
 my $celltext;
 my $startspanpos;
 # Convert long colspans into ||<-N> format
 #while (($startspanpos = index($mmtr,'||||')) >= 0) {
 #  my $spans = substr($mmtr,$startspanpos); $spans =~ m/^(\|*)/; $spans = $1;
 #  my $endspanpos = rindex($mmtr,'|',$startspanpos);
 #  substr($mmtr,$startspanpos,length($spans)) = '||<-' . (length($spans) / 2) . '>';
 #}
 my @cells = split(/\|\|/,$mmtr);
 @cells = @cells[1..@cells-1];
 my $mwcells = '';
 foreach my $cell (@cells) {
   if ( $cell =~ m/^\s*((<.[^>]+>|<\(>|<:>|<\)>)+)(.+)/ ) {

     $style = $1;
     $celltext = $3;

     # combinations
     $style =~ s/<(\(|:|\)|\^|v)([^>]+)>/<$1><$2>/g;   # e.g.  <:90%>  -->  <:><90%>
     # background colour
     $style =~ s/<(#[^:]*?):>/bgcolor="$1" /g;
     $style =~ s/<bgcolor=([^>]+)>/bgcolor=$1 /g;
     # alignment
     $style =~ s/<\(>/align="left" /g;
     $style =~ s/<style="align\s*:\s*(left|right|center);">/align="$1" /g;
#      $style =~ s/<style="align\s*:\s*left;">/align="left" /g;
     $style =~ s/<\:>/align="center" /g;
   #$style =~ s/\s+:\s+/text-align: center; /g;
     $style =~ s/\s+:\s+/align="center" /g;
#      $style =~ s/<style="align\s*:\s*center;">/align="center" /g;
     $style =~ s/<\)>/align="right" /g;
#      $style =~ s/<style="align\s*:\s*right;">/align="right" /g;
     $style =~ s/<\^>/valign="top" /g;
#      $style =~ s/<style="vertical-align\s*:\s*top;">/valign="top" /g;
     $style =~ s/<v>/valign="bottom" /g;
     $style =~ s/<style="vertical-align\s*:\s*(top|bottom);">/valign="$1" /g;
     # rowspan
     $style =~ s/\|(\d+)/rowspan="$1" /g;
     #$style =~ s/<(rowspan=[^>]+)>/$1 /g;
     # colspan
     $style =~ s/-(\d+)/colspan="$1" /g;
     #$style =~ s/<(colspan=[^>]+)>/$1 /g;
     # width
     $style =~ s/<(\d+)\%>/width="$1%" /g;
	 # row style
	 # In mediawiki, the row styling is defined on the row divider line
	 if($style =~ m/rowstyle="([^"]+)"/)
	 {
	   my $rowstyle = $style;
	   $rowstyle =~ s/rowstyle="([^"]+)"/style="$1"/g;
	   $rowstyle =~ s/<([^>]+)>/$1 /g;
	   $mwcells .= "|- $rowstyle\n";
	   $style =~ s/rowstyle="([^"]+)"/ /g;
	 }

     # everything else
     #$style =~ s/rowbgcolor="([^"]+)"/background-color: $1; /g;
     if($style =~ m/rowbgcolor="([^"]+)"/)
     {
       my $rowstyle = $style;
       $rowstyle =~ s/rowbgcolor="([^"]+)"/style="background-color: $1;"/g;
       $rowstyle =~ s/<([^>]+)>/$1 /g;
       $mwcells .= "|- $rowstyle\n";
       $style =~ s/rowbgcolor="([^"]+)"/ /g;
     }

     #Move everything left in a style property
     $style =~ s/<([^>]+)>/$1/g;
     
     $style =~ s/<(\w+=[^>])>/$1 /g;
     if ($style =~ /^\s*$/) {
       $mwcells .= "|$celltext\n";
     }
     else {
       $mwcells .= "|$style |$celltext\n";
     }
   }
   else {
     $mwcells .= "| $cell\n";
   }
 }
 #$mwcells = substr $mwcells, 0, -1;
 #$mwcells .= "\n";
 return $mwcells;
}


sub embeddings {
  my ($line, $mwname_) = @_;

  my $escapedPagePath = $mwname_;
  $escapedPagePath =~ s/\//\$\$/g;

  $line =~ s/\{\{attachment:([^\s\/]+\.(png|jpg|gif)) ([^\]]+)\}\}/[[Image:$escapedPagePath\/attachments\/$1|$2]]/g;  # {{attachment:file.png/jpg/gif}}  ->  [[Image:MoinMoinPageName/attachments/file.ext]]
  $line =~ s/\{\{attachment:(\S+\.(png|jpg|gif)) ([^\]]+)\}\}/[[Image:$1|$2]]/g;                              # {{attachment:file.png/jpg/gif}}  ->  [[Image:MoinMoinPageName/attachments/file.ext]]
  $line =~ s/\{\{attachment:([^\s\/]+\.(png|jpg|gif))\}\}/[[Image:$escapedPagePath\/attachments\/$1]]/g;      # {{attachment:file.png/jpg/gif}}  ->  [[Image:MoinMoinPageName/attachments/file.ext]]
  $line =~ s/\{\{attachment:(\S+\.(png|jpg|gif))\}\}/[[Image:$1]]/g;                                          # {{attachment:file.png/jpg/gif}}  ->  [[Image:MoinMoinPageName/attachments/file.ext]]
      
  # Dealing with the older syntax
  $line =~ s/\s*attachment:([^\s\/]+\.(png|jpg|gif))/[[Image:$escapedPagePath\$$1|$1]]/g;                     # attachment:file.png/jpg/gif  ->  [[Image:MoinMoinPageName$file.ext]]
  $line =~ s/\s*attachment:(\S+\.(png|jpg|gif))/[[Image:$1|$1]]/g;                                            # attachment:file.png/jpg/gif  ->  [[Image:MoinMoinPageName/attachments/file.ext]]
  $line =~ s/\s*attachment:([^\s\/]+\.(png|jpg|gif))/[[Image:$escapedPagePath\$$1]]/g;                        # attachment:file.png/jpg/gif  ->  [[Image:MoinMoinPageName/attachments/file.ext]]
  $line =~ s/\s*attachment:(\S+\.(png|jpg|gif))/[[Image:$1]]/g;                                               # attachment:file.png/jpg/gif  ->  [[Image:MoinMoinPageName/attachments/file.ext]]
        
  $line =~ s/attachment:(\S+\.\S+)/[[:File:$escapedPagePath\$$1|$1]]/g;                                       # attachment:file.csv  ->  [[:File:MoinMoinPageName$file.csv]]

  $line =~ s/\{\{attachment:([^\s\/]+) ([^\]]+)\}\}/[[Media:$escapedPagePath\/attachments\/$1|$2]]/g;         # [attachment:file.ext]  ->  [[Media:MoinMoinPageName/attachments/file.ext]]
  $line =~ s/\{\{attachment:(\S+) ([^\]]+)\]/[[Media:$1|$2]]/g;                                               # [attachment:file.ext]  ->  [[Media:MoinMoinPageName/attachments/file.ext]]
  $line =~ s/\{\{attachment:([^\s\/]+)\}\}/[[Media:$escapedPagePath\/attachments\/$1]]/g;                     # [attachment:file.ext]  ->  [[Media:MoinMoinPageName/attachments/file.ext]]
  $line =~ s/\{\{attachment:(\S+)\}\}/[[Media:$1]]/g;                                                         # [attachment:file.ext]  ->  [[Media:MoinMoinPageName/attachments/file.ext]]

  return $line;
}


sub macros {
  my ($line, $toc, $footnote) = @_;

  $line =~ s/\[\[GetText\((\w+)\)\]\]/$1/g;                       # [[GetText(xx)]] -> xx

  if($line =~ s/<<TableOfContents>>//g) {     # Cannot support TOC mid-text, but can put comment in.
    $$toc = 1;
  }
      
  if($line =~ s/\[\[TableOfContents\(.*\)\]\]//g) {     # Cannot support TOC mid-text, but can put comment in.
    $$toc = 1;
  }
      
  if($line =~ s/\[\[TableOfContents\]\]//g) {     # Cannot support TOC mid-text, but can put comment in.
    $$toc = 1;
  }
      
  $line =~ s/= Table of Contents =//g;
  $line =~ s/== Table of Contents ==//g;
  $line =~ s/=== Table of Contents ===//g;

  $line =~ s/<<FullSearch(\([^)]*\))?>>//g;
  $line =~ s/\s*<<Anchor\((\w+)\)>>/<span id="$1"><\/span>/g;        # <<Anchor(name)>> -> <span id="name"></span>
  $line =~ s/\s*\[\[Anchor\((\w+)(.*)\)\]\]/<span id="$1"><\/span>/g;# [[Anchor(name)]] -> <span id="name"></span>
  $line =~ s/<<Include\((.*?)\)>>/{{:$1}}/g;                         # [[Include(OtherPage)]]  ->  {{:OtherPage}}
  $line =~ s/<<DateTime\((.*?)\)>>/$1/g;                             # <<DateTime(timestamp)>>  ->  timestamp
  $line =~ s/\[\[DateTime\((.*?)\)\]\]/$1/g;                         # [[DateTime(timestamp)]]  ->  timestamp
  $line =~ s/\[\[Date\((.*?)\)\]\]/$1/g;                             # [[Date(timestamp)]]  ->  timestamp
  $line =~ s/\[\[ImageLink\((.*?),(.*?)\)\]\]/[[$2]]/g;              # [[ImageLink(target)]]  ->  [[target|{{image|alt|width=123,height=456}}]]
  $line =~ s/\[\[MailTo\((.*?)\)\]\]/[mailto:$1]/g;
  $line =~ s/\[mailto:(.*?)\]/[mailto:$1 $1]/g;
  
  if( $line =~ /\[mailto:.*?\]/ )
  {
    $line =~ s/ DOT /./g;
    $line =~ s/ AT /@/g;
  }

  if(  $line =~ s/\[\[FootNote\((.+?)(?=\)\]\])\)\]\]/<ref>$1<\/ref>/g) {      # Converting footnotes
    $$footnote = 1;
  }

  return $line;
}


sub codeblocks {
  my ($line, $indent_level, $numbered) = @_;
  
  # One-line codeblocks
  $line =~ s/\{\{\{(.*?)\}\}\}/<code\>\<nowiki\>$1\<\/nowiki\>\<\/code\>/g; # {{{ * }}}  ->  <code><nowiki> * </nowiki></code>

  
  # Multi-line codeblocks
  if( $indent_level>0 && $numbered){
    my $columns = replicate(":",$indent_level-1);
    $line =~ s/\{\{\{(.*?)/\n\#${columns}<pre><nowiki>$1/g;
    $line =~ s/(.*?)\}\}\}/$1\#${columns}<\/nowiki><\/pre>/g;
  }
  else {
    $line =~ s/\{\{\{(.*?)/\n<pre><nowiki>$1/g;       # {{{ *   ->  <pre><nowiki> *
    $line =~ s/(.*?)\}\}\}/$1<\/nowiki><\/pre>/g;     #  * }}}  ->  * <\nowiki><\pre>
  }
  $line =~ s/--\(/<span style="text-decoration: line-through">/g;   # --(  ->  <span style="text-decoration: line-through">  # could also use <s>   ?
  $line =~ s/\)--/<\/span>/g;                                       # >--  ->  </span>                                       # could also use </s>  ?

  return $line;
}

sub replicate {
  my ($char, $qty) = @_;
  return $char x $qty;
}


1;
