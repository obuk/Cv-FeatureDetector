# -*- mode: perl; coding: utf-8; tab-width: 4 -*-

use strict;
use warnings;
use Test::More qw(no_plan);
# use Test::More;
use Test::Exception;
BEGIN { use_ok('Cv', -nonfree) }
BEGIN { use_ok('Cv::Features2d', qw(:all)) }

my $verbose = Cv->hasGUI;

use Time::HiRes qw(gettimeofday);
my $image = chessboard();

sub chessboard {
	my $img = Cv->createMat(270, 270, CV_8UC3)
		->fill(cvScalarAll(127));
	for my $i (0 .. 7) {
		for my $j (0 .. 7) {
			my ($x, $y) = ($i * 30 + 15, $j * 30 + 15);
			$img->rectangle(
				[$x, $y], [$x + 30, $y + 30],
				cvScalarAll(($i + $j + 1) % 2? 255 : 0), -1,
				);
		}
	}
	$img;
}

my $font = Cv->InitFont(CV_FONT_NORMAL, (0.4) x 2, 0, 1, CV_AA);
if ($verbose) {
	Cv->namedWindow('Cv', 0);
}

for (
	SIFT(),
	SURF(500),
	FastFeatureDetector(10, 0),
	StarFeatureDetector(),
	) {
	my $detector = PyramidAdaptedFeatureDetector($_, 500);
	(my $name = "Pyramid+" . (split('::', ref $_))[-1]) =~ s/FeatureDetector//g;
	ok($detector, $name);
	my $oimage = $image->cvtColor(CV_BGR2GRAY)->cvtColor(CV_GRAY2BGR);
	my $t0 = gettimeofday();
	my $keypoints = $detector->detect($image);
	diag($name) unless @$keypoints;
	my $ti = sprintf("$name: %.1f(ms)", (gettimeofday() - $t0) * 1000);
	my ($x, $y) = (10, $image->height - 10);
	$oimage->drawKeypoints($keypoints, cvScalarAll(-1), 4);
	$oimage->putText($ti, [ $x-1, $y-1 ], $font, cvScalarAll(250));
	$oimage->putText($ti, [ $x+1, $y+1 ], $font, cvScalarAll(50));
	$oimage->putText($ti, [ $x+0, $y+0 ], $font, [100, 220, 220]);
	if ($verbose) {
		$oimage->show;
		Cv->waitKey(1000);
	}
}

# my $detector = FastFeatureDetector(10, 1);
my $detector = SURF(500);
isa_ok($detector, 'Cv::Features2d::Feature2D');
can_ok($detector, qw(detect detectAndCompute compute));

isa_ok($detector, 'Cv::Features2d::FeatureDetector');
can_ok($detector, qw(detect));

my $extractor = $detector;
isa_ok($extractor, 'Cv::Features2d::DescriptorExtractor');
can_ok($extractor, qw(compute));

my $detector2 = PyramidAdaptedFeatureDetector($detector, 500);
isa_ok($detector2, 'Cv::Features2d::FeatureDetector');
can_ok($detector2, qw(detect));

isa_ok($extractor, 'Cv::Features2d::DescriptorExtractor');
can_ok($extractor, qw(compute));
