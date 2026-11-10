package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import java.math.BigDecimal
import java.time.LocalDate

@Entity
class Funcionario (
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
    val salario : BigDecimal = BigDecimal.ZERO,
    @Enumerated(EnumType.STRING)
    val cargo : Cargo,
    val dataAdmissao : LocalDate,
    val ativo : Boolean = true
): Pessoa(id, cpf, nome, telefone, email, dataNascimento, cep, logradouro, numero, bairro, cidade, uf) {
}