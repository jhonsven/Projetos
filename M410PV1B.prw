#Include "TOTVS.ch"
#Include "TBICONN.ch"
#Include "TOPCONN.CH"
#Include "Protheus.ch"

//////////////////////////////////////////////////////////
// Autor: JOAO VICTOR                                   //
// Empresa: JVC INFO                                    //
// Funcao: M410PV1B                                     // 
// Descricao: Faz a separa√ß√£o dos itens nos pedidos de//
//              venda                                   //
// Data: 16/08/2022                                     //
//////////////////////////////////////////////////////////

User Function M410PV1B()
	local aArea  := GetArea()

	local cC5num := ""
	local cTipo  := ""
	local cLoja  := ""
	Local cC5Loj := ""
	local cCdpg  := ""
	local cVend  := ""
	local cTran  := ""
	local cMent  := ""
	local cC5cli := ""
	local cC5emi := ""
	local cC5bai := ""
	local cQryC6 := ""
	local cQryC5 := ""

	Local aCabc       := {}
	local aItensMeee  := {}
	Local aItensExec  := {}
	Local aItems      := {}
	local aItensPAaa  := {}


	local nXi        := 1
	local nX         := 1

	Local aLogAuto := {}
	Local cLogTxt  := ""
	Local nAux     := 0

	Private aPvs    := {}
	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .T.
	Private lAutoErrNoFile  := .T.



	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "12" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
	ConOut("TESTEX - START - FILIAL : " + XFILIAL("SC5") )

	//cQryC5 := "SELECT C5_FILIAL,C5_NUM,C5_CLIENTE,C5_EMISSAO,C5_TIPO,C5_LOJAENT,C5_LOJACLI,C5_CONDPAG,C5_VEND1,C5_TRANSP,C5_MENNOTA,C5_XJOBCK,R_E_C_N_O_ "
	//cQryC5 += " FROM SC5010 WHERE C5_EMISSAO = '"+DTOS(DaySub(Date(), 1))+"' AND C5_FILIAL = '1B' AND C5_XJOBCK <> 'S' AND D_E_L_E_T_ <> '*' AND C5_NOTA = ' ' AND C5_LIBEROK = ' '"
    
	cQryC5 := "SELECT C5_FILIAL,C5_NUM,C5_CLIENTE,C5_EMISSAO,C5_TIPO,C5_LOJAENT,C5_LOJACLI,C5_CONDPAG,C5_VEND1,C5_TRANSP,C5_MENNOTA,C5_XJOBCK,R_E_C_N_O_ , C5_XBAIR"
	cQryC5 += " FROM SC5010 WHERE C5_EMISSAO > '20221020' AND C5_FILIAL = '1B' AND C5_XJOBCK <> 'S' AND D_E_L_E_T_ <> '*' AND C5_NOTA = ' ' AND C5_LIBEROK = ' '"



	TCQUERY cQryC5 NEW ALIAS "QRY5"


	while QRY5->(!EoF())

		aadd(aPvs, {QRY5->C5_NUM, QRY5->C5_TIPO, QRY5->C5_CLIENTE, QRY5->C5_LOJACLI, QRY5->C5_LOJAENT,QRY5->C5_CONDPAG,QRY5->C5_VEND1,QRY5->C5_TRANSP,QRY5->C5_MENNOTA,QRY5->C5_EMISSAO,QRY5->R_E_C_N_O_,QRY5->C5_XBAIR})
		QRY5->(DbSkip())

	enddo

	ConOut(len(aPvs))


	if len(aPvs) >= 1

		for nX := 1 to len(aPvs)

		 PREPARE ENVIRONMENT EMPRESA "01" FILIAL "12" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
	     ConOut("TESTEX - START - FILIAL : " + XFILIAL("SC5") )

			cC5num := aPvs[nX][1]
			cTipo  := aPvs[nX][2]
			cC5cli := aPvs[nX][3]
			cC5Loj := aPvs[nX][4]
			cLoja  := aPvs[nX][5]
			cCdpg  := aPvs[nX][6]
			cVend  := aPvs[nX][7]
			cTran  := aPvs[nX][8]
			cMent  := AllTrim(aPvs[nX][9])
			cC5emi := aPvs[nX][10]
			cC5rec := aPvs[nX][11]
			cC5bai := AllTrim(aPvs[nX][12])



			cQryC6 := " SELECT C6_ITEM,C6_PRODUTO,C6_QTDVEN,C6_QTDLIB,C6_QTDENT,C6_PRUNIT,C6_PRCVEN,C6_UM,C6_VALOR,C6_PEDCLI, R_E_C_N_O_ "
			cQryC6 += "  FROM " + RetSQLName("SC6")  + " "
			cQryC6 += " WHERE C6_FILIAL = '1B'  AND  C6_NUM = '"+cC5num+"' AND C6_CLI = '"+cC5cli+"'"
			cQryC6 += "  AND C6_LOJA = '" + cC5Loj + "' AND D_E_L_E_T_ <> '*' "

			TCQUERY cQryC6 NEW ALIAS "QRY6"

			aItensMeee := {}
			aItensPAaa := {}

			while !QRY6->(EoF())

				if left(AllTrim(C6_PRODUTO), 2) == "13" //me
					aadd(aItensMeee, {QRY6->C6_ITEM,QRY6->C6_PRODUTO,QRY6->C6_QTDVEN, QRY6->C6_QTDLIB,QRY6->C6_QTDENT, QRY6->C6_PRUNIT, QRY6->C6_PRCVEN,QRY6->C6_UM, QRY6->C6_VALOR,QRY6->C6_PEDCLI,QRY6->R_E_C_N_O_ })
				else
					aadd(aItensPAaa, {QRY6->C6_ITEM,QRY6->C6_PRODUTO,QRY6->C6_QTDVEN, QRY6->C6_QTDLIB,QRY6->C6_QTDENT, QRY6->C6_PRUNIT, QRY6->C6_PRCVEN,QRY6->C6_UM, QRY6->C6_VALOR,QRY6->C6_PEDCLI,QRY6->R_E_C_N_O_  })
				endif

				QRY6->(DbSkip())

			enddo




			if EMPTY(aItensMeee)

				SC5->(DbSetOrder(1))
				SC5->(DbGoTo(cC5rec))

				SC5->(RecLock("SC5",.F.))
				SC5->C5_XJOBCK := "S"      //marcaÁ„o para n„o processar o registro novamente
				SC5->(MsUnlock())

				QRY6->(DbCloseArea())
				

				loop

			endif

			QRY6->(DbCloseArea())



			aCabc := {}
			AAdd(aCabc, {"C5_TIPO"   , cTipo , NIL})
			AAdd(aCabc, {"C5_CLIENTE", cC5cli, NIL})
			AAdd(aCabc, {"C5_LOJAENT", cLoja , NIL})
			AAdd(aCabc, {"C5_CONDPAG", cCdpg , NIL})
			AAdd(aCabc, {"C5_VEND1"  , cVend , NIL})
			AAdd(aCabc, {"C5_TRANSP" , cTran , NIL})
			AAdd(aCabc, {"C5_MENNOTA", cMent , NIL})
			AAdd(aCabc, {"C5_TABELA" , "001" , NIL})
			AAdd(aCabc, {"C5_XBAIR"  , cC5bai, NIL})
			AAdd(aCabc, {"C5_XJOBCK" ,  "S"  , NIL})


			aItems  := {}
			For nXi := 1  to len(aItensMeee)
				aItensExec := {}
				AAdd(aItensExec, {"C6_ITEM"   , StrZero(nXi,2)    , NIL})
				AAdd(aItensExec, {"C6_PRODUTO", aItensMeee[nXi][2], NIL})
				AAdd(aItensExec, {"C6_QTDVEN" , aItensMeee[nXi][3], NIL})
				AAdd(aItensExec, {"C6_QTDLIB" , aItensMeee[nXi][4], NIL})
				AAdd(aItensExec, {"C6_QTDENT" , aItensMeee[nXi][5], NIL})
				AAdd(aItensExec, {"C6_PRUNIT" , aItensMeee[nXi][9]/aItensMeee[nXi][3], NIL})
				AAdd(aItensExec, {"C6_PRCVEN" , aItensMeee[nXi][9]/aItensMeee[nXi][3], NIL})    //AAdd(aItensExec, {"C6_PRCVEN" , aItensMeee[nXi][7], NIL})
				AAdd(aItensExec, {"C6_UM"     , aItensMeee[nXi][8], NIL})
				AAdd(aItensExec, {"C6_VALOR"  , aItensMeee[nXi][9], NIL})
				AAdd(aItensExec, {"C6_OPER"   , "03"              , NIL})
				//AAdd(aItensExec, {"C6_TES"  , "530"             , NIL})
				AAdd(aItensExec, {"C6_PEDCLI" , aItensMeee[nXi][10], NIL})
				AAdd(aItems, aItensExec)

			next nXi

			MsExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabc, aItems, 3, .F.)

			If  lMsErroAuto


				ConOut(Repl("-", 80))
				ConOut(PadC("MATA410 automatic routine ended with error", 80))
				ConOut(PadC("Ended at: " + Time(), 80))
				ConOut(Repl("-", 80))

				aLogAuto := GetAutoGRLog()


