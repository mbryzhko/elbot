package org.bma.elbot;

import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import static org.junit.jupiter.api.Assertions.assertNotNull;

class AppContextTest {
    @Test
    void contextLoadsAndWiresGreetingService() {
        try (var ctx = new AnnotationConfigApplicationContext(AppConfig.class)) {
            assertNotNull(ctx.getBean(GreetingService.class));
        }
    }
}
