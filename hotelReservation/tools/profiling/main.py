import logger
import perf
import argparse


def process_args():
    parser = argparse.ArgumentParser(description='DSB performance profoling tools.')
    parser.add_argument('command',
     help='''Specify the profiling command, valid command is "flamegraph, inst_and_cycle".
    flamegraph: Generate flame graphs for all uService processes as well as the
    system wide function call stack.
    inst_and_cycle: Record system scope CPU instructions and cycles for 30 seconds.
     '''

    )

    args = parser.parse_args()

    if args.command in ['flamegraph', 'inst_and_cycle']:
        return args.command
    else:
        parser.print_help()
        return


def command_handler(cmd):
    if cmd is None:
        return

    if cmd == 'flamegraph':
        perf.create_all_flame_graphs()
    elif cmd == 'inst_and_cycle':
        perf.get_system_cycles_intructions()


if __name__ == "__main__":
    logger.init()
       
    cmd = process_args()
    command_handler(cmd)