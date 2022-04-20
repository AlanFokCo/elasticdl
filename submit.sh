#elasticdl train \
#  --image_name=elasticdl/elasticdl:1.0.0 \
#  --worker_image=registry.cn-beijing.aliyuncs.com/huozx/kubeai-dev-console:iris_estimator-1 \
#  --ps_image=registry.cn-beijing.aliyuncs.com/huozx/kubeai-dev-console:iris_estimator-1 \
#  --job_command="python -m model_zoo.iris.dnn_estimator" \
#  --master_resource_request="cpu=0.2,memory=1024Mi" \
#  --master_resource_limit="cpu=1,memory=2048Mi" \
#  --num_ps=1 \
#  --ps_resource_request="cpu=0.2,memory=1024Mi" \
#  --ps_resource_limit="cpu=1,memory=2048Mi" \
#  --num_workers=2 \
#  --worker_resource_request="cpu=0.3,memory=1024Mi" \
#  --worker_resource_limit="cpu=1,memory=2048Mi" \
#  --chief_resource_request="cpu=0.3,memory=1024Mi" \
#  --chief_resource_limit="cpu=1,memory=2048Mi" \
#  --num_evaluator=1 \
#  --evaluator_resource_request="cpu=0.3,memory=1024Mi" \
#  --evaluator_resource_limit="cpu=1,memory=2048Mi" \
#  --job_name=test-iris-estimator-1 \
#  --image_pull_policy=Always \
#  --distribution_strategy=ParameterServerStrategy

elasticdl train \
  --image_name=registry.cn-hongkong.aliyuncs.com/huozx/ubuntu:elasticdl-v1.0.0 \
  --worker_image=registry.cn-hongkong.aliyuncs.com/huozx/ubuntu:elasticdl-mnist_pytorch-2 \
  --job_command="python -m model_zoo.mnist.mnist_pytorch --batch_size 64 --num_epochs 50 --training_data=/mnist_png/training --validation_data=/mnist_png/testing" \
  --num_minibatches_per_task=2 \
  --num_workers=2 \
  --master_resource_request="cpu=0.2,memory=1024Mi" \
  --master_resource_limit="cpu=1,memory=2048Mi" \
  --worker_resource_request="cpu=0.3,memory=1024Mi" \
  --worker_resource_limit="cpu=1,memory=2048Mi" \
  --envs="USE_TORCH=true,HOROVOD_GLOO_TIMEOUT_SECONDS=60,PYTHONUNBUFFERED=true" \
  --job_name=test-mnist-allreduce-1 \
  --image_pull_policy=Always \
  --distribution_strategy=AllreduceStrategy