package br.unipar.gerenciadorcaixas.controller

import br.unipar.gerenciadorcaixas.service.RelatorioPessoaService
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.CrossOrigin
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@CrossOrigin(origins = ["*"])
@RequestMapping("/relatorio")
class RelatorioController(
    private val service: RelatorioPessoaService
) {

    @GetMapping("/pessoa", produces = [MediaType.APPLICATION_PDF_VALUE])
    fun baixarRelatorio(): ResponseEntity<ByteArray> {
        val pdf = service.gerarRelatorio()

        val headers = HttpHeaders().apply {
            //tipo PDF
            contentType = MediaType.APPLICATION_PDF
            //baixa o arquivo com esse nome
            setContentDispositionFormData("attachment", "relatorio-pessoas.pdf")
        }

        return ResponseEntity.ok()
            .headers(headers)
            .body(pdf)
    }
}
