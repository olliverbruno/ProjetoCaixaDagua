package br.unipar.gerenciadorcaixas.service

import br.unipar.gerenciadorcaixas.repository.PessoaRepository
import net.sf.jasperreports.engine.JasperCompileManager
import net.sf.jasperreports.engine.JasperExportManager
import net.sf.jasperreports.engine.JasperFillManager
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource
import java.io.InputStream
import org.springframework.stereotype.Service

@Service
class RelatorioPessoaService(
    private val repository: PessoaRepository
) {

    fun gerarRelatorio(): ByteArray {
        val pessoas = repository.findAll()
        val arquivo: InputStream = this.javaClass.getResourceAsStream("/relatorios/pessoa_relatorio.jrxml")
            ?: throw RuntimeException("Arquivo nao encontrado")

        //transformar os dados em uma fonte preenchivel pelo jasper
        val dados = JRBeanCollectionDataSource(pessoas)

        val relatorio = JasperCompileManager.compileReport(arquivo)
        val parametros = HashMap<String, Any>()
        //preenche com as pessoas
        val preencherRelatorio = JasperFillManager.fillReport(relatorio, parametros, dados)
        return JasperExportManager.exportReportToPdf(preencherRelatorio)

    }
}
