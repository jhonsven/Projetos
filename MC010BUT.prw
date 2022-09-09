#include "protheus.ch"
#Include 'fwmvcdef.ch'
#include "topconn.ch"

//////////////////////////////////////////////////////////////////////////////////////
// Empresa: JVCS                                                                    //
// Autor : Joao Victor Coelho dos Santos                                            //
// Data: 22/08/2022                                                                 //
//                                                           //
// Descricao: Tela para visualizar preços de venda na tela de formacao de preco     //
//////////////////////////////////////////////////////////////////////////////////////

User Function MC010BUT()

	Local oDlg     := ParamIxb[1]
	Local aPosObj  := ParamIxb[2]
	Local aProd    := ParamIxb[3]
	Local oButt


	DEFINE SBUTTON oButt FROM aPosObj[1,4]-80,aPosObj[1,3]-33 TYPE 7  ENABLE OF oDlg Action U_ALTPRCVD(aProd,oDlg)

	oButt:cTitle := "Prc. Vnd"
Return





Static Function Mod3aCols(cAliasDet,cCodPro,DA1rec)

	Local aArea := GetArea()
	Local nI := 0


	DbSelectArea(cAliasDet)
	DA1->(DbSetOrder(2))
	DA1->(DbSeek(xFilial(cAliasDet)+AllTrim(cCodPro)))

	While DA1->(!EOF()) .AND. AllTrim(cCodPro) == AllTrim(DA1->DA1_CODPRO)
		AADD( aCols, Array( Len( aHeader ) + 1 ) )
		For nI := 1 To Len( aHeader )
			aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
		Next nI
		aCols[Len(aCols),Len(aHeader)+1] := .F.
		aadd(DA1rec, DA1->(Recno()))
		DA1->(DbSkip())
	EndDo


	Restarea( aArea )
Return



Static Function Mod3aHeader(cAliasDet)

	Local aArea := GetArea()
	Local sCampos:= "DA1_CODTAB|DA1_CODPRO|DA1_PRCVEN|DA1_PRBS|DA0_DESCRI"


	DbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	SX3->(dbSeek("DA0")) // tabela de chamados

	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "DA0"
		If  cNivel >= SX3->X3_NIVEL .and. Alltrim(SX3->X3_CAMPO) $ sCampos
			AADD( aHeader,{	Trim( X3Titulo() ),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT})
		Endif
		SX3->(dbSkip())
	End

	SX3->(dbgotop())

	SX3->(dbSeek(cAliasDet)) // tabela de chamados
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cAliasDet
		If  cNivel >= SX3->X3_NIVEL .and. Alltrim(SX3->X3_CAMPO) $ sCampos
			AADD( aHeader,{	Trim( X3Titulo() ),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT})
		Endif
		SX3->(dbSkip())
	End

	RestArea(aArea)
Return




User Function ALTPRCVD(aProd,oDlg)



	Local lAtu  := .F.
	local cCadastro := "Preço de Venda"


	Private cCodPro := aProd[1][4] //oDlg:ACONTROLS[1]:COLPOS
	private cAliasDet := "DA1"
	Private aHeader	  := {}
	Private aCols     := {}
	Private aGets	  := {}
	Private oArial10N1:=TFont():New("Arial",10,16,,.T.,,,,.T.,.F.)
	Private oArial10N3:=TFont():New("Arial",20,32,,.T.,,,,.T.,.F.)
	Private oArial10N2:=TFont():New("Arial",10,16,,.T.,,,,.T.,.F.)
	Private aSize		:= {}
	Private aObj		:= {}
	Private aPObj		:= {}
	Private aPGet		:= {}
	Private aInfo		:= {}
	Private DA1rec      := {}
	Private cNewpr      := SPACE(12)
	Private oDlg1
	Private oGet1

	oFont1      :=oArial10N1  //Say
	oFont2      :=oArial10N2  //Get
	oFont3      :=oArial10N3

	aSize := MsAdvSize(,.F.,200)
	AADD( aObj, { 000, 041, .T., .F. })  //AADD( aObj, { 100, 180, .T., .F. })
	AADD( aObj, { 100, 170, .T., .F. })  //AADD( aObj, { 100, 100, .T., .T. })
	AADD( aObj, { 000, 020, .T., .F. })  //AADD( aObj, { 100, 015, .T., .F. })

	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPObj := MsObjSize( aInfo, aObj )


	Mod3aHeader(cAliasDet)
	Mod3aCols(cAliasDet,cCodPro,DA1rec)
	COLSDESCRI()




	DEFINE MSDIALOG oDlg1 TITLE cCadastro FROM aSize[7],aSize[1] TO 250,800 OF oMainWnd PIXEL

	@ 035,348 SAY "Prc Venda"  OF oDlg1 PIXEL SIZE 060,010 COLOR CLR_BLUE FONT oFont1
	@ 042,348 MSGET cNewpr  OF oDlg1 PIXEL SIZE 050,010  Picture "@E"


	oGet1 := MsGetDados():New(35,5,120,340,1,,,,.F.,{"DA1_PRBS","DA1_PRCVEN"},,,,,,,, oDlg1)
	oGet1:oBrowse:bLDblClick := {|| U_ATPRECO(cNewpr,oGet1,oDlg1,oDlg) }


	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| lAtu := .T. , oDlg1:End() },{|| oDlg1:End() })

	if lAtu

		Gravarpr(cCodPro)

	endif



