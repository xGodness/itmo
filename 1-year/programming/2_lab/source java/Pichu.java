import ru.ifmo.se.pokemon.*;

public class Pichu extends Pokemon {
	public Pichu(String name, int level) {
		super(name, level);
		setStats(0.6, 8.6, 0.5, 9.2, 6.2, 41.3);
		setType(Type.ELECTRIC);
		setMove(new Metronome(), new Fissure());
	}
}