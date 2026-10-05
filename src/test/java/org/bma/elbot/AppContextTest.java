package org.bma.elbot;

import org.bma.elbot.monitor.GridMonitorJob;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.config.ScheduledTaskHolder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class AppContextTest {
//    @Configuration
//    @EnableScheduling
//    @ComponentScan(basePackageClasses = AppConfig.class, excludeFilters = {
//            @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = {Pi4jSignalReader.class, AppConfig.class}),
//            @ComponentScan.Filter(type = FilterType.REGEX, pattern = ".*Test.*")})
//    static class TestConfig {
//        @Bean
//        SignalReader fakeReader() {
//            return () -> false;
//        }
//    }
//
//    @Test
//    void contextWiresMonitorJobAndSchedulesIt() {
//        try (var ctx = new AnnotationConfigApplicationContext(TestConfig.class)) {
//            assertNotNull(ctx.getBean(GridMonitorJob.class));
//            var scheduled = ctx.getBean(ScheduledTaskHolder.class);
//            assertEquals(1, scheduled.getScheduledTasks().size());
//        }
//    }
}
