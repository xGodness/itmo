import lab3.enums.Place;

abstract class Character {
    private String name;
    private Place place;

    public Character(String name, Place place) {
        this.name = name;
        this.place = place;
    }

    public String getName() {
        return this.name;
    }

    public Place getPlace(){
        return this.place;
    }

    public void setPlace(Place place) {
        this.place = place;
        System.out.println(this.name + " перешел в локацию \'" + place.getName() + "\'");
    }

    abstract public void describe();

    @Override
    public String toString() {
        return String.format("Character = {name: %s, currentPlace: %s}", this.name, this.place);
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) return false;
        if (obj instanceof Character) {
            return ( this.name.equals(((Character) obj).getName()) &&
                     this.place.equals(((Character) obj).getPlace()) );
        }
        return false;
    }

    @Override
    public int hashCode() {
        return ( this.name.hashCode() + this.place.hashCode() );
    }

}