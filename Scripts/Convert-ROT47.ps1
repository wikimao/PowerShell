###############################################################################################################
# Language     :  PowerShell 4.0
# Filename     :  Convert-ROT47.ps1
# Autor        :  BornToBeRoot (https://github.com/BornToBeRoot)
# Description  :  Rotate ascii chars by n places (Caesar cipher)
# Repository   :  https://github.com/BornToBeRoot/PowerShell
###############################################################################################################

<#
    .SYNOPSIS
    Rotate ascii chars by n places (Caesar cipher)

    .DESCRIPTION
    Rotate ascii chars by n places (Caesar cipher). You can encrypt with the parameter "-Encrypt" or decrypt with the parameter "-Decrypt", depens on what you need. Decryption is selected by default.

    Try the parameter "-UseAllAsciiChars" if you have a string with umlauts which e.g. exist in the German language. 

    .EXAMPLE
    .\Convert-ROT47.ps1 -Text "This is an encrypted string!" -Rot 7

    Rot Text
    --- ----
      7 [opz pz hu lujy"w{lk z{ypun(

    .EXAMPLE
    .\Convert-ROT47.ps1 -Text '[opz pz hu lujy"w{lk z{ypun(' -Rot (1..10)

    Rot Text
    --- ----
      1 Znoy oy gt ktix!vzkj yzxotm'
      2 Ymnx nx fs jshw~uyji xywnsl&
      3 Xlmw mw er irgv}txih wxvmrk%
      4 Wklv lv dq hqfu|swhg vwulqj$
      5 Vjku ku cp gpet{rvgf uvtkpi#
      6 Uijt jt bo fodszqufe tusjoh"
      7 This is an encrypted string!
      8 Sghr hr `m dmbqxosdc rsqhmf~
      9 Rfgq gq _l clapwnrcb qrpgle}
     10 Qefp fp ^k bk`ovmqba pqofkd|

    .EXAMPLE
    .\Convert-ROT47.ps1 -Text "Beispiel: Cäsar-Verschlüsselung - Sprache Deutsch!" -Rot 3 -Encrypt -UseAllAsciiChars

    Rot Text
    --- ----
      3 Ehlvslho= Fçvdu0Yhuvfkoÿvvhoxqj 0 Vsudfkh Ghxwvfk$

    .EXAMPLE
    .\Convert-ROT47.ps1 -Text "Ehlvslho= Fçvdu0Yhuvfkoÿvvhoxqj 0 Vsudfkh Ghxwvfk$" -Rot (1..10) -UseAllAsciiChars

    Rot Text
    --- ----
      1 Dgkurkgn< Eæuct/Xgtuejnþuugnwpi / Urtcejg Fgwvuej#
      2 Cfjtqjfm; Dåtbs.Wfstdimýttfmvoh . Tqsbdif Efvutdi"
      3 Beispiel: Cäsar-Verschlüsselung - Sprache Deutsch!
      4 Adhrohdk9 Bãr`q,Udqrbgkûrrdktmf , Roq`bgd Cdtsrbg
      5 @cgqngcj8 Aâq_p+Tcpqafjúqqcjsle + Qnp_afc Bcsrqaf▼
      6 ?bfpmfbi7 @áp^o*Sbop`eiùppbirkd * Pmo^`eb Abrqp`e▲
      7 >aeoleah6 ?ào]n)Rano_dhøooahqjc ) Oln]_da @aqpo_d↔
      8 =`dnkd`g5 >ßn\m(Q`mn^cg÷nn`gpib ( Nkm\^c` ?`pon^c∟
      9 <_cmjc_f4 =Þm[l'P_lm]bfömm_foha ' Mjl[]b_ >_onm]b←
     10 ;^blib^e3 <ÝlZk&O^kl\aeõll^eng` & LikZ\a^ =^nml\a→

    .LINK
    https://github.com/BornToBeRoot/PowerShell/blob/master/Documentation/Convert-ROT47.README.md
#>

[CmdletBinding(DefaultParameterSetName='Decrypt')]
param (
    [Parameter(
        Position=0,
        Mandatory=$true,
        HelpMessage='String which you want to encrypt or decrypt')]    
    [String]$Text,

    [Parameter(
        Position=1,
        HelpMessage='Specify which rotation you want to use (Default=1..47)')]
    [ValidateRange(1,47)]
    [Int32[]]$Rot=1..47,

    [Parameter(
        ParameterSetName='Encrypt',
        Position=2,
        HelpMessage='Encrypt a string')]
    [switch]$Encrypt,
    
    [Parameter(
        ParameterSetName='Decrypt',
        Position=2,
        HelpMessage='Decrypt a string')]
    [switch]$Decrypt,

    [Parameter(
        Position=3,
        HelpMessage='Use complete ascii table 0..255 chars (Default=33..126)')]
    [switch]$UseAllAsciiChars
)

Begin{
    [System.Collections.ArrayList]$AsciiChars = @()
     
    $CharsIndex = 1
    
    $StartAscii = 33
    $EndAscii = 126

    # Use all ascii chars (useful for languages like german)
    if($UseAllAsciiChars.IsPresent)
    {
        $StartAscii = 0
        $EndAscii = 255

        Write-Host "Warning: Parameter -UseAllAsciiChars will use all chars from 0 to 255 in the ascii table. This may not work properly, but could be usefull to encrypt or decrypt languages like german with umlauts!" -ForegroundColor Yellow
    }

    # Add chars from ascii table
    foreach($i in $StartAscii..$EndAscii)
    {
        $Char = [char]$i

        [pscustomobject]$Result = @{
            Index = $CharsIndex
            Char = $Char
        }   

        [void]$AsciiChars.Add($Result)

        $CharsIndex++
    }

    # Default mode is "Decrypt"
    if(($Encrypt.IsPresent -eq $false -and $Decrypt.IsPresent -eq $false) -or ($Decrypt.IsPresent)) 
    {        
        $Mode = "Decrypt"
    }    
    else 
    {
        $Mode = "Encrypt"
    }

    Write-Verbose "Mode is set to: $Mode"
}

Process{
    foreach($Rot2 in $Rot)
    {        
        $ResultText = [String]::Empty

        # Go through each char in string
        foreach($i in 0..($Text.Length -1))
        {
            $CurrentChar = $Text.Substring($i, 1)

            if(($AsciiChars.Char -ccontains $CurrentChar) -and ($CurrentChar -ne " ")) # Upper chars
            {
                if($Mode -eq  "Encrypt")
                {                    
                    [int]$NewIndex = ($AsciiChars | Where-Object {$_.Char -ceq $CurrentChar}).Index + $Rot2 
                    
                    if($NewIndex -gt $AsciiChars.Count)
                    {
                        $NewIndex -= $AsciiChars.Count                     
                    
                        $ResultText +=  ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    else 
                    {
                        $ResultText += ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char    
                    }
                }
                else 
                {
                    [int]$NewIndex = ($AsciiChars | Where-Object {$_.Char -ceq $CurrentChar}).Index - $Rot2 

                    if($NewIndex -lt 1)
                    {
                        $NewIndex += $AsciiChars.Count                     
                    
                        $ResultText +=  ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char
                    }
                    else 
                    {
                        $ResultText += ($AsciiChars | Where-Object {$_.Index -eq $NewIndex}).Char    
                    }
                }   
            }
            else 
            {
                $ResultText += $CurrentChar  
            }
        } 
    
        $Result = [pscustomobject] @{
            Rot = $Rot2
            Text = $ResultText
        }

        $Result
    }
}

End{

}
        