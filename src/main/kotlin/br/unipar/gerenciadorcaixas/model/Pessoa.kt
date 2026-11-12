package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Inheritance
import jakarta.persistence.InheritanceType
import java.time.LocalDate

@Entity
//Herança, cada filha tem sua tabela
@Inheritance(strategy = InheritanceType.JOINED)
open class Pessoa(
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    val id : Long = 0L,
    val cpf : String,
    val nome : String,
    val telefone : String,
    val email : String? = null,
    val dataNascimento : LocalDate,
    val cep : String,
    val logradouro : String,
    val numero : String,
    val bairro : String,
    cidade : String,
    @Enumerated(EnumType.STRING)
    val uf : UF
) {
    //cidade maiuscula e sem espaço
    val cidade : String = cidade.trim().uppercase()
}
