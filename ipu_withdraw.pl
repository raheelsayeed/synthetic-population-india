#!/usr/bin/perl
##########
#
# Guido C. Espana
#
##########
use warnings;
use strict;
use Cwd;
use POSIX;
use Getopt::Long;
use Data::Dumper;

my %codes;
my $cdir = getcwd;
my $code;
my $field_separator = ':';
my $email_flag = "";
my $mun_file = "mun_file.txt";
my $students_file = "INPUT_FILES/students.txt";
my $workers_file = "INPUT_FILES/workers.txt";
my $pop_file = "INPUT_FILES/population.txt";
my $ipums_vs_code = "INPUT_FILES/ipums_codes.txt";
my $result_opts = GetOptions(
                  "f=s"=>\$mun_file,                  
                  "s=s"=>\$students_file,
                  "w=s"=>\$workers_file,
                  "p=s"=>\$pop_file,
                  "ipums=s"=>\$ipums_vs_code,
);

open my $fh,'<',$mun_file or die "cannot open $mun_file\n";
my $FS = ",";
while(<$fh>){
    chomp;
    next unless($_ =~ /^[0-9]+/);
    my ($mun_,$dpto_) = split/$FS/,$_;
    $dpto_ = int($dpto_);
    $codes{$dpto_}{$mun_} = $mun_;

	print Dumper(%codes);
}
close $fh;
#my @a = qw(0 0.32 0.49 0.50 0.52 0.75 0.94 0.98);
#&find_index(\@a,0.1);
my $start_time = localtime;
my @dptos = sort keys %codes;
foreach my $dpto_(@dptos){
    my $ofh;
    print "DPTO: $dpto_\n";
    my $new_dpto_ipums_file = "Complete_dataset_".$dpto_.".txt";
    print "Output: $new_dpto_ipums_file\n";
    open $ofh, '>',$new_dpto_ipums_file or die "cannot open $new_dpto_ipums_file \n";
    foreach my $mun(sort keys %{$codes{$dpto_}}){
	&extract_by_mun($mun,$dpto_,$ofh,$students_file,$workers_file);
    }
    close $ofh;
}
	my $elapsed_time = localtime;
