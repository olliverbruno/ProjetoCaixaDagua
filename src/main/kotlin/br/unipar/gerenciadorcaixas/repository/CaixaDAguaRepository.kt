package br.unipar.gerenciadorcaixas.repository

import br.unipar.gerenciadorcaixas.model.CaixaDAgua
import br.unipar.gerenciadorcaixas.model.Marca
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface CaixaDAguaRepository : JpaRepository<CaixaDAgua, Long> {
        fun findByMarcaNomeContainingIgnoreCase(marca : String) : List<CaixaDAgua>
        fun countByMarca(marca : Marca) : Long
    }
