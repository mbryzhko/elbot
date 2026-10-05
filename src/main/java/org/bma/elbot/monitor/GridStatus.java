package org.bma.elbot.monitor;

public enum GridStatus {
    ON_GRID,
    OFF_GRID;

    /** A high (1) signal means there is no electricity; low (0) means the grid is fine. */
    public static GridStatus fromSignal(boolean high) {
        return high ? OFF_GRID : ON_GRID;
    }
}
