use strict;
use warnings;
package Device::PCA9685;

# PODNAME: Device::PCA9685
# ABSTRACT: I2C interface to PCA9685 16 channel 12 bit PWM Generator 
# COPYRIGHT
# VERSION

# Dependencies
use 5.010;
use Moose;
use POSIX;

use Device::PWMGenerator::PCA9685;

=attr I2CBusDevicePath

this is the device file path for your I2CBus that the PCA9685 is connected on e.g. /dev/i2c-1
This must be provided during object creation.

=cut

has 'I2CBusDevicePath' => (
    is => 'ro',
);

=attr PWMGenerator 

    $self->PWMGenerator->enable();
    $self->PWMGenerator->setChannelPWM($channel,$pulseOnPoint,$pulseOffPoint);

The PCA9685 offers a 12 bit resolution which means across a duty cycle you may set and unset the PWM at 4096 different point. 
Range of values for $pulseOnPoint and $pulseOffPoint is 0 to 4095
Range of values of $channel is 0 to 15

This is a object of L<Device::PWMGenerator::PCA9685>

=cut

has PWMGenerator => (
    is => 'ro',
    isa => 'Device::PWMGenerator::PCA9685',
    lazy_build => 1,
);

sub _build_PWMGenerator {
    my ($self) = @_;
    my $obj = Device::PWMGenerator::PCA9685->new(
        I2CBusDevicePath => $self->I2CBusDevicePath,
        frequency        => 400,
        debug            => 0,
    );
    return $obj;
}

1;

__END__

=begin wikidoc

= SYNOPSIS

    use Device::PWMGenerator::PCA9685;

    my $dev = Device::PWMGenerator::PCA9685->new(
        I2CBusDevicePath => '/dev/i2c-1', # this would be '//dev/i2c-dev-0 for Model A Pi
        debug            => 1,
        frequency        => 400, #Hz
    );
    $dev->enable();
    $dev->setChannelPWM(4,0,$dutycycle); # Duty cycle values between 0 and 4096 channel 4

= DESCRIPTION

This module provides a Object oriented interface to Adafruit 16 channel 12 bit
PWM Generator(PCA9685). Before you use this module make sure you follow install
Prerequisites for [Device::SMBus]

=end wikidoc

=cut
