package br.unipar.gerenciadorcaixas.repository

import br.unipar.gerenciadorcaixas.model.CaixaDAgua
import br.unipar.gerenciadorcaixas.model.Funcionario
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CaixaDAguaRepository : JpaRepository<CaixaDAgua, Long> {
        fun findByMarcaContainingIgnoreCase(marca : String) : List<CaixaDAgua>
        fun findByFuncionario(funcionario : Funcionario) : List<CaixaDAgua>
    }
