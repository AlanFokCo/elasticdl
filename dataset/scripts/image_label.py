#!/usr/bin/env python
# Copyright 2020 The ElasticDL Authors. All rights reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


import argparse
import logging
import os
import sys
import numpy as np

import recordio
import tensorflow as tf


def convert(x, y, args, subdir):
    """Convert pairs of image and label in NumPy arrays into a set of
    RecordIO files.
    """
    logger = logging.getLogger("image_label::convert")
    logger.setLevel("INFO")
    row = 0
    shard = 0
    w = None
    while row < x.shape[0] * args.fraction:
        if row % args.records_per_shard == 0:
            if w:
                w.close()
            dn = os.path.join(args.dir, args.dataset, subdir)
            fn = os.path.join(dn, "data-%05d" % (shard))
            if not os.path.exists(dn):
                os.makedirs(os.path.dirname(fn))
            logger.info("Writing {} ...".format(fn))
            w = recordio.Writer(fn)
            shard = shard + 1

        w.write(
            tf.train.Example(
                features=tf.train.Features(
                    feature={
                        "image": tf.train.Feature(
                            float_list=tf.train.FloatList(
                                value=x[row].flatten()
                            )
                        ),
                        "label": tf.train.Feature(
                            int64_list=tf.train.Int64List(
                                value=y[row].flatten()
                            )
                        ),
                    }
                )
            ).SerializeToString()
        )
        row = row + 1
    w.close()
    logger.info(
        "Wrote {} of total {} records into {} files".format(
            row, x.shape[0], shard
        )
    )


def main(args):
    # if args.dataset == "mnist":
    #     from tensorflow.python.keras.datasets import mnist
    #
    #     (x_train, y_train), (x_test, y_test) = mnist.load_data()
    # elif args.dataset == "fashion_mnist":
    #     from tensorflow.python.keras.datasets import fashion_mnist
    #
    #     (x_train, y_train), (x_test, y_test) = fashion_mnist.load_data()
    # elif args.dataset == "cifar10":
    #     from tensorflow.python.keras.datasets import cifar10
    #
    #     (x_train, y_train), (x_test, y_test) = cifar10.load_data()
    # else:
    #     sys.exit("Unknown dataset {}".format(args.dataset))

    data = np.load("/work/NNop/cifar-10-train-data.npz")

    train_labels = data.f.labels
    train_data = data.f.data

    data = np.load("/work/NNop/cifar-10-test-data.npz")

    test_labels = data.f.labels
    test_data = data.f.data

    train_data, test_data = train_data / 255.0, test_data / 255.0
    x_train = train_data
    y_train = train_labels
    x_test = test_data
    y_test = test_labels

    convert(x_train, y_train, args, "train")
    convert(x_test, y_test, args, "test")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=("Convert TensorFlow image datasets into RecordIO format.")
    )
    parser.add_argument("dir", help="Output directory")
    parser.add_argument(
        "--records_per_shard",
        default=16 * 1024,
        type=int,
        help="Maximum number of records per shard file.",
    )
    parser.add_argument(
        "--dataset",
        choices=["mnist", "fashion_mnist", "cifar10"],
        default="mnist",
        help="Dataset name: mnist or fashion_mnist or cifar10",
    )
    parser.add_argument(
        "--fraction",
        default=1.0,
        type=float,
        help="The fraction of the dataset to be converted",
    )
    args = parser.parse_args(sys.argv[1:])
    main(args)