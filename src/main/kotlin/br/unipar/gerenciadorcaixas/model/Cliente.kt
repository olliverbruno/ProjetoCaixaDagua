package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Entity
import java.time.LocalDate

@Entity
class Cliente(
    id : Long = 0L,
    cpf : String,
    nome : String,
    telefone : String,
    email : String? = null,
    dataNascimento : LocalDate,
    cep : String,
    logradouro : String,
    numero : String,
    bairro : String,
    cidade : String,
    uf : UF,
    val dataCadastro : LocalDate = LocalDate.now(),
    val observacao : String? = null,
    val ativo : Boolean = true
): Pessoa(id, cpf, nome, telefone, email, dataNascimento, cep, logradouro, numero, bairro, cidade, uf)  {
}