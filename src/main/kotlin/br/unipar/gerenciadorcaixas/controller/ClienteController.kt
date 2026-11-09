package br.unipar.gerenciadorcaixas.controller

import br.unipar.gerenciadorcaixas.model.Cliente
import br.unipar.gerenciadorcaixas.service.ClienteService
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
@RequestMapping("/cliente")
class ClienteController (
    private val servico : ClienteService
){

    @GetMapping("/listar")
    fun listar() : ResponseEntity<List<Cliente>>{
        return servico.listar()

    }

    //Para criar variáveis na URL use {}
    @GetMapping("/buscar/{id}")
    fun buscar(@PathVariable id : Long) : ResponseEntity<Cliente>{
        return servico.buscar(id)
    }

    @PostMapping("/salvar")
    fun salvar(@RequestBody cliente : Cliente) : ResponseEntity<String> {
        return servico.salvar(cliente)

    }

    @DeleteMapping("/excluir/{id}")
    fun excluir(@PathVariable id : Long) :ResponseEntity<Void>{
        return servico.excluir(id)
    }
}
