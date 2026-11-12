package br.unipar.gerenciadorcaixas.service

import br.unipar.gerenciadorcaixas.model.Marca
import br.unipar.gerenciadorcaixas.repository.CaixaDAguaRepository
import br.unipar.gerenciadorcaixas.repository.MarcaRepository
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service

@Service
class MarcaService(
    private val repository : MarcaRepository,
    private val caixaRepository : CaixaDAguaRepository
) {

    fun salvar(marca: Marca): ResponseEntity<String> {
        if (marca.nome.isBlank()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Nome da marca não pode ser vazio")
        }
        if (repository.existsByNome(marca.nome)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Marca ${marca.nome} já cadastrada")
        }
        repository.save(marca)
        return ResponseEntity.status(HttpStatus.CREATED).body("Marca foi salva no banco!")

    }

    fun listar(): ResponseEntity<List<Marca>> {
        return ResponseEntity.status(HttpStatus.OK)
            .body(repository.findAll())

    }

    fun buscar(id: Long): ResponseEntity<Marca> {
        val resposta = repository.findById(id).orElseThrow {
            NoSuchElementException("O $id digitado não é válido")
        }
        return ResponseEntity.status(HttpStatus.OK).body(resposta)

    }

    fun atualizar(id: Long, marca: Marca): ResponseEntity<String> {
        val resposta = repository.findById(id).orElseThrow {
            NoSuchElementException("O $id digitado não é válido")
        }
        if (marca.nome.isBlank()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Nome da marca não pode ser vazio")
        }
        //nao deixa repetir o nome
        if (repository.existsByNomeAndIdNot(marca.nome, id)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Marca ${marca.nome} já cadastrada")
        }
        repository.save(Marca(resposta.id, marca.nome))
        return ResponseEntity.status(HttpStatus.OK)
            .body("Marca foi atualizada!")

    }

    fun excluir(id: Long): ResponseEntity<String> {
        val resposta = repository.findById(id).orElseThrow {
            NoSuchElementException("O $id digitado não é válido")
        }
        //se tiver caixa usando nao apaga
        val emUso = caixaRepository.countByMarca(resposta)
        if (emUso > 0) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                .body("Não é possível excluir: a marca ${resposta.nome} está em uso em $emUso caixa(s).")
        }
        repository.deleteById(id)
        return ResponseEntity.noContent().build()

    }
}
