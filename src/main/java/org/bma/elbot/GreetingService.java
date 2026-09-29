package org.bma.elbot;

import org.springframework.stereotype.Service;

@Service
public class GreetingService {
    public void run(String[] args) {
        System.out.println("Hello from Spring! args=" + String.join(",", args));
    }
}
