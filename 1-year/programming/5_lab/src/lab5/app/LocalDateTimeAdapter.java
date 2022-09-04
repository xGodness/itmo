package lab5.app;

import javax.xml.bind.annotation.adapters.XmlAdapter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Adapter class that gives instructions to JAXB how to handle LocalDateTime fields
 */

public class LocalDateTimeAdapter extends XmlAdapter<String, LocalDateTime> {

    private DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss");

    @Override
    public String marshal(LocalDateTime dateTime) {
        return dateTime.format(dateFormat);
    }

    @Override
    public LocalDateTime unmarshal(String dateTime) {
        return LocalDateTime.parse(dateTime, dateFormat);
    }

}
