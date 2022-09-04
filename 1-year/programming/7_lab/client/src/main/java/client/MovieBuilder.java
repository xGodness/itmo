package client;

import common.IO.IOManager;
import common.movieclasses.*;
import common.movieclasses.enums.*;

import java.time.DateTimeException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Locale;

/**
 * Class that connects with IO and creates new Movie instance based on user input.
 */
public class MovieBuilder {
    private IOManager ioManager;

    /**
     * The only constructor. IO Manager is necessary.
     *
     * @param ioManager IO Manager to connect with
     */
    public MovieBuilder(IOManager ioManager) {
        this.ioManager = ioManager;
    }

    /**
     * Main method to create new movie instance
     *
     * @return Built movie
     */
    public Movie buildMovie(String username) {

        String input;
        int choice;

/*--------------------------------------------------- For debugging ---------------------------------------------------*/
//        input = ioManager.getNextInput("Auto? (y for yes): ");
//        if (input.equalsIgnoreCase("y")) {
//            String movieName = "name";
//            Coordinates coordinates = new Coordinates(1.0, 1F);
//            LocalDateTime creationDate = LocalDateTime.now();
//            Integer oscarsCount = 1;
//            String tagline = "tagline";
//            MovieGenre genre = MovieGenre.ACTION;
//            MpaaRating mpaaRating = MpaaRating.PG;
//            Person screenwriter = new Person("smb", null, EyeColor.BROWN, HairColor.BLUE, Country.NORTH_KOREA, new Location(1, 2.0, "loc_name"));
//            return new Movie(movieName, coordinates, creationDate, oscarsCount, tagline, genre, mpaaRating, screenwriter);
//        }

        /**
         * Movie name field fetch
         */
        String movieName = null;
        while (movieName == null) {
            input = ioManager.getNextInput("Specify movie name: ");
            if (ioManager.isStringValid(input)) {
                movieName = input;
            } else {
                ioManager.printlnErr("Incorrect input. Movie name must contain at least one alphanumeric or standard special character");
            }
        }

        /**
         * Coordinates field fetch
         */
        Double x = ioManager.getNextDouble("Specify X (double) coordinate: ", false);
        Float y = ioManager.getNextFloat("Specify Y (float) coordinate: ", false);
        Coordinates coordinates = new Coordinates(x, y);

        /**
         * Creation date field generation
         */
        LocalDateTime creationDate = LocalDateTime.now();

        /**
         * Oscars count field fetch
         */
        Integer oscarsCount = 0;
        while (oscarsCount < 1) {
            oscarsCount = ioManager.getNextInteger("Specify Oscar count: ", true);
            if (oscarsCount == null) break;
            if (oscarsCount < 1) {
                ioManager.printlnErr("Incorrect input. Oscars count must be positive integer or null");
            }
        }

        /**
         * Tagline field fetch
         */
        String tagline = "";
        while (tagline.equals("")) {
            input = ioManager.getNextInput("Specify tagline: ");
            if (input.equals("")) {
                tagline = null;
                break;
            }
            if (ioManager.isStringValid(input)) {
                tagline = input;
            } else {
                ioManager.printlnErr("Incorrect input. Tagline must contain only standard characters or be a null");
            }
        }

        /**
         * Genre field fetch
         */
        MovieGenre genre = null;
        while (genre == null) {
            input = ioManager
                    .getNextInput("Specify movie genre (Action [1], Western [2], Drama [3], Musical [4] or Sci-Fi [5]): ")
                    .toLowerCase(Locale.ROOT)
                    .trim();
            try {
                choice = Integer.parseInt(input);
                switch (choice) {
                    case 1:
                        genre = MovieGenre.ACTION;
                        break;
                    case 2:
                        genre = MovieGenre.WESTERN;
                        break;
                    case 3:
                        genre = MovieGenre.DRAMA;
                        break;
                    case 4:
                        genre = MovieGenre.MUSICAL;
                        break;
                    case 5:
                        genre = MovieGenre.SCIENCE_FICTION;
                        break;
                    default:
                        break;
                }
            } catch (NumberFormatException e) {
                genre = MovieGenre.valueOfLabel(input);
            } catch (IllegalArgumentException e) {
                ioManager.printlnErr("Incorrect input. Movie genre must be Action, Western, Drama, Musical or Sci-Fi");
            }
        }

        /**
         * Mpaa rating fetch
         */
        MpaaRating mpaaRating = null;
        while (mpaaRating == null) {
            input = ioManager
                    .getNextInput("Specify MPAA rating (PG [1], PG-13 [2], R [3]): ")
                    .toLowerCase(Locale.ROOT)
                    .trim();
            try {
                choice = Integer.parseInt(input);
                switch (choice) {
                    case 1:
                        mpaaRating = MpaaRating.PG;
                        break;
                    case 2:
                        mpaaRating = MpaaRating.PG_13;
                        break;
                    case 3:
                        mpaaRating = MpaaRating.R;
                        break;
                    default:
                        break;
                }
            } catch (NumberFormatException e) {
                mpaaRating = MpaaRating.valueOfLabel(input);
            } catch (IllegalArgumentException e) {
                ioManager.printlnErr("Incorrect input. MPAA rating must be PG, PG-13 or R");
            }
        }

        /**
         * Screenwriter name field fetch
         */
        String personName = null;
        while (personName == null) {
            input = ioManager.getNextInput("Specify screenwriter's name: ");
            if (ioManager.isStringValid(input)) {
                personName = input;
            } else {
                ioManager.printlnErr("Incorrect input. Screenwriter's name must contain only standard characters, at least one must be provided");
            }
        }

        /**
         * Screenwriter's birthday field fetch
         */
        LocalDate birthday = null;
        while (birthday == null) {
            input = ioManager.getNextInput("Specify screenwriter's date of birth (dd.mm.yyyy): ");
            if (input.equals("")) {
                break;
            }
            String[] birthDate = input.split("\\.");
            try {
                birthday = LocalDate.of(
                        Integer.parseInt(birthDate[2]),
                        Integer.parseInt(birthDate[1]),
                        Integer.parseInt(birthDate[0])
                );
            } catch (IllegalArgumentException | ArrayIndexOutOfBoundsException e) {
                ioManager.printlnErr("Incorrect input. Year, month and day must be valid integers");
            } catch (DateTimeException e) {
                ioManager.printlnErr("Incorrect input. Date must have proper format");
            }

        }

        /**
         * Screenwriter's eye color fetch
         */
        EyeColor eyeColor = null;
        while (eyeColor == null) {
            input = ioManager
                    .getNextInput("Specify screenwriter's eye color (green [1], red [2], white [3] or brown [4]): ")
                    .toLowerCase(Locale.ROOT)
                    .trim();
            try {
                choice = Integer.parseInt(input);
                switch (choice) {
                    case 1:
                        eyeColor = EyeColor.GREEN;
                        break;
                    case 2:
                        eyeColor = EyeColor.RED;
                        break;
                    case 3:
                        eyeColor = EyeColor.WHITE;
                        break;
                    case 4:
                        eyeColor = EyeColor.BROWN;
                        break;
                    default:
                        break;
                }
            } catch (NumberFormatException e) {
                eyeColor = EyeColor.valueOfLabel(input);
            } catch (IllegalArgumentException e) {
                ioManager.printlnErr("Incorrect input. Eye color must be green, red, white or brown");
            }
        }

        /**
         * Screenwriter's hair color fetch
         */
        HairColor hairColor = null;
        while (hairColor == null) {
            input = ioManager
                    .getNextInput("Specify screenwriter's hair color (blue [1], yellow [2] or white [3]): ")
                    .toLowerCase(Locale.ROOT)
                    .trim();
            try {
                choice = Integer.parseInt(input);
                switch (choice) {
                    case 1:
                        hairColor = HairColor.BLUE;
                        break;
                    case 2:
                        hairColor = HairColor.YELLOW;
                        break;
                    case 3:
                        hairColor = HairColor.WHITE;
                        break;
                    default:
                        break;
                }
            } catch (NumberFormatException e) {
                hairColor = HairColor.valueOfLabel(input);
            } catch (IllegalArgumentException e) {
                ioManager.printlnErr("Incorrect input. Eye color must be blue, yellow or white");
            }
        }

        /**
         * Screenwriter's country fetch
         */
        Country nationality = null;
        while (nationality == null) {
            input = ioManager
                    .getNextInput("Specify screenwriter's nationality (UK [1], USA [2], Vatican [3], South Korea [4], North Korea [5]): ")
                    .toLowerCase(Locale.ROOT)
                    .trim();
            try {
                choice = Integer.parseInt(input);
                switch (choice) {
                    case 1:
                        nationality = Country.UNITED_KINGDOM;
                        break;
                    case 2:
                        nationality = Country.USA;
                        break;
                    case 3:
                        nationality = Country.VATICAN;
                        break;
                    case 4:
                        nationality = Country.SOUTH_KOREA;
                        break;
                    case 5:
                        nationality = Country.NORTH_KOREA;
                        break;
                    default:
                        break;
                }
            } catch (NumberFormatException e) {
                nationality = Country.valueOfLabel(input);
            } catch (IllegalArgumentException e) {
                ioManager.printlnErr("Incorrect input. Nationality must be UK, USA, Vatican, South Korea or North Korea");
            }
        }

        /**
         * Screenwriter's location fetch
         */
        Location location = null;

        Integer locX = ioManager.getNextInteger("Specify X (integer) coordinate: ", false);
        Double locY = ioManager.getNextDouble("Specify Y (double) coordinate: ", false);
        String locName = null;
        while (locName == null) {
            input = ioManager.getNextInput("Specify location name: ");
            if (!ioManager.isStringValid(input)) {
                ioManager.printlnErr("Incorrect input. Name must contain at least one standard character");
                continue;
            }
            locName = input;
        }
        location = new Location(locX, locY, locName);


        Person screenwriter = new Person(personName, birthday, eyeColor, hairColor, nationality, location);

        return new Movie(movieName, coordinates, creationDate, oscarsCount, tagline, genre, mpaaRating, screenwriter, username);

    }
}
