package org.bma.elbot.monitor;

import org.bma.elbot.reader.SignalReader;
import org.bma.elbot.config.GpioProperties;
import org.junit.jupiter.api.Test;
import org.springframework.mock.env.MockEnvironment;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class GridMonitorJobTest {
    private boolean high;
    private boolean fail;

    private final SignalReader reader = () -> {
        if (fail) {
            throw new IllegalStateException("gpio down");
        }
        return high;
    };
    private final GridMonitorJob job = new GridMonitorJob(reader, new GpioProperties(new MockEnvironment()));

    @Test
    void firstReadingIsReported() {
        assertEquals(Optional.of(GridStatus.ON_GRID), job.poll());
    }

    @Test
    void unchangedStatusIsNotReportedAgain() {
        job.poll();
        assertEquals(Optional.empty(), job.poll());
    }

    @Test
    void transitionsAreReported() {
        job.poll();
        high = true;
        assertEquals(Optional.of(GridStatus.OFF_GRID), job.poll());
        high = false;
        assertEquals(Optional.of(GridStatus.ON_GRID), job.poll());
    }

    @Test
    void readerFailureDoesNotEscapeCheckAndNextTickRecovers() {
        fail = true;
        assertThrows(IllegalStateException.class, job::poll);
        assertDoesNotThrow(job::check);
        fail = false;
        assertEquals(Optional.of(GridStatus.ON_GRID), job.poll());
    }
}
