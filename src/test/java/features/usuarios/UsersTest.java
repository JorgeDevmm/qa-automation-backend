package features.usuarios;

import com.intuit.karate.junit5.Karate;

public class UsersTest {

//    @Karate.Test
//    Karate testUsers() {
//        return Karate.run("users").relativeTo(getClass());
//    }

    @Karate.Test
    Karate testSmoke() {
        return Karate.run().tags("@smoke").relativeTo(getClass());
    }
}
