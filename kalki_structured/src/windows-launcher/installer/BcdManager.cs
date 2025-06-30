using System;
using System.Diagnostics;
using System.Threading.Tasks;

namespace KalkiLauncher
{
    public class BcdManager
    {
        // Add Kalki OS entry to BCD
        public async Task<string> AddKalkiEntryAsync(string targetDrive, string entryName = "Kalki OS")
        {
            // Use bcdedit to create a new boot entry
            string cmd = $@"
set KALKIID=
for /f ""tokens=2"" %%a in ('bcdedit /copy {{current}} /d ""{entryName}""') do set KALKIID=%%a
bcdedit /set %KALKIID% device partition={targetDrive}:
 bcdedit /set %KALKIID% osdevice partition={targetDrive}:
 bcdedit /set %KALKIID% path \EFI\Boot\bootx64.efi
 bcdedit /set %KALKIID% systemroot \Windows
 bcdedit /displayorder %KALKIID% /addlast
";
            return await RunCmdAsync(cmd);
        }

        // Remove Kalki OS entry from BCD (by description)
        public async Task<string> RemoveKalkiEntryAsync(string entryName = "Kalki OS")
        {
            string cmd = $@"
for /f ""tokens=1,2*"" %%a in ('bcdedit /enum all') do @if /i ""%%c""==""{entryName}"" set KALKIID=%%b
if defined KALKIID bcdedit /delete %KALKIID% /f
";
            return await RunCmdAsync(cmd);
        }

        // Helper to run CMD and capture output
        private async Task<string> RunCmdAsync(string cmd)
        {
            var psi = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/C {cmd}",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                Verb = "runas"
            };
            try
            {
                using var proc = Process.Start(psi);
                string output = await proc.StandardOutput.ReadToEndAsync();
                string error = await proc.StandardError.ReadToEndAsync();
                await proc.WaitForExitAsync();
                if (!string.IsNullOrWhiteSpace(error))
                    return $"[ERROR] {error}";
                return output.Trim();
            }
            catch (Exception ex)
            {
                return $"[EXCEPTION] {ex.Message}";
            }
        }

        // TODO: Integrate with main UI after ISO deployment
    }
} 