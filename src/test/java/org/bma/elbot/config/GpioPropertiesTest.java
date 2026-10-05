package org.bma.elbot.config;

import org.junit.jupiter.api.Test;
import org.springframework.core.env.MapPropertySource;
import org.springframework.core.env.StandardEnvironment;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class GpioPropertiesTest {
    private static GpioProperties with(Map<String, Object> values) {
        var env = new StandardEnvironment();
        env.getPropertySources().addFirst(new MapPropertySource("test", values));
        return new GpioProperties(env);
    }

    @Test
    void defaults() {
        var props = with(Map.of());
        assertEquals(17, props.pin());
        assertEquals(1000, props.pollIntervalMs());
    }

    @Test
    void overridesFromEnvironment() {
        var props = with(Map.of("ELBOT_GPIO_PIN", "27", "ELBOT_POLL_INTERVAL_MS", "250"));
        assertEquals(27, props.pin());
        assertEquals(250, props.pollIntervalMs());
    }

    @Test
    void rejectsNegativePin() {
        assertThrows(IllegalArgumentException.class, () -> with(Map.of("ELBOT_GPIO_PIN", "-1")));
    }

    @Test
    void rejectsNonPositiveInterval() {
        assertThrows(IllegalArgumentException.class, () -> with(Map.of("ELBOT_POLL_INTERVAL_MS", "0")));
    }

    @Test
    void rejectsNonNumericPin() {
        assertThrows(RuntimeException.class, () -> with(Map.of("ELBOT_GPIO_PIN", "abc")));
    }
}