Return

User Function ATPRECO(cNewpr,oGet1,oDlg1,oDlg)
	local aArea := GetArea()
	Local nTab    := ascan(aHeader,{|x| AllTrim(x[2])== "DA1_CODTAB"  })
	Local nPrcv   := ascan(aHeader,{|x| AllTrim(x[2])== "DA1_PRCVEN"  })
	Local nPrcb  := ascan(aHeader,{|x| AllTrim(x[2])== "DA1_PRBS"  })
	local nCdtab  := ACols[n][nTab]
	local nPor := ""
	local nDes


	DbSelectArea("DA1")
	DbSetOrder(1)
	if Val(cNewpr) > 0
		if DbSeek(xFilial("DA1")+nCdtab+cCodPro)
			if DA1->DA1_PRCVEN == DA1->DA1_PRBS .OR. DA1->DA1_PRBS = 0
				ACols[n][nPrcv] := Val(cNewpr)
				ACols[n][nPrcb] := Val(cNewpr)
			else
				If MsgYesNo("Deseja aplicar desconto no preco de venda?", "Desconto detectado")
					nPor := FwInputBox("Digite o desconto:",nPor)
					nDes := Val(nPor)/100*Val(cNewpr)

					ACols[n][nPrcv] := Val(cNewpr) - nDes
					ACols[n][nPrcb] := Val(cNewpr)
				else

				endif
			endif
		endif
	endif


	oDlg1:refresh()
	oGet1:refresh()
	oDlg:refresh()

	GETDREFRESH()

	RestArea(aArea)
return


Static Function Gravarpr(cCodPro)

	local aArea    := GetArea()
	Local nPrbs    := ascan(aHeader,{|x| AllTrim(x[2])==  "DA1_PRBS"   })
	Local nPrvd    := ascan(aHeader,{|x| AllTrim(x[2])==  "DA1_PRCVEN"  })
	Local nCodtab  := ascan(aHeader,{|x| AllTrim(x[2])==  "DA1_CODTAB"  })
	local nX := 1

	DbSelectArea("DA1")
	DbSetOrder(1)

	for nX := 1 to len(aCols)
		if DbSeek(xFilial("DA1")+aCols[nX][nCodtab]+cCodPro)
			DA1->(RecLock("DA1",.F.))
			DA1->DA1_PRCVEN := aCols[nX][nPrvd]
			DA1->DA1_PRBS  := aCols[nX][nPrbs]
			DA1->(MsUnlock())
		endif
	next

	RestArea(aArea)

return

Static Function COLSDESCRI()
	local nX := 0
	Local nCodtab  := ascan(aHeader,{|x| AllTrim(x[2])==  "DA1_CODTAB"  })
	Local nDesctab  := ascan(aHeader,{|x| AllTrim(x[2])==  "DA0_DESCRI"  })

	for nX := 1 to len(aCols)
		DbSelectArea("DA0")
		DA0->(DbSetOrder(1))
		if DbSeek(xFilial("DA0")+aCols[nX][nCodtab])
			aCols[nX][nDesctab] := DA0->DA0_DESCRI
		endif
	next

return
