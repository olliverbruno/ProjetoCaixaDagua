package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import java.math.BigDecimal

@Entity
class CaixaDAgua(
    @Id
    @GeneratedValue(GenerationType.SEQUENCE)
    val id : Long? = null,
    val marca : String,
    val modelo : String,
    val dimensao : MutableList<Double>,
    val cor : Cor,
    val material : Material,
    val formato : String,
    val preco : BigDecimal,
)
