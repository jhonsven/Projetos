#Include "Protheus.ch"
#include "topconn.ch"

//////////////////////////////////////////////////////////////////////////////////////
// Empresa: JVCS                                                                    //
// Autor : Joao Victor Coelho dos Santos                                            //
// Data: 16/06/2022                                                                 //
//                                                           //
// Descricao: Botões de aplicar desconto e igualar a preco base                     //
//////////////////////////////////////////////////////////////////////////////////////
  
User Function OS010BTN()

    Local aArea    := GetArea()
    Local aButtons := {}
     
    aAdd(aButtons,{ "* Desconto", {|| u_zDesc01() },"* Desconto" }) //20220728
    aAdd(aButtons,{ "* Igualar preco de VENDA a preco BASE", {|| Processa({|| u_zIgualar01()}, "Igualando...")}, "* Igualar preco de VENDA a preco BASE" })
    aAdd(aButtons,{ "* transferir preco de venda a preco base", {|| Processa({|| u_zTransf()}, "Igualando...")}, "transferir preco de venda a preco base" })
    RestArea(aArea)

Return aButtons
 
User Function zDesc01()

    Local aArea      := GetArea()
    Local nJanAltu   := 100
    Local nJanLarg   := 150
    Local oFontPad   := TFont():New("Arial", , -14)
   

    Private lNovo    := .F.
    Private oDlgAtu
    Private cMaskDA1 := PesqPict('DA1', 'DA1_PRCVEN')

    Private oModelPad  := FWModelActive()
    Private oModelGrid := oModelPad:GetModel('DA1DETAIL')
    Private mvpar11 := ""
    Private mvpar22 := ""
    Private mvpar33 := ""
    
     
    //Pegando posições do aHeader
    Private nPosVlDes   := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_VLRDES")})    
    Private nPosPrcV    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_PRCVEN")})
    Private nPosPrcbase := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_PRCBAS")})
    Private nPosGrupo   := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_GRUPO" )})
    Private nPosProd    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_CODPRO")})
   
    Private nLinAtu    := oModelGrid:nLine
    
    //Linha encontrada
    Private nLinEnc    := 0
     
    Private oGetPrc, nGetPrc := 0
    Private oGetMsg, cGetMsg := ""


    Pergunte("XTABPREC",.T.)

    mvpar11 := mv_par01
    mvpar22 := mv_par02
    mvpar33 := mv_par03

     
    //Montando a janela
    DEFINE MSDIALOG oDlgAtu TITLE "Aplicar Desconto" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
    
        nColAux := 015
        
        @ 007, nColAux    SAY  oSayPrc PROMPT "% Desconto: " SIZE 050, 007 OF oDlgAtu COLORS 0, 16777215  PIXEL
        @ 004, nColAux   MSGET oGetPrc   VAR      nGetPrc    SIZE 045, 010 OF oDlgAtu COLORS 0, 16777215 PICTURE cMaskDA1 PIXEL 
         
        @ 023, 003       MSGET oGetMsg   VAR      cGetMsg    SIZE (nJanLarg/2)-12, 012 OF oDlgAtu COLORS 0, 16777215 NO BORDER FONT oFontPad PIXEL
        oGetMsg:lActive := .F.
        oGetMsg:setCSS("QLineEdit{color:#FF0000; background-color:#FEFEFE;}")
         
        //Botão confirmar
       
        @ (nJanAltu/2)-24, (nJanLarg/2)-60  BUTTON oBtnCon  PROMPT "Confirmar"  SIZE 048, 018 OF oDlgAtu ACTION(Processa({|| fConfirmar()}, "Aplicando desconto..."), oDlgAtu:end() )                                                 PIXEL
     
    ACTIVATE MSDIALOG oDlgAtu CENTERED
     
    oModelGrid:nLine := 1
     
    RestArea(aArea)

   

Return




User Function zIgualar01()

local aPrecobase := ""          
local nXi        := 1
local cCodpro    := ""
local cCodTab    := ""
local mvpar1  := ""
local mvpar2  := ""
local mvpar3  := ""
local nRegua := 1
local cGrupo := ""


Private oModelPad  := FWModelActive()
Private oModelGrid := oModelPad:GetModel('DA1DETAIL')

Private nPosPrcV    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_PRCVEN")})
Private nPosPrcbase := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_PRBS")})
Private nPosGrupo   := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_GRUPO" )})
Private nPosProd    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_CODPRO")})
Private nPosCodTabe := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_CODTAB")})


   if MsgYesNo( "Você está prestes a igualar o preco de VENDA ao preco BASE. Confirmar?", "Igualar precos" )
        
       Pergunte("XTABPREC",.T.)

       mvpar1 := mv_par01
       mvpar2 := mv_par02
       mvpar3 := mv_par03


       ProcRegua(len(oModelGrid:aCols)) //20220728


       for nXi := 1 to len(oModelGrid:aCols)
          cCodpro := oModelGrid:aCols[nXi, nPosProd]
          cCodTab := oModelGrid:aCols[nXi, nPosCodTabe]
          SB1->(Dbsetorder(1))
          if SB1->(DbSeek(xFilial("SB1") + cCodpro )) //.and. !EMPTY(SB1->B1_XFORNEC)
              cGrupo := SB1->B1_GRUPO

              oModelGrid:GoLine(nXi)
              
             if mvpar2 <= SB1->B1_XFORNEC .and. SB1->B1_XFORNEC <= mvpar3
                if EMPTY(mvpar1)

                    aPrecobase := oModelGrid:aCols[nXi, nPosPrcbase] 
                    //oModelGrid:aCols[nXi, nPosPrcV] := aPrec
                  
                   if aPrecobase <> 0
                    oModelGrid:SetValue("DA1_PRCVEN",aPrecobase)
                    endif

                       
                   
                elseif oModelGrid:aCols[nXi, nPosGrupo] <> mvpar1 .AND. cGrupo <> mvpar1

                    aPrecobase := oModelGrid:aCols[nXi, nPosPrcbase] 
                   //oModelGrid:aCols[nXi, nPosPrcV] := aPrecobase  
                    if aPrecobase <> 0
                    oModelGrid:SetValue("DA1_PRCVEN",aPrecobase)
                    endif

                endif
           endif 
        endif 
        nRegua++
        IncProc("Igualando precos: " + cValToChar(nRegua) + " de " + cValToChar(len(oModelGrid:aCols)) + "...")
       next
    endif

oModelGrid:nLine := 1

return



Static Function fConfirmar()

local aPrcvenda  := ""          //oModelGrid:aCols[nLinatu, nPosPrcV]
local nXi := 1
Local cCodpro := ""
local cPrecDesc := 0
local cGrupo :=  ""


    ProcRegua(len(oModelGrid:aCols))

for nXi := 1 to len(oModelGrid:aCols)   
   
    

    cCodpro := oModelGrid:aCols[nXi, nPosProd]
    SB1->(Dbsetorder(1))
    if SB1->(DbSeek(xFilial("SB1") + cCodpro )) //.and. !EMPTY(SB1->B1_XFORNEC)  oModelGrid:LoadValue("DA1_PRCVEN",cPrecDesc)
       cGrupo := SB1->B1_GRUPO
       if mvpar22 <= SB1->B1_XFORNEC .and. SB1->B1_XFORNEC <= mvpar33
            aPrcvenda  := oModelGrid:aCols[nXi, nPosPrcV]
            cPrecDesc := aPrcvenda - (nGetPrc/100*aPrcvenda)
            oModelGrid:GoLine(nXi)

            IF oModelGrid:aCols[nXi, nPosPrcbase] == 0  

              oModelGrid:SetValue("DA1_PRBS",aPrcvenda) 

            endif  

            if Empty(mvpar11)

                oModelGrid:SetValue("DA1_PRCVEN",cPrecDesc)

            elseif oModelGrid:aCols[nXi, nPosGrupo] <> mvpar11 .AND. cGrupo <> mvpar11

                oModelGrid:SetValue("DA1_PRCVEN",cPrecDesc)

            endif
        endif
    endif
 IncProc("Aplicando desconto " + cValToChar(nXi) + " de " + cValToChar(len(oModelGrid:aCols)) + "...")
next

return




User Function zTransf()
local aPrecobase := ""          
local nXi        := 1
local cCodpro    := ""
local cCodTab    := ""
local mvpar1  := ""
local mvpar2  := ""
local mvpar3  := ""
local nRegua := 1
local cGrupo := ""
local nPrcven := ""


Private oModelPad  := FWModelActive()
Private oModelGrid := oModelPad:GetModel('DA1DETAIL')

Private nPosPrcV    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_PRCVEN")})
Private nPosPrcbase := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_PRBS")})
Private nPosGrupo   := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_GRUPO" )})
Private nPosProd    := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_CODPRO")})
Private nPosCodTabe := aScan(oModelGrid:aHeader, {|x| AllTrim(x[2]) == AllTrim("DA1_CODTAB")})


   if MsgYesNo( "Você está prestes a igualar o preco de VENDA ao preco BASE. Confirmar?", "Igualar precos" )
        
       Pergunte("XTABPREC",.T.)

       mvpar1 := mv_par01
       mvpar2 := mv_par02
       mvpar3 := mv_par03


       ProcRegua(len(oModelGrid:aCols)) //20220728


       for nXi := 1 to len(oModelGrid:aCols)
          cCodpro := oModelGrid:aCols[nXi, nPosProd]
          cCodTab := oModelGrid:aCols[nXi, nPosCodTabe]
          SB1->(Dbsetorder(1))
          if SB1->(DbSeek(xFilial("SB1") + cCodpro )) //.and. !EMPTY(SB1->B1_XFORNEC)
              cGrupo := SB1->B1_GRUPO

              oModelGrid:GoLine(nXi)
              
             if mvpar2 <= SB1->B1_XFORNEC .and. SB1->B1_XFORNEC <= mvpar3
                if EMPTY(mvpar1)

                    aPrecobase := oModelGrid:aCols[nXi, nPosPrcbase] 
                    nPrcven    := oModelGrid:aCols[nXi, nPosPrcV]
                  
                    if nPrcven != 0
                    oModelGrid:SetValue("DA1_PRBS",nPrcven)
                    endif
                    
                       
                elseif oModelGrid:aCols[nXi, nPosGrupo] <> mvpar1 .AND. cGrupo <> mvpar1

                    aPrecobase := oModelGrid:aCols[nXi, nPosPrcbase] 
                    nPrcven    := oModelGrid:aCols[nXi, nPosPrcV]
                   
                    if nPrcven != 0
                    oModelGrid:SetValue("DA1_PRBS",nPrcven)
                    endif
                  
                endif
           endif 
        endif 
        nRegua++
        IncProc("Igualando precos: " + cValToChar(nRegua) + " de " + cValToChar(len(oModelGrid:aCols)) + "...")
       next
    endif

oModelGrid:nLine := 1


return
