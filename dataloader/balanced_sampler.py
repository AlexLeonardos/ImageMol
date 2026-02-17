import torch
from torch.utils.data import Sampler
import numpy as np

class BalancedBatchSampler(Sampler):
    """
    Samples equal numbers of positive and negative samples for each batch.
    Assumes binary classification (labels are 0 or 1).
    """
    def __init__(self, labels, batch_size):
        self.labels = np.array(labels).flatten()
        self.batch_size = batch_size
        self.num_per_class = batch_size // 2
        self.pos_indices = np.where(self.labels == 1)[0]
        self.neg_indices = np.where(self.labels == 0)[0]
        assert self.num_per_class > 0, "Batch size must be at least 2."

    def __iter__(self):
        pos = np.random.permutation(self.pos_indices)
        neg = np.random.permutation(self.neg_indices)
        min_class_len = min(len(pos), len(neg))
        num_batches = min_class_len // self.num_per_class
        for i in range(num_batches):
            pos_batch = pos[i*self.num_per_class:(i+1)*self.num_per_class]
            neg_batch = neg[i*self.num_per_class:(i+1)*self.num_per_class]
            batch = np.concatenate([pos_batch, neg_batch])
            np.random.shuffle(batch)
            yield from batch

    def __len__(self):
        min_class_len = min(len(self.pos_indices), len(self.neg_indices))
        return 2 * (min_class_len // self.num_per_class) * self.num_per_class
