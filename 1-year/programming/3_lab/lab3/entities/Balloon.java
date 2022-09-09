package lab3.entities;

public class Balloon {

    private Basket basket;
    private Net net = new Net();
    private boolean isLiftedUp = false;
    private int liftingUpParticipants = 0;

    public boolean checkIsLiftedUp() {
        return isLiftedUp;
    }

    public void liftUp() {
        liftingUpParticipants++;
        if (liftingUpParticipants >= 2) {
            isLiftedUp = true;
            System.out.println("Шар приподнялся");
            net.hangOver();
        }

    }

    public void attachBasket(Basket basket) {
        this.basket = basket;
        basket.attachToNet();
    }

}
