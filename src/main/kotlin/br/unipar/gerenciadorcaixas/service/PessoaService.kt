package br.unipar.gerenciadorcaixas.service


import br.unipar.gerenciadorcaixas.model.Pessoa
import br.unipar.gerenciadorcaixas.repository.PessoaRepository
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service

@Service
class PessoaService(
    private val repository : PessoaRepository,
    private val validar : ValidarCpf
) {

        fun salvar(pessoa: Pessoa): ResponseEntity<String> {
            if(validar.validarCpfViaAPI(pessoa.cpf)){
                println("CPF Válido!")
                repository.save(pessoa)
                return ResponseEntity.status(HttpStatus.CREATED).body("Pessoa foi salva no banco!")
            }else{
                println("CPF inválido!")
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build()
            }

        }

        fun listar(): ResponseEntity<List<Pessoa>> {
            return ResponseEntity.status(HttpStatus.OK)
                .body(repository.findAll())

        }

        fun buscar(id: Long): ResponseEntity<Pessoa> {
            val resposta = repository.findById(id).orElseThrow {
                NoSuchElementException("O $id digitado não é válido")
            }
            return ResponseEntity.status(HttpStatus.OK).body(resposta)

        }

        fun excluir(id: Long): ResponseEntity<Void> {
            repository.deleteById(id)
            return ResponseEntity.noContent().build()

        }

        /*Opcional
        fun buscarCpf(cpf : String) : ResponseEntity<Pessoa>{
            return repository.findByCpf(cpf)
            return ResponseEntity.ok(pessoas)
        }

         */
}