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
    @ManyToOne
    val marca : Marca,
    val capacidadeLitros : Int,
    val altura : Double,
    val largura : Double,        //na redonda é o diâmetro
    @Enumerated(EnumType.STRING)
    val cor : Cor,
    @Enumerated(EnumType.STRING)
    val material : Material,
    @Enumerated(EnumType.STRING)
    val formato : Formato,
    val preco : BigDecimal,
    val estoque : Int
)
