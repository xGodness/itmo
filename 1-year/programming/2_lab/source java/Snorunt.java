import ru.ifmo.se.pokemon.*;

public class Snorunt extends Pokemon {
	public Snorunt(String name, int level) {
		super(name, level);
		setStats(22.7, 17.1, 23.1, 27.2, 22.7, 29.7);
		setType(Type.ICE);
		setMove(new Metronome(), new Fire_Blast(), new Facade());
	}
}