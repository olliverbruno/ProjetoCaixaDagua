package br.unipar.gerenciadorcaixas.service

import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate

@Service
class ValidarCpf(
    //Para conectar uma API precisa:

    //Chave token
    private val token : String = "cole-seu-token-aqui", //token pego no site depois do cadastro
    // URL
    private val url : String = "https://api.cpf-brasil.org/"
) {
    //Template
    private val restTemplate = RestTemplate()

    fun validarCpfViaAPI(cpf : String) : Boolean {
        try {
            val cpfLimpo = cpf.replace(Regex("[^0-9]"), "")
            if (cpfLimpo.length != 11)
            return false

            //Essa API precisa de um Header
            val header = HttpHeaders().apply() {
                set("X-API-Key", token)
                set("Content-Type", "application/json")
            }

            val conn = HttpEntity<Void>(header)


            //CPF vai direto na URL
            val urlCompleta = "${url}cpf/$cpfLimpo"
            val resposta : ResponseEntity<String> = restTemplate.exchange(
                urlCompleta,
                HttpMethod.GET,
                conn,
                String::class.java
            )
            println("Conexão bem sucedida, status: ${resposta.statusCode}")
            return resposta.statusCode == HttpStatus.OK

        }catch (e : Exception){
            println("Deu Erro: ${e.message}")
            return false
        }
    }
}