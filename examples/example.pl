use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";

use Device::PCA9685::PWMGenerator;

my $dev = Device::PCA9685::PWMGenerator->new(
    I2CBusDevicePath => '/dev/i2c-1',
    debug            => 1,
    frequency        => 40,
);
$dev->enable();
$dev->frequency(400);
$dev->setChannelPWM(4,0,10);
sleep(1);
$dev->setChannelPWM(4,0,2048);
sleep(1);
$dev->setChannelPWM(4,0,2748);
sleep(1);
$dev->setChannelPWM(4,0,10);

