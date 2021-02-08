import logger
import perf
import argparse


def process_args():
    parser = argparse.ArgumentParser(description='DSB performance profoling tools.')
    parser.add_argument('command',
     help='''Specify the profiling command, valid command is "flamegraph".\n\n'
    'flamegraph: \tGenerate flame graphs for all uService processes as well as the '
    'system wide function call stack.'''
    )

    args = parser.parse_args()

    if args.command in ['flamegraph']:
        return args.command
    else:
        parser.print_help()
        return

def command_handler(cmd):
    if cmd is None:
        return

    if cmd == 'flamegraph':
        perf.create_all_flame_graphs()


if __name__ == "__main__":
    logger.init()
       
    cmd = process_args()
    command_handler(cmd)

    