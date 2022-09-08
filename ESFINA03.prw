#include "protheus.ch"
#include "tbiconn.ch"

//////////////////////////////////////////////////////////
// Autor: JOAO VICTOR                                   //
// Empresa: JVC INFO                                    //
// Funcao: M410PVNF                                     // 
// Descricao: tela de revisao das despesas              //
// Data: 16/08/2022                                     //
//////////////////////////////////////////////////////////


user function ESFINA03()

	local aArea := GetArea()

	Private cCadastro := "Movimentos Bancarios"
	Private aRotina   := {}
	Private aCores    := {}




	AADD(aRotina,{"Visualizar"  ,"AxVisual"	    ,0,2})
	AADD(aRotina,{"Revisado"    ,"U_REVISADO01" ,0,3})
	AADD(aRotina,{"Legenda"     ,"U_LEGENDA"    ,0,6})
	AADD(aRotina,{"Recusar"     ,"U_CANCEL01"   ,0,7})
	aadd(aRotina,{  "Alterar"   ,"AxAltera"     ,0,6})

	AADD(aCores,  {"ZZB_STATUS = 'S'"    ,"BR_PRETO"})
	AADD(aCores,  {"ZZB_STATUS = 'N'"    ,"BR_VERMELHO"})
	AADD(aCores,  {"ZZB_TIPOOP = 'P'"    ,"BR_AZUL" })
	AADD(aCores,  {"ZZB_TIPOOP = 'R'"    ,"BR_VERDE"})



	DbSelectArea("ZZB")
	ZZB->(DbSetOrder(1))

	mBrowse( 6,1,22,75,"ZZB",,,,,,aCores)



	ZZB->(DbCloseArea())
	RestArea(aArea)

return



User Function CANCEL01()

	Local nRecnoc   := ZZB->(RecNo())

	ZZB->(DbGoTo(nRecNoc))


	ZZB->(RecLock("ZZB", .F.) )
	ZZB->ZZB_STATUS := "N"
	ZZB->ZZB_DTREV  := dDataBase
	ZZB->(MsUnlock())
	alert("Movimento recusado!")



return






User Function LEGENDA()

	local aLegenda := {}

	AADD(aLegenda, {"BR_VERDE"    ,"A Receber"})
	AADD(aLegenda, {"BR_AZUL"     ,"A Pagar"  })
	AADD(aLegenda, {"BR_PRETO"    ,"Aprovado" })
	AADD(aLegenda, {"BR_VERMELHO" ,"Recusado" })

	BrwLegenda("Revisao","Legenda",aLegenda)

return



User Function REVISADO01()
	Local nRecno   := ZZB->(RecNo())
	Local aFINA100 := {}
	Local filial
	Local ddata
	Local moeda
	Local valor
	Local natur
	Local banc
	Local agen
	Local conta
	Local docm
	Local histo
	Local loja

	Private lMsHelpAuto := .t.
	Private lMsErroAuto := .f.


	ZZB->(DbGoTo(nRecNo))

	filial  := ZZB->ZZB_FILIAL
	ddata   := ZZB->ZZB_DATA
	moeda   := ZZB->ZZB_MOEDA
	valor   := ZZB->ZZB_VALOR //
	natur   := ZZB->ZZB_NATUR
	banc    := ZZB->ZZB_BANC
	agen    := ZZB->ZZB_AGEN
	conta   := ZZB->ZZB_CONTA
	docm    := ZZB->ZZB_DOCM
	histo   := ZZB->ZZB_HISTO
	loja    := ZZB->ZZB_LOJA

	nOpc := iif(ZZB->ZZB_TIPOOP == "P", 3, 4 )

	if ZZB_STATUS != AllTrim("S") .AND. ZZB_STATUS != AllTrim("N")
	    
        Prepare Environment Empresa "01" Filial filial
		//RpcSetEnv("01", filial)

		//Begin Transaction
		aFINA100:= {{'E5_DATA'     ,ddata   ,Nil},; //{'E5_FILIAL' ,xFilial("SE5")  ,Nil},;
			        {'E5_MOEDA'    ,moeda   ,Nil},;
			        {'E5_VALOR'    ,valor   ,Nil},;
			        {'E5_NATUREZ'  ,natur   ,Nil},;
			        {'E5_VENCTO'   ,ddata   ,Nil},;
			        {'E5_BANCO'    ,banc    ,Nil},;
			        {'E5_AGENCIA'  ,agen    ,Nil},;
			        {'E5_CONTA'    ,conta   ,Nil},;
			        {'E5_DOCUMEN'  ,docm    ,Nil},;
			        {'E5_HISTOR'   ,histo   ,Nil},;
			        {'E5_LOJA'     ,loja    ,Nil}  }
			
			  
		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,nOpc)

		If lMsErroAuto
			//DisarmTransaction()
			Mostraerro()
		else
			ZZB->(RecLock("ZZB", .F.) )
			ZZB->ZZB_STATUS := "S"
			ZZB->ZZB_DTREV  := dDataBase
			ZZB->(MsUnlock())
			alert("Movimento incluido com sucesso!")

		EndIf

	endif
	//End Transaction

	//Reset Environment

Return










