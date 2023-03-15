//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

Static nCorCinza := RGB(110, 110, 110)
Static nCorAzul  := RGB(193, 231, 253)



/*/
+-----------------------------------------------------------------------------
| Programa  | MRP002	 | Autor | clayson alves   | Data |       16/03/2022 |
+-----------------------------------------------------------------------------
| Relatório zebrado mostrando a visão geral da filial(loja) no qual este é   |
|  solicitado.              			                                     |
+-----------------------------------------------------------------------------
|                             |                                              |
+-----------------------------------------------------------------------------
/*/



User Function RERAIOX()
	Local aPergs       := {}
	local CodeUsr      := UsrRetName(RetCodUsr())
	Private cFiliate1  := cFilAnt
	Private cBancosald := "000"


	SA6->(DbSetOrder(2))
	if SA6->(DbSeek(xFilial("SA6")+ CodeUsr))
		cBancosald := AllTrim(SA6->A6_COD)
	endif


	//Monta os parâmetros da tela
	aAdd(aPergs, {1, "FILIAL",     cFiliate1,  "@!",                  ".T.", , ".T.", 90,   .F.})
	aAdd(aPergs, {1, "CAIXA",      cBancosald,  "@!",                  ".T.", "SA6", ".T.", 90,   .F.})


	//Se a pergunta for confirmada
	If ParamBox(aPergs, "Informe os parâmetros", , , , , , , , , .F., .F.)
		cFiliate1  := MV_PAR01
		cBancosald := MV_PAR02
		Processa({|| fImprime()})
	EndIf
Return



Static Function fImprime()
	Local aArea        := GetArea()
	Local cArquivo     := "RAIOX_"+RetCodUsr()+"_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".pdf"
	Local nTotAux      := 0
	Local nAtuAux      := 0
	Local nFlag1       := 0
	Local nTotMeta     := 0
	Local nTotVend     := 0 
	Local nVendAlug    := 0

	Local nTotVend1     := 0
	Local nTotVend2     := 0
	Local nTotVend3     := 0
	Local nTotVend4     := 0
	Local nTotVend5     := 0 
	Local nPorcen       := 0
	Local nPorcentot    := 0

	Local cData1 := " "
	Local cData2 := " "
	Local cData3 := " "


	Local cQryAux      := " "
	Local cQryAux1     := " "
	Local cQryAux2     := " "
	Local cQryAux3     := " "
	Local cQryAux4     := " "
	Local cQryAux5     := " "
	Local cQryAux6     := " "
	Local cQryAux7     := " "
	Local cQryAux8     := " "
	Local cQryAux9     := " "
	Local _QryAux      := GetNextAlias()
	Local _QryAux1     := GetNextAlias()
	Local _QryAux2     := GetNextAlias()
	Local _QryAux3     := GetNextAlias()
	Local _QryAux4     := GetNextAlias()
	Local _QryAux5     := GetNextAlias()
	Local _QryAux6     := GetNextAlias()
	Local _QryAux7     := GetNextAlias()
	Local _QryAux8     := GetNextAlias()
	Local _QryAux9     := GetNextAlias()

	Private oPrintPvt
	Private oBrushAzul := TBRUSH():New(,nCorAzul)
	Private cHoraEx    := Time()
	Private nPagAtu    := 1
	//Linhas e colunas
	Private nLinAtu    := 0
	Private nLinFin    := 800
	Private nColIni    := 010
	Private nColFin    := 815
	Private nEspCol    := (nColFin-(nColIni+150))/13
	Private nColMeio   := (nColFin-nColIni)/2
	//Colunas dos relatorio
	Private nColProd    := nColIni
	Private nColDesc    := nColIni + 050
	Private nColUnid    := nColFin - 425
	Private nColTipo    := nColFin - 340
	Private nColBarr    := nColFin - 200
	//Declarando as fontes
	Private cNomeFont  := "Arial"
	Private oFontDet   := TFont():New(cNomeFont, 9, -9,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontDetN  := TFont():New(cNomeFont, 9, -12, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontRod   := TFont():New(cNomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontMin   := TFont():New(cNomeFont, 9, -7,  .T., .F., 5, .T., 5, .T., .F.)
	Private oFontMinN  := TFont():New(cNomeFont, 9, -7,  .T., .T., 5, .T., 5, .T., .F.)
	Private oFontTit   := TFont():New(cNomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.) 
	Private oFontTots  := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)


	Private dDedata   := mv_par01
	Private dAtedata  := mv_par02
	Private oSection  as Object
	Private oSection1 as Object
	Private oSection2 as Object
	Private oSection3 as Object
	Private oSection4 as Object
	Private oSection5 as Object
	Private oSection8 as Object
	Private oBreak    as Object



	//Criando o objeto de impressao
	oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., ,   .T., ,    @oPrintPvt, ,   ,    , ,.T.)
	oPrintPvt:cPathPDF := GetTempPath()
	oPrintPvt:SetResolution(72)
	oPrintPvt:SetPortrait()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	oPrintPvt:SetMargin(0, 0, 0, 0)


	fImpCab()

	//meta mensal x venda por departamento
	cQryAux += " SELECT ct_filial ||' - ' || nome AS FILIALQ, bm_desc AS GRUPO, ct_valor AS META, sum(l2_vlritem+l2_valfre) AS VENDIDO "
	cQryAux += " FROM sct010, filiais, sbm010, sl2010, sl1010, sb1010 WHERE  sct010.D_E_L_E_T_<>'*' AND ct_catego='000001'  "
	cQryAux += " AND ct_data >=( "
	cQryAux += " SELECT to_char(sysdate,'YYYYMM') ||'01' from dual) "
	cQryAux += " AND ct_data <=( "
	cQryAux += " select to_char(sysdate,'YYYYMM') ||'31' from dual) "
	cQryAux += " AND codigo=ct_filial AND bm_grupo=ct_grupo "
	cQryAux += " AND l1_filial=ct_filial "
	cQryAux += " AND l2_filial=ct_filial "
	cQryAux += " AND l1_num=l2_num  "
	cQryAux += " AND l1_filial=l2_filial AND l1_tipo IN ('P','V')  "
	cQryAux += " AND sl1010.D_E_L_E_T_<>'*' AND l2_produto=b1_cod AND l1_tpfret in (' ','F')    "
	cQryAux += " AND l1_emissao >=( "
	cQryAux += " SELECT to_char(sysdate,'YYYYMM') ||'01' from dual) "
	cQryAux += " AND l1_emissao <=( "
	cQryAux += " SELECT to_char(sysdate,'YYYYMM') ||'31' from dual) "
	cQryAux += " AND sl2010.D_E_L_E_T_<>'*' AND sb1010.D_E_L_E_T_<>'*'  "
	cQryAux += " AND l1_filial='"+cFiliate1+"' "
	cQryAux += " AND b1_grupo=bm_grupo GROUP BY  ct_filial,nome,bm_desc,ct_valor "
	cQryAux += " ORDER BY 1,2 "

	TCQuery cQryAux New Alias (_QryAux)

	nFlag1 := 0
	While !(_QryAux)->(EoF())
		nFlag1 += 1


		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif

			oPrintPvt:SayAlign(nLinAtu, nColMeio-320, "META MENSAL x VENDA POR DEPARTAMENTO", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, 10 ,   "FILIAL",      oFontMin,  (nColDesc - nColProd)-10,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 130,   "GRUPO" ,      oFontMin,  (nColDesc - nColProd),      10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 280,   "META"  ,      oFontMin,  (nColUnid - nColDesc)-30,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 420,  "VENDIDO",      oFontMin,  (nColTipo - nColUnid),      10, nCorCinza, PAD_LEFT,  ) 
			oPrintPvt:SayAlign(nLinAtu, 510,  "% ATINGIDO",      oFontMin,  (nColTipo - nColUnid),      10, nCorCinza, PAD_LEFT,  )
		endif
		nLinAtu += 15

		nAtuAux++
		IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")

		//Faz o zebrado ao fundo
		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf 

        nPorcen := Round( ((_QryAux)->VENDIDO * 100)/(_QryAux)->META, 1 )



		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 10 ,                     (_QryAux)->FILIALQ                      ,    oFontDet,  (nColDesc - nColProd)+100,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 130,                     (_QryAux)->GRUPO                        ,    oFontDet,  (nColUnid - nColDesc)    ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 280,   AllTrim(Transform((_QryAux)->META,"@E 999,999,999.99"))   ,    oFontDet,  (nColTipo - nColUnid)    ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 420,   AllTrim(Transform((_QryAux)->VENDIDO,"@E 999,999,999.99")),    oFontDet,  (nColBarr - nColTipo)    ,    10, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, 512,   cValToChar(nPorcen)+"%",    oFontDet,  (nColBarr - nColTipo)    ,    10, , PAD_LEFT,  )
		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza)

		nTotMeta +=(_QryAux)->META
		nTotVend +=(_QryAux)->VENDIDO
		(_QryAux)->(DbSkip())

		if (_QryAux)->(EoF()) 

		 nPorcentot := Round( (nTotVend * 100)/nTotMeta, 1 ) 
		 nVendAlug := nTotVend


			nLinAtu += 18
			oPrintPvt:SayAlign(nLinAtu, 10 ,                 "TOTAL"                           ,    oFontTots,  (nColBarr - nColTipo),    10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 280,   AllTrim(Transform(nTotMeta,"@E 999,999,999.99")),    oFontTots,  (nColBarr - nColTipo),    10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 420,   AllTrim(Transform(nTotVend,"@E 999,999,999.99")),    oFontTots,  (nColBarr - nColTipo),    10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 512,   cValToChar(nPorcentot)+"%",    oFontTots,  (nColBarr - nColTipo),    10, , PAD_LEFT,  )
		endif

	EndDo





//estoque por produtos - CURVA A
cQryAux1 := " SELECT l2_produto AS CODIGO, l2_descri AS Descricao,  b2_qatu AS ESTOQUE , sum(l2_quant)  AS QTDVEN FROM sl1010, sl2010, sb2010 WHERE "  
cQryAux1 += " l2_emissao BETWEEN '"+DTOS(MonthSub(Date(),3))+"' AND '"+DTOS(Date())+"' "
cQryAux1 += " AND l1_tpfret in (' ','F') "
cQryAux1 += " and l1_num=l2_num "
cQryAux1 += " and l1_filial=l2_filial "
cQryAux1 += " and sl1010.D_E_L_E_T_<>'*' "
cQryAux1 += " and sl2010.D_E_L_E_T_<>'*' "
cQryAux1 += " AND b2_filial=l2_filial "
cQryAux1 += " AND l2_produto=b2_cod "
cQryAux1 += " and l1_emissao=l2_emissao "
cQryAux1 += " AND l1_tipo IN ('V') "
cQryAux1 += " AND l1_filial='"+cFiliate1+"' "
cQryAux1 += " GROUP BY l2_produto,l2_descri,b2_qatu ORDER BY sum(l2_quant) DESC "

	TCQuery cQryAux1 New Alias (_QryAux1)
	nFlag1 := 0
	While !(_QryAux1)->(EoF())

		nFlag1 += 1

		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif
			oPrintPvt:SayAlign(nLinAtu, nColMeio-320, "ESTOQUE POR PRODUTO - CURVA A", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, 10 ,    "CODIGO"  ,     oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 100,   "DESCRICAO",     oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 420,   "QTD. VENDIDO",     oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 510,   "ESTOQUE"  ,     oFontMin,  (nColUnid - nColDesc),   10, nCorCinza, PAD_LEFT,  )

		endif
		nLinAtu += 15

		nAtuAux++

		//Faz o zebrado ao fundo
		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf
		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 10 ,   (_QryAux1)->CODIGO             ,    oFontDet,  (nColDesc - nColProd)    ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 100,   (_QryAux1)->Descricao          ,    oFontDet,  (nColUnid - nColDesc)-150,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 420,   cValTochar((_QryAux1)->QTDVEN),    oFontDet,  (nColTipo - nColUnid)    ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 510,   cValTochar((_QryAux1)->ESTOQUE),    oFontDet,  (nColTipo - nColUnid)    ,    10, , PAD_LEFT,  )

		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza)

		if nFlag1 = 20
			(_QryAux1)->(DbCloseArea())
			EXIT
		else
			(_QryAux1)->(DbSkip())
		endif

	EndDo





//estoque por dpto
	cQryAux2 += " SELECT NOme AS FILIALQ, bm_grupo|| ' - ' ||bm_desc AS GRUPO, sum(b2_qatu) AS QUANTIDADE, sum(b2_qatu*b2_cm1) AS VLRCUSTO "
	cQryAux2 += " FROM sbm010, sb2010, sb1010, filiais, sys_company  "
	cQryAux2 += " WHERE  b1_cod=b2_cod AND b1_grupo=bm_grupo  "
	cQryAux2 += " AND b2_filial not IN ('1B','01')   "
	cQryAux2 += " AND bm_grupo NOT IN ('0010','0008') "
	cQryAux2 += " AND b2_qatu>'0'  "
	cQryAux2 += " AND m0_codfil=b2_filial  "
	cQryAux2 += " AND b2_filial=filiais.filial  "
	cQryAux2 += " AND b2_filial='"+cFiliate1+"' "
	cQryAux2 += " GROUP BY b2_filial,nome, m0_estent,m0_cident, bm_grupo, bm_desc "
	cQryAux2 += " ORDER BY b2_filial,bm_grupo "

	TCQuery cQryAux2 New Alias (_QryAux2)

	nFlag1 := 0
	nTotVend := 0
	While !(_QryAux2)->(EoF())
		nFlag1 += 1


		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif
			oPrintPvt:SayAlign(nLinAtu, nColMeio-315, "ESTOQUE POR DEPARTAMENTO", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, 10,   "FILIAL",       oFontMin,  (nColDesc - nColProd)-10,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 130,   "GRUPO" ,      oFontMin,  (nColDesc - nColProd),      10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 280,   "QUANTIDADE",        oFontMin,  (nColUnid - nColDesc)-30,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 440,  "VALOR CUSTO",      oFontMin,  (nColTipo - nColUnid),      10, nCorCinza, PAD_LEFT,  )
		endif
		nLinAtu += 15

		nAtuAux++
		IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")

		//Faz o zebrado ao fundo
		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf
		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 10 ,    (_QryAux2)->FILIALQ,                                          oFontDet,  (nColDesc - nColProd)+100,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 130,   (_QryAux2)->GRUPO,                                             oFontDet,  (nColUnid - nColDesc)    ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 280,   AllTrim(cValToChar((_QryAux2)->QUANTIDADE)),                   oFontDet,  (nColTipo - nColUnid)    ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 440,   AllTrim(Transform((_QryAux2)->VLRCUSTO,"@E 999,999,999.99")),  oFontDet,  (nColBarr - nColTipo)    ,    10, , PAD_LEFT,  )

		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza)

		nTotVend +=(_QryAux2)->VLRCUSTO

		if nFlag1 = 20
			(_QryAux2)->(DbCloseArea())
			EXIT
		else
			(_QryAux2)->(DbSkip())
		endif

		if (_QryAux2)->(EoF())
			nLinAtu += 18
			oPrintPvt:SayAlign(nLinAtu, 10 ,                      "TOTAL"                      ,    oFontTots,  (nColBarr - nColTipo),    10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 440,   AllTrim(Transform(nTotVend,"@E 999,999,999.99")),    oFontTots,  (nColBarr - nColTipo),    10, , PAD_LEFT,  )

		endif

	EndDo
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	fQuebra()

	cQryAux3 += " SELECT ALUGUEL, CODIGO, NOME FROM filiais WHERE codigo='"+cFiliate1+"' "

	TCQuery cQryAux3 New Alias (_QryAux3)

	nFlag1 := 0
	While !(_QryAux3)->(EoF())
		nFlag1 += 1

		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif

			oPrintPvt:SayAlign(nLinAtu, nColMeio-315, "ALUGUEL", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, 10 ,          "FILIAL" ,       oFontMin,  (nColDesc - nColProd)-10,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 130,          "ALUGUEL",       oFontMin,  (nColUnid - nColDesc)-10,   10, nCorCinza, PAD_LEFT,  ) 
			oPrintPvt:SayAlign(nLinAtu, 240,          "% ALUGUEL X VENDIDO",       oFontMin,  (nColUnid - nColDesc)-10,   10, nCorCinza, PAD_LEFT,  )

		endif
		nLinAtu += 15

		nAtuAux++
		IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")

		//Faz o zebrado ao fundo
		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf 

		 nPorcentot := Round( ((_QryAux3)->ALUGUEL * 100)/nVendAlug, 1 ) 

		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 130,  AllTrim(Transform((_QryAux3)->ALUGUEL,"@E 999,999,999.99")),    oFontDet,  (nColDesc - nColProd)+100,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 10 ,   cValToChar((_QryAux3)->CODIGO)+"-"+(_QryAux3)->NOME       ,    oFontDet,  (nColDesc - nColProd)+140,    10, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, 245,  cValToChar(nPorcentot)+"%",    oFontDet,  (nColDesc - nColProd)+100,    10, , PAD_LEFT,  )
		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza)

		(_QryAux3)->(DbSkip())
		fQuebra()
	EndDo





