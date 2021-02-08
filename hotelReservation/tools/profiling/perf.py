import logging
from subprocess import check_output, Popen


log = logging.getLogger(__name__)


def get_docker_compose_processes(file=None):
    compose_top_result = None
    if file is not None:
        with open(file) as compose_result_file:
            compose_top_result = compose_result_file.readlines()
    else:
        cmds = ['docker-compose', '-f', '../../docker-compose.yml', 'top']
        try:
            out = check_output(cmds)
        except Exception as e:
            log.error("docker-compose top command failed: %s" % e)
            return
        compose_top_result = out.decode().split('\n')

    if compose_top_result is None:
        return

    compose_top_result_in_group = []
    service_lines = []
    for line in compose_top_result:
        if line.strip() == '':
            if len(service_lines) == 0:
                continue
            compose_top_result_in_group.append(service_lines)
            service_lines = []
        else:
            service_lines.append(line)

    service_pids = {}
    for group in compose_top_result_in_group:
        service_name = group[0].strip()
        try:
            pid_pos = group[1].index('PID')
        except ValueError:
            raise ValueError("Invalid docker compose top result. PID error")
        pid_lines = [l for l in group[3:] if l[:pid_pos].strip() != '']
        pids = [int(l.split()[1]) for l in pid_lines]
        service_pids[service_name] = pids

    return service_pids or None


def get_flame_graph(pid=None, time=60, svg_file_name=None):
    """Create flame graph with perf."""

    if pid is None:
        pid_flag = '-a'
    else:
        pid_flag = '-p %d' % pid

    if svg_file_name is None:
        if pid is not None:
            svg_file_name = 'flame_graph%d.svg' % pid
        else:
            svg_file_name = 'flame_graph-all.svg'

    cmds = ['rm perf.data',
            'perf record -e cycles -F 99 -o perf.data %s -g -- sleep %d' \
                 % (pid_flag, time),
                 'perf script > perf.script_dat',
                 './third-part/FlameGraph/stackcollapse-perf.pl '
                 'perf.script_dat > ' \
                 'out.perf-folded',
                 'perl ./third-part/FlameGraph/flamegraph.pl out.perf-folded '
                 '> ' \
                 '%s'%(svg_file_name)]

    for cmd in cmds:
        try:
            output = check_output(cmd, shell=True)
            if len(output) > 0:
                log.info(output)
        except Exception as e:
            log.error(e)


def create_all_flame_graphs():
    pids = get_docker_compose_processes()
    if pids is None:
        log.error("No PIDs found")
        raise( ValueError("no docker composed services"))
    for service_name, pids in pids.items():
        
        for pid in pids:
            file_name = 'flame_graph-%s-pid_%d.svg' % (service_name, pid)
            log.info("Generating flame graph for %s pid=%d, save to file %s" %
                     (service_name, pid, file_name))
            get_flame_graph(pid, time=10, svg_file_name=file_name)
    get_flame_graph(pid=None, time=10, svg_file_name='flame_graph-all.svg')
