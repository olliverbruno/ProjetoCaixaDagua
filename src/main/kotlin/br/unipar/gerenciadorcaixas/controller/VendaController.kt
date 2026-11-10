package br.unipar.gerenciadorcaixas.controller

import br.unipar.gerenciadorcaixas.model.Venda
import br.unipar.gerenciadorcaixas.service.VendaService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.CrossOrigin
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@CrossOrigin(origins = ["*"])
@RequestMapping("/venda")
class VendaController (
    private val servico : VendaService
){

    @GetMapping("/listar")
    fun listar() : ResponseEntity<List<Venda>>{
        return servico.listar()

    }

    //Para criar variáveis na URL use {}
    @GetMapping("/buscar/{id}")
    fun buscar(@PathVariable id : Long) : ResponseEntity<Venda>{
        return servico.buscar(id)
    }

    @PostMapping("/salvar")
    fun salvar(@RequestBody venda : Venda) : ResponseEntity<String> {
        return servico.salvar(venda)

    }

    @PutMapping("/atualizar/{id}")
    fun atualizar(@PathVariable id : Long, @RequestBody venda : Venda) : ResponseEntity<String> {
        return servico.atualizar(id, venda)

    }

    @DeleteMapping("/excluir/{id}")
    fun excluir(@PathVariable id : Long) :ResponseEntity<Void>{
        return servico.excluir(id)
    }
}