print "\nSTARTED at: $start_time\nFINISHED at: $elapsed_time\n";
unlink "temp.txt";
###SUB_ROUTINES###
sub extract_by_mun{
    my $mun_code = int(shift @_);
    my $dpto_code = int(shift @_);
    my $output_handle = shift @_;
    my $st_file = shift @_;
    my $work_file = shift @_;
    print "MUN: $mun_code\n";
    my $dpto_ipums_file = "INPUT_FILES/ipums_dataset_".$dpto_code.".txt";
    my @constraints = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
    my @perf1 = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
    my @perf2 = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
    my $population = &get_population($mun_code,\@constraints,$st_file,$work_file);
	print Dumper($constraints[0]);
    return if ($population <= 0);

    my %houses;
    my $percentage_urban = &read_ipums($mun_code,$dpto_code,$population,$dpto_ipums_file,\%houses,\@constraints,\@perf1);
	# print Dumper(houses);
    print "mun $mun_code $population Perc Urban: $percentage_urban\n";
	return;

    # calculate cumulative sum and frecuency
    my $error;
    my $threshold = 0.0001;


    for my $h(0..100){
	&adjust_weights(\%houses,\@constraints,$percentage_urban,\@perf2);
	$error = abs(&sum(\@perf2) - &sum(\@perf1));
	last if ($error < $threshold);
	@perf1 = @perf2;
    }
    print "Total error : $error\n";
    my @cdf_rural;
    my @cdf_urban;
    &calculate_cdf(\%houses,\@cdf_urban,\@cdf_rural);
    my $persons = 0;
    my $rural_persons = 0;
    my $urban_persons = 0;
    my $houses_counter = 0;
    my @rural_keys = sort keys %{$houses{1}};
    my @urban_keys = sort keys %{$houses{2}};
    my $chi = 100;
    my $count_ = 0;
    my $temp_file = "temp.txt";
    my $critical = 27;
    while($chi > $critical && $count_ < 5){
	print "iter: $count_\n";
	$rural_persons = 0;
	$urban_persons = 0;
	$houses_counter = 0;
	open my $temp_fh,'>',$temp_file or die "cannot create $temp_file\n";
	while($rural_persons < $population * (1 - $percentage_urban)){
	    my $r = rand();
	    $houses_counter++;
	    my $index = &find_index(\@cdf_rural,$r);
	    die "something is wrong with find_index \n" if ($index < 0);
	    my $p = &create_new_records($mun_code,$temp_fh,$houses{1}{$rural_keys[$index]}{records},$persons,$houses_counter);
	    $persons += $p;
	    $rural_persons += $p;
		print Dumper($persons) , "\n";
	
	}
	while($urban_persons < $population * $percentage_urban){
	    my $r = rand();
	    $houses_counter++;
	    my $index = &find_index(\@cdf_urban,$r);
	    die "something is wrong with find_index \n" if ($index < 0);
	    my $p = &create_new_records($mun_code,$temp_fh,$houses{2}{$urban_keys[$index]}{records},$persons,$houses_counter);
	    $persons += $p;
	    $urban_persons += $p;
	}

	close $temp_fh;
	mkdir 'OUTPUT' unless(-e 'OUTPUT');
	system "./bin/get_temp_population -f $temp_file";
	system "./bin/compare_age_sex -m $mun_code -census $pop_file ";
	my $dif_file = "OUTPUT/Difference_age_$mun_code".".txt";
	$chi = `./bin/calculate_chi2 -f $dif_file -e 1 -m 2`;
	chomp($chi);
	$count_++;
    }
    print "Chi2: $chi mun $mun_code iter: $count_\n";
    &print_record($temp_file,$output_handle);
    my $rural_ = $population * (1 - $percentage_urban);
    my $urban_ = $population *  $percentage_urban;
    print "MUN: $mun_code POPULATION: $population ASSIGNED: $persons HOUSES: $houses_counter URBAN_CENSUS: $urban_ URBAN_AS: $urban_persons RURAL_CENSUS: $rural_ RURAL_AS: $rural_persons\n";

}
sub print_record{
    my $temp_file = shift @_;
    my $ofh = shift @_;
    open my $fh,'<',$temp_file or die "cannot read $temp_file\n";
    while(<$fh>){
	print {$ofh} $_;
    }
    close $fh;
    return 0;
}
sub find_index{
    my $cdf_ = shift @_;
    my $r = shift @_;
    my $low = 0;
    my $high = $#{$cdf_};
    my $mid = 0;
    return $low if (${$cdf_}[$low] > $r);
    while(($high - $low) > 1){
#	print "$low - $high - $mid\n";
	$mid = $low + floor(($high - $low) / 2);
	if(${$cdf_}[$mid] > $r){
	    $high = $mid;
	}else{
	    $low = $mid;
	}
	last if ($high == $r);
    }
#    print "$r index: $high val: $$cdf_[$high]\n";
    return $low if (${$cdf_}[$low] > $r);
    return $high;
}
sub find_index2{
    my $cdf_ = shift @_;
    my $r = shift @_;
    foreach my $k(0..$#{$cdf_}){
	return $k if($r < ${$cdf_}[$k]);
    }
    return -1;
}
sub calculate_cdf {
    my $house_hash = shift @_;
    my $cdf_urb = shift @_;
    my $cdf_rur = shift @_;
    my @rural_keys = sort keys %{${$house_hash}{1}};
    my @urban_keys = sort keys %{${$house_hash}{2}};
    my $sum = 0;
    foreach my $k(0..$#rural_keys){
	
	$sum += ${$house_hash}{1}{$rural_keys[$k]}{weight};
	${$cdf_rur}[$k] = $sum;
    }
	
    foreach my $k(0..$#{$cdf_rur}){
	${$cdf_rur}[$k] /= $sum;
    }
    $sum = 0;
    foreach my $k(0..$#urban_keys){
	$sum += ${$house_hash}{2}{$urban_keys[$k]}{weight};
	${$cdf_urb}[$k] = $sum;
    }
    foreach my $k (0..$#{$cdf_urb}){
	${$cdf_urb}[$k] /= $sum;
    }
    return 0;
}
sub adjust_weights {
    my $house_hash = shift @_;
    my $const = shift @_;
    my $urban_per = shift @_;
    my $performance = shift @_;
    my @sum_weights_u = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
    my @sum_weights_r = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
    my @rural_keys = sort keys %{${$house_hash}{1}};
    my @urban_keys = sort keys %{${$house_hash}{2}};

	
    my $sum = 0;
    my $ratio_r = 1;
    my $ratio_u = 1;
    foreach my $i(0..$#sum_weights_r){
        
        my $constraint = ${$const}[$i]*(1 - $urban_per);
        foreach my $k(0..$#rural_keys){
            $sum_weights_r[$i] += ${$house_hash}{1}{$rural_keys[$k]}{weights}[$i] * ${$house_hash}{1}{$rural_keys[$k]}{weight};
        }
        $ratio_r = $sum_weights_r[$i] > 0 ? $constraint / $sum_weights_r[$i]: $constraint;
        foreach my $k(0..$#rural_keys){
            if( ${$house_hash}{1}{$rural_keys[$k]}{weights}[$i] > 0){
                ${$house_hash}{1}{$rural_keys[$k]}{weight} *= $ratio_r;
            }
        }
        $constraint = ${$const}[$i]* $urban_per;
        foreach my $k(0..$#urban_keys){
            $sum_weights_u[$i] += ${$house_hash}{2}{$urban_keys[$k]}{weights}[$i] * ${$house_hash}{2}{$urban_keys[$k]}{weight};
        }
        $ratio_u = $sum_weights_u[$i] > 0 ? $constraint / $sum_weights_u[$i]: $constraint;
        foreach my $k(0..$#urban_keys){
            if( ${$house_hash}{2}{$urban_keys[$k]}{weights}[$i] > 0){
                ${$house_hash}{2}{$urban_keys[$k]}{weight} *= $ratio_u;
            }
        }
    }    
    @sum_weights_u = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
    @sum_weights_r = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
    foreach my $i(0..$#sum_weights_r){
	foreach my $k(0..$#rural_keys){
	    $sum_weights_r[$i] += ${$house_hash}{1}{$rural_keys[$k]}{weights}[$i] * ${$house_hash}{1}{$rural_keys[$k]}{weight};
	}
	foreach my $k(0..$#urban_keys){
	    $sum_weights_u[$i] += ${$house_hash}{2}{$urban_keys[$k]}{weights}[$i] * ${$house_hash}{2}{$urban_keys[$k]}{weight};
	}
	${$performance}[$i] = ${$const}[$i] > 0 ? abs(${$const}[$i] - ($sum_weights_r[$i] + $sum_weights_u[$i])) / ${$const}[$i]: abs(${$const}[$i] - ($sum_weights_r[$i] + $sum_weights_u[$i]));
    }
    my $format = "Performance: ".("%.2f " x @sum_weights_u). "\n";
#    printf $format, @{$performance};
    return 0;
}

sub  get_population{
    my $mun_code = shift @_;
    my $const = shift @_;
    my $st_file  = shift @_;
    my $work_file = shift @_;
    open POPFILE ,'<',$pop_file or die "cannot open $pop_file to read populations by municipality\n";
    open STUDENTS,'<',$st_file or die "cannot read $st_file\n";
    open WORKERS,'<',$work_file or die "cannot read $work_file\n";

	


    my $population = 0;
    while (<POPFILE>){
	chomp;
	next unless($_ =~ /^[0-9]/);
	my @values = split;
	next if(! defined($values[1]));
	if($values[0] == $mun_code){
	    $population = $values[1];
	    @{$const} = @values[4..20]
	}
    }
    while (<STUDENTS>){
	chomp;
	next unless($_ =~ /^[0-9]/);
	my @values = split;
	next if(! defined($values[1]));
	if($values[0] == $mun_code){
	    push @{$const}, $values[2];
	}
    }
    while (<WORKERS>){
	chomp;
	next unless($_ =~ /^[0-9]/);
	my @values = split;
	next if(! defined($values[1]));
	if($values[0] == $mun_code){
	    push @{$const}, $values[2];
	}
    }
    close POPFILE;
    close STUDENTS;
    print "@{$const}\n";
    return $population;
}
sub read_ipums{
    my $mun_code = shift @_;
    my $dpto_code = shift @_;
    my $population = shift @_;
    my $dpto_ipums_file = shift @_;
    my $house_hash = shift @_;
    my $const = shift @_; 
    my $performance = shift @_;
    open IPUMSCODES, '<',$ipums_vs_code or die "cannot open $ipums_vs_code to read Ipums and Divipola relation codes\n";
    # 1 column: Ipums -  2 column: Divipola
    my $ipums;
    my $code;
    while(<IPUMSCODES>){
	chomp;
	($ipums,$code) = split;
	last if ($code == $mun_code);
    }
    close IPUMSCODES;
	
	
    my $urban_percentage = &get_urban_percentage($ipums,$dpto_ipums_file,$house_hash,$const,$performance);
    print "IPUMS: $ipums CODE $code POPULATION $population URBAN \%: $urban_percentage\n";
    return $urban_percentage;
}
sub get_urban_percentage{
    my $ipums_code = shift @_;
    my $dpto_ipums_file = shift @_;
    my $house_hash = shift @_;
    my $const = shift @_;
    my $performance = shift @_;
    my $urban = 0;
    my $line = 0;
    my @weights = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
    my @age_ranks = qw (5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 200); 
    my $school_index = 17;
    my $work_index = 18;
    open IPUMSFILE, '<',$dpto_ipums_file or die "cannot open $dpto_ipums_file to calculate the urban and rural percentage\n";
    #headers_ipums.txt: position 10 is urban
    while(<IPUMSFILE>){
	chomp;
	my $FS = ":";
	my ($h_id,$weight,$urb,$mun_ipums) = (split /$FS/,$_)[3,5,10,15];
	
	if( ($mun_ipums == $ipums_code)){
	    $line += $weight;
	    $urban += $weight if ($urb ==2);
	}
	if($urb == 1 || $urb == 2){
	    my @fields = (split /$FS/,$_)[3,4,5,10,12,13,14,15,16,20,21,24,47,48,49,65,66,67,68,69,75,76,77,78,79,81,82,83,84,85,86,87,88];
	    my $age = (split /$FS/,$_)[67];
	    my $school = (split /$FS/,$_)[79];
	    my $work = (split /$FS/,$_)[85];
	    my $index = &find_range(\@age_ranks,$age);
		print Dumper($house_hash), '\n';
	
	    ${$house_hash}{$urb}{$h_id}{weight} = $weight;
	    push @{${$house_hash}{$urb}{$h_id}{records}}, $_;
	    ${$house_hash}{$urb}{$h_id}{persons}++;
	    unless(exists ${$house_hash}{$urb}{$h_id}{weights}){
		${$house_hash}{$urb}{$h_id}{weights} = [@weights];
	    }
	    ${$house_hash}{$urb}{$h_id}{weights}[$index]++;
	    ${$house_hash}{$urb}{$h_id}{weights}[$school_index]++ if($school == 1);
	    ${$house_hash}{$urb}{$h_id}{weights}[$work_index]++ if($work == 1);
	}
    }
    $urban /=$line;
	
	# print Dumper(\keys %{${$house_hash}{2}});	

	
	
    close IPUMSFILE;
    my @rural_keys = sort keys %{${$house_hash}{1}};
    my @urban_keys = sort keys %{${$house_hash}{2}};

	# print Dumper(@rural_keys), "\n\nURBAN:\n", Dumper(@urban_keys), "\n";
	

    my @sum_weights_u = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
    my @sum_weights_r = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);



    foreach my $i(0..$#sum_weights_r){
	foreach my $k(0..$#rural_keys){
	    $sum_weights_r[$i] += ${$house_hash}{1}{$rural_keys[$k]}{weights}[$i] * ${$house_hash}{1}{$rural_keys[$k]}{weight};
	}
	foreach my $k(0..$#urban_keys){
		
		# print "urban key: ", ${$house_hash}{2}{$urban_keys[$k]} , "\n";
		
		# print "urban key: ", ${$house_hash}{2}{$urban_keys[$k]}{weights}[$i] * ${$house_hash}{2}{$urban_keys[$k]}{weight}, "\n";
		
	    $sum_weights_u[$i] += ${$house_hash}{2}{$urban_keys[$k]}{weights}[$i] * ${$house_hash}{2}{$urban_keys[$k]}{weight};

	}
	${$performance}[$i] = ${$const}[$i] > 0 ? abs(${$const}[$i] - ($sum_weights_r[$i] + $sum_weights_u[$i])) / ${$const}[$i]: abs(${$const}[$i] - ($sum_weights_r[$i] + $sum_weights_u[$i]));
    }


   my $format = "%s ".("%.2f " x @sum_weights_u). "\n";
   printf $format,"performance", @{$performance};
   printf $format,"urban: ", @sum_weights_u;
   printf $format,"rural: ", @sum_weights_r;
   return $urban;
}

sub create_new_records{
    my $mun_code = shift @_;
    my $ofh = shift @_;
    my $records_r = shift @_;
    my $person_counter = shift @_;
    my $house_counter = shift @_;
    my $persons = 0;
    my $FS = ":";
    foreach(@{$records_r}){
	my @fields = (split /$FS/,$_)[3,4,5,10,12,13,14,15,16,20,21,24,47,48,49,65,66,67,68,69,75,76,77,78,79,81,82,83,84,85,86,87,88];
	my $new_house_serial;
	my $new_person_serial;
	$persons ++;
	$new_house_serial = 170 * 1000000000000 + $mun_code * 10000000 + $house_counter;
	$new_person_serial = 170 * 1000000000000 + $mun_code * 10000000 + $person_counter + $persons;
	my $print_string = join $FS,@fields,$new_house_serial,$new_person_serial,$mun_code;
	print $ofh "$print_string\n";
    }
    return $persons;
}

sub find_range {
    my $age_ranks_ref = shift @_;
    my $age = shift @_;
    for (my $i = 0;$i<@{$age_ranks_ref};$i++){
	if ($age < ${$age_ranks_ref}[$i]){
	    return $i;
	}
    }
    return 0;
}
sub sum {
    my $array_ref = shift @_;
    my $sum = 0;
    foreach(@{$array_ref}){
	$sum += $_;
    }
    return $sum;
}