//sem venda a mais de 30 dias com estoque maior que 5 
	cQryAux4 += " SELECT b1_cod AS CODIGO, b1_desc DESCRICAO, b2_qatu AS ESTOQUE               "
	cQryAux4 += " FROM sb1010, sb2010 WHERE b1_cod=b2_cod AND b2_qatu>'0' AND b2_filial='"+cFiliate1+"'   "
	cQryAux4 += " AND b2_cod NOT IN (  "
	cQryAux4 += " SELECT l2_produto FROM sl2010, sl1010 WHERE l1_num=l2_num   "
	cQryAux4 += " AND l1_filial=l2_filial AND l1_tipo IN ('P','V')   "
	cQryAux4 += " AND sl1010.D_E_L_E_T_<>'*'  AND l1_tpfret in (' ','F')     "
	cQryAux4 += " AND l1_emissao >=(  "
	cQryAux4 += " SELECT to_char(sysdate-30,'YYYYMMDD') from dual)  "
	cQryAux4 += " AND sl2010.D_E_L_E_T_<>'*'   "
	cQryAux4 += " AND l1_filial='"+cFiliate1+"')  "
	cQryAux4 += " AND b2_qatu>='5'  "
	cQryAux4 += " ORDER BY b2_qatu desc  " 
//estoque por produtos - CURVA A


	TCQuery cQryAux4 New Alias (_QryAux4)


	nFlag1 := 0
	While !(_QryAux4)->(EoF())
		nFlag1 += 1


		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif
			oPrintPvt:SayAlign(nLinAtu, nColMeio-320, "SEM VENDA A MAIS DE 30 DIAS / ESTOQUE MAIOR QUE 5", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, 10,    "CODIGO"   ,       oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 100,   "DESCRICAO",       oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 440,   "ESTOQUE"  ,       oFontMin,  (nColUnid - nColDesc),   10, nCorCinza, PAD_LEFT,  )

		endif
		nLinAtu += 15
		nAtuAux++
		IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")
		//Se atingiu o limite, quebra de pagina

		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf
		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 10 ,   (_QryAux4)->CODIGO            ,  oFontDet,  (nColDesc - nColProd)    ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 100,  (_QryAux4)->Descricao          ,  oFontDet,  (nColUnid - nColDesc)-150,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 440,  cValTochar((_QryAux4)->ESTOQUE),  oFontDet,  (nColTipo - nColUnid)    ,    10, , PAD_LEFT,  )

		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza)

		if nFlag1 = 20
			(_QryAux4)->(DbCloseArea())
			EXIT
		else
			(_QryAux4)->(DbSkip())
		endif
		fQuebra()

	EndDo







//NOTA DE ENTRADA PENDENTE
	cQryAux5 += " SELECT filiais.nome AS FILIALQ, f1_doc AS NOTA,                                                        "
	cQryAux5 += " SUBSTR(F1_RECBMTO, 7, 2)||'/'|| SUBSTR(F1_RECBMTO, 5, 2)||'/'|| SUBSTR(F1_RECBMTO, 1, 4) AS DATAA  "
	cQryAux5 += " FROM sf1010, filiais  where F1_STATUs=' '  "
	cQryAux5 += " AND F1_RECBMTO>='20210901' AND f1_filial ='"+cFiliate1+"' AND SF1010.D_E_L_E_T_<>'*'  "
	cQryAux5 += " AND filiais.filial=f1_filial ORDER BY f1_filial, F1_RECBMTO "

	TCQuery cQryAux5 New Alias (_QryAux5)


	nFlag1 := 0
	While !(_QryAux5)->(EoF())
		nFlag1 += 1

		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif
			oPrintPvt:SayAlign(nLinAtu, nColMeio-320, "NOTA DE ENTRADA PENDENTE", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, 10 ,   "FILIAL",       oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 100,   "NOTA"  ,       oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 440,   "DATA"  ,       oFontMin,  (nColUnid - nColDesc),   10, nCorCinza, PAD_LEFT,  )

		endif
		nLinAtu += 15
		nAtuAux++
		IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")


		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf
		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 10,   (_QryAux5)->FILIALQ,                oFontDet,  (nColDesc - nColProd)    ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 100,  (_QryAux5)->NOTA,            oFontDet,  (nColUnid - nColDesc)-150,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 440,  cValTochar((_QryAux5)->DATAA),  oFontDet,  (nColTipo - nColUnid)    ,    10, , PAD_LEFT,  )

		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza)

		(_QryAux5)->(DbSkip())

	enddo

	fQuebra()




SA6->(DbSetOrder(1))
SA6->(DbSeek(xFilial("SA6")+ cBancosald))


//SALDO ATUAL DO CAIXA
	cQryAux6 := " SELECT E8_SALATUA AS SALDOATU FROM SE8010 WHERE E8_BANCO = '"+cBancosald+"' AND D_E_L_E_T_ <> '*' "
	cQryAux6 += " AND E8_DTSALAT = (SELECT MAX(E8_DTSALAT) FROM SE8010 WHERE E8_BANCO = '"+cBancosald+"' AND  D_E_L_E_T_ <> '*') "

	TCQuery cQryAux6 New Alias (_QryAux6)

	nFlag1 := 0
	While !(_QryAux6)->(EoF())
		nFlag1 += 1

		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif
			oPrintPvt:SayAlign(nLinAtu, nColMeio-320, "SALDO ATUAL DO CAIXA", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, 10,   "CAIXA",    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 100,   "NOME",    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 440,   "SALDO",   oFontMin,  (nColUnid - nColDesc),   10, nCorCinza, PAD_LEFT,  )

		endif
		nLinAtu += 15
		nAtuAux++
		IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")


		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf
		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 10,   AllTrim(SA6->A6_COD),             oFontDet,  (nColDesc - nColProd)      ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 100,  AllTrim(SA6->A6_NOME),            oFontDet,  (nColUnid - nColDesc)-150  ,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 440,  cValTochar((_QryAux6)->SALDOATU), oFontDet,  (nColTipo - nColUnid)      ,    10, , PAD_LEFT,  )

		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza)

		(_QryAux6)->(DbSkip())
		fQuebra()

	enddo




