package br.unipar.gerenciadorcaixas.controller

import br.unipar.gerenciadorcaixas.model.Funcionario
import br.unipar.gerenciadorcaixas.service.FuncionarioService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.CrossOrigin
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@CrossOrigin(origins = ["*"])
@RequestMapping("/funcionario")
class FuncionarioController (
    private val servico : FuncionarioService
){

    @GetMapping("/listar")
    fun listar() : ResponseEntity<List<Funcionario>>{
        return servico.listar()

    }

    //Para criar variáveis na URL use {}
    @GetMapping("/buscar/{id}")
    fun buscar(@PathVariable id : Long) : ResponseEntity<Funcionario>{
        return servico.buscar(id)
    }

    @PostMapping("/salvar")
    fun salvar(@RequestBody funcionario : Funcionario) : ResponseEntity<String> {
        return servico.salvar(funcionario)

    }

    @DeleteMapping("/excluir/{id}")
    fun excluir(@PathVariable id : Long) :ResponseEntity<Void>{
        return servico.excluir(id)
    }
}
