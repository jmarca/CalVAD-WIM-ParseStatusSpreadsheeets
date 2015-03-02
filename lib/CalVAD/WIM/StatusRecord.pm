# ABSTRACT: turns baubles into trinkets
use strict;
use warnings;
package CalVAD::WIM::StatusRecord;

use namespace::autoclean;
use Moose;


has 'site_no' => (
    is  => 'ro',
    isa => 'Int',
    required => 1,
);
has 'class_status' => (
    is  => 'ro',
    isa => 'Str',
);
has 'weight_status' => (
    is  => 'ro',
    isa => 'Str',
);
has 'class_notes' => (
    is  => 'ro',
    isa => 'Maybe[Str]',
);
has 'weight_notes' => (
    is  => 'ro',
    isa => 'Maybe[Str]',
);
has 'internal_class_notes' => (
    is  => 'ro',
    isa => 'Maybe[Str]',
);
has 'internal_weight_notes' => (
    is  => 'ro',
    isa => 'Maybe[Str]',
);
has 'parser_decisions_notes' => (
    is  => 'ro',
    isa => 'Maybe[Str]',
);
has 'ts' => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
);


my $siteinfo = [
    { 'site' => 1,   'site_name' => 'LODI' },
    { 'site' => 2,   'site_name' => 'REDDING' },
    { 'site' => 3,   'site_name' => 'ANTELOPE EB' },
    { 'site' => 4,   'site_name' => 'ANTELOPE WB' },
    { 'site' => 5,   'site_name' => 'INDIO' },
    { 'site' => 7,   'site_name' => 'SANTA NELLA' },
    { 'site' => 8,   'site_name' => 'CONEJO SB' },
    { 'site' => 9,   'site_name' => 'CONEJO NB' },
    { 'site' => 10,  'site_name' => 'FRESNO' },
    { 'site' => 12,  'site_name' => 'VAN NUYS SB' },
    { 'site' => 13,  'site_name' => 'VAN NUYS NB' },
    { 'site' => 14,  'site_name' => 'SAN MARCOS' },
    { 'site' => 15,  'site_name' => 'IRVINE SB' },
    { 'site' => 16,  'site_name' => 'IRVINE NB' },
    { 'site' => 17,  'site_name' => 'HAYWARD SB' },
    { 'site' => 18,  'site_name' => 'HAYWARD NB' },
    { 'site' => 20,  'site_name' => 'LOLETA' },
    { 'site' => 22,  'site_name' => 'JEFFREY' },
    { 'site' => 23,  'site_name' => 'EL CENTRO' },
    { 'site' => 24,  'site_name' => 'NAPA' },
    { 'site' => 25,  'site_name' => 'NEWBERRY' },
    { 'site' => 26,  'site_name' => 'CAMERON' },
    { 'site' => 27,  'site_name' => 'TRACY' },
    { 'site' => 28,  'site_name' => 'MACDOEL' },
    { 'site' => 30,  'site_name' => 'MT. SHASTA' },
    { 'site' => 31,  'site_name' => 'WOODSIDE SB' },
    { 'site' => 32,  'site_name' => 'WOODSIDE NB' },
    { 'site' => 33,  'site_name' => 'BURLINGAME SB' },
    { 'site' => 34,  'site_name' => 'BURLINGAME NB' },
    { 'site' => 35,  'site_name' => 'PACHECO' },
    { 'site' => 36,  'site_name' => 'LOS BANOS' },
    { 'site' => 37,  'site_name' => 'ELSINORE SB' },
    { 'site' => 38,  'site_name' => 'ELSINORE NB' },
    { 'site' => 39,  'site_name' => 'REDLANDS' },
    { 'site' => 40,  'site_name' => 'COACHELLA' },
    { 'site' => 41,  'site_name' => 'VACAVILLE EB' },
    { 'site' => 42,  'site_name' => 'VACAVILLE WB' },
    { 'site' => 43,  'site_name' => 'CHOLAME' },
    { 'site' => 44,  'site_name' => 'BANTA' },
    { 'site' => 46,  'site_name' => 'GALT' },
    { 'site' => 47,  'site_name' => 'CASTAIC SB' },
    { 'site' => 48,  'site_name' => 'CASTAIC NB' },
    { 'site' => 49,  'site_name' => 'AUBURN' },
    { 'site' => 50,  'site_name' => 'ELMIRA' },
    { 'site' => 51,  'site_name' => 'WESTSAC EB' },
    { 'site' => 52,  'site_name' => 'WESTSAC WB' },
    { 'site' => 55,  'site_name' => 'DUBLIN SB' },
    { 'site' => 56,  'site_name' => 'DUBLIN NB' },
    { 'site' => 57,  'site_name' => 'PINOLE EB' },
    { 'site' => 58,  'site_name' => 'PINOLE WB' },
    { 'site' => 59,  'site_name' => 'LA 710 SB' },
    { 'site' => 60,  'site_name' => 'LA 710 NB' },
    { 'site' => 61,  'site_name' => 'PERALTA EB' },
    { 'site' => 62,  'site_name' => 'PERALTA WB' },
    { 'site' => 63,  'site_name' => 'MURRIETA' },
    { 'site' => 64,  'site_name' => 'FOSTER CITY' },
    { 'site' => 65,  'site_name' => 'PIRU' },
    { 'site' => 66,  'site_name' => 'CALICO' },
    { 'site' => 67,  'site_name' => 'DEVORE' },
    { 'site' => 68,  'site_name' => 'GILROY' },
    { 'site' => 69,  'site_name' => 'FONTANA SB' },
    { 'site' => 70,  'site_name' => 'FONTANA NB' },
    { 'site' => 71,  'site_name' => 'HINKLEY' },
    { 'site' => 72,  'site_name' => 'BOWMAN' },
    { 'site' => 73,  'site_name' => 'STOCKDALE' },
    { 'site' => 74,  'site_name' => 'BAKERSFIELD' },
    { 'site' => 75,  'site_name' => 'KEYES' },
    { 'site' => 76,  'site_name' => 'TEMPLETON' },
    { 'site' => 77,  'site_name' => 'COLTON EB ' },
    { 'site' => 78,  'site_name' => 'COLTON WB' },
    { 'site' => 79,  'site_name' => 'ARTESIA EB' },
    { 'site' => 80,  'site_name' => 'ARTESIA WB' },
    { 'site' => 81,  'site_name' => 'POSITAS' },
    { 'site' => 82,  'site_name' => 'GLENDORA EB' },
    { 'site' => 83,  'site_name' => 'GLENDORA WB' },
    { 'site' => 84,  'site_name' => 'LEUCADIA SB' },
    { 'site' => 85,  'site_name' => 'LEUCADIA NB' },
    { 'site' => 86,  'site_name' => 'UKIAH' },
    { 'site' => 87,  'site_name' => 'BALBOA SB' },
    { 'site' => 88,  'site_name' => 'BALBOA NB' },
    { 'site' => 89,  'site_name' => 'DEKEMA SB' },
    { 'site' => 90,  'site_name' => 'DEKEMA NB' },
    { 'site' => 91,  'site_name' => 'POGGI SB' },
    { 'site' => 92,  'site_name' => 'POGGI NB' },
    { 'site' => 93,  'site_name' => 'LAKEPORT' },
    { 'site' => 94,  'site_name' => 'GREENFIELD' },
    { 'site' => 95,  'site_name' => 'ONTARIO EB' },
    { 'site' => 96,  'site_name' => 'ONTARIO WB' },
    { 'site' => 97,  'site_name' => 'CHINO' },
    { 'site' => 98,  'site_name' => 'PRADO' },
    { 'site' => 99,  'site_name' => 'TULLOCH' },
    { 'site' => 100, 'site_name' => 'MIRAMAR SB' },
    { 'site' => 101, 'site_name' => 'MIRAMAR NB' },
    { 'site' => 103, 'site_name' => 'ORANGE SB' },
    { 'site' => 104, 'site_name' => 'ORANGE NB' },
    { 'site' => 105, 'site_name' => 'ELKHORN' },
    { 'site' => 106, 'site_name' => 'ELVERTA' },
    { 'site' => 107, 'site_name' => 'CHICO' },
    { 'site' => 108, 'site_name' => 'WILLOWS' },
    { 'site' => 109, 'site_name' => 'INYO' },
    { 'site' => 110, 'site_name' => 'HONEY LAKE' },
    { 'site' => 111, 'site_name' => 'SAIGON SB' },
    { 'site' => 112, 'site_name' => 'SAIGON NB' },
    { 'site' => 113, 'site_name' => 'CARBONA 2' },
    { 'site' => 114, 'site_name' => 'ARVIN' },
    { 'site' => 115, 'site_name' => 'PORTERVILLE' },
    { 'site' => 116, 'site_name' => 'LONG BEACH PORT' },
    { 'site' => 804, 'site_name' => 'SANTA NELLA SB' },
    { 'site' => 812, 'site_name' => 'COTTONWOOD NB' },
    { 'site' => 814, 'site_name' => 'SANTA NELLA NB' },
    { 'site' => 828, 'site_name' => 'BLACKROCK WB' },
    { 'site' => 834, 'site_name' => 'DONNER PASS' },
    { 'site' => 844, 'site_name' => 'CALEXICO NB' },
    { 'site' => 846, 'site_name' => 'COTTONWOOD SB' },
    { 'site' => 848, 'site_name' => 'OTAY MESA WB' },
    { 'site' => 854, 'site_name' => 'RAINBOW SB' },
    { 'site' => 856, 'site_name' => 'MISSION GRADE NB' },
];

my $lookup = {};
for (@{$siteinfo}){
    my $namekey = $_->{'site_name'};
    my $siteno = $_->{'site'};
    $lookup->{$namekey} = $siteno;
}

sub get_site_from_name {
    my $self = shift;
    my $name = shift;
    return $lookup->{$name};
}

__PACKAGE__->meta->make_immutable;
1;
