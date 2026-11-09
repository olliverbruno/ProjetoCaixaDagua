package br.unipar.gerenciadorcaixas.repository

import br.unipar.gerenciadorcaixas.model.Funcionario
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface FuncionarioRepository : JpaRepository<Funcionario, Long> {
}
