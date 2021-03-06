# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv', -nonfree) }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

for (
	# DescriptorExtractor
	# FREAK(),
	BriefDescriptorExtractor(),
	# Feature2D
	SIFT(),
	SURF(500),
	ORB(),
	BRISK(),
	) {
	my $extractor = OpponentColorDescriptorExtractor($_);
	isa_ok($extractor, 'Cv::Features2d::DescriptorExtractor');
	can_ok($extractor, qw(compute));
}
