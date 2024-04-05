package algorithm;

import java.util.*;

public class HashTableImpl<T extends Comparable<T>> {
    private final ArrayList<LinkedList<T>> list;
    private final int initialCapacity;
    private int size;

    public HashTableImpl(int initialCapacity) {
        this.initialCapacity = initialCapacity;
        list = new ArrayList<>();
        for (int i = 0; i < initialCapacity; i++) list.add(new LinkedList<>());
        this.size = 0;
    }

    public boolean add(T obj) {
        List<T> bucket = getBucket(obj);

        if (bucket.isEmpty()) {
            bucket.add(obj);
            size++;
            return true;
        }

        int bound = lowerBound(bucket, obj);
        if (bound != -1 && checkEquals(bucket.get(bound), obj)) {
            return false;
        }

        while (++bound < bucket.size()) {
            obj = bucket.set(bound, obj);
        }
        bucket.add(obj);
        size++;
        return true;
    }

    public boolean remove(T obj) {
        List<T> bucket = getBucket(obj);

        if (bucket == null) return false;

        int bound = lowerBound(bucket, obj);
        if (bound != -1 && checkEquals(bucket.get(bound), obj)) {
            bucket.remove(bound);
            size--;
            return true;
        }
        return false;
    }

    public List<T> getBucket(T obj) {
        int index = calculateIndex(obj);
        return list.get(index);
    }

    public int size() {
        return size;
    }

    public boolean isEmpty() {
        return size == 0;
    }

    /**
     *
     * @param bucket list to search
     * @param obj element to find
     * @return index of the largest element that is lower or equals to obj; -1 if there's no such element
     */
    private int lowerBound(List<T> bucket, T obj) {
        if (bucket.isEmpty()) return -1;
        if (obj == null) return (bucket.get(0) == null) ? 0 : -1;
        int low = 0;
        int high = bucket.size() - 1;
        int mid;
        T cur;
        int comparison;
        while (low < high) {
            mid = (high + low) / 2;
            cur = bucket.get(mid);
            comparison = obj.compareTo(cur);
            if (comparison == 0) return mid;
            if (comparison > 0) low = mid + 1;
            else high = mid - 1;
        }
        return (obj.compareTo(bucket.get(low)) < 0) ? low - 1 : low;
    }

    private int calculateIndex(T obj) {
        return (obj == null) ? 0 : Math.abs(obj.hashCode()) % initialCapacity;
    }

    private boolean checkEquals(T obj1, T obj2) {
        if (obj1 == null || obj2 == null) return obj1 == obj2;
        return obj1.equals(obj2);
    }
}
