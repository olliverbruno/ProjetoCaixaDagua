package br.unipar.gerenciadorcaixas.controller

import br.unipar.gerenciadorcaixas.model.Marca
import br.unipar.gerenciadorcaixas.service.MarcaService
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
@RequestMapping("/marca")
class MarcaController (
    private val servico : MarcaService
){

    @GetMapping("/listar")
    fun listar() : ResponseEntity<List<Marca>>{
        return servico.listar()

    }

    //Para criar variáveis na URL use {}
    @GetMapping("/buscar/{id}")
    fun buscar(@PathVariable id : Long) : ResponseEntity<Marca>{
        return servico.buscar(id)
    }

    @PostMapping("/salvar")
    fun salvar(@RequestBody marca : Marca) : ResponseEntity<String> {
        return servico.salvar(marca)

    }

    @PutMapping("/atualizar/{id}")
    fun atualizar(@PathVariable id : Long, @RequestBody marca : Marca) : ResponseEntity<String> {
        return servico.atualizar(id, marca)

    }

    @DeleteMapping("/excluir/{id}")
    fun excluir(@PathVariable id : Long) :ResponseEntity<String>{
        return servico.excluir(id)
    }
}
