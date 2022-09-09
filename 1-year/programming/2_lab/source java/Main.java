import ru.ifmo.se.pokemon.*;

public class Main {
	public static void main(String[] args) {
		Battle battle = new Battle();
		Pokemon manaphy = new Manaphy("Boris 'The Blade' Yurinov", 1);
		Pokemon snorunt = new Snorunt("Turkish", 1);
		Pokemon froslass = new Froslass("Franky Four-Fingers", 1);
		Pokemon pichu = new Pichu("Sol", 1);
		Pokemon pikachu = new Pikachu("Bullet Tooth Tony", 1);
		Pokemon raichu = new Raichu("Gorgeous George", 1);
		battle.addAlly(pichu);
		battle.addAlly(pikachu);
		battle.addAlly(raichu);
		battle.addFoe(manaphy);
		battle.addFoe(snorunt);
		battle.addFoe(froslass);
		battle.go();
	}
}