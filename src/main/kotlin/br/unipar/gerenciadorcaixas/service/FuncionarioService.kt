package br.unipar.gerenciadorcaixas.service


import br.unipar.gerenciadorcaixas.model.Funcionario
import br.unipar.gerenciadorcaixas.repository.FuncionarioRepository
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service

@Service
class FuncionarioService(
    private val repository : FuncionarioRepository,
    private val validar : ValidarCpf
) {

        fun salvar(funcionario: Funcionario): ResponseEntity<String> {
            if(funcionario.cidade.isBlank()){
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Cidade não pode ser vazia")
            }
            if(validar.validarCpfViaAPI(funcionario.cpf)){
                println("CPF Válido!")
                repository.save(funcionario)
                return ResponseEntity.status(HttpStatus.CREATED).body("Funcionário foi salvo no banco!")
            }else{
                println("CPF inválido!")
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build()
            }

        }

        fun listar(): ResponseEntity<List<Funcionario>> {
            return ResponseEntity.status(HttpStatus.OK)
                .body(repository.findAll())

        }

        fun buscar(id: Long): ResponseEntity<Funcionario> {
            val resposta = repository.findById(id).orElseThrow {
                NoSuchElementException("O $id digitado não é válido")
            }
            return ResponseEntity.status(HttpStatus.OK).body(resposta)

        }

        fun excluir(id: Long): ResponseEntity<Void> {
            repository.deleteById(id)
            return ResponseEntity.noContent().build()

        }
}
