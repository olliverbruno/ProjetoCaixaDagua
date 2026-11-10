package br.unipar.gerenciadorcaixas.model

import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.ManyToMany
import jakarta.persistence.ManyToOne
import java.math.BigDecimal
import java.time.LocalDate

@Entity
class Venda(
    @Id
    @GeneratedValue(GenerationType.SEQUENCE)
    val id : Long? = null,
    val dataVenda : LocalDate = LocalDate.now(),
    @ManyToOne
    val cliente : Cliente,
    @ManyToOne
    val vendedor : Funcionario,
    @ManyToOne
    val instalador : Funcionario? = null,
    //N para N, uma venda tem varias caixas e uma caixa aparece em varias vendas
    @ManyToMany
    val caixas : MutableList<CaixaDAgua>,
    val valorTotal : BigDecimal = BigDecimal.ZERO,
    val dataInstalacao : LocalDate? = null
)