//Percorrendo o Log e incrementando o texto (para usar o CRLF vocÍ deve usar a include "Protheus.ch")

		For nAux := 1 To Len(aLogAuto)
			cLogTxt += aLogAuto[nAux] + CRLF
		Next
//Criando o arquivo txt

		ConOut(cLogTxt)

			Else

				ConOut(Repl("-", 80))
				ConOut(PadC("MATA410 automatic routine successfully ended", 80))
				ConOut(PadC("Ended at: " + Time(), 80))
				ConOut(Repl("-", 80))


				EXCLUIPV410(cC5num, cTipo, cC5cli, cLoja, cCdpg, cVend, cTran, cMent,cC5bai, aItensPAaa) //exclui pedido da 1B

			EndIf

         RESET ENVIRONMENT
		next
	endif

	RestArea(aArea)
	

Return






Static Function EXCLUIPV410(cC5num, cTipo, cC5cli, cLoja, cCdpg, cVend, cTran, cMent,cC5bai, aItensPAaa)

	local aItems := {}
	Local aLogAuto := {}
	Local cLogTxt  := ""
	Local nAux     := 0

	RESET ENVIRONMENT
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "1B" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
	ConOut("TESTEX - START - FILIAL : " + XFILIAL("SC5") )


	aCabc := {}
	AAdd(aCabc, {"C5_FILIAL" ,  "1B" , NIL})
	AAdd(aCabc, {"C5_NUM"    , cC5num, NIL})
	AAdd(aCabc, {"C5_TIPO"   , cTipo , NIL})
	AAdd(aCabc, {"C5_CLIENTE", cC5cli, NIL})
	AAdd(aCabc, {"C5_LOJAENT", cLoja , NIL})
	AAdd(aCabc, {"C5_CONDPAG", cCdpg , NIL})
	//AAdd(aCabc, {"C5_VEND1"  , cVend , NIL})
	//AAdd(aCabc, {"C5_TRANSP" , cTran , NIL})
	//AAdd(aCabc, {"C5_MENNOTA", cMent , NIL})


	MsExecAuto({|a, b, c| MATA410(a, b, c)}, aCabc, aItems, 5)

	ConOut("TESTEX - START - EXCLUSAO : " +aCabc[2][2] + aCabc[3][2] + aCabc[4][2])

	If  lMsErroAuto


		ConOut(Repl("-", 80))
		ConOut(PadC("MATA410 automatic EXCLUSAO ended with error", 80))
		ConOut(PadC("Ended at: " + Time(), 80))
		ConOut(Repl("-", 80))

		aLogAuto := GetAutoGRLog()


//Percorrendo o Log e incrementando o texto (para usar o CRLF vocÍ deve usar a include "Protheus.ch")

		For nAux := 1 To Len(aLogAuto)
			cLogTxt += aLogAuto[nAux] + CRLF
		Next
//Criando o arquivo txt

		ConOut(cLogTxt)


	Else

		ConOut(Repl("-", 80))
		ConOut(PadC("MATA410 automatic EXCLUSAO successfully ended", 80))
		ConOut(PadC("Ended at: " + Time(), 80))
		ConOut(Repl("-", 80))

		ConOut(len(aItensPAaa))

		if len(aItensPAaa) > 0

			ConOut(Repl("-", 80))
			ConOut(PadC("Recriando pedido na 1B", 80))
			ConOut(PadC("Ended at: " + Time(), 80))
			ConOut(Repl("-", 80))


			CRIAPV1B(cTipo, cC5cli, cLoja, cCdpg, cVend, cTran, cMent,cC5bai, aItensPAaa) //cria na 1B se houver itens PA
		endif

	EndIf

return




Static Function CRIAPV1B(cTipo, cC5cli, cLoja, cCdpg, cVend, cTran, cMent,cC5bai, aItensPAaa)

	local nXi       := 0
	local aItems    := {}
	local aCabc     := {}
	local aItensExec := {}
	Local aLogAuto := {}
	Local cLogTxt  := ""
	Local nAux     := 0



	aCabc := {}
	AAdd(aCabc, {"C5_TIPO"   , cTipo , NIL})
	AAdd(aCabc, {"C5_CLIENTE", cC5cli, NIL})
	AAdd(aCabc, {"C5_LOJAENT", cLoja , NIL})
	AAdd(aCabc, {"C5_CONDPAG", cCdpg , NIL})
	AAdd(aCabc, {"C5_VEND1"  , cVend , NIL})
	AAdd(aCabc, {"C5_TRANSP" , cTran , NIL})
	AAdd(aCabc, {"C5_MENNOTA", cMent , NIL})
	AAdd(aCabc, {"C5_XBAIR"  , cC5bai, NIL})
	AAdd(aCabc, {"C5_TABELA" , "001" , NIL})
	AAdd(aCabc, {"C5_XJOBCK" ,  "S"  , NIL})

	aItems := {}
	For nXi := 1  to len(aItensPAaa)
		aItensExec := {}
		AAdd(aItensExec, {"C6_ITEM"   , StrZero(nXi,2)     , NIL})
		AAdd(aItensExec, {"C6_PRODUTO", aItensPAaa[nXi][2] , NIL})
		AAdd(aItensExec, {"C6_QTDVEN" , aItensPAaa[nXi][3] , NIL})
		AAdd(aItensExec, {"C6_QTDLIB" , aItensPAaa[nXi][4] , NIL})
		AAdd(aItensExec, {"C6_QTDENT" , aItensPAaa[nXi][5] , NIL})
		AAdd(aItensExec, {"C6_PRUNIT" , aItensPAaa[nXi][9]/aItensPAaa[nXi][3] , NIL})
		AAdd(aItensExec, {"C6_PRCVEN" , aItensPAaa[nXi][9]/aItensPAaa[nXi][3] , NIL})
		AAdd(aItensExec, {"C6_UM"     , aItensPAaa[nXi][8] , NIL})
		AAdd(aItensExec, {"C6_VALOR"  , aItensPAaa[nXi][9] , NIL})
		AAdd(aItensExec, {"C6_OPER"   , "03"               , NIL})
		AAdd(aItensExec, {"C6_PEDCLI" , aItensPAaa[nXi][10], NIL})
		AAdd(aItems, aItensExec)

	next nXi

	MsExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabc, aItems, 3, .F.)

	If  lMsErroAuto

		ConOut(Repl("-", 80))
		ConOut(PadC("MATA410 automatic routine ended with error 1B", 80))
		ConOut(PadC("Ended at: " + Time(), 80))
		ConOut(Repl("-", 80))

		aLogAuto := GetAutoGRLog()

		For nAux := 1 To Len(aLogAuto)
			cLogTxt += aLogAuto[nAux] + CRLF
		Next

		ConOut(cLogTxt)

	Else

		ConOut(Repl("-", 80))
		ConOut(PadC("MATA410 automatic routine successfully ended 1B", 80))
		ConOut(PadC("Ended at: " + Time(), 80))
		ConOut(Repl("-", 80))

	EndIf

return
