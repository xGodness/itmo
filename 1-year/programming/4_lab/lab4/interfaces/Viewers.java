package lab4.interfaces;

public interface Viewers {
    default void rejoice() {
        System.out.println("Зрители обрадовались");
    }
}
