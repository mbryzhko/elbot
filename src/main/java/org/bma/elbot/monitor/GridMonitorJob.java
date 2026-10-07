package org.bma.elbot.monitor;

import lombok.extern.slf4j.Slf4j;
import org.bma.elbot.reader.SignalReader;
import org.bma.elbot.config.GpioProperties;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@Slf4j
public class GridMonitorJob {

    private final SignalReader reader;
    private final GpioProperties props;
    private GridStatus last;

    public GridMonitorJob(SignalReader reader, GpioProperties props) {
        this.reader = reader;
        this.props = props;
        log.info("Grid Monitor Job Started with props: {}", props);
    }

    @Scheduled(fixedDelayString = "${" + GpioProperties.POLL_INTERVAL_VAR + ":1000}")
    public void check() {
        try {
            poll().ifPresent(status -> log.info("Grid status: {} (pin={})", status, props.pin()));
        } catch (RuntimeException e) {
            log.error("Failed to read GPIO pin {}", props.pin(), e);
        }
    }

    /** Reads the signal; returns the new status only when it differs from the previous reading. */
    Optional<GridStatus> poll() {
        GridStatus status = GridStatus.fromSignal(reader.isHigh());
        if (status == last) {
            return Optional.empty();
        }
        last = status;
        return Optional.of(status);
    }
}
