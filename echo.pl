use warnings; 
use strict;

use vars qw($VERSION %IRSSI);
use Irssi;

$VERSION = '0.1';
%IRSSI = (
    authors     => "ndob",
    contact     => "ndob",
    name        => "echo",
    description => 'Echo all messages across set of channels',
    url         => 'https://github.com/ndob/irssi-echo',
    license     => 'MIT',
);

my @channels = (
    {
        channel         => "#test",
        server_address  => "irc.server.com",
        prefix          => "irc",
    },
    {
        channel         => "#test2",
        server_address  => "irc.another.server.com",
        prefix          => "irc2",
    }
);

sub get_channel_data {
    my ($arg_channel, $arg_server_address) = @_;

    foreach my $idx (0..@channels-1) {

        my $channel = $channels[$idx]{channel};
        my $server_address = $channels[$idx]{server_address};

        if($arg_channel eq $channel && $arg_server_address eq $server_address) {
            return $channels[$idx];
        }
    }

    return undef;
}

sub pipe_msg {

    my ($source_server, $msg, $nick, $addr, $tgt) = @_;
    my $source_channel = get_channel_data($tgt, $source_server->{address});

    if(!$source_channel) {
        return;
    }

    my $source_prefix = $source_channel->{prefix};

    foreach my $idx (0..@channels-1) {

        my $channel = $channels[$idx]{channel};
        my $server_address = $channels[$idx]{server_address};

        foreach my $server (Irssi::servers()) {

            if($server->{address} eq $server_address && !($server->{address} eq $source_server->{address} && $channel eq $tgt)) {
                $server->command("MSG " . $channel . " " . $source_prefix . "<" . $nick . "> " . $msg);
            }
        }            
    }
}

Irssi::signal_add_first("message public", "pipe_msg");
