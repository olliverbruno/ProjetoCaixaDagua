package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Entity
import java.math.BigDecimal

@Entity
class Funcionario (
    id : Long,
    cpf : String,
    val salario : BigDecimal = BigDecimal.ZERO
): Pessoa(id, cpf) {
}