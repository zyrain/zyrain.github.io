#!/usr/bin/perl -w
use CGI;

$query = new CGI();

print $query->header, $query->start_html("The Keirsey Temperament Sorter II");

%full = ("iSfP", "Composer",
         "iStP", "Crafter",
         "eSfP", "Performer",
         "eStP", "Promoter",
         "iStJ", "Inspector",
         "iSfJ", "Protector",
         "eStJ", "Supervisor",
         "eSfJ", "Provider",
         "iNFp", "Healer",
         "iNFj", "Counselor",
         "eNFp", "Champion",
         "eNFj", "Teacher",
         "iNTp", "Architect",
         "iNTj", "Mastermind",
         "eNTp", "Inventor",
         "eNTj", "Fieldmarshal");
@names = ('E', 'I', 'S', 'N', 'T', 'F', 'J', 'P');
@tot = ();

$missed = 70;

for($i=1;$i<=70;$i++) {
    $ans = $query->param("Q${i}");
    next if !defined($ans);
    $missed--;

    $idx = 0 + $ans if ($i % 7 == 1);
    $idx = 2 + $ans if ($i % 7 == 2);
    $idx = 2 + $ans if ($i % 7 == 3);
    $idx = 4 + $ans if ($i % 7 == 4);
    $idx = 4 + $ans if ($i % 7 == 5);
    $idx = 6 + $ans if ($i % 7 == 6);
    $idx = 6 + $ans if ($i % 7 == 0);
    
    $tot[$idx]++;
}

if($missed == 0) {
    @temp = ();

    for($i=0;$i<8;$i+=2) {
        $temp[$i/2] = 'X' if($tot[$i] == $tot[$i+1]);
        $temp[$i/2] = $names[$i] if($tot[$i] > $tot[$i+1]);
        $temp[$i/2] = $names[$i+1] if($tot[$i] < $tot[$i+1]);
    }
    
    $temp[0] = 'e' if $temp[0] eq 'E';
    $temp[0] = 'i' if $temp[0] eq 'I';
    
    if($temp[1] eq 'S') {
        $temp[2] = 't' if $temp[2] eq 'T';
        $temp[2] = 'f' if $temp[2] eq 'F';
    }    
    
    if($temp[1] eq 'N') {
        $temp[3] = 'p' if $temp[3] eq 'P';
        $temp[3] = 'j' if $temp[3] eq 'J';
    }    
    
    print $query->h1("Results");
    
    $temp = join('',@temp);
    $name = $query->param("name");
    if($temp =~ /X/) {
        print $query->h2("$name\'s Temperament is Uncertain ($temp)");
    } else {
        print $query->h2("$name\'s Temperament is $full{$temp} ($temp)");
    }
    print "<B>Score</B><br><PRE>";
    
    for($i=0;$i<8;$i++) {
        print "$names[$i] $tot[$i]<br>";
    }
    print "</PRE>".$query->hr;
} elsif($missed > 0) {
    print $query->h3("You failed to answer $missed questions.  Verify and resubmit below");
    print $query->hr;
}

print $query->h1("The Keirsey Temperament Sorter II");
open(F, "ktsii.txt") || die "Couldn't open test file kfts.txt";
print $query->start_form;
print "<p>Each of the following 70 questions has two choices.<br>";
print "Please choose the one that best describes you.</p>";

print "<TABLE border=0>";

for($i=1;$i<=70;$i++) {
    $line = <F>;
    $checked = $query->param("Q${i}");
    if(($missed > 0) && (!defined($checked))) {
        $color="#ff0000";
    } else {
        $color="#000000"; 
    }
    print "<TR><TD colspan=2><B>$i) $line</B></TD></TR>";
    for($j=0;$j<2;$j++) {
        print "<TR><TD><input type=\"radio\" name=\"Q${i}\", value=\"$j\"";
        print " checked " if (defined($checked) && ($checked eq $j));             
        print "></TD>";
        $line = <F>;
        print "<TD><font color=$color>$line</font></TD></TR>";
    }
}
print "</TABLE>";
print $query->p("Enter your name: ", $query->textfield('name'));
print $query->p($query->submit("What's my temperment?"), $query->reset("Reset"));
print $query->end_form();

print $query->end_html();
