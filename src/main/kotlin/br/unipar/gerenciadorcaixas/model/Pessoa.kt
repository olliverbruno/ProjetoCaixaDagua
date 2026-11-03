package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Inheritance
import jakarta.persistence.InheritanceType

@Entity
//Herança, cada filha tem sua tabela
@Inheritance(strategy = InheritanceType.JOINED)
open class Pessoa(
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    val id : Long = 0L,
    val cpf : String
) {}
