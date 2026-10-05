package org.bma.elbot.config;

import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
public class GpioProperties {
    public static final String PIN_VAR = "ELBOT_GPIO_PIN";
    public static final String POLL_INTERVAL_VAR = "ELBOT_POLL_INTERVAL_MS";

    private final int pin;
    private final long pollIntervalMs;

    public GpioProperties(Environment env) {
        this.pin = env.getProperty(PIN_VAR, Integer.class, 17);
        this.pollIntervalMs = env.getProperty(POLL_INTERVAL_VAR, Long.class, 1000L);
        if (pin < 0) {
            throw new IllegalArgumentException(PIN_VAR + " must not be negative: " + pin);
        }
        if (pollIntervalMs <= 0) {
            throw new IllegalArgumentException(POLL_INTERVAL_VAR + " must be positive: " + pollIntervalMs);
        }
    }

    /** BCM pin number. */
    public int pin() {
        return pin;
    }

    public long pollIntervalMs() {
        return pollIntervalMs;
    }
}
