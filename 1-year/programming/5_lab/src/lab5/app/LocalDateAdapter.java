package lab5.app;

import javax.xml.bind.annotation.adapters.XmlAdapter;
import java.time.LocalDate;

/**
 * Adapter class that gives instructions to JAXB how to handle LocalDate fields
 */
public class LocalDateAdapter extends XmlAdapter<String, LocalDate> {
    public LocalDate unmarshal(String v) {
        return LocalDate.parse(v);
    }

    public String marshal(LocalDate v) {
        return v.toString();
    }
}
