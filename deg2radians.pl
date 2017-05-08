#!/usr/local/bin/perl

# The perl sin and cos functions take arguments in the form of radians (rather than degrees). 
# 180 degrees = Pi radians so both radians and degrees are measures of angle. 
# The asin, acos and atan functions return radians and are the inverse functions of sin, cos and tan respectively

my $pi = 4*atan2(1,1);		# gives the value of pi

sub deg_to_rad { ($_[0]/180) * $pi }
sub rad_to_deg { ($_[0]/$pi) * 180 }

sub asin { atan2($_[0], sqrt(1 - $_[0] * $_[0])) }
sub acos { atan2( sqrt(1 - $_[0] * $_[0]), $_[0] ) }
sub tan  { sin($_[0]) / cos($_[0])  }
sub atan { atan2($_[0],1) };

print 'sin 30 degrees is ', sin(deg_to_rad(30)), "\n";
print 'inverse sin 0.5 is ', rad_to_deg(asin(0.5)), ' degrees';