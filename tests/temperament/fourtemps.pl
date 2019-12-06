#!/usr/bin/perl -w
use CGI;

$query = new CGI();

my $name = $query->param("name");
print $query->header, $query->start_html("The Keirsey Four Temperament Sorter");

@tot=();
$missed = 64;

for($i=1;$i<=16;$i++) {
    for($j=0;$j<4;$j++) {
        $ans = $query->param("Q${i}A$j");
        next if !defined($ans);
        $tot[$j] += $ans;
        $missed--;
    }
}

if($missed == 0) {
    $max = 0;
    for($i=0;$i<4;$i++) {
        $tot[$i] = 64 - $tot[$i];
        if($tot[$i] > $max) {
            $max = $tot[$i];
            $temp = $i;
        }
    }
    
    @names = ("Artisan (SP)", "Idealist (NF)", "Guardian (SJ)", "Rational (NT)");
    
    print $query->h1("Results");
    print $query->h3("$name\'s Temperament is $names[$temp]");
    
    print "<B>Score</B><br>";
    for($i=0;$i<4;$i++) {
        print "$names[$i] $tot[$i]<br>";
    }
    print $query->hr;
} elsif($missed < 64) {
    print $query->h3("You failed to select $missed answers.  Verify and re-submit below");
    print $query->hr;
}

print $query->h1("The Keirsey Four Temperament Sorter");
open(F, "kfts.txt") || die "Couldn't open test file kfts.txt";
print $query->start_form;
print $query->p("Enter your name: ", $query->textfield('name'));
print "<p>Each of the following 16 questions has four responses.<br>";
print "Please rate each response according to how well it describes you from<br>";
print "most like you to least like you.</p>";

print "<TABLE border=0><TH></TH><TH colspan=4>most <-> least</TH>";
for($i=1;$i<=16;$i++) {
    $line = <F>;
    print "<TR><TD colspan=5><B>$i) $line</B></TD></TR>";
    for($j=0;$j<4;$j++) {
        $line = <F>;
        $checked = $query->param("Q${i}A$j");
        if((defined($checked)) || ($missed == 64)) {
            $color = "#000000";
        } else {
            $color = "#ff0000";
        }
        print "<TR><TD><font color=$color>$line</font></TD>";
        
        for($k=0;$k<4;$k++) {
            print "<TD><input type=\"radio\" name=\"Q${i}A$j\", value=\"$k\" onClick=\"";
            for($l=0;$l<4;$l++) {
                print "document.forms[0].Q${i}A${l}[$k].checked=false;" if $l != $j;
            }
            print "\"";
            print " checked " if (defined($checked) && $checked eq $k);             
            print "></TD>";
        }
        print "</TR>";
    }
}
print "</TABLE>",$query->p($query->submit("What's my temperment?"), $query->reset("Reset"));
print $query->end_form();

