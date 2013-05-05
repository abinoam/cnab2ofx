
cnab2ofx 
========

**cnab2ofx** é script simples em [Ruby][1] que serve para converter extratos bancários no formato CNAB240 para o formato ofx.
A Unicred emite extratos nesse formato.

[CNAB240][2] é o formato padrão da [FEBRABAN][3] (Federação Brasileira de Bancos) utilizado para gerar extratos dentre outras transações bancárias.
[OFX][4] é a sigla do "Open Financial Exchange" e é o que permite a importação de extratos bancários para softwares como o  [GnuCash][5], [Microsoft Money][6] e [Quicken][7].

**Uso:**

    cnab2ofx [extrato_cnab240] > [arquivo_ofx]

---------------------------------------

cnab2ofx
========
[**English**]

**cnab2ofx** is a simple [Ruby][1] script that can be used to convert from CNAB240 to ofx.

[CNAB240][2] is a brazilian account statement format by [FEBRABAN][3] (Brazilian Bank Federation).
[OFX][4] stands for Open Financial Exchange and can be used to allow financial softwares as [GnuCash][5], [Microsoft Money][6] and [Quicken][7] to import bank statemnts.

**Usage:**

    cnab2ofx [cnab240_bank_statement_file] > [ofx_output_file]
    
     
[1]: http://ruby-lang.org/ "Ruby Language"
[2]: http://www.febraban.org.br/Acervo1.asp?id_texto=717&id_pagina=173 "CNAB240"
[3]: http://www.febraban.org.br "Febraban"
[4]: http://www.ofx.net/ "Open Financial Exchange"
[5]: http://www.gnucash.org/ "GnuCash - Free Accounting Software"
[6]: http://support.microsoft.com/kb/2118008 "Microsoft Money"
[7]: http://quicken.intuit.com/ "Quicken"
