package org.bma.elbot.monitor;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class GridStatusTest {
    @Test
    void highSignalMeansOffGrid() {
        assertEquals(GridStatus.OFF_GRID, GridStatus.fromSignal(true));
    }

    @Test
    void lowSignalMeansOnGrid() {
        assertEquals(GridStatus.ON_GRID, GridStatus.fromSignal(false));
    }
}
