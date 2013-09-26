package Device::PCA9685::PWMGenerator;

# PODNAME: Device::PCA9685::PWMGenerator
# ABSTRACT: I2C interface to PWM Generator on PCA9685 using Device::SMBus
# COPYRIGHT
# VERSION

# Dependencies
use 5.010;
use Moose;
use POSIX;

use Time::HiRes qw(usleep);

extends 'Device::SMBus';

use constant {
  MODE1              => 0x00,

  SUBADR1            => 0x02,
  SUBADR2            => 0x03,
  SUBADR3            => 0x04,

  PRESCALE           => 0xFE,

  LED0_ON_L          => 0x06,
  LED0_ON_H          => 0x07,
  LED0_OFF_L         => 0x08,
  LED0_OFF_H         => 0x09,

  ALLLED_ON_L        => 0xFA,
  ALLLED_ON_H        => 0xFB,
  ALLLED_OFF_L       => 0xFC,
  ALLLED_OFF_H       => 0xFD,
};

=attr I2CDeviceAddress

Containd the I2CDevice Address for the bus on which your PWM Generator is connected. It would look like 0x40. Default value is 0x40, If you have not set any of the six jumpers on the PCA9685, this should be the correct address and you will not have to modify this value in most cases.

=cut

has '+I2CDeviceAddress' => (
    is      => 'ro',
    default => 0x40,
);

=attr Frequency

Frequency of the PWM Pulse in Hz

=cut

has frequency => (
    is       => 'rw',
    required => 1,
    trigger  => \&_frequencySet,
);

has debug => (
    is      => 'ro',
    default => 1,
);

sub _frequencySet {
    my ( $self, $newFrequency, $oldFrequency ) = @_;

    # PCA9685 allows you to set the frequency using a register it calls PRESCALE
    say "Making PCA9685 go to sleep" if $self->debug;
    my $oldMode = $self->readByteData( MODE1 );
    my $newMode = ( $oldMode & 0x7f ) | 0x10; #set sleep bit while preserving other bits and ensuring that restart bit is set to 0 when writing to register
    $self->writeByteData( MODE1, $newMode );

    # Calculate Prescale from Frequency. Clock is 25 MHz on PCA8695
    my $prescale = floor( ( 25000000 / ( 4096 * $newFrequency ) ) + 0.5 ) - 1;
    say "Setting frequency to $newFrequency Hz. Calcualting prescale value \nprescale=round( 25000000/(4096 * frequency)) - 1 \nfrom frequency as $prescale(PCA9685 clock is at 25MHz or 25000000 Hz)" if $self->debug;
    if($prescale >= 0x03){
        $self->writeByteData( PRESCALE, $prescale );
    }else{
        die "Bad frequency value. Can't set prescale less than 3. reduce your frequency value";
    }
    $self->writeByteData( MODE1, $oldMode );
    usleep(5000);
    $self->writeByteData( MODE1, $oldMode | 0x80 ); # set extclk bit
}

=method enable

    $self->enable()

This function is just a placeholder. It is not required to call this function for this particular chipset

=cut

sub enable {
    my ( $self ) = @_;
    say "Setting up PCA9685" if $self->debug;
    $self->writeByteData( MODE1,0b00000000 );
}

=method setPWM

    $self->setPWM($channel,$pulseOnPoint,$pulseOffPoint)
    The PCA9685 offers a 12 bit resolution which means across a duty cycle you may set and unset the PWM at 4096 different point. 
    Range of values for $pulseOnPoint and $pulseOffPoint is 0 to 4095
    Range of values of $channel is 0 to 15

=cut

sub setChannelPWM {
    my ( $self, $channel, $on, $off ) = @_;

    say "Setting Channel $channel PWM on at $on step, off at $off step in 0 to 4095 steps at " . $self->frequency . "Hz" if $self->debug;
    $self->writeByteData( LED0_ON_L + ( 4 * $channel ), $on & 0xff );
    $self->writeByteData( LED0_ON_H + ( 4 * $channel ), $on >> 8 );

    $self->writeByteData( LED0_OFF_L + ( 4 * $channel ), $off & 0xff );
    $self->writeByteData( LED0_OFF_H + ( 4 * $channel ), $off >> 8 );
}

1;
