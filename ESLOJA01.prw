#INCLUDE "PROTHEUS.CH"
#include "TOPCONN.ch"
//////////////////////////////////////////////////////////////////////////////////////
// Empresa: JVCS                                                                    //
// Autor : Joao Victor Coelho dos Santos                                            //
// Data: 16/06/2022                                                                 //
// Solicitante: John/Ruan                                                           //
// Descricao:     tela alternativa de cadastro de despesas (loja)                   //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

User Function ESLOJA01()

	local aArea  := GetArea()
	Local aCores := {}

	Private cCadastro := "Movimentos Bancarios"
	Private aRotina:= {}


	AADD(aCores, {"ZZB_STATUS = 'S'","BR_VERDE"})
	AADD(aCores, {"ZZB_STATUS = 'A'","BR_AZUL"})
	AADD(aCores, {"ZZB_STATUS = 'N'","BR_VERMELHO"})


	aadd(aRotina, {"Pesquisar"  , "AxPesqui"    , 0, 1})
	aadd(aRotina, {"Visualizar" , "AxVisual"    , 0, 2})
	aadd(aRotina, { "Pagar"     ,"U_ESLOJAa(3)" , 0, 3})
	aadd(aRotina, {"Receber"    ,"U_ESLOJAa(4)" , 0, 4})
	aadd(aRotina, {""           ,          ""   , 0, 5})
	aadd(aRotina, {  "Legenda"  , "U_LEGENDA02" , 0, 6})
	aadd(aRotina, {  "Alterar"  , "AxAltera"    , 0, 6})




	DbSelectArea("ZZB")
	ZZB->(DbSetOrder(1))
	//Eval( bFiltraBrw )
	mBrowse( 6,1,22,75,"ZZB",,,,,,aCores)
	//EndFilBrw( "SL1" , @aIndex )

	RestArea(aArea)

Return

User Function ESLOJAa(nOpc)


	Local nAxInc := 0
	Local nRec := 0


	nAxInc := AxInclui('ZZB', nRec, 3)

	nRec := ZZB->(Recno())

	if nAxInc > 0 .and. nRec > 0
		ZZB->(RecLock("ZZB", .F.) )
		ZZB->ZZB_TIPOOP := iif (nOpc == 3, "P", "R")
		ZZB->ZZB_STATUS := "A"
		ZZB->(MsUnlock())
	endif


return

User Function FA100MoedaALT()
	Local lRet := .T.

	dbSelectArea("SX5")
	dbSetOrder(1)  // X5_FILIAL, X5_TABELA, X5_CHAVE.
	IF !(dbSeek(cFilial + "06" + M->ZZB_MOEDA, .F.))
		Help(" ",1,"ZZB_MOEDA")
		lRet := .F.
	EndIf

Return lRet


User Function LEGENDA02()

	local aLegenda := {}

	AADD(aLegenda, {"BR_VERDE"    ,"Aprovado"})
	AADD(aLegenda, {"BR_AZUL"     ,"Em Revisão"})
	AADD(aLegenda, {"BR_VERMELHO" ,"Reprovado"})

	BrwLegenda("Revisao","Legenda",aLegenda)

return


