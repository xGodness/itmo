import ru.ifmo.se.pokemon.*;

public class Manaphy extends Pokemon {
	public Manaphy(String name, int level) {
		super(name, level);
		setStats(90.4, 75.0, 82.7, 80.1, 84.4, 84.3);
		setType(Type.WATER);
		setMove(new Bind(), new Metronome(), new Tail_Whip(), new Fire_Blast());
	}
}