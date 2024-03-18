package algorithm;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class HashTableTest {
    private final int tableCapacity = 20;

    private static Stream<Arguments> provideArgsForBucketsAddingOrderTest() {
        return Stream.of(
                Arguments.of(
                        List.of(12, 3, 1, 10, 5, 12),
                            Map.of(1, List.of(1), 3, List.of(3, 10), 5, List.of(5, 12))
                ),
                Arguments.of(
                        List.of(32, 25, 18, 4, 11),
                        Map.of(4, List.of(4, 11, 18, 25, 32))
                ),
                Arguments.of(
                        Stream.of(7, 14, null, null).collect(Collectors.toList()),
                        Map.of(7, Stream.of(null, 7, 14).collect(Collectors.toList()))
                )
        );
    }

    @ParameterizedTest
    @MethodSource("provideArgsForBucketsAddingOrderTest")
    void bucketsAddingOrderTest(List<Integer> list, Map<Integer, List<Integer>> bucketMap) {
        HashTableImpl<FunnyInteger> hashTable = new HashTableImpl<>(tableCapacity);
        addAll(hashTable, list);
        bucketMap.forEach((k, bucket) -> compareBuckets(hashTable, k, bucket));
    }

    @Test
    void removeTest() {
        HashTableImpl<FunnyInteger> hashTable = new HashTableImpl<>(tableCapacity);
        addAll(hashTable, Stream.of(14, 9, 2, 7, 10, null).collect(Collectors.toList()));

        Assertions.assertTrue(hashTable.remove(new FunnyInteger(14)));
        Assertions.assertFalse(hashTable.remove(new FunnyInteger(14)));
        Assertions.assertFalse(hashTable.remove(new FunnyInteger(1)));

        compareBuckets(hashTable, null, Stream.of(null, 7).collect(Collectors.toList()));
        compareBuckets(hashTable, 2, List.of(2, 9));
        compareBuckets(hashTable, 10, List.of(10));
    }

    private void addAll(HashTableImpl<FunnyInteger> hashTable, List<Integer> listToAdd) {
        listToAdd.stream().map(e -> (e == null) ? null : new FunnyInteger(e)).forEach(hashTable::add);
    }

    private void compareBuckets(HashTableImpl<FunnyInteger> hashTable, Integer value, List<Integer> expectedBucket) {
        Assertions.assertEquals(
                expectedBucket,
                hashTable.getBucket(
                                (value == null) ? null : new FunnyInteger(value)
                        ).stream()
                        .map(e -> (e == null) ? null : e.get()).collect(Collectors.toList())
        );
    }
}
