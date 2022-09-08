#include 'protheus.ch'
#include 'topconn.ch'
#Include 'FWMVCDef.ch'
//////////////////////////////////////////////////////////
// Autor: JOAO VICTOR                                   //
// Empresa: JVC INFO                                    //
// Funcao: M410PVNF                                     // 
// Descricao:  Pequena tela para criaÁ„o de pedido de   //
//             venda via celular                        //
// Data: 16/08/2022                                     //
//////////////////////////////////////////////////////////

User Function EXECPV02()
	Local aArea := GetArea()

	Private oLista                    //Declarando o objeto do grid
	Private aCabecalho  := {}         //Variavel que monta o aHeader do grid
	Private aColsEx 	:= {}         //Vari√°vel que receber√° os dados

	Private cCodbar  := SPACE(50)
	Private cCodprod := SPACE(06)
	Private cDsc     := SPACE(20)
	Private cQuant   := SPACE(10)
	Private cTotpr   := SPACE(10)
	Private nVlruni  := 0
	Private nTotprr  := 0

	//Objetos da Janela
	Private oDlgPvt
	Private oBtnFech
	Private nTamBtn  := 040
	Private cGetTot  := ""
	Private oGetObs
	Private oBtfec
	Private oBtcon
	Private oBtinc
	Private oTot
	//Tamanho da Janela
	Private    aTamanho    := MsAdvSize()
	Private    nJanLarg    := 300 //aTamanho[5]
	Private    nJanAltu    := 600 //aTamanho[6]
	//Fontes
	Private cFontUti    := "Tahoma"
	Private oFontSubN   := TFont():New(cFontUti,,-20,,.T.)
	Private oFontBtn    := TFont():New(cFontUti,,-14)

	Private aTFolder
	Private oTFolder
	Private cTGet1
	Private oBitmap1
	Private aItemped := {}



	//Criacao da tela com os dados que serao informados dos titulos
	DEFINE MSDIALOG oDlgPvt TITLE "Incluir Pedido de Venda" FROM 000, 000  TO nJanAltu, nJanLarg COLORS "CLR_HBLUE", 16777215 PIXEL


	aTFolder := { 'Produto', 'Finalizar' }
	oTFolder := TFolder():New( 0,0,aTFolder,,oDlgPvt,,,,.T.,,155,350 )


	// Insere um TGet em cada aba da folder
	cTGet1 := "Incluir Produtos"

	@ 000, 000 BITMAP oBitmap1 SIZE 155,400 OF oTFolder:aDialogs[1] FILENAME "\system\fundotela.bmp" NOBORDER PIXEL
	@ 000, 000 BITMAP oBitmap1 SIZE 250,500 OF oTFolder:aDialogs[2] FILENAME "\system\fundotela.bmp" NOBORDER PIXEL


	@ 005, 030 SAY "Codigo de Barras"  SIZE 200, 030 FONT oFontSubN OF oTFolder:aDialogs[1] COLORS RGB( 0, 0, 128 ) PIXEL
	@ 005+12, 003  MSGET oGetObs VAR  cCodbar  SIZE 145, 015 OF oTFolder:aDialogs[1] COLORS 0, 16777215 FONT oFontBtn  PIXEL VALID CODBAR(@cCodbar,@cCodprod,@cDsc)

	@ 050, 028 SAY "Codigo do Produto"  SIZE 200, 030 FONT oFontSubN OF oTFolder:aDialogs[1] COLORS RGB( 0, 0, 128 ) PIXEL
	@ 050+12, 003  MSGET oGetObs VAR  cCodprod  SIZE 145, 015 OF oTFolder:aDialogs[1] COLORS 0, 16777215 FONT oFontBtn VALID ATDESC01(@cCodprod,oDlgPvt,oTFolder) F3 "SB1"  PIXEL

	@ 095, 022 SAY "Descricao do Produto"  SIZE 200, 030 FONT oFontSubN OF oTFolder:aDialogs[1] COLORS RGB( 0, 0, 128 ) PIXEL
	@ 095+12, 003  MSGET oGetObs VAR  cDsc  SIZE 145, 015 OF oTFolder:aDialogs[1] COLORS 0, 16777215 FONT oFontBtn  PIXEL WHEN .F.

	@ 140, 045 SAY "Quantidade"  SIZE 200, 030 FONT oFontSubN OF oTFolder:aDialogs[1] COLORS RGB( 0, 0, 128 ) PIXEL
	@ 140+12, 003  MSGET oTot VAR  cQuant  SIZE 145, 015 OF oTFolder:aDialogs[1] COLORS 0, 16777215 FONT oFontBtn  PIXEL
	oBtinc := TButton():New(245, 035," INCLUIR PRODUTO ",oTFolder:aDialogs[1],{|| incluir01(oTFolder,oDlgPvt,@cQuant,nVlruni,@cCodprod,@cDsc,aItemped,@cCodbar,@cTotpr,@nTotprr) },080,035,,,.F.,.T.,.F.,,.F.,,,.F. )


	@ 050,010    BUTTON oBtnFech  PROMPT "Fechar"  SIZE nTamBtn, 018 OF oTFolder:aDialogs[2]  ACTION (oDlgPvt:End())
	@ 200,035       SAY  "Total De Produtos"  SIZE 200, 030 FONT oFontSubN OF oTFolder:aDialogs[2] COLORS RGB( 0, 0, 128 ) PIXEL
	@ 200+12, 003  MSGET oTot VAR  cTotpr  SIZE 145, 015 OF oTFolder:aDialogs[2] COLORS 0, 16777215 FONT oFontBtn  PIXEL WHEN .F.

	oBtcon := TButton():New(250, 090," CONFIRMAR ",oTFolder:aDialogs[2],{|| fAtuTela(@aItemped,@aColsEx,@cTotpr,@nTotprr,@oTFolder) },050,025,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtfec := TButton():New(250, 010," EXCLUIR",oTFolder:aDialogs[2],{|| delitem(@aItemped,@aColsEx,@cTotpr,@nTotprr,@cCodprod)},050,025,,,.F.,.T.,.F.,,.F.,,,.F.)
	oBtcon:SetCSS( getCSS('TBUTTON_02') )
	oBtfec:SetCSS( getCSS('TBUTTON_01') )
	oBtinc:SetCSS( getCSS('TBUTTON_03') )

	CriaCabec()

	oLista := MsNewGetDados():New( 020, 001, 190, 150, 2, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue",,1, 999, "AllwaysTrue", "", "AllwaysTrue", oTFolder:aDialogs[2], aCabecalho, aColsEx)
    oLista:disable()
	//Chamando a primeira vez para atualizar o get
	ACTIVATE MSDIALOG oDlgPvt CENTERED

	RestArea(aArea)
Return



Static Function fAtuTela(aItemped,aColsEx,cTotpr,nTotprr,oTFolder)
	local aCabc
	local aArea     := GetArea()
	local nXi       := 1
	local aItems    := {}
	local itensExec := {}

	Private lMsErroAuto := .F.

	if !Empty(aItemped)

		aCabc := {}
		AAdd(aCabc, {"C5_TIPO"   ,   "N"      , NIL})
		AAdd(aCabc, {"C5_CLIENTE", "009628"   , NIL})
		AAdd(aCabc, {"C5_CLIENT" ,  "009628"  , NIL})
		AAdd(aCabc, {"C5_CONDPAG",   "001"    , NIL})
		AAdd(aCabc, {"C5_MENNOTA", "OBRIGADO!", NIL})
		//AAdd(aCabc, {"C5_VEND1"  , cVend , NIL})
		//AAdd(aCabc, {"C5_TRANSP" , cTran , NIL})


		aItems  := {}
		For nXi := 1  to len(aItemped)
			itensExec := {}
			AAdd(itensExec, {"C6_ITEM"   , StrZero(nXi,2)   , NIL})
			AAdd(itensExec, {"C6_PRODUTO", aItemped[nXi][1] , NIL})
			AAdd(itensExec, {"C6_QTDVEN" , aItemped[nXi][2] , NIL})
			AAdd(itensExec, {"C6_PRCVEN" , aItemped[nXi][3] , NIL})
			AAdd(itensExec, {"C6_TES"    , "551"            , NIL})
			//AAdd(itensExec, {"C6_PEDCLI" , aItensMeee[nXi][10], NIL})
			//AAdd(itensExec, {"C6_QTDLIB" , aItensMeee[nXi][4] , NIL})
			//AAdd(itensExec, {"C6_QTDENT" , aItensMeee[nXi][5] , NIL})
			//AAdd(itensExec, {"C6_PRUNIT" , aItensMeee[nXi][6] , NIL})
			//AAdd(itensExec, {"C6_UM"     , aItensMeee[nXi][8] , NIL})
			//AAdd(itensExec, {"C6_VALOR"  , aItensMeee[nXi][9] , NIL})
			//AAdd(itensExec, {"C6_OPER"   , "03"               , NIL})
			AAdd(aItems, itensExec)

		next nXi

		MsExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabc, aItems, 3, .F.)

		If  lMsErroAuto
			MostraErro()
			alert("erro na inclusao")

		Else
			MsgInfo("sucesso")
			aItemped := {}
			aColsEx  := {}
			nTotprr := 0
			cTotpr   := "          "
		EndIf
		oLista:aCols := {}
		oLista:refresh()
	endif


	RestArea(aArea)

Return


Static Function incluir01(oTFolder,oDlgPvt,cQuant,nVlruni,cCodprod,cDsc,aItemped,cCodbar,cTotpr,nTotprr)

	local aArea := GetArea()
	local i := 1
	local cTotal := 0
	Local aProdutos := {}
	local cQuery := ""


	if EMPTY(cCodprod) .OR. EMPTY(cQuant)
		alert("Codigo do produto ou quantidade vazio!")

		RETURN
	endif


	cQuery += " SELECT B2_CM1, B2_DMOV FROM SB2010 WHERE B2_COD = '"+cCodprod+"' "
	cQuery +=" AND B2_DMOV IN (SELECT MAX(B2_DMOV) FROM SB2010 "
	cQuery +=" WHERE B2_COD = '"+cCodprod+"' AND B2_CM1 <> '0') "

	TCQUERY cQuery NEW ALIAS "QRY"
	DbSelectArea("QRY")
	nVlruni := B2_CM1
	cTotal := nVlruni * val(cQuant)
	nTotprr += val(cQuant)
	cTotpr := cValToChar(nTotprr)

	QRY->(DbCloseArea())

	aadd(aItemped ,{cCodprod,val(cQuant),nVlruni,cTotal})
	aadd(aProdutos,{AllTrim(cCodprod),left(cDsc,22),AllTrim(cQuant)})
	aadd(aColsEx  ,{aProdutos[i,1],aProdutos[i,2],aProdutos[i,3],.F.})

	//Setar array do aCols do Objeto.
	oLista:SetArray(aColsEx,.T.)

	cCodbar  := SPACE(50)
	cCodprod := SPACE(06)
	cDsc     := SPACE(20)
	cQuant   := SPACE(10)

	//Atualizo as informa√ß√µes no grid
	oLista:Refresh()
	oTFolder:aDialogs[1]:refresh()
	oTFolder:aDialogs[2]:refresh()


	RestArea(aArea)

return



Static Function CriaCabec()



	Aadd(aCabecalho, {;
		"Codigo",;	//X3Titulo()
	"CODIGO",;  	//X3_CAMPO
	"@!",;	//X3_PICTURE
	6,;	//X3_TAMANHO
	0,;	//X3_DECIMAL
	"",;	//X3_VALID
	"",;	//X3_USADO
	"C",;    //X3_TIPO
	"SB1",;	//X3_F3
	"R",;	//X3_CONTEXT
	"",;    //X3_CBOX
	"",;	//X3_RELACAO
	""})	//X3_WHEN
	Aadd(aCabecalho, {;
		"Desc. Produto",;	//X3Titulo()
	"Quant.",;  	//X3_CAMPO
	"@!",;	//X3_PICTURE
	22,;	//X3_TAMANHO
	0,;	//X3_DECIMAL
	"",;	//X3_VALID
	"",;	//X3_USADO
	"C",;	//X3_TIPO
	"",;	//X3_F3
	"R",;	//X3_CONTEXT
	"",;	//X3_CBOX
	"",;	//X3_RELACAO
	""})	//X3_WHEN
	Aadd(aCabecalho, {;
		"Quant.",;	//X3Titulo()
	"Quant.",;  	//X3_CAMPO
	"@!",;	//X3_PICTURE
	3,;	//X3_TAMANHO
	0,;	//X3_DECIMAL
	"",;	//X3_VALID
	"",;	//X3_USADO
	"C",;    //X3_TIPO
	"",;	//X3_F3
	"R",;	//X3_CONTEXT
	"",;	//X3_CBOX
	"",;	//X3_RELACAO
	""})	//X3_WHEN

Return






Static Function ATDESC01(cCodprod,oDlgPvt,oTFolder)
	local aArea := GetArea()
	local lRet := .T.
	local cQuery := ""

	cQuery += " SELECT B2_CM1, B2_DMOV FROM SB2010 WHERE B2_COD = '"+cCodprod+"' "
	cQuery +=" AND B2_DMOV IN (SELECT MAX(B2_DMOV) FROM SB2010 "
	cQuery +=" WHERE B2_COD = '"+cCodprod+"' AND B2_CM1 <> '0') "

	If !EMPTY(cCodprod)

		TCQUERY cQuery NEW ALIAS "QRY"
		DbSelectArea("QRY")
		nVlruni := B2_CM1

		if EMPTY(nVlruni)
			lRet := .F.
			alert("produto com custo zerado!")
		endif
		QRY->(DbCloseArea())


		SB1->(DbSetOrder(1))
		if SB1->(DbSeek(xFilial("SB1")+cCodprod))
			cDsc := AllTrim(SB1->B1_DESC)
		endif


		if ExistCpo("SB1",cCodprod)
		else
			lRet := .F.
		endif

	endif

	oTFolder:aDialogs[1]:refresh()

	RestArea(aArea)
return lRet



Static Function CODBAR(cCodbar,cCodprod,cDsc)
	local aArea := GetArea()

	if !EMPTY(cCodbar)
		SB1->(DbSetOrder(5))
		if SB1->(DbSeek(xFilial("SB1")+cCodbar))
			cCodprod := SB1->B1_COD
			cDsc     := SB1->B1_DESC


		else
			alert("Codigo de barras n„o encontrado!")
			cCodbar := ""

		endif
	endif

	RestArea(aArea)

return

Static Function delitem(aItemped,aColsEx,cTotpr,nTotprr,cCodprod)

	local cProddel := ""


	if len(aColsEx) != 0
		cProddel := oLista:aCols[oLista:nAt][1]
		If MsgYesNo("Deseja excluir o item "+cProddel+" ?" , "Desconto detectado" )
			if len(aColsEx) = 1
				aItemped     := {}
				aColsEx      := {}
				oLista:aCols := {}
			else

				nTotprr-= aItemped[oLista:nAt][2]
				cTotpr := cValToChar(nTotprr)

				aDel(aItemped, oLista:nAt)
				aDel(aColsEx  ,oLista:nAt)
				aDel(oLista:aCols, oLista:nAt)

				aSize(aItemped,len(aItemped)-1)
				aSize(aColsEx,len(aColsEx)-1)
				aSize(oLista:aCols,len(oLista:aCols)-1)

			endif
		endif
		oLista:refresh()
		oTFolder:aDialogs[1]:refresh()
		oTFolder:aDialogs[2]:refresh()


	endif




return





/*/{Protheus.doc} getCSS
Retorna CSS

@type    function
@author    Eurai Rapelli
@since     2021.08.15
/*/


Static Function getCSS( cClass )
	Local cCSS      := '' as character

	Default cClass    := ''

	If cClass == 'TBUTTON_01'
		cCSS   += "QPushButton { color: white }"
		cCSS   += "QPushButton { font-weight: bolder }"
		cCSS   += "QPushButton { border: 2px solid #CECECE }"
		cCSS   += "QPushButton { background-color: red }"
		cCSS   += "QPushButton { border-radius: 8px }"
		cCSS   += "QPushButton:hover { background-color: #434bdf } "
		cCSS   += "QPushButton:hover { border-style: solid } "
		cCSS   += "QPushButton:hover { border-width: 4px }"
		cCSS   += "QPushButton:pressed { background-color: #373fd4 }"

	ElseIf cClass == 'TBUTTON_02'
		cCSS   += "QPushButton { color: white }"
		cCSS   += "QPushButton { font-weight: bolder }"
		cCSS   += "QPushButton { border: 2px solid #CECECE }"
		cCSS   += "QPushButton { background-color: green }"
		cCSS   += "QPushButton { border-radius: 8px }"
		cCSS   += "QPushButton:hover { background-color: #457432 } "
		cCSS   += "QPushButton:hover { border-style: solid } "
		cCSS   += "QPushButton:hover { border-width: 4px }"
		cCSS   += "QPushButton:pressed { background-color: #355926 }"

	ElseIf cClass == 'TBUTTON_03'
		cCSS   += "QPushButton { color: white }"
		cCSS   += "QPushButton { font-weight: bolder }"
		cCSS   += "QPushButton { border: 2px solid #CECECE }"
		cCSS   += "QPushButton { background-color: blue }"
		cCSS   += "QPushButton { border-radius: 8px }"
		cCSS   += "QPushButton:hover { background-color: #457432 } "
		cCSS   += "QPushButton:hover { border-style: solid } "
		cCSS   += "QPushButton:hover { border-width: 4px }"
		cCSS   += "QPushButton:pressed { background-color: #355926 }"

	ElseIf cClass == 'TGET_01'
		cCSS   += "QLineEdit { border-radius: 8px }"
		cCSS   += "QLineEdit { border: 1px solid #CECECE } "
		cCSS   += "QLineEdit { background-color: #fff } "
		cCSS   += "QLineEdit:disabled{ background-color: #D7E3F0 }"
	ElseIf cClass == 'TCOMBO_01'
		cCSS   := "QComboBox { font: bold } "
		cCSS   := "QComboBox { border-radius: 8px } "
		cCSS   += "QComboBox { border: 2px solid #CECECE } "
		cCSS   += "QComboBox { background-color: green } "
		cCSS   += "QComboBox { color: white } "
		cCSS   += "QComboBox:hover { background-color: #6fcd4a } "
		cCSS   += "QComboBox:!editable:on { background-color: #52c923 }"
		cCSS   += "QComboBox QListView{ font: bold; color: white; background-color: #52c923; }"
		cCSS   += "QComboBox QAbstractItemView{  selection-background-color:red; }"
	Endif

Return( cCSS )