//COMPARATIVO VENDA
	cQryAux7 += " SELECT a.grupo AS GRUPOP,vmesanterior AS MESANTERIOR, vpassado AS PERIODOPASSA,vatual  AS PERIODOATUAL,     "
	cQryAux7 += " vatual-vpassado AS PERIODODIFE,                                                         "
	cQryAux7 += " trunc((vatual/(select to_char(sysdate,'DD' )from dual))*30,2) AS TENDMESATU, "
	cQryAux7 += " (trunc((vatual/(select to_char(sysdate,'DD' )from dual))*30,2))-vmesanterior AS DIFMES "
	cQryAux7 += " from(  "
	cQryAux7 += " SELECT bm_desc grupo, sum(l2_vlritem+l2_valfre) vatual "
	cQryAux7 += " FROM sbm010, sb1010, sl2010, sl1010 WHERE l1_num=l2_num  "
	cQryAux7 += " AND l1_filial=l2_filial AND l1_tipo IN ('P','V')  "
	cQryAux7 += " AND sl1010.D_E_L_E_T_<>'*' AND l2_produto=b1_cod AND l1_tpfret in (' ','F')    "
	cQryAux7 += " AND l1_emissao >= '"+DTOS(FirstDate(Date()))+"' "
	cQryAux7 += " AND l1_emissao <= '"+DTOS((Date()))+"' "
	cQryAux7 += " AND sl2010.D_E_L_E_T_<>'*' AND sb1010.D_E_L_E_T_<>'*'  "
	cQryAux7 += " AND l1_filial='"+cFiliate1+"'       "
	cQryAux7 += " AND b1_grupo=bm_grupo   "
	cQryAux7 += " GROUP BY bm_desc) a,( "
	cQryAux7 += " SELECT bm_desc grupo, sum(l2_vlritem+l2_valfre) vpassado "
	cQryAux7 += " FROM sbm010, sb1010, sl2010, sl1010 WHERE l1_num=l2_num  "
	cQryAux7 += " AND l1_filial=l2_filial AND l1_tipo IN ('P','V')  "
	cQryAux7 += " AND sl1010.D_E_L_E_T_<>'*' AND l2_produto=b1_cod AND l1_tpfret in (' ','F')    "
	cQryAux7 += " AND l1_emissao >='"+DTOS(FirstDate(MonthSub(Date(),1)))+"' "
	cQryAux7 += " AND l1_emissao <='"+DTOS((MonthSub(Date(),1)))+"' "
	cQryAux7 += " AND sl2010.D_E_L_E_T_<>'*' AND sb1010.D_E_L_E_T_<>'*'  "
	cQryAux7 += " AND l1_filial='"+cFiliate1+"' "
	cQryAux7 += " AND b1_grupo=bm_grupo   "
	cQryAux7 += " GROUP BY bm_desc) b,( "
	cQryAux7 += " SELECT bm_desc grupo, sum(l2_vlritem+l2_valfre) vmesanterior "
	cQryAux7 += " FROM sbm010, sb1010, sl2010, sl1010 WHERE l1_num=l2_num  "
	cQryAux7 += " AND l1_filial=l2_filial AND l1_tipo IN ('P','V')  "
	cQryAux7 += " AND sl1010.D_E_L_E_T_<>'*' AND l2_produto=b1_cod AND l1_tpfret in (' ','F')    "
	cQryAux7 += " AND l1_emissao >='"+DTOS(FirstDate(MonthSub(Date(),1)))+"' "
	cQryAux7 += " AND l1_emissao <='"+DTOS(LastDate(MonthSub(Date(),1)))+"' "
	cQryAux7 += " AND sl2010.D_E_L_E_T_<>'*' AND sb1010.D_E_L_E_T_<>'*'  "
	cQryAux7 += " AND l1_filial='"+cFiliate1+"' "
	cQryAux7 += " AND b1_grupo=bm_grupo   "
	cQryAux7 += " GROUP BY bm_desc) c WHERE a.grupo=b.grupo AND a.grupo=c.grupo AND b.grupo=c.grupo "



	TCQuery cQryAux7 New Alias (_QryAux7)

	nFlag1 := 0

	nTotVend1  := 0
	nTotVend2  := 0
	nTotVend3  := 0
	nTotVend4  := 0
	nTotVend5  := 0

	cData1 := DTOC(FirstDate(MonthSub(Date(),1)))
	cData2 := DTOC(FirstDate(MonthSub(Date(),1)))
	cData3 := DTOC(FirstDate(Date()))

	cData11 := DTOC(LastDate(MonthSub(Date(),1)))
	cData22 := DTOC((MonthSub(Date(),1)))
	cData33 := DTOC((Date()))

	While !(_QryAux7)->(EoF())
		nFlag1 += 1

		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif
			oPrintPvt:SayAlign(nLinAtu, nColMeio-320, "COMPARATIVO VENDA", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu+9, 10 ,   "GRUPO"             ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 105,   "MES ANTERIOR"        ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 190,   "PER. PASSADO"        ,    oFontMin,  (nColUnid - nColDesc),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 270,   "PER. ATUAL"          ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu+9, 350,   "DIFERENCA PER."      ,    oFontMin,  (nColDesc - nColProd)+20,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu+9, 430,   "TEND. ATUAL"         ,    oFontMin,  (nColUnid - nColDesc),   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu+9, 510,   "DIF MES ANT. X TEND.",    oFontMin,  (nColUnid - nColDesc),   10, nCorCinza, PAD_LEFT,  ) 
              nLinAtu += 8
			oPrintPvt:SayAlign(nLinAtu, 111,  cData1  ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  ) //
			oPrintPvt:SayAlign(nLinAtu, 195,  cData2  ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )  
			oPrintPvt:SayAlign(nLinAtu, 273,  cData3  ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )  
               nLinAtu += 6
			oPrintPvt:SayAlign(nLinAtu, 120,  "ate"  ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  ) //
			oPrintPvt:SayAlign(nLinAtu, 204,  "ate"  ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )  
			oPrintPvt:SayAlign(nLinAtu, 283,  "ate"  ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )  
			 nLinAtu += 6
			oPrintPvt:SayAlign(nLinAtu, 111,  cData11 ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  ) //
			oPrintPvt:SayAlign(nLinAtu, 195,  cData22 ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  )  
			oPrintPvt:SayAlign(nLinAtu, 273,  cData33 ,    oFontMin,  (nColDesc - nColProd),   10, nCorCinza, PAD_LEFT,  ) 


		endif
		nLinAtu += 15
		nAtuAux++
		IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")
		//Se atingiu o limite, quebra de pagina

		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf
		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 10 ,                    (_QryAux7)->GRUPOP                              ,   oFontDet,  (nColDesc - nColProd)+40  ,   10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 105,  AllTrim(Transform((_QryAux7)->MESANTERIOR  ,"@E 999,999,999.99")) ,   oFontDet,  (nColDesc - nColProd)     ,   10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 190,  AllTrim(Transform((_QryAux7)->PERIODOPASSA ,"@E 999,999,999.99")) ,   oFontDet,  (nColUnid - nColDesc)     ,   10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 270,  AllTrim(Transform((_QryAux7)->PERIODOATUAL ,"@E 999,999,999.99")) ,   oFontDet,  (nColDesc - nColProd)     ,   10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 350,  AllTrim(Transform((_QryAux7)->PERIODODIFE  ,"@E 999,999,999.99")) ,   oFontDet,  (nColDesc - nColProd)     ,   10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 430,  AllTrim(Transform((_QryAux7)-> TENDMESATU  ,"@E 999,999,999.99")) ,   oFontDet,  (nColUnid - nColDesc)     ,   10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 510,  AllTrim(Transform((_QryAux7)-> DIFMES      ,"@E 999,999,999.99")) ,   oFontDet,  (nColUnid - nColDesc)     ,   10, , PAD_LEFT,  )

		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza)

		nTotVend1  += (_QryAux7)->MESANTERIOR
		nTotVend2  += (_QryAux7)->PERIODOPASSA
		nTotVend3  += (_QryAux7)->PERIODOATUAL
		nTotVend4  += (_QryAux7)->PERIODODIFE
		nTotVend5  += (_QryAux7)->TENDMESATU



		(_QryAux7)->(DbSkip())

		if (_QryAux7)->(EoF())
			nLinAtu += 18
			oPrintPvt:SayAlign(nLinAtu, 10 ,                      "TOTAL"                      ,     oFontTots,  (nColBarr - nColTipo)     ,    10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 105,  AllTrim(Transform(nTotVend1  ,"@E 999,999,999.99")) ,  oFontTots,  (nColDesc - nColProd)     ,   10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 190,  AllTrim(Transform(nTotVend2 ,"@E 999,999,999.99")) ,   oFontTots,  (nColUnid - nColDesc)     ,   10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 270,  AllTrim(Transform(nTotVend3 ,"@E 999,999,999.99")) ,   oFontTots,  (nColDesc - nColProd)     ,   10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 350,  AllTrim(Transform(nTotVend4  ,"@E 999,999,999.99")) ,  oFontTots,  (nColDesc - nColProd)     ,   10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 430,  AllTrim(Transform(nTotVend5  ,"@E 999,999,999.99")) ,  oFontTots,  (nColUnid - nColDesc)     ,   10, , PAD_LEFT,  )

		endif

	enddo



//total desconto
	cQryAux8 := " SELECT nome AS FILIALQ, sum(l2_valdesc) AS DESCONTO FROM sl1010, sl2010, filiais WHERE  "
	cQryAux8 += " l2_emissao >=( "
	cQryAux8 += " select to_char(sysdate, 'YYYYMM') || '01' from dual) "
	cQryAux8 += " AND l2_emissao <=( "
	cQryAux8 += " select to_char(sysdate, 'YYYYMMDD') from dual) "
	cQryAux8 += " AND l2_valdesc>'0'   "
	cQryAux8 += " AND l2_filial NOT IN ('12','1B','36') "
	cQryAux8 += " AND l1_tpfret in (' ','F') "
	cQryAux8 += " and l1_num=l2_num "
	cQryAux8 += " and l1_filial=l2_filial "
	cQryAux8 += " and sl1010.D_E_L_E_T_<>'*' "
	cQryAux8 += " and sl2010.D_E_L_E_T_<>'*' "
	cQryAux8 += " AND filial=l2_filial "
	cQryAux8 += " and l1_emissao=l2_emissao "
	cQryAux8 += " AND l1_tipo IN ('P','V') "
	cQryAux8 += " AND l1_filial='"+cFiliate1+"' "
	cQryAux8 += " GROUP BY l2_filial,nome ORDER BY sum(l2_valdesc) DESC "

	TCQuery cQryAux8 New Alias (_QryAux8)


	nFlag1 := 0
	While !(_QryAux8)->(EoF())
		nFlag1 += 1
		fQuebra()

		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif

			oPrintPvt:SayAlign(nLinAtu, nColMeio-315, "DESCONTO TOTAL NO PERIODO ATUAL", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, 10 ,    "FILIAL" ,       oFontMin,  (nColDesc - nColProd)-10,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 130,   "DESCONTO",       oFontMin,  (nColUnid - nColDesc)-10,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 240,   "% DESCONTO x VENDIDO",       oFontMin,  (nColUnid - nColDesc)-10,   10, nCorCinza, PAD_LEFT,  )

		endif
		nLinAtu += 15

		nAtuAux++
		IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")

		//Faz o zebrado ao fundo
		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf 

		nPorcentot := Round( ((_QryAux8)->DESCONTO * 100)/nVendAlug, 1 ) 
		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 130,  AllTrim(Transform((_QryAux8)->DESCONTO,"@E 999,999,999.99")),    oFontDet,  (nColDesc - nColProd)+100,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 10 ,   cValToChar((_QryAux8)->FILIALQ)                            ,    oFontDet,  (nColDesc - nColProd)+140,    10, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, 243 ,   cValToChar(nPorcentot)+"%"                        ,    oFontDet,  (nColDesc - nColProd)+140,    10, , PAD_LEFT,  )
		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza)

		(_QryAux8)->(DbSkip())

	EndDo 

