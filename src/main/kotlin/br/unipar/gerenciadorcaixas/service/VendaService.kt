package br.unipar.gerenciadorcaixas.service

import br.unipar.gerenciadorcaixas.model.CaixaDAgua
import br.unipar.gerenciadorcaixas.model.Cargo
import br.unipar.gerenciadorcaixas.model.Venda
import br.unipar.gerenciadorcaixas.repository.CaixaDAguaRepository
import br.unipar.gerenciadorcaixas.repository.ClienteRepository
import br.unipar.gerenciadorcaixas.repository.FuncionarioRepository
import br.unipar.gerenciadorcaixas.repository.VendaRepository
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import java.math.BigDecimal

@Service
class VendaService(
    private val repository : VendaRepository,
    private val clienteRepository : ClienteRepository,
    private val funcionarioRepository : FuncionarioRepository,
    private val caixaRepository : CaixaDAguaRepository
) {

    fun salvar(venda: Venda): ResponseEntity<String> {
        //busca no banco pra conferir
        val cliente = clienteRepository.findById(venda.cliente.id).orElseThrow {
            NoSuchElementException("O cliente ${venda.cliente.id} não existe")
        }
        val vendedor = funcionarioRepository.findById(venda.vendedor.id).orElseThrow {
            NoSuchElementException("O funcionário ${venda.vendedor.id} não existe")
        }
        if (vendedor.cargo != Cargo.VENDEDOR) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("O vendedor precisa ter cargo VENDEDOR")
        }
        val instalador = venda.instalador?.let {
            funcionarioRepository.findById(it.id).orElseThrow {
                NoSuchElementException("O funcionário ${it.id} não existe")
            }
        }
        if (instalador != null && instalador.cargo != Cargo.INSTALADOR) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("O instalador precisa ter cargo INSTALADOR")
        }
        if (venda.caixas.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("A venda precisa ter pelo menos uma caixa")
        }

        //confere estoque e soma o total
        val caixas = mutableListOf<CaixaDAgua>()
        var total = BigDecimal.ZERO
        for (item in venda.caixas) {
            val caixa = caixaRepository.findById(item.id ?: 0L).orElseThrow {
                NoSuchElementException("A caixa ${item.id} não existe")
            }
            val quantidade = caixas.count { it.id == caixa.id } + 1
            if (caixa.estoque < quantidade) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Caixa ${caixa.marca.nome} ${caixa.capacidadeLitros}L sem estoque suficiente")
            }
            caixas.add(caixa)
            total = total.add(caixa.preco)
        }

        //desconta do estoque
        for (caixa in caixas) {
            alterarEstoque(caixa.id!!, -1)
        }

        repository.save(Venda(cliente = cliente, vendedor = vendedor, instalador = instalador,
            caixas = caixas, valorTotal = total, dataInstalacao = venda.dataInstalacao))
        return ResponseEntity.status(HttpStatus.CREATED).body("Venda foi salva no banco!")

    }

    fun listar(): ResponseEntity<List<Venda>> {
        return ResponseEntity.status(HttpStatus.OK)
            .body(repository.findAll())

    }

    fun buscar(id: Long): ResponseEntity<Venda> {
        val resposta = repository.findById(id).orElseThrow {
            NoSuchElementException("O $id digitado não é válido")
        }
        return ResponseEntity.status(HttpStatus.OK).body(resposta)

    }

    //so muda instalador e data
    fun atualizar(id: Long, venda: Venda): ResponseEntity<String> {
        val resposta = repository.findById(id).orElseThrow {
            NoSuchElementException("O $id digitado não é válido")
        }
        val instalador = venda.instalador?.let {
            funcionarioRepository.findById(it.id).orElseThrow {
                NoSuchElementException("O funcionário ${it.id} não existe")
            }
        }
        if (instalador != null && instalador.cargo != Cargo.INSTALADOR) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("O instalador precisa ter cargo INSTALADOR")
        }
        val atualizada = Venda(resposta.id, resposta.dataVenda, resposta.cliente, resposta.vendedor, instalador,
            resposta.caixas, resposta.valorTotal, venda.dataInstalacao)

        repository.save(atualizada)
        return ResponseEntity.status(HttpStatus.OK)
            .body("Venda foi atualizada!")

    }

    fun excluir(id: Long): ResponseEntity<Void> {
        val resposta = repository.findById(id).orElseThrow {
            NoSuchElementException("O $id digitado não é válido")
        }
        //devolve pro estoque
        for (caixa in resposta.caixas) {
            alterarEstoque(caixa.id!!, 1)
        }
        repository.deleteById(id)
        return ResponseEntity.noContent().build()

    }

    //soma ou tira do estoque
    private fun alterarEstoque(idCaixa: Long, quantidade: Int) {
        val caixa = caixaRepository.findById(idCaixa).orElseThrow {
            NoSuchElementException("A caixa $idCaixa não existe")
        }
        caixaRepository.save(CaixaDAgua(caixa.id, caixa.marca, caixa.capacidadeLitros, caixa.altura, caixa.largura,
            caixa.cor, caixa.material, caixa.formato, caixa.preco, caixa.estoque + quantidade))
    }
}
