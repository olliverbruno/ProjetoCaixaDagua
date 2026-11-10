package br.unipar.gerenciadorcaixas.repository

import br.unipar.gerenciadorcaixas.model.Marca
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface MarcaRepository : JpaRepository<Marca, Long> {
    fun existsByNome(nome : String) : Boolean
    fun existsByNomeAndIdNot(nome : String, id : Long) : Boolean
}
