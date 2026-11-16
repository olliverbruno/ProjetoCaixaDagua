package br.unipar.gerenciadorcaixas.service


import br.unipar.gerenciadorcaixas.model.Cliente
import br.unipar.gerenciadorcaixas.repository.ClienteRepository
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service

@Service
class ClienteService(
    private val repository : ClienteRepository,
    private val validar : ValidarCpf
) {

        fun salvar(cliente: Cliente): ResponseEntity<String> {
            if(cliente.cidade.isBlank()){
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Cidade não pode ser vazia")
            }
            if(validar.validarCpfViaAPI(cliente.cpf)){
                println("CPF Válido!")
                repository.save(cliente)
                return ResponseEntity.status(HttpStatus.CREATED).body("Cliente foi salvo no banco!")
            }else{
                println("CPF inválido!")
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build()
            }

        }

        fun listar(): ResponseEntity<List<Cliente>> {
            return ResponseEntity.status(HttpStatus.OK)
                .body(repository.findAll())

        }

        fun buscar(id: Long): ResponseEntity<Cliente> {
            val resposta = repository.findById(id).orElseThrow {
                NoSuchElementException("O $id digitado não é válido")
            }
            return ResponseEntity.status(HttpStatus.OK).body(resposta)

        }

        fun atualizar(id: Long, cliente: Cliente): ResponseEntity<String> {
            val resposta = repository.findById(id).orElseThrow {
                NoSuchElementException("O $id digitado não é válido")
            }
            if(cliente.cidade.isBlank()){
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Cidade não pode ser vazia")
            }
            //so valida o cpf se mudou
            if(cliente.cpf != resposta.cpf && !validar.validarCpfViaAPI(cliente.cpf)){
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("CPF inválido")
            }
            //mantem o id e a data de cadastro
            val atualizado = Cliente(resposta.id, cliente.cpf, cliente.nome, cliente.telefone, cliente.email,
                cliente.dataNascimento, cliente.cep, cliente.logradouro, cliente.numero, cliente.bairro,
                cliente.cidade, cliente.uf, resposta.dataCadastro, cliente.observacao, cliente.ativo)
            repository.save(atualizado)
            return ResponseEntity.status(HttpStatus.OK).body("Cliente foi atualizado!")

        }

        fun excluir(id: Long): ResponseEntity<Void> {
            repository.deleteById(id)
            return ResponseEntity.noContent().build()

        }
}
