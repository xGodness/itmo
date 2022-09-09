import ru.ifmo.se.pokemon.*;

public class Raichu extends Pikachu {
	public Raichu(String name, int level) {
		super(name, level);
		setStats(38.5, 65.1, 29.3, 70.6, 64.0, 91.0);
		addMove(new Dynamic_Punch());
	}
}