package br.unipar.gerenciadorcaixas.service


import br.unipar.gerenciadorcaixas.model.Cargo
import br.unipar.gerenciadorcaixas.model.Funcionario
import br.unipar.gerenciadorcaixas.repository.FuncionarioRepository
import br.unipar.gerenciadorcaixas.repository.VendaRepository
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service

@Service
class FuncionarioService(
    private val repository : FuncionarioRepository,
    private val validar : ValidarCpf,
    private val vendaRepository : VendaRepository
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

        fun atualizar(id: Long, funcionario: Funcionario): ResponseEntity<String> {
            val resposta = repository.findById(id).orElseThrow {
                NoSuchElementException("O $id digitado não é válido")
            }
            if(funcionario.cidade.isBlank()){
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Cidade não pode ser vazia")
            }
            //so valida o cpf se mudou
            if(funcionario.cpf != resposta.cpf && !validar.validarCpfViaAPI(funcionario.cpf)){
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("CPF inválido")
            }
            //nao muda o cargo se ja tiver venda com o cargo atual
            if(funcionario.cargo != resposta.cargo){
                val vendas = if(resposta.cargo == Cargo.VENDEDOR) vendaRepository.countByVendedor(resposta)
                    else vendaRepository.countByInstalador(resposta)
                if(vendas > 0){
                    return ResponseEntity.status(HttpStatus.CONFLICT)
                        .body("Não é possível mudar o cargo: o funcionário já está em $vendas venda(s)")
                }
            }
            val atualizado = Funcionario(resposta.id, funcionario.cpf, funcionario.nome, funcionario.telefone,
                funcionario.email, funcionario.dataNascimento, funcionario.cep, funcionario.logradouro,
                funcionario.numero, funcionario.bairro, funcionario.cidade, funcionario.uf, funcionario.salario,
                funcionario.cargo, funcionario.dataAdmissao, funcionario.ativo)
            repository.save(atualizado)
            return ResponseEntity.status(HttpStatus.OK).body("Funcionário foi atualizado!")

        }

        fun excluir(id: Long): ResponseEntity<Void> {
            repository.deleteById(id)
            return ResponseEntity.noContent().build()

        }
}
