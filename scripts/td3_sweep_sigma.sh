#!/bin/bash
#
# Run a sweep of TD3 with different exploration noise levels.

run ()
{
    WANDB_DIR=/tmp/nanorl/ MUJOCO_GL=egl XLA_PYTHON_CLIENT_PREALLOCATE=false CUDA_VISIBLE_DEVICES=$(($1%8)) MUJOCO_EGL_DEVICE_ID=$(($1%8)) python nanorl/infra/run_control_suite.py \
        td3 \
        --root-dir /tmp/nanorl/runs/ \
        --warmstart-steps 5000 \
        --max-steps 250000 \
        --discount 0.99 \
        --agent-config.critic-dropout-rate 0.01 \
        --agent-config.critic-layer-norm \
        --agent-config.hidden-dims 256 256 256 \
        --agent-config.sigma $2 \
        --agent-config.target-sigma $(echo "2 * $2" | bc -l) \
        --domain-name cartpole \
        --task-name swingup
}
export -f run

parallel --delay 20 --linebuffer -j 16 run {%} {} ::: 0.001 0.01 0.05 0.1 0.2 0.5
