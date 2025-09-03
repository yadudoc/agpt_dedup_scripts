from parsl.config import Config

# PBSPro is the right provider for Polaris:
from parsl.providers import PBSProProvider
# The high throughput executor is for scaling to HPC systems:
from parsl.executors import HighThroughputExecutor
# Use the MPI launcher to create one worker per GPU
from parsl.launchers import MpiExecLauncher
# For checkpointing:
from parsl.utils import get_all_checkpoints

# Adjust your user-specific options here:
from parsl.utils import get_all_checkpoints



user_opts = {
    "worker_init":      f"source /home/yadunand/setup_agpt_env_3.sh", # load the environment where parsl is installed
    "scheduler_options":"#PBS -l filesystems=home:eagle" , # specify any PBS options here, like filesystems
    "account":          "argonne_tpc",
    "queue":            "debug-scaling",
    "walltime":         "1:00:00",
}


config = Config(
        executors=[
            HighThroughputExecutor(
                label="htex",
                heartbeat_period=15,
                heartbeat_threshold=120,
                worker_debug=True,
                max_workers_per_node=4,
                # This give optimal binding of threads to GPUs on a Polaris node
                provider=PBSProProvider(
                    launcher=MpiExecLauncher(bind_cmd="--cpu-bind", overrides="--depth=64 --ppn 1"),
                    account=user_opts["account"],
                    queue=user_opts["queue"],
                    select_options="ngpus=4",
                    # PBS directives (header lines)
                    scheduler_options=user_opts["scheduler_options"],
                    # Command to be run before starting a worker, such as:
                    worker_init=user_opts["worker_init"],
                    # number of compute nodes allocated for each block
                    nodes_per_block=2,
                    init_blocks=1,
                    min_blocks=0,
                    max_blocks=1, # Can increase more to have more parallel jobs
                    walltime=user_opts["walltime"]
                ),
            ),
        ],
        checkpoint_mode='task_exit',
        checkpoint_files=get_all_checkpoints(),
        retries=2,
        app_cache=True,
)
