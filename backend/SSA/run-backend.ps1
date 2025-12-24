# Run backend locally: sets env vars for this session and runs Spring Boot
$env:DB_URL  = "jdbc:mysql://localhost:3306/skillswapdb"
$env:DB_USER = "root"
# set this to your password for this session only
#$env:DB_PASS = "your_password"

mvn -DskipTests spring-boot:run
