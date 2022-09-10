import ru.ifmo.se.pokemon.*;

public class Pikachu extends Pichu {
	public Pikachu(String name, int level) {
		super(name, level);
		setStats(4.5, 23.5, 10.6, 27.2, 22.7, 73.2);
		addMove(new Twineedle());
	}
}