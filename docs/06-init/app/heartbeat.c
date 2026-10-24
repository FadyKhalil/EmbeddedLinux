/*
 * heartbeat - the demo daemon of the Embedded Linux course.
 *
 * Prints a numbered, timestamped heartbeat every few seconds and exits
 * cleanly when it receives SIGTERM or SIGINT. That makes it easy to see an
 * init system start a service at boot and stop it at shutdown.
 *
 * Usage: heartbeat [-i seconds] [-p pidfile]
 *   -i seconds   interval between beats (default 4)
 *   -p pidfile   write the process ID to this file (removed on exit)
 */
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

static volatile sig_atomic_t running = 1;

static void on_stop_signal(int sig)
{
	(void)sig;
	running = 0;
}

static void usage(const char *prog)
{
	fprintf(stderr, "Usage: %s [-i seconds] [-p pidfile]\n", prog);
}

int main(int argc, char *argv[])
{
	unsigned int interval = 4;
	const char *pidfile = NULL;
	unsigned long beats = 0;
	struct sigaction sa;
	int opt;

	while ((opt = getopt(argc, argv, "i:p:h")) != -1) {
		switch (opt) {
		case 'i':
			interval = (unsigned int)strtoul(optarg, NULL, 10);
			if (interval == 0)
				interval = 1;
			break;
		case 'p':
			pidfile = optarg;
			break;
		case 'h':
			usage(argv[0]);
			return 0;
		default:
			usage(argv[0]);
			return 1;
		}
	}

	/* no SA_RESTART: a stop signal also wakes us up from sleep() */
	memset(&sa, 0, sizeof(sa));
	sa.sa_handler = on_stop_signal;
	sigaction(SIGTERM, &sa, NULL);
	sigaction(SIGINT, &sa, NULL);

	if (pidfile) {
		FILE *f = fopen(pidfile, "w");
		if (f) {
			fprintf(f, "%d\n", (int)getpid());
			fclose(f);
		}
	}

	/* line-buffered, so every beat shows up immediately on a console or in the journal */
	setvbuf(stdout, NULL, _IOLBF, 0);
	printf("heartbeat: started (pid %d), one beat every %u s\n", (int)getpid(), interval);

	while (running) {
		char stamp[16];
		time_t now = time(NULL);

		strftime(stamp, sizeof(stamp), "%H:%M:%S", localtime(&now));
		printf("heartbeat: beat #%lu at %s\n", ++beats, stamp);
		sleep(interval);
	}

	printf("heartbeat: stop signal received, exiting cleanly after %lu beats\n", beats);
	if (pidfile)
		unlink(pidfile);
	return 0;
}
