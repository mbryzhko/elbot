package org.bma.elbot.reader;

import com.pi4j.Pi4J;
import com.pi4j.context.Context;
import com.pi4j.io.gpio.digital.DigitalInput;
import com.pi4j.io.gpio.digital.DigitalState;
import com.pi4j.library.pigpio.PiGpio;
import com.pi4j.plugin.pigpio.provider.gpio.digital.PiGpioDigitalInputProvider;
import com.pi4j.plugin.raspberrypi.platform.RaspberryPiPlatform;
import org.bma.elbot.config.GpioProperties;
import org.springframework.stereotype.Component;

/**
 * Hardware adapter. Pi4J is initialised lazily on the first read so that creating the bean
 * never touches GPIO. Providers are registered explicitly because the fat jar does not
 * merge META-INF/services, which breaks Pi4J's autoDetect().
 */
@Component
public class Pi4jSignalReader implements SignalReader, AutoCloseable {
    private final GpioProperties props;
    private Context context;
    private DigitalInput input;

    public Pi4jSignalReader(GpioProperties props) {
        this.props = props;
    }

    @Override
    public synchronized boolean isHigh() {
        if (input == null) {
            context = Pi4J.newContextBuilder()
                    .noAutoDetect()
                    .add(new RaspberryPiPlatform())
                    .add(PiGpioDigitalInputProvider.newInstance(PiGpio.newNativeInstance()))
                    .build();
            input = context.create(DigitalInput.newConfigBuilder(context)
                    .id("grid-signal")
                    .name("Grid signal")
                    .address(props.pin())
                    .provider("pigpio-digital-input")
                    .build());
        }
        return input.state() == DigitalState.HIGH;
    }

    @Override
    public synchronized void close() {
        if (context != null) {
            context.shutdown();
            context = null;
            input = null;
        }
    }
}
