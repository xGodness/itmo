package lab3.entities;

public class Basket {

    public void attachToNet() {
        System.out.println("Теперь к сетке на шаре прикреплена корзина");
        this.describe();
    }

    public void describe() {
        System.out.println("Корзина из березовой коры. Четырехугольная. С каждой ее стороны есть лавочка, и на каждой лавочке может поместиться по четыре малыша");
    }
}
