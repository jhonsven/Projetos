#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.CH"

//////////////////////////////////////////////////////////
// Autor: JOAO VICTOR                                   //
// Empresa: JVC INFO                                    //
// Funcao: M410PVNF                                     // 
// Descricao: Importação de excel dos itens do pedido   //
//            de compra                                 //
// Data: 16/08/2022                                     //
//////////////////////////////////////////////////////////

//Posições do Array
Static nPosprod   := 1 //Coluna A no Excel
Static nPostes    := 2 //Coluna B no Excel
Static nPosquant  := 3 //Coluna C no Excel
Static nPosprcuni := 4 //Coluna D no Excel
Static nPosfornec := 5 //Coluna E no Excel
Static nPoscondpag:= 6 //Coluna F no Excel


User Function zImpCSVCOM()
	Local aArea     := GetArea()

	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| fImporta() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
 
Static Function fImporta()
    Local aArea      := GetArea()
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local oArquivo
    Local aLinhas

    Local cProd := ""
    Local cTes  := ""
    Local cQuant:= ""
    Local cPrcuni := ""
    Local cForne:= ""
    Local cPag  := ""

    Local aItens := {}
    Local nX := 0
    Local aCab1 := {}
    Local aItn1 := {}
   
    Private lMsErroAuto := .F.
    Private cDirLog    := GetTempPath() + "x_importacao\"
    Private cLog       := ""
     
    //Se a pasta de log não existir, cria ela
    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf
 
    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
     
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
 
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
 
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
             
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()
 
            While (oArquivo:HasLine())
 
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, ";")

                If !("produto" $ Lower(cLinAtu))
 
                    cProd  := aLinha[nPosprod]
                    cTes   := aLinha[nPostes]
                    cQuant := aLinha[nPosquant]
                    cPrcuni:= aLinha[nPosprcuni]
                    cForne := aLinha[nPosfornec]
                    cPag   := aLinha[nPoscondpag]
                    aadd(aCab1, {cForne, cPag})
                    aadd(aItn1, {cProd, cTes, cQuant, cPrcuni})
                   
                EndIf
                 
            EndDo
 
        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf
    endif    


For nX := 1 To len(aItn1)
aLinha := {}
aadd(aLinha,{"C7_PRODUTO" ,aItn1[nX][1] ,Nil})
aadd(aLinha,{"C7_TES"     ,aItn1[nX][2] ,Nil})
aadd(aLinha,{"C7_QUANT"   ,aItn1[nX][3] ,Nil})
aadd(aLinha,{"C7_PRECO"   ,aItn1[nX][4] ,Nil})
aadd(aItens,aLinha)

Next nX


 oArquivo:Close()
    

 RestArea(aArea)

Return


