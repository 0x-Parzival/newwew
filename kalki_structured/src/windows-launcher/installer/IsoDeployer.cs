using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;

namespace KalkiLauncher
{
    public class IsoDeployer
    {
        // Mount the ISO and return the mounted drive letter
        public async Task<string> MountIsoAsync(string isoPath)
        {
            string script = $@"
$img = Mount-DiskImage -ImagePath '{isoPath}' -PassThru
$vol = ($img | Get-Volume)[0]
$vol.DriveLetter
";
            return await RunPowerShellAsync(script);
        }

        // Copy all files from sourceDrive (ISO) to targetDrive (partition)
        public async Task<string> CopyIsoContentsAsync(string sourceDrive, string targetDrive)
        {
            // Use robocopy for robust copying
            string cmd = $"robocopy {sourceDrive}:\\ {targetDrive}:\\ /E /COPYALL /R:1 /W:1";
            return await RunCmdAsync(cmd);
        }

        // Unmount the ISO
        public async Task<string> UnmountIsoAsync(string isoPath)
        {
            string script = $"Dismount-DiskImage -ImagePath '{isoPath}'";
            return await RunPowerShellAsync(script);
        }

        // Helper to run PowerShell and capture output
        private async Task<string> RunPowerShellAsync(string script)
        {
            var psi = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = $"-NoProfile -ExecutionPolicy Bypass -Command \"{script.Replace("\"", "\\\"")}\"",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                Verb = "runas" // Requires admin
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

        // TODO: Integrate with main UI after partitioning
    }
} 