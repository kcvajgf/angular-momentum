#!/usr/bin/perl

### Calculate Krippendorff's alpha, including confidence intervals
### using bootstrapping.

### Usage: perl calculate-alpha.perl <metric> <data-file> <samples> [subsets]

### <metric> is the distance metric; currently accepted values are
### "nominal" and "interval". 

### <data-file> is a tab-separated text file: the first line is
### annotator id's separated by tabs, and subsequent lines are
### annotation data, with each line representing a single item, and
### individual values separated by tabs. Values must be numeric;
### non-numeric categories must be converted to numbers (but the
### nominal distance metric does not consider their numeric values).

### <samples> is the number of resamplings used for calculating
### confidence intervals. It must be a multiple of 200, in order to
### give two-tailed 1% confidence intervals. A parameter value 0 means
### no confidence intervals are calculated.

### [subsets] is a flag: leaving it blank calculates reliability for
### all coders as a group, while specifying "subsets" also calculates
### reliability for each subset of coders (exponential time, usually
### not feasible with more than 4 or 5 coders).

### Questions, suggestions and bug reports welcome!
### Ron Artstein, http://ron.artstein.org/
### Email: my last name [at] ict.usc.edu

### Version History:
### Version 1.00, 2008-08-08: initial version with interval distance.
### Version 1.01, 2008-08-26: corrected bug of division by zero when
###   two annotators had no items in common.
### Version 1.10, 2009-02-25: added nominal distance.
### Version 1.11, 2009-02-26: some code tidying.
### Version 1.12, 2009-07-30: no mean-median-variance for nominal data.
### Version 1.13, 2009-07-31: fixed error from printing uninitialized values.
### Version 1.20, 2010-02-17: added command-line option for subsets of
###   coders, fixed sorting in summary statistics, fixed cr+lf bug in
###   parsing Windows-formatted data on Unix.

### Known bugs:

### If two annotators have a large number of identical agreeing
### judgments (that is, the same agreeing judgments appear over and
### over), then when calculating confidence intervals, resampling is
### likely to result in a sample annotation where all values are
### identical, in which case alpha is undefined; pushing the resulting
### "undef" value causes an error message with numerical sort at line
### 349. It is not clear whether this is an implementation bug or a
### problem with the bootstrapping algorithm, so I'm leaving this for
### future research; at any rate, this only happens in pathological
### cases where the validity of the bootstrapping method is doubtful.


####### begin program #######

use warnings ;
use strict ;

### Integrity tests

if (2 > $#ARGV or 3 < $#ARGV) # Exactly 2 or 3 arguments required
  {die "Usage: perl calculate-alpha.perl <metric> <data-file> <samples> [subsets]\n"}

my $distance_metric ;
if ("nominal" eq $ARGV[0])  {
  $distance_metric = \&nominal_distance ;
} elsif ("interval" eq $ARGV[0]) {
  $distance_metric = \&interval_distance ;
} else {
  die "Only acceptable metrics are nominal and interval\n" ;
}

sub nominal_distance {return 1} ;
sub interval_distance {return ($_[0] - $_[1]) ** 2} ;

my $data_file = $ARGV[1] ;

my $num_samples = $ARGV[2] ;
if ($num_samples =~ /\D/) {
  die "<samples> must be a non-negative multiple of 200\n" ;
}
if (int ($num_samples/200) != $num_samples/200) {
  die "Number of samples must be a multiple of 200\n" ;
}

my $subsets = 0 ;
if (2 == $#ARGV) {
  $subsets = 0 ;
} elsif ("subsets" eq $ARGV[3]) {
  $subsets = 1 ;
} else {
  die "Usage: perl calculate-alpha.perl <metric> <data-file> <samples> [subsets]\nLeave [subsets] blank to calculate reliability for all coders as a group\nUse \"subsets\" to also calculate reliability for each subset of coders\n" ;
}



### Main

my @annotators = () ;
my @all_scores = () ;

read_data ($data_file) ;

print_summary_statistics () ;

print_reliability_all_raters () ;

if ($subsets) {print_reliability_subsets_of_raters ()}

if (0 < $num_samples) {print_confidence_intervals ()}


###

sub print_summary_statistics {
  print "Summary statistics\n\n" ;
  # Create an array of all scores
  my @temp_array = () ;
  foreach my $item (0 .. @all_scores - 1) {
    foreach my $annotator (0 .. @annotators - 1) {
      if (0 != $all_scores[$item][$annotator] 
	  or "0" eq $all_scores[$item][$annotator]) {
	push (@temp_array, $all_scores[$item][$annotator])
      }
    }
  }
  # Summary statistics for all scores
  my $mean ; my $median ; my $variance ;
  if ("interval" eq $ARGV[0]) {
    $median = median (@temp_array) ;
    $mean = mean (@temp_array) ;
    $variance = variance (@temp_array) ;
  }
  my %scores = histogram (@temp_array) ;
  foreach my $key (sort {$a <=> $b} keys %scores) {print sprintf ("%-6s", $key)}
  print "N     " ;
  if ("interval" eq $ARGV[0]) {print "Med.  Mean  Var.  "}
  print "Annotator\n" ;
  foreach my $key (sort {$a <=> $b} keys %scores) {print sprintf ("%5s", $scores{$key})," "}
  print sprintf ("%5s", scalar(@temp_array)) , " " ;
  if ("interval" eq $ARGV[0]) {
    print sprintf ("%.3f", $median) , " " ;
    print sprintf ("%.3f", $mean) , " " ;
    print sprintf ("%.3f", $variance) , " " ;
  }
  print "All scores\n" ;
  foreach my $annotator (0 .. @annotators - 1) {
    # Create an array of all scores for one annotator
    my @temp_array = () ;
    foreach my $item (0 .. @all_scores - 1) {
      if (0 != $all_scores[$item][$annotator] 
	  or "0" eq $all_scores[$item][$annotator]) {
	push (@temp_array, $all_scores[$item][$annotator])
      }
    }
    # Summary statistics for one annotator
    if ("interval" eq $ARGV[0]) {
      $median = median (@temp_array) ;
      $mean = mean (@temp_array) ;
      $variance = variance (@temp_array) ;
    }
    my %annotator_scores = histogram (@temp_array) ;
    foreach my $key (sort {$a <=> $b} keys %scores) {
      if ($annotator_scores{$key}) {
	print sprintf ("%5s", $annotator_scores{$key}) , " " ;
      } else {
	print "      " ;
      }
    }
    print sprintf ("%5s", scalar(@temp_array)) , " " ;
    if ("interval" eq $ARGV[0]) {
      print sprintf ("%.3f", $median) , " " ;
      print sprintf ("%.3f", $mean) , " " ;
      print sprintf ("%.3f", $variance) , " " ;
    }
    print "\u$annotators[$annotator]\n" ;
  }
}


### Reliability for all raters, taken together as a group. Calculated
### only on the items scored by all raters.

sub print_reliability_all_raters {

  my $all_annotators_report = generate_subset_report (0 .. @annotators - 1) ;
  print "\nReliability for all judges together\n\n" ;
  print "Alpha D-obs D-exp N    Raters\n" ;
  print "$all_annotators_report\n" ;

}


### Reliability for all possible subgroups of raters. CAUTION: THIS
### GROWS EXPONENTIALLY WITH THE NUMBER OF RATERS. For each group of
### raters, reliability is calculated on the items scored by all
### raters in the group. Results are sorted by reliability (alpha),
### from the least agreeing subset to the most agreeing one.

sub print_reliability_subsets_of_raters {

  my @annotator_subsets = find_all_subsets (0 .. @annotators - 1) ;
  my @reports = () ;

  foreach my $subset (@annotator_subsets) {
    if (2 <= scalar (@{$subset})) {
      my $annotator_subset_report = generate_subset_report (@{$subset}) ;
      push (@reports, $annotator_subset_report) ;
    }
  }
  # sort by alpha value
  @reports = sort {substr ($a, 0, 5) <=> substr($b, 0, 5)} (@reports) ; 
  print "\nReliability for subsets of judges\n\n" ;
  print "Alpha D-obs D-exp N    Raters\n" ;
  foreach my $report (@reports) {print "$report\n"}

}

### Takes an array of size n and returns a two-dimensional array of
### 2^n - 1 rows, consisting of all non-empty subsets of the original
### array.

sub find_all_subsets {
  if (1 == scalar (@_)) {return [@_]}
  else {
    my @all_subsets = () ;
    my $last_item = pop (@_) ;
    my @first_subsets = find_all_subsets (@_) ;
    foreach my $subset (@first_subsets) {
      push (@all_subsets, $subset) ;
      my @ext_subset = @{$subset} ;
      push (@ext_subset, $last_item) ;
      push (@all_subsets, [@ext_subset]) ;
    }
    push (@all_subsets, [$last_item]) ;
    return (@all_subsets) ;
  }
}


### Takes an array of annotator indices and returns a line of text
### consisting of alpha value, observed disagreement, expected
### disagreement, number of item on which these values were
### calculated, and the annotator id's of the indices in the array.

sub generate_subset_report {
  my @restricted_scores = restrict_scores_to (@_) ;
  my $annotator_subset_report = "" ;
  if (0 == scalar (@restricted_scores)) {
    $annotator_subset_report = " -No items in common-  " ;
  } else {
    (my $num_items , my $expected_disagreement , my $observed_disagreement , my $alpha) = 
      calculate_alpha (@restricted_scores) ;
    foreach my $x ($alpha , $observed_disagreement  , $expected_disagreement) {
      if ("undef" eq $x) {$annotator_subset_report .= "$x "}
      elsif (0 <= $x) {$annotator_subset_report .= sprintf ("%.3f" , $x) . " "}
      elsif (0 > $x) {$annotator_subset_report .= sprintf ("%.2f" , $x) . " "}
    }
    $annotator_subset_report .= sprintf ("%4s" , $num_items) . " " ;
  }
  foreach my $x (@_) {
    $annotator_subset_report .= "\u$annotators[$x] " ;
  }
  return $annotator_subset_report ;
}


### Takes an array of annotator indices and returns a matrix
### consisting of the items rated by all of these annotators, with all
### the scores given by these annotators.

sub restrict_scores_to {
  my @restricted_scores = () ;
  foreach my $item (0 .. @all_scores - 1) {
    my @item_ratings = @{$all_scores[$item]}[@_] ;
    if (valid_scores (@item_ratings)) {
      push (@restricted_scores, [@item_ratings]) ;
    }
  }
  return (@restricted_scores) ;
}


### Confidence intervals for all possible subgroups of raters.
### CAUTION: THIS GROWS EXPONENTIALLY WITH THE NUMBER OF RATERS. For
### each group of raters, a distribution of alpha is simulated through
### bootstrapping, and key points in the distribution are
### reported. Results are sorted by the median of the distribution,
### from the least agreeing subset to the most agreeing one.

sub print_confidence_intervals {
  my @annotator_subsets ;
  if ($subsets) {
    @annotator_subsets = find_all_subsets (0 .. @annotators - 1) ;
  } else {
    @annotator_subsets = ([(0 .. @annotators - 1)]) ;
  }
  my @reports = () ;

  foreach my $subset (@annotator_subsets) {
    if (2 <= scalar (@{$subset})) {
      my $annotator_initials = annotator_initials (@{$subset}) ;
      my $confidence_intervals = confidence_intervals (@{$subset}) ;
      push (@reports, $confidence_intervals . $annotator_initials) ;
    }
  }
  # sort by median alpha value
  @reports = sort {substr ($a, 30, 5) <=> substr ($b, 30, 5)} (@reports) ;
  print "\nConfidence intervals for Alpha (bootstrapping, $num_samples resamples)\n\n" ;
  print "  0   0.005 0.01  0.025 0.05   0.5  0.95  0.975 0.99  0.995   1\n" ;
  foreach my $report (@reports) {print "$report\n"}

}

### Get the initials of annotator id's from an array of annotator
### indices, to include in an abbreviated report.

sub annotator_initials {
  my $annotator_initials = "" ;
  foreach my $annotator (@_) 
    {$annotator_initials .= substr ($annotators[$annotator], 0, 1)}
  return ($annotator_initials) ;
}


### Simulate a distribution of alpha through bootstrapping for a a
### group of raters, and report key points in the distribution.

sub confidence_intervals {
  my @restricted_scores = restrict_scores_to (@_) ;
  if (0 == scalar (@restricted_scores)) 
    {return "                     -- No items in common --                     "}
  my @simulation_results = () ;          # array of alpha values
  my $confidence_intervals = "" ;        # string of key alpha values
  foreach my $sample (0 .. $num_samples) {  # number of simulations
    my @fake_scores = fake_scores (@restricted_scores) ;    # simulated coding instance
    (my $num_items , my $expected_disagreement , my $observed_disagreement , my $alpha) = 
      calculate_alpha (@fake_scores) ;
    if ("undef" eq $alpha) {push (@simulation_results, $alpha)}
    elsif (0 <= $alpha) 
      {push (@simulation_results, sprintf ("%.3f" , $alpha))}
    elsif (0 > $alpha) 
      {push (@simulation_results, sprintf ("%.2f" , $alpha))}
  }
  @simulation_results = sort {$a <=> $b} (@simulation_results) ;
  foreach my $key_value
    (0 , 0.005 , 0.01 , 0.025 , 0.05 , 0.5 , 0.95 , 0.975 , 0.99 , 0.995 ,1) {
    my $sample_number = $key_value * $num_samples ;
    $confidence_intervals .= "$simulation_results[$sample_number] " ; 
  }
  return ($confidence_intervals) ;
}

### Simulates a coding instance for an array of annotators: first
### creates the actual coding table restricted to these annotators,
### and then randomly picks items from this table (with replacement)
### to create a simulated table of the same size.

sub fake_scores {
  my @fake_scores = () ;
  foreach my $item (0 .. @_ - 1) {
    my $fake_item = int (rand () * @_) ;
    push (@fake_scores, $_[$fake_item]) ;
  }
  return (@fake_scores) ;
}


### Takes a two-dimensional array of scores, with each row
### representing the scores of a single item, and returns the number
### of items, expected disagreement, observed disagreement, and
### alpha. It is assumed that all scores are valid and that each item
### has the same number of scores -- it is the responsibility of the
### function that calls calculate_alpha to pass a valid array.

sub calculate_alpha {
  my @all_ratings = () ;              # array of all the individual scores
  my @item_disagreement = () ;        # disagreement values for each item
  foreach my $item (0 .. @_ - 1) {
    my @item_ratings = @{$_[$item]} ; # individual scores for the item
    push (@all_ratings, @item_ratings) ;
    my $item_disagreement = disagreement (@item_ratings) ;
    push (@item_disagreement, $item_disagreement) ;
  }
  my $num_items = scalar (@item_disagreement) ;
  my $expected_disagreement = disagreement (@all_ratings) ;
  my $observed_disagreement = mean (@item_disagreement) ;
  my $alpha ;
  if (0 < $expected_disagreement) 
    {$alpha = 1 - $observed_disagreement / $expected_disagreement}
  else {$alpha = "undef"}
  return ($num_items , $expected_disagreement , $observed_disagreement , $alpha) ;
}

### Disagreement on a set of scores. 

sub disagreement {
  my $disagreement = 0;
  my %aggregate = () ;
  foreach my $item (@_) {$aggregate{$item}++}
  foreach my $cat_a (keys %aggregate) {
    foreach my $cat_b (keys %aggregate) {
      if ($cat_a != $cat_b) {$disagreement += $aggregate{$cat_a} * $aggregate{$cat_b} * &$distance_metric ($cat_a , $cat_b)}
    }
  }
  $disagreement /= @_ * (@_ - 1) ;
  return ($disagreement) ;
}


### Checks whether all members of an array are valid scores, returns 0
### or 1. Valid scores are numbers.

sub valid_scores {
  my $valid_scores = 1 ;
  foreach my $score (@_) {
    if (0 == $score and "0" ne $score) {$valid_scores = 0}
  }
  return $valid_scores ;
}

############################################################
### Read the data file into two arrays:
### @annotators holds the annotator id's
### @all_scores holds all the ratings (two-dimensional)

sub read_data {

  open (DATA, "$_[0]") ;
  @all_scores = ( ) ;

  # First line is annotator identifiers, separated by tabs

  my $header = <DATA> ;
  $header =~ s/\r//g ;
  chomp $header ;
  @annotators = split (/\t/ , $header) ;

  # Subsequent lines are scores -- one line per item, with individual
  # scores separated by tabs. Number of fields must match number of
  # annotators.

  while (<DATA>) {
    s/\r//g ;
    chomp ;
    my @item_scores = split (/\t/ , $_) ;
    if ($#annotators != $#item_scores) 
      {die "Mismatch in the number of judgments"}
    push (@all_scores , [@item_scores]) ;
  }
  close (DATA) ;
}

############################################################
### General statistical functions

sub mean { # mean of values in an array
  my $sum = 0 ;
  foreach my $x (@_) {
    $sum += $x ;
  }
  return $sum/@_ ;
}

sub sum_squares { # sum of square differences from the mean
  my $mean = mean (@_) ;
  my $sum_squares = 0 ;
  foreach my $x (@_) {
    $sum_squares += ($x - $mean) ** 2 ;
  }
  return $sum_squares ;
}

sub variance { # variance of values in an array
  my $sum_squares = sum_squares (@_) ;
  my $deg_freedom = @_ - 1 ;
  return $sum_squares/$deg_freedom ;
}

sub median { # median of values in an array
  my @sorted = sort {$a <=> $b} (@_) ;
  if (1 == @sorted % 2) # Odd number of elements
    {return $sorted[($#sorted)/2]}
  else                   # Even number of elements
    {return ($sorted[($#sorted-1)/2]+$sorted[($#sorted+1)/2]) / 2}
}

sub histogram { # Counts of elements in an array
  my %histogram = () ;
  foreach my $value (@_) {$histogram{$value}++}
  return (%histogram) ;
}