//venda e comissao por vendedor
cQryAux9 += " SELECT l2_vend AS CODVEND,a3_nome AS NOMVEND ,sum(l2_vlritem+l2_valfre) AS VLRVEND,sum(l2_xcomis) AS VLRCOMIS "
cQryAux9 += " FROM  sb1010, sl2010, sl1010,sa3010 WHERE l1_num=l2_num  "
cQryAux9 += " AND l1_filial=l2_filial AND l1_tipo IN ('P','V')  "
cQryAux9 += " AND sl1010.D_E_L_E_T_<>'*' AND l2_produto=b1_cod AND l1_tpfret in (' ','F')    "
cQryAux9 += " AND l1_emissao  BETWEEN '"+DTOS(FirstDate(Date()))+"' AND'"+DTOS(LastDate(Date()))+"'  AND sl2010.D_E_L_E_T_<>'*' AND sb1010.D_E_L_E_T_<>'*'  "
cQryAux9 += " AND l1_filial='"+cFiliate1+"' "
cQryAux9 += " AND a3_cod=l2_vend "
cQryAux9 += " GROUP BY l2_vend,a3_nome "
cQryAux9 += " ORDER BY  sum(l2_vlritem+l2_valfre)  DESC "

TCQuery cQryAux9 New Alias (_QryAux9) 

nFlag1 := 0 
nTotVend := 0
	While !(_QryAux9)->(EoF())
		nFlag1 += 1
		fQuebra()

		if nFlag1 = 1
			if nLinAtu >= 66
				nLinAtu += 50
			endif

			oPrintPvt:SayAlign(nLinAtu, nColMeio-315, "VENDA POR VENDEDOR", oFontDetN, 400, 20, , PAD_CENTER, )
			nLinAtu += 17
			oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230)
			nLinAtu += 2
			oPrintPvt:SayAlign(nLinAtu, 10 ,    "COD. VENDEDOR" ,       oFontMin,  (nColDesc - nColProd)-10,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 130,    "NOM. VENDEDOR",       oFontMin,  (nColUnid - nColDesc)-10,   10, nCorCinza, PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 280,    "VLR. VENDIDO",       oFontMin,  (nColUnid - nColDesc)-10,   10, nCorCinza, PAD_LEFT,  )

		endif
		nLinAtu += 15

		nAtuAux++
		IncProc("Imprimindo produto " + cValToChar(nAtuAux) + " de " + cValToChar(nTotAux) + "...")

		//Faz o zebrado ao fundo
		If nAtuAux % 2 == 0
			oPrintPvt:FillRect({nLinAtu - 2, nColIni, nLinAtu + 12, nColFin-230}, oBrushAzul)
		EndIf 

		//Imprime a linha atual
		oPrintPvt:SayAlign(nLinAtu, 10 ,   AllTrim((_QryAux9)->CODVEND)                            ,    oFontDet,  (nColDesc - nColProd)+140,    10, , PAD_LEFT,  )
		oPrintPvt:SayAlign(nLinAtu, 130,  AllTrim((_QryAux9)->NOMVEND),    oFontDet,  (nColDesc - nColProd)+100,    10, , PAD_LEFT,  )
        oPrintPvt:SayAlign(nLinAtu, 283 ,   AllTrim(Transform((_QryAux9)->VLRVEND,"@E 999,999,999.99"))                        ,    oFontDet,  (nColDesc - nColProd)+140,    10, , PAD_LEFT,  )
		oPrintPvt:Line(nLinAtu-3, nColIni, nLinAtu-3, nColFin-230, nCorCinza) 

		nTotVend +=(_QryAux9)->VLRVEND

		(_QryAux9)->(DbSkip()) 


		if (_QryAux9)->(EoF())
			nLinAtu += 18
			oPrintPvt:SayAlign(nLinAtu, 10 ,                      "TOTAL"                      ,    oFontTots,  (nColBarr - nColTipo),    10, , PAD_LEFT,  )
			oPrintPvt:SayAlign(nLinAtu, 283,   AllTrim(Transform(nTotVend,"@E 999,999,999.99")),    oFontTots,  (nColBarr - nColTipo),    10, , PAD_LEFT,  )

		endif

	EndDo 


	fImpRod()


	oPrintPvt:preview()
	RestArea(aArea)
return




/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Funcao que imprime o rodape                                  |
 *---------------------------------------------------------------------*/
 Static Function fImpCab()
    Local cTexto    := "RAIO X"
    Local nLinCab   := 015
	local cComtitle := cFiliate1


    //Iniciando Pagina
    oPrintPvt:StartPage()
     
    cTexto := "RAIO X FILIAL - "+cComtitle
   
	oPrintPvt:SayAlign(nLinCab, nColMeio-315, cTexto, oFontTit, 400, 20, , PAD_CENTER, )
    nLinCab += 020
    oPrintPvt:Line(nLinCab,   0, nLinCab,   nColFin-200)
    
    nLinAtu := nLinCab + 5
    nLinAtu += 15
Return


Static Function fImpRod()
    Local nLinRod:= nLinFin+10
    Local cTexto := ''
 
    //Linha Separatoria
    oPrintPvt:Line(nLinRod,   nColIni, nLinRod,   nColFin-230)
    nLinRod += 3
    
    cTexto := dToC(dDataBase) + "     " + cHoraEx + "     " + FunName() +"  "+ UsrRetName(RetCodUsr())
    oPrintPvt:SayAlign(nLinRod, nColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )
     
    cTexto := "Pagina "+cValToChar(nPagAtu)
    oPrintPvt:SayAlign(nLinRod, nColFin-275, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
     
    oPrintPvt:EndPage()
    nPagAtu++
Return
 

Static Function fQuebra()
    if   nLinAtu >= nLinFin-80
        fImpRod()
        fImpCab()
    EndIf
Return












