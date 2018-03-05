#!/usr/bin/perl
use strict;
use User::pwent;
my ($user,$host,$line);

$host = `hostname`;
chomp($host);

if ($ARGV[0] ne "-noheader"){
        print "hostname,user,uid,gecos,shell,home,pgrp,groups,login,rlogin,";
        print "loginretries,account_locked,minage,maxage,minlen,time_last_login,";
        print "time_last_unsuccessful_login,host_last_login,host_last_unsuccessful_login,";
        print "unsuccussful_login_count,date_pw_change,is_password_set\n";
}

while ($user = getpwent()){
        my $userid = $user->name;
        print "$host,", $user->name, ",", $user->uid, ",", $user->gecos, ","; 
        print $user->shell, ",", $user->dir, ",";

        my ($pgrp,$groups,$login,$rlogin,$loginretries,$account_locked,$minage);
        my ($maxage,$minlen,$time_last_login,$time_last_unsuccessful_login);
        my ($host_last_login,$host_last_unsuccessful_login,$unsuccessful_login_count);
        my ($date_pw_change,$pw_set);

        my @lsuser = `lsuser -f $userid`;
        foreach $line (@lsuser){
                chomp($line);
                if ($line =~ /^\spgrp=(.*)$/) {$pgrp = $1;}
                if ($line =~ /^\sgroups=(.*)$/) {($groups = $1) =~ s/,/:/g;}
                if ($line =~ /^\slogin=(.*)$/) {$login = $1;}
                if ($line =~ /^\srlogin=(.*)$/) {$rlogin = $1;}
                if ($line =~ /^\sloginretries=(.*)$/) {$loginretries = $1;}
                if ($line =~ /^\saccount_locked=(.*)$/) {$account_locked = $1;}
                if ($line =~ /^\sminage=(.*)$/) {$minage = $1;}
                if ($line =~ /^\smaxage=(.*)$/) {$maxage = $1;}
                if ($line =~ /^\sminlen=(.*)$/) {$minlen = $1;}
                if ($line =~ /^\stime_last_login=(.*)$/) {$time_last_login = &converttime($1);}
                if ($line =~ /^\stime_last_unsuccessful_login=(.*)$/) {$time_last_unsuccessful_login = converttime($1);}
                if ($line =~ /^\shost_last_login=(.*)$/) {$host_last_login = $1;}
                if ($line =~ /^\shost_last_unsuccessful_login=(.*)$/) {$host_last_unsuccessful_login = $1;}
                if ($line =~ /^\sunsuccessful_login_count=(.*)$/) {$unsuccessful_login_count = $1;}
        }       
        
        $line = `usrck -bl $userid 2>&1 | awk '{print \$2}`;
        chomp($line);
        if ($line){
                if (substr($line, 12, 1) eq "1"){
                        $pw_set = "false";
                }else{
                        $pw_set = "true";
                }
        }else{
                $pw_set = "true";
        }

        $line = `lssec -f /etc/security/passwd -s $userid -a lastupdate | awk -F= '{print \$2}'`;
        chomp($line);
        if ($line){
                $date_pw_change = &converttime($line);
        }

        print "$pgrp,$groups,$login,$rlogin,$loginretries,$account_locked,$minage,";
        print "$maxage,$minlen,$time_last_login,$time_last_unsuccessful_login,";
        print "$host_last_login,$host_last_unsuccessful_login,$unsuccessful_login_count,";
        print "$date_pw_change,$pw_set\n";
}

sub converttime{
        my $time = $_[0];
        my ($day,$month,$year) = (localtime($time))[3,4,5];
        $year += 1900; 
        $month += 1; 
        "$month/$day/$year";
}
