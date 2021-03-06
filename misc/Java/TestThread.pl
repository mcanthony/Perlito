package Java::Thread {
    import => "java.lang.Thread"
};

my Java::Thread $thread1 = new Java::Thread(
    sub {
        for my $i (0..10) {
            print "thread 1\n";
            sleep (1);
        }
    }
);
my Java::Thread $thread2 = new Java::Thread(
    sub {
        for my $i (0..10) {
            print "thread 2\n";
            sleep (1);
        }
    }
);

$thread1->start();
$thread2->start();

