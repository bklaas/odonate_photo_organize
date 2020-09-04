#!/usr/bin/perl
#
use strict;

use Image::IPTCInfo;
use Data::Dump qw(dump);
use File::Copy;
 
my $dir = "/home/benklaas/git/odonate_photo_organize/originals";
my $out_dir = "organized";
my $images = get_images($dir);

# Create new info object
my $x = 0;
my $species_list = {};
for my $img (@$images) {
    $x++;
    my $i = "$dir/$img";
    my $info = new Image::IPTCInfo("$i");
     
    # Check if file had IPTC data
    unless (defined($info)) { 
        print STDERR "No info in $img: copying to organized/unidentified/$img\n";
        copy_img($i, 'unidentified');
       next;
    }
       
    # Get list of keywords, supplemental categories, or contacts
    my $keywordsRef = $info->Keywords();
    my $suppCatsRef = $info->SupplementalCategories();
    my $contactsRef = $info->Contacts();
       
    # Get specific attributes...
    my $caption = $info->Attribute('caption/abstract');
 
    #my $date_created = $info->Attribute('writer/editor');
    #print "!!!\t$date_created\n";
    my $orig_caption = $caption;
    if ($orig_caption eq "n") {
        copy($i, "$out_dir/unidentified/$img");
        next;
    }
    $caption =~ s/--.*//;
    $caption =~ s/^male\s+//i;
    $caption =~ s/^female\s+//i;
    $caption =~ s/female.*//i;
    $caption =~ s/male.*//i;
    $caption =~ s/pair.*//i;
    $caption =~ s/in wheel//i;
    $caption =~ s/in flight//i;
    $caption =~ s/immature//i;
    $caption =~ s/with prey//i;
    $caption =~ s/powderd/powdered/i;
    $caption =~ s/dull//i;
    $caption =~ s/blue form//i;
    $caption =~ s/brown form//i;
    $caption =~ s/with butterfly.*//i;
    $caption =~ s/with buttefly.*//i;
    $caption =~ s/feeding on small moth//i;
    $caption =~ s/feeding on butterfly//i;
    $caption =~ s/in spider's web//i;
    $caption =~ s/bluets/bluet/i;
    $caption =~ s/femlae//i;
    $caption =~ s/dull$//i;
    $caption =~ s/blue fronted/blue-fronted/i;
    $caption =~ s/ephemeral//i;
    $caption =~ s/white tailed skimmer/white-tail/i;
    $caption =~ s/white tail/white-tail/i;
    $caption =~ s/whitetailed skimmer/white-tail/i;
    $caption =~ s/white face/whiteface/i;
    $caption =~ s/fortail/forktail/i;
    $caption =~ s/forttail/forktail/i;
    $caption =~ s/pond hawk/pondhawk/i;
    $caption =~ s/familair/familiar/i;
    $caption =~ s/laeg/leg/i;
    $caption =~ s/spinyleg/spineyleg/i;
    $caption =~ s/flagtailed/flag-tailed/i;
    $caption =~ s/spiney-leg/spineyleg/i;
    $caption =~ s/spiney leg/spineyleg/i;
    $caption =~ s/spiny-legged flagtail/flag-tailed spineyleg/i;
    $caption =~ s/teneril//i;
    $caption =~ s/bluet\?/bluet/i;
    $caption =~ s/haek/hawk/i;
    $caption =~ s/skimmer-/skimmer/i;
    $caption =~ s/amber wing/amberwing/i;
    $caption =~ s/blue dancer/blue dasher/i;
    $caption =~ s/dot-tailed skimmer/dot-tailed whiteface/i;
    $caption =~ s/yellow-legged or //i;
    $caption =~ s/1$//i;
    $caption =~ s/2$//i;
    $caption =~ s/,//i;
    $caption =~ s/\(.*//i;
    $caption =~ s/\s+-.*//i;
    $caption =~ s/\-$//i;
    $caption =~ s/\?$//i;
    $caption =~ s/\s+$//i;
    $caption =~ s/^meadowhawk$/meadowhawk sp./i;
    $caption =~ s/sp./species/i;


       
    #print $x . ": " . $img . ": " . $caption . "|$orig_caption\n";
    #print "|$caption|\n|$orig_caption|\n\n";
    $caption = lc($caption);
    $species_list->{$caption}++;
    #print "$caption|\n";
    # Create object for file that may or may not have IPTC data.
    #$info = create Image::IPTCInfo('file-name-here.jpg');
       
    # Add/change an attribute
    #$info->SetAttribute('caption/abstract', 'Witty caption here');
     
    # Save new info to file 
    ##### See disclaimer in 'SAVING FILES' section #####
    #$info->Save();
    #$info->SaveAs('new-file-name.jpg');
    if ($caption =~ /^unidentified/) {
        copy_img($i, 'unidentified');
    }
    else {
        copy_img($i, $caption);
    }
}

#print dump($species_list);
for my $s (sort keys %$species_list) {
    print "|" . $s . "|" . "\t|$species_list->{$s}|\n";
}

# pics that start with "unidentified" go into unidentified

sub get_images {
    my $dir = shift;
    opendir(DIR, $dir);
    my $ret = [];
    while (my $i = readdir(DIR)) {
        push @$ret, $i if $i =~ /JPG$/i && -f "$dir/$i";
    }
    return $ret;
}

sub copy_img {
    my $img = shift;
    my $species = shift;
    my $d = "$out_dir/$species";
    if (! -d ($d)) {
        mkdir("$out_dir/$species");
    }
    my $i = 1;
    while (-e "$d/${species}_$i.jpg") {
        $i++;
        print "Copy $img to $d/${species}_$i.jpg\n";
    }
}