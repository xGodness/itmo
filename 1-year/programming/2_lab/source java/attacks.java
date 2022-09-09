import ru.ifmo.se.pokemon.*;

class Bind extends PhysicalMove {
	public Bind() {
		accuracy = 0.85;
		power = 15;
		priority = 0;
		type = Type.NORMAL;
		
		double r = Math.random() * 100 / 8;
		if (r < 37.5) hits = 2;
		else if (r < 75) hits = 3;
		else if (r < 87.5) hits = 4;
		else hits = 5;
	}
	
	protected void applyOppEffects(Pokemon opp) {
		double T = Math.random();
		int t = 0;
		if (T < 0.25) t = 2;
		else if (T < 0.5) t = 3;
		else if (T < 0.75) t = 4;
		else t = 5;
		opp.addEffect(new Effect().turns(t).stat(Stat.HP, (int) -(opp.getHP() / 16.0)));
	}
	
	protected String describe() {
		return "uses bind! Enemy's going to lose 1/16 of his HP for the next several turns!";
	}
}

class Tail_Whip extends StatusMove {
	public Tail_Whip() {
		accuracy = 1;
		hits = 1;
		power = 0;
		priority = 0;
		type = Type.NORMAL;
	}
	
	protected void applyOppEffects(Pokemon opp) {
		opp.addEffect(new Effect().stat(Stat.DEFENSE, -1));
	}
	
	protected String describe() {
		return "uses tail whip! Opponent's thick skin have just become a bit thinner!";
	}
}

class Fire_Blast extends SpecialMove {
	public Fire_Blast() {
		accuracy = 0.85;
		hits = 1;
		power = 110;
		priority = 0;
		type = Type.FIRE;
	}
	
	protected void applyOppEffects(Pokemon opp) {
		opp.addEffect(new Effect().chance(0.1).condition(Status.BURN));
	}
	
	protected String describe() {
		return "uses fire blast! Smells like shashlik. Mmm, delicious!";
	}
}

class Facade extends PhysicalMove {
	public Facade() {
		accuracy = 1;
		hits = 1;
		power = 70;
		priority = 0;
		type = Type.NORMAL;
	}
	
	protected void applyOppEffects(Pokemon opp) {
		Status currentStatus = opp.getCondition();
		if (currentStatus == Status.BURN || currentStatus == Status.PARALYZE || currentStatus == Status.POISON) hits++;
	}
	
	protected String describe() {
		return "uses facade! What a slaughter!";
	}
}

class Wrap extends PhysicalMove {
	public Wrap() {
		accuracy = 0.9;
		power = 15;
		priority = 0;
		type = Type.NORMAL;
		
		double r = Math.random() * 100 / 8;
		if (r < 37.5) hits = 2;
		else if (r < 75) hits = 3;
		else if (r < 87.5) hits = 4;
		else hits = 5;
	}
		
	protected void applyOppEffects(Pokemon opp) {
		double T = Math.random();
		int t = 0;
		if (T < 0.25) t = 2;
		else if (T < 0.5) t = 3;
		else if (T < 0.75) t = 4;
		else t = 5;
		opp.addEffect(new Effect().turns(t).stat(Stat.HP, (int) -(opp.getHP() / 16.0)));
	}
	
	protected String describe() {
		return "uses wrap! So now opponent is kinda... Wrapped? Like a christmas present?..";
	}
}

class Fissure extends PhysicalMove {
	public Fissure() {
		accuracy = 0.3;
		hits = 1;
		power = 0;
		priority = 0;
		type = Type.GROUND;
	}
	
	int selfLevel;
	protected void applySelfEffect(Pokemon self) {
		selfLevel = self.getLevel();
	}
	
	protected void applyOppEffects(Pokemon opp) {
		int oppLevel = opp.getLevel();
		if (selfLevel >= oppLevel) {
			opp.addEffect(new Effect().stat(Stat.HP, (int) -(opp.getHP())));
		}
	}
	
	protected String describe() {
		return "uses fissure! Oh boy, that's painful!";
	}
}

class Twineedle extends PhysicalMove {
	public Twineedle() {
		accuracy = 1;
		hits = 2;
		power = 25;
		priority = 0;
		type = Type.BUG;
	}
	
	protected void applyOppEffects(Pokemon opp) {
		opp.addEffect(new Effect().chance(0.2).condition(Status.POISON));
	}
	
	protected String describe() {
		return "uses twineedle! Powerful bug bite! How he managed to do that if he isn't even a bug?..";
	}
}

class Dynamic_Punch extends PhysicalMove {
	public Dynamic_Punch() {
		accuracy = 0.5;
		hits = 1;
		power = 100;
		priority = 0;
		type = Type.FIGHTING;
	}
	
	protected void applyOppEffects(Pokemon opp) {
		opp.confuse();
	}
	
	protected String describe() {
		return "uses dynamic punch! Big-bam-boom! Watch your face!";
	}
}


class Metronome extends StatusMove {
	public Metronome() {	
		accuracy = 1;
		hits = 1;
		power = 0;
		priority = 0;
		type = Type.NORMAL;
	}
	
	double d_self = Math.random();
	double d_opp = Math.random();
	
	protected void applyOppEffects(Pokemon opp) {
		opp.addEffect(new Effect().stat(Stat.HP, (int) (opp.getHP() * d_opp)));
	}
	protected void applySelfEffect(Pokemon self) {
		self.addEffect(new Effect().stat(Stat.HP, (int) -(self.getHP() * d_self)));
	}
	
	protected String describe() {
		return "uses metronome! Oh, wait.. No way! They are playing russian roulette!";
	}
}
