public class Main {
	public static void main(String[] args) {
		//------------------------------------------------------------
		
		// TASK 1
		
		short a[] = new short[20];
		for (short number = 20; number > 0; number--) {
			a[20 - number] = number; 
		}
		
		//------------------------------------------------------------		
		
		// TASK 2
		
		float x[] = new float[16];
		for (int i = 0; i < 16; i++) {
			x[i] = (float) Math.random() * 19 - 4;
		}
		
		//------------------------------------------------------------
		
		// TASK 3
		
		double arr[][] = new double[20][];
		int[] check = {1, 3, 4, 6, 8, 9, 11, 17, 18, 19};
		for (int i = 0; i < 20; i++) {
			arr[i] = new double[16];
			for (int j = 0; j < 16; j++) {
				if (a[i] == 16) {
					arr[i][j] = Math.cos(Math.cbrt(Math.cos(x[j])));
				}
				else {
					boolean flag = false;
					for (int n : check) {
						if (a[i] > n) break;
						if (a[i] == n) {
							flag = true;
							break;
						}
					}
					if (flag) arr[i][j] = Math.pow(Math.cos(Math.pow((x[j] - 1) / 2, 2)), 2 * Math.pow((4.0 / 3 / (x[j] - 0.5)), 2));
					else arr[i][j] = Math.log(Math.sqrt((Math.abs(x[j]) + 1) / Math.abs(x[j]))) * Math.pow(1.0 / 3 + Math.atan(Math.pow(Math.E, Math.cbrt(-Math.pow(Math.cos(x[j]), 2)))), 2);
				}
			}
		}
		
		//------------------------------------------------------------
		
		// Print results
		
		for (int i = 0; i < 20; i++) {
			for (int j = 0; j < 16; j++) {
				System.out.printf("%4.2f ", arr[i][j]);
			}
			System.out.print('\n');
		}
		
		//------------------------------------------------------------
	}
}