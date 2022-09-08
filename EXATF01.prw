//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Grupo de Produtos"

//////////////////////////////////////////////////////////
// Autor: JOAO VICTOR                                   //
// Empresa: JVC INFO                                    //
// Funcao: M410PVNF                                     // 
// Descricao: Cadastro de SubGrupos e Familias para o   //
//            produto                                   //
// Data: 16/08/2022                                     //
//////////////////////////////////////////////////////////
User Function EXATF01()
	Local aArea   := GetArea()
	Local oBrowse
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SBM")
	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	//Legendas
	//oBrowse:AddLegend( "SBM->BM_PROORI == '1'", "GREEN",	"Original" )
	//oBrowse:AddLegend( "SBM->BM_PROORI == '0'", "RED",	"Não Original" )
	//Ativa a Browse
	oBrowse:Activate()
	RestArea(aArea)
Return Nil
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

// Menu 
Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.EXATF01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.EXATF01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Inc. Subg/Familia'    ACTION 'VIEWDEF.EXATF01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    //ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.EXATF01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

//Adiciona o arrya do submenu a opção do menu


Return aRot



Static Function ModelDef()
	Local oModel 	:= Nil
	Local oStPai    := FWFormStruct(1, 'SBM')
	Local oStFilho 	:= FWFormStruct(1, 'SZA')
	Local oStNeto 	:= FWFormStruct(1, 'SZB')
	Local aSZARel	:= {}
	Local aSZBRel	:= {}
	//Local aAux
	//local CONFIRMMVC02 := {|| u_CONFIRM02()}
  //local CANCELMVC02  := {|| u_CANCEL02()}
	 aAux := FwStruTrigger("ZB_DESCRIC","ZB_CODIGO","U_EXATF02()",.F. ,"" ,0 ,"" ,NIL , "ITR01" ) 
	 oStNeto:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )
	 aAux1 := FwStruTrigger("ZA_DESCRIC","ZA_CODIGO","U_EXATF03()",.F. ,"" ,0 ,"" ,NIL , "ITR01" ) 
	 oStFilho:AddTrigger( aAux1[1], aAux1[2], aAux1[3], aAux1[4] )
	
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('EXATF01M',, /*CONFIRMMVC02 , ,CANCELMVC02*/)
	oModel:AddFields('SBMMASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('SZADETAIL','SBMMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	oModel:AddGrid('SZBDETAIL','SZADETAIL',oStNeto, /*{ |oModelGrid, nLine, cAction, cField| COMPPRE(oModelGrid, nLine, cAction, cField) }*/, /*bLinePos*/ ,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aSZARel, {'ZA_FILIAL',	'BM_FILIAL'} )
	aAdd(aSZARel, {'ZA_GRUPO',	'BM_GRUPO'})
	
	//Fazendo o relacionamento entre o Filho e Neto GETSXENUM("SZB","ZB_CODIGO")
	aAdd(aSZBRel, {'ZB_FILIAL',	'ZA_FILIAL'} )
	aAdd(aSZBRel, {'ZB_SUBGR',  'ZA_CODIGO'}) 
	
	oModel:SetRelation('SZADETAIL', aSZARel, SZA->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('SZADETAIL'):SetUniqueLine({"ZA_FILIAL","ZA_CODIGO"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	oModel:SetRelation('SZBDETAIL', aSZBRel, SZB->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('SZBDETAIL'):SetUniqueLine({"ZB_FILIAL","ZB_ITEM","ZB_CODIGO"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey({})
	
	//Setando as descrições
	oModel:SetDescription("Grupo de Produtos")
	oModel:GetModel('SBMMASTER'):SetDescription('Modelo Grupo')
	oModel:GetModel('SZADETAIL'):SetDescription('Modelo SubGrupo')
	oModel:GetModel('SZBDETAIL'):SetDescription('Modelo Familia')
	
	//Adicionando totalizadores
	//oModel:AddCalc('TOT_SALDO', 'SB1DETAIL', 'SB2DETAIL', 'B2_QATU', 'XX_TOTAL', 'SUM', , , "Saldo Total:" )
Return oModel
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	Local oView	  	:= Nil
	Local oModel    := FWLoadModel('EXATF01')
	Local oStPai	:= FWFormStruct(2, 'SBM')
	Local oStFilho	:= FWFormStruct(2, 'SZA',{ |cCampo| CABSTRU(cCampo,'SZA') } )
	Local oStNeto	:= FWFormStruct(2, 'SZB',{ |cCampo| CABSTRU(cCampo,'SZB') } )
	
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)


	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_SBM',oStPai  ,'SBMMASTER')
	oView:AddGrid('VIEW_SZA' ,oStFilho,'SZADETAIL')
	oView:AddGrid('VIEW_SZB' ,oStNeto ,'SZBDETAIL')
	//oView:AddField('VIEW_TOT', oStTot,'TOT_SALDO')
	oView:AddIncrementField('VIEW_SZB', 'ZB_ITEM')
	oView:AddIncrementField('VIEW_SZA', 'ZA_ITEM')
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',40)
	oView:CreateHorizontalBox('GRID2',30)
	//oView:CreateHorizontalBox('TOTAL',13)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_SBM','CABEC')
	oView:SetOwnerView('VIEW_SZA','GRID')
	oView:SetOwnerView('VIEW_SZB','GRID2')
	//oView:SetOwnerView('VIEW_TOT','TOTAL')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_SBM','Grupo')
	oView:EnableTitleView('VIEW_SZA','Subgrupo')
	oView:EnableTitleView('VIEW_SZB','Familia')
	
	oStFilho:SetProperty("ZA_ITEM", MVC_VIEW_ORDEM, "2")
	
Return oView
/*
User Function CONFIRM02()
	local oModelPad := FWModelActivate()
	local nOpc      := oModelPad:GetOperation()
	if nOpc == 3 .or. nOpc == 4
		alert("CONFIRM")
		ConfirmSX8()
	endif
return .T.
User Function CANCEL02
	alert("cancel")
	RollBackSX8()
return .T.
*/
Static Function CABSTRU( cCampo,cAlias )
	Local lRet := .T.
	If cAlias == "SZA" .and. ( alltrim(cCampo) == 'ZA_FILIAL' .OR.  alltrim(cCampo) == 'ZA_GRUPO')
		lRet := .F.
	EndIf
	If cAlias == "SZB".and. ( alltrim(cCampo) == 'ZB_FILIAL' .OR.  alltrim(cCampo) == 'ZB_SUBGR')
		lRet := .F.
	EndIf
	If cAlias == "SZA".and. ( alltrim(cCampo) == 'ZA_FILIAL' .OR.  alltrim(cCampo) == 'ZA_CODANT')
		lRet := .F.
	EndIf
Return lRet
/*Static Function COMPPRE(oModelGrid, nLine, cAction, cField)
 	Local lRet := .T.
 	Local oModel := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()
	// Valida se pode ou não apagar uma linha do Grid
	If cAction == 'CANSETVALUE' .AND. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
			oModelGrid:SetValue('ZB_CODIGO', M->ZA_CODIGO + oModelGrid:getValue("ZB_IEM"))
	EndIf
Return lRet*/
User function EXATF02()
    Local cCod := ""
	Local cIt := ""
	Local oModel := FWModelActive()
	Local oMZB := oModel:GetModel('SZBDETAIL')
	Local oMZA := oModel:GetModel('SZADETAIL')
	cIt := oMZB:getValue("ZB_ITEM")
	cCod := AllTrim(oMZA:getValue("ZA_CODIGO"))
return 	cCod + cIt 

User function EXATF03()

    Local cCod := ""
	Local cIt := ""
	local cSubant := ""
	Local oModel := FWModelActive()
	Local oMZA := oModel:GetModel('SZADETAIL')
	Local oMBM := oModel:GetModel('SBMMASTER')
  
	cIt := oMZA:getValue("ZA_ITEM")
	cSubant := oMZA:getValue("ZA_CODANT")
	cCod := oMBM:getValue("BM_GRUPO") 
	oMZA:SetValue("ZA_GRUPO", cCod)

	
return 	cCod + cIt  
