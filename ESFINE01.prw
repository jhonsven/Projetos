#include 'protheus.ch'
#include 'parmtype.ch'

//////////////////////////////////////////////////////////
// Autor: JOAO VICTOR                                   //
// Empresa: JVC INFO                                    //
// Funcao: M410PVNF                                     // 
// Descricao: gatilho no lançamento da despesa          //
// Data: 16/08/2022                                     //
//////////////////////////////////////////////////////////

User function ESFINE01(nTipo)
	local cRet     := ""
	local CodeUsr  := UsrRetName(RetCodUsr()) //UsrRetName()
	local aArea := GetArea()

	DbSelectArea("SA6")
	DbSetOrder(2)

	if DbSeek(xFilial("SA6")+ UPPER(CodeUsr))
		SLF->(DbSetOrder(1))
		if SLF->(Dbseek(xFilial("SLF") + SA6->A6_COD))
			if nTipo == 1
				cRet     := SA6->A6_COD
			elseif nTipo == 2
				cRet     := SA6->A6_AGENCIA
			elseif nTipo == 3
				cRet := SA6->A6_NUMCON
			endif
		endif
	endif

	RestArea(aArea)

return(cRet)
