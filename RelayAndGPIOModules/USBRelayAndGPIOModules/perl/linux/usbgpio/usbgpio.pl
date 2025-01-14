#!/usr/bin/perl -w
use strict;
# Numato Lab - http://numato.com
# This Perl sample script opens the port and sends two commands to the device. These commands 
# will turn on GPIO0, wait for 2 seconds and then turn off.
# Please follow the steps below to test the script.
#
# 1. Install Perl and then install Device::SerialPort perl modules from the following link
#    Device::SerialPort (For Linux) - http://search.cpan.org/dist/Device-SerialPort/SerialPort.pm
# 2. Attach the Relay Module to the PC and note the port identifier corresponding to the device
# 3. Update the line below that starts with "$portName =" with the port number for your device
# 4. Comment/uncomment lines below as necessary (see associated comments)
# 5. Run the script by entering the command "perl usbgpio.pl" at command line

use Device::SerialPort;
use Time::HiRes;

my $serPort = new Device::SerialPort("/dev/ttyACM0") || die "Could not open the port specified";

# Configure the port	   
$serPort->baudrate(19200);
$serPort->parity("none");
$serPort->databits(8);
$serPort->stopbits(1);
$serPort->handshake("none"); #Most important
$serPort->buffers(4096, 4096); 
$serPort->lookclear();
$serPort->are_match("\n"); # set up 'lookfor' to find EOL
$serPort->purge_all;
$serPort->write("\r"); # Initialize the prompt
$serPort->write_drain;

###########################################################################################
# Read and write subroutines
###########################################################################################	

sub readSerialLine() {
  my $gotit = "";
  until("" ne $gotit) { $gotit = $serPort->lookfor; Time::HiRes::usleep(50); }
  return $gotit;
}

sub sendCmd($) {
  $serPort->write("$_[0]\r");
  $serPort->write_drain;
  my $line = &readSerialLine();
  while(! ($line =~ m/>$_[0]/)) { $line = &readSerialLine(); }
}

sub readCmd($) { # Command that expects a response
  &sendCmd($_[0]);
  return &readSerialLine();
}

###########################################################################################
# Get version and id
###########################################################################################	

print "ver: " . &readCmd("ver") . "\n";
print "id: " . &readCmd("id get") . "\n";

###########################################################################################
# GPIO commands set/clear/read
###########################################################################################

&sendCmd("gpio set 0");
&sendCmd("gpio clear 0");
print "Value received " . &readCmd("gpio read 0") . "\n";
