package client;

import java.util.*;


/**
 * Singleton class that receives hash map and returns sorted linked hash map of Entry<String, String> elements.
 */
public class HashMapSorter {

    /**
     * Comparator to compare Entry<String, String> objects
     */
    public static final Comparator<Map.Entry<String, String>> comparator = new Comparator<Map.Entry<String, String>>() {

        @Override
        public int compare(Map.Entry<String, String> entry1, Map.Entry<String, String> entry2) {
            return entry1.getValue().compareTo(entry2.getValue());
        }
    };

    /**
     * Method that sorts hash map
     *
     * @param hashMap <String, String> hash map to sort
     * @return Sorted linked hash map
     */
    public static LinkedHashMap sortHashMap(HashMap<String, String> hashMap) {

        List<Map.Entry<String, String>> entryList = new LinkedList<>(hashMap.entrySet());

        entryList.sort(comparator);

        LinkedHashMap<String, String> sortedHashMap = new LinkedHashMap<>();
        for (Map.Entry<String, String> entry : entryList) {
            sortedHashMap.put(entry.getKey(), entry.getValue());
        }

        return sortedHashMap;
    }


}
