package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Entity

@Entity
class Cliente(
    id : Long,
    cpf : String,
    val nome : String,
): Pessoa(id, cpf)  {
}