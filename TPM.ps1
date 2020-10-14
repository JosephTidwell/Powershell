$computers= Get-ADComputer -filter * | select name

foreach ($computer in $computers) {

Invoke-Command -ScriptBlock {

$_

get-tpm | select ManufacturerIdTxt, ManufacturerVersion

    }
}




$Jobs= @()
ForEach ($Machine in $MachinesToRemote) {
    ForEach ($Module in $Modules) {
        $Jobs += Invoke-Command $Machine.Name -Credential $Machine.Credentials -scriptblock $Module.ScriptBlock -ArgumentList $Machine, $False, $ModVars -AsJob
    }
}