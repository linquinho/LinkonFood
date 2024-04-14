package br.com.linkonfood.pagamentos.repository;

import br.com.linkonfood.pagamentos.model.Pagamento;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PagamentoRepository extends JpaRepository<Pagamento, Long> {


}
