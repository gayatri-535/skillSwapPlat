import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Databaseconnector {
    public static void main(String[] args) {
        // Read DB settings from environment variables with sensible fallbacks
        String DB_URL = System.getenv("DB_URL");
        if (DB_URL == null || DB_URL.isEmpty()) {
            DB_URL = "jdbc:mysql://localhost:3306/skillSwapDB";
        }

        String USER = System.getenv("DB_USER");
        if (USER == null || USER.isEmpty()) {
            USER = "root"; // fallback username
        }

        String PASS = System.getenv("DB_PASS");
        if (PASS == null) {
            PASS = ""; // fallback to empty password
        }

        try {
            @SuppressWarnings("unused")
            Connection conn = DriverManager.getConnection(DB_URL, USER, PASS);
            System.out.println("Connected successfully!");
        } catch (SQLException e) {
            System.out.println("Connection failed: " + e.getMessage());
        }
    }
}

