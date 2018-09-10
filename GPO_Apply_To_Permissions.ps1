$perms = Foreach ($GPO in (Get-GPO -All )){
   Foreach ($Perm in (Get-GPPermissions $GPO.DisplayName -All | Where {$_.Permission -eq "GpoApply"})) {
      New-Object PSObject -property @{GPO=$GPO.DisplayName;Trustee=$Perm.Trustee.Name;Permission=$Perm.Permission}
   }
}
$perms | Select GPO,Trustee,Permission