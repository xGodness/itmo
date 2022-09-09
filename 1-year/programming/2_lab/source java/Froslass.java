import ru.ifmo.se.pokemon.*;

public class Froslass extends Pokemon {
	public Froslass(String name, int level) {
		super(name, level);
		setStats(56.6, 54.5, 50.5, 62.6, 50.6, 91.0);
		setType(Type.ICE, Type.GHOST);
		setMove(new Metronome(), new Fire_Blast(), new Facade(), new Wrap());
	}
}