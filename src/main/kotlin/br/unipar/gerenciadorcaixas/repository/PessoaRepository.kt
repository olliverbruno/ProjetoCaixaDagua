package br.unipar.gerenciadorcaixas.repository

import br.unipar.gerenciadorcaixas.model.Pessoa
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface PessoaRepository : JpaRepository<Pessoa, Long> {
    fun findByCpf(cpf : String) : Pessoa?
}