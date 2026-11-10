package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id

@Entity
class Marca(
    @Id
    @GeneratedValue(GenerationType.SEQUENCE)
    val id : Long? = null,
    nome : String
) {
    //Salva sempre em maiúsculo e sem espaço sobrando
    @Column(unique = true)
    val nome : String = nome.trim().uppercase()
}
