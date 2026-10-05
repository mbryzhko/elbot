package org.bma.elbot;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

@Configuration
@EnableScheduling
@ComponentScan("org.bma.elbot")
public class Main {
    public static void main(String[] args) throws InterruptedException {
        var ctx = new AnnotationConfigApplicationContext();
        ctx.registerShutdownHook();
        Thread.currentThread().join();
    }
}
