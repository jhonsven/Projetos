#include "protheus.ch"
//////////////////////////////////////////////////////////
// Autor: JOAO VICTOR                                   //
// Empresa: JVC INFO                                    //
// Funcao: M410PVNF                                     // 
// Descricao: Salvar bairro no pedido de venda          //
// Data: 16/05/2022                                     //
//////////////////////////////////////////////////////////


User Function A100CABE()
 Local aArea := GetArea()

	If nOrigExp == 1 // Pedido de Venda liberado

		//CB7->(RecLock("CB7",.F.))

		CB7->CB7_BAIR := Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE,"A1_BAIRRO")

		//CB7->(MsUnlock())

	Endif

  RestArea(aArea)

return












