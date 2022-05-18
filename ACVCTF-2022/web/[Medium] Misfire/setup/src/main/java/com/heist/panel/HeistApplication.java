package com.heist.panel;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;


@SpringBootApplication
public class HeistApplication extends SpringBootServletInitializer{
	public static void main(String[] args) {
		SpringApplication.run(HeistApplication.class, args);
	}

}
