from random import Random
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import make_blobs
from sklearn.cluster import KMeans

rng = Random()


def setup():
    plt.style.use("ggplot")
    plt.rcParams["figure.figsize"] = (12, 8)


def show_plot(x, labels):
    plt.scatter(x[:, 0], x[:, 1], c=labels)
    plt.show()


def calculate_k(x, r):
    criteria_arr = []
    delta_arr = []
    last_criteria = 0
    clusters = 0
    for k in range(2, 20):
        kmeans_model = KMeans(n_clusters=k, random_state=r)
        kmeans_model.fit(x)

        criteria = kmeans_model.inertia_
        criteria_arr.append(criteria)

        slope = criteria - last_criteria
        delta = slope
        delta_arr.append(delta)
        print("Slope: {} | Delta: {}".format(slope, delta))

        # if delta < min_delta:
        #     clusters = k
        #     min_delta = delta
            # break
        last_criteria = criteria

    i = 0
    while delta_arr[i] < -1:
        i += 1

    clusters = i - 1 if delta_arr[i - 1] < delta_arr[i] else i

    plt.plot(range(2, 20), criteria_arr, marker="o")
    plt.show()
    print(criteria_arr)
    print("Calculated k: {}".format(clusters))
    return clusters


def main():
    global rng
    random_state = rng.randint(1, 100)
    n_clusters = rng.randint(4, 20)
    print("Clusters generated: {}".format(n_clusters))
    x, y = make_blobs(n_samples=100, centers=n_clusters, random_state=random_state)
    k = calculate_k(x, random_state)

    # kmeans_model = KMeans(n_clusters=k)
    # kmeans_model.fit(x)
    # labels = kmeans_model.labels_
    # show_plot(x, labels)


if __name__ == '__main__':
    setup()
    main()
