package br.unipar.gerenciadorcaixas.service

import br.unipar.gerenciadorcaixas.model.CaixaDAgua
import br.unipar.gerenciadorcaixas.repository.CaixaDAguaRepository
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service

@Service
class CaixaDAguaService(
    //Injeção de Dependência
    val repository: CaixaDAguaRepository) {

    fun salvar(caixa: CaixaDAgua): ResponseEntity<String> {

            repository.save(caixa)
            return ResponseEntity.status(HttpStatus.CREATED)
                .body("Caixa de Água foi salva no banco!")

    }

    fun listar(): ResponseEntity<List<CaixaDAgua>> {
        return ResponseEntity.status(HttpStatus.OK)
            .body(repository.findAll())

    }

    fun buscar(id: Long): ResponseEntity<CaixaDAgua> {
        val resposta = repository.findById(id).orElseThrow {
            NoSuchElementException("O $id digitado não é válido")
        }
        return ResponseEntity.status(HttpStatus.OK).body(resposta)

    }

    fun buscarMarca(marca : String) : List<CaixaDAgua>{
        return repository.findByMarcaContainingIgnoreCase(marca)
    }

    fun atualizar(id: Long, caixa: CaixaDAgua): ResponseEntity<String> {
        val resposta = repository.findById(id).orElseThrow {
            NoSuchElementException("O $id digitado não é válido")
        }
        //Usa o id que já existe pra atualizar
        val atualizada = CaixaDAgua(resposta.id, caixa.marca, caixa.modelo, caixa.dimensao,
            caixa.cor, caixa.material, caixa.formato, caixa.preco, caixa.funcionario)

        repository.save(atualizada)
        return ResponseEntity.status(HttpStatus.OK)
            .body("Caixa de Água foi atualizada!")

    }

    fun excluir(id: Long): ResponseEntity<Void> {
        repository.deleteById(id)
        return ResponseEntity.noContent().build()

    }
}