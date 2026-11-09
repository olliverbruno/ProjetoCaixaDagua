package br.unipar.gerenciadorcaixas.controller

import br.unipar.gerenciadorcaixas.model.CaixaDAgua
import br.unipar.gerenciadorcaixas.service.CaixaDAguaService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.CrossOrigin
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController

@RestController
@CrossOrigin(origins = ["*"])
class CaixaDAguaController (
    private val servico : CaixaDAguaService
){

    @GetMapping("/listar")
    fun listar() : ResponseEntity<List<CaixaDAgua>>{
        return servico.listar()

    }

    @GetMapping("/marcas/{marca}")
    fun buscarMarca(@PathVariable marca : String)
    : ResponseEntity<List<CaixaDAgua>>{
        return ResponseEntity.ok(servico.buscarMarca(marca))
    }

    //Para criar variáveis na URL use {}
    @GetMapping("/buscar/{id}")
    fun buscar(@PathVariable id : Long) : ResponseEntity<CaixaDAgua>{
        return servico.buscar(id)
    }

    @PostMapping("/salvar")
    fun salvar(@RequestBody caixa : CaixaDAgua) : ResponseEntity<String> {
        return servico.salvar(caixa)

    }

    @PutMapping("/atualizar/{id}")
    fun atualizar(@PathVariable id : Long, @RequestBody caixa : CaixaDAgua) : ResponseEntity<String> {
        return servico.atualizar(id, caixa)

    }

    @DeleteMapping("/excluir/{id}")
    fun excluir(@PathVariable id : Long) :ResponseEntity<Void>{
        return servico.excluir(id)
    }
}