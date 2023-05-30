#include "totvs.ch"
#include "fwmvcdef.ch"
#include "restful.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} Produtos1
API para cadastro de clientes
@version 1.0
*/
//-------------------------------------------------------------------
WSRESTFUL CADCLI0 DESCRIPTION "Serviço REST para cadastro de Clientes"

	WSMETHOD POST DESCRIPTION "Post Cliente" WSSYNTAX "/CADCLI0" PRODUCES APPLICATION_JSON 

END WSRESTFUL



WSMETHOD POST WSRECEIVE RECEIVE WSSERVICE CADCLI0

	Local cJSON := Self:GetContent() // Pega a string do JSON
	Local oParseJSON := Nil
	Local aDadosCli := {} //–> Array para ExecAuto do MATA030
	//Local cFileLog := ""
	Local cJsonRet := ""
	Local cArqLog := ""
	Local cErro   := ""
	Local lRet    := .T.
	Local aLog := {}
	Local nY := 1


	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.
	Private lAutoErrNoFile := .T.

// –> Cria o diretório para salvar os arquivos de log

	If !ExistDir("\log_cli")

		MakeDir("\log_cli")

	EndIf

// –> Deserializa a string JSON

	FWJsonDeserialize(cJson, @oParseJSON)

	SA1->( DbSetOrder(3) )

	If !(SA1->( DbSeek( xFilial("SA1") + oParseJSON:CLIENTE:CGC ) ))

		Aadd(aDadosCli, {"A1_LOJA"    , "01"                                            , Nil} )
		Aadd(aDadosCli, {"A1_CGC"     , oParseJSON:CLIENTE:CGC                          , Nil} )
		Aadd(aDadosCli, {"A1_NOME"    , oParseJSON:CLIENTE:NOME                         , Nil} )
		Aadd(aDadosCli, {"A1_NREDUZ"  , oParseJSON:CLIENTE:NOME                         , Nil} )
		Aadd(aDadosCli, {"A1_CEP"     , oParseJSON:CLIENTE:CEP                          , Nil} )
		Aadd(aDadosCli, {"A1_XNUMERO" , oParseJSON:CLIENTE:NUMERO                       , Nil} )
		Aadd(aDadosCli, {"A1_XEND"    , FwCutOff(oParseJSON:CLIENTE:ENDERECO , .T. )    , Nil} )
		Aadd(aDadosCli, {"A1_BAIRRO"  , oParseJSON:CLIENTE:BAIRRO                       , Nil} )
		Aadd(aDadosCli, {"A1_PESSOA"  , Iif(Len(oParseJSON:CLIENTE:CGC)== 11, "F", "J") , Nil} )
		Aadd(aDadosCli, {"A1_EST"     , oParseJSON:CLIENTE:ESTADO                       , Nil} )
		Aadd(aDadosCli, {"A1_COD_MUN" , oParseJSON:CLIENTE:CODMUNI                      , Nil} )
		Aadd(aDadosCli, {"A1_MUN"     , oParseJSON:CLIENTE:MUNICIPIO                    , Nil} )
		Aadd(aDadosCli, {"A1_TIPO"    , "F"                                             , Nil} )
		Aadd(aDadosCli, {"A1_TEL"     , oParseJSON:CLIENTE:TELEFONE                     , Nil} )
		Aadd(aDadosCli, {"A1_DTNASC"  , STOD(oParseJSON:CLIENTE:NASCIMENTO)             , Nil} )
		Aadd(aDadosCli, {"A1_XPESQ"   , oParseJSON:CLIENTE:PESQUISA                     , Nil} )
		Aadd(aDadosCli, {"A1_EMAIL"   , oParseJSON:CLIENTE:EMAIL                        , Nil} )

	
		

		MsExecAuto({|x,y| MATA030(x,y)}, aDadosCli, 3)

		If lMsErroAuto

			aLog        := GetAutoGRLog()
			For nY := 1 To Len(aLog)
				If !Empty(cErro)
					cErro += CRLF
				EndIf
				cErro += aLog[nY]
			Next nY

			SetRestFault(400, cErro,.T.)
			lRet := .F.

		Else

	
			cJSONRet := '{"cod_cli":"' + SA1->A1_COD + '"' +'}'
			::SetResponse( cJSONRet )

		EndIf

	Else

		SetRestFault(400, "Cliente já cadastrado: " + SA1->A1_COD + " – " + SA1->A1_NOME)
		lRet := .F.

	EndIf

Return(lRet)



