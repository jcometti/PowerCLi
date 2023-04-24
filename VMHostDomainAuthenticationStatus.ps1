$vcList = "[vcenter1.domain.com](http://vcenter1.domain.com/)","[vcenter2.domain.com](http://vcenter2.domain.com/)","[vcenter3.domain.com](http://vcenter3.domain.com/)" # Replace with your vCenters
$outputFile = "C:\temp\vmHostAuthResults.txt" # Replace with the desired output file path

# Get credential to connect to vCenters

$cred = Get-Credential

ForEach ($vc in $vcList) {
    Connect-VIServer $vc -Credential $cred
    $hosts = Get-VMHost
    Get-VMHostAuthentication -VMHost $hosts | Select VMHost, domain, domainmembershipstatus, trusteddomains | Sort VMHost | Format-Table -Autosize | Out-File $outputFile -Append
    Disconnect-VIServer -Confirm:$false
}
