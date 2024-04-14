package br.com.linkonfood.pagamentos;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;


/**
 * The type Pagamentos application.
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class PagamentosApplication {

    /**
     * The entry point of application.
     *
     * @param args the input arguments
     */
    public static void main(String[] args) {
		SpringApplication.run(PagamentosApplication.class, args);
	}

}
