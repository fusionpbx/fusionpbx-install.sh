Function Get-CPU() {
    if ($env:PROCESSOR_ARCHITECTURE -eq "x86") {
        Return "x86"
    }
    else {
        Return "x64"
    }
}