package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.ManyToOne
import java.math.BigDecimal

@Entity
class CaixaDAgua(
    @Id
    @GeneratedValue(GenerationType.SEQUENCE)
    val id : Long? = null,
    val marca : String,
    val modelo : String,
    val dimensao : MutableList<Double>,
    @Enumerated(EnumType.STRING)
    val cor : Cor,
    @Enumerated(EnumType.STRING)
    val material : Material,
    val formato : String,
    val preco : BigDecimal,
    @ManyToOne
    val funcionario: Funcionario? = null
)
