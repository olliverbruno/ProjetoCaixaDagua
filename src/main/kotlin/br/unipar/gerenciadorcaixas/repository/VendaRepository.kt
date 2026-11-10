package br.unipar.gerenciadorcaixas.repository

import br.unipar.gerenciadorcaixas.model.Venda
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface VendaRepository : JpaRepository<Venda, Long> {
}
