using System;
using System.Diagnostics;
using System.Threading.Tasks;

namespace KalkiLauncher
{
    public class DiskManager
    {
        // List partitions (calls PowerShell Get-Partition)
        public async Task<string> ListPartitionsAsync()
        {
            return await RunPowerShellAsync("Get-Partition | Format-Table -AutoSize");
        }

        // Shrink the main Windows partition (C:) by a given size in GB
        public async Task<string> ShrinkWindowsPartitionAsync(int shrinkGB)
        {
            // Use PowerShell Resize-Partition
            string script = $@"
$partition = Get-Partition -DriveLetter C
Resize-Partition -DriveLetter C -Size ($partition.Size - {shrinkGB}GB)
";
            return await RunPowerShellAsync(script);
        }

        // Create a new partition in unallocated space
        public async Task<string> CreateNewPartitionAsync(int sizeGB)
        {
            string script = $@"
$disk = Get-Disk | Where-Object PartitionStyle -Eq 'GPT' | Where-Object IsSystem -Eq $true
New-Partition -DiskNumber $disk.Number -UseMaximumSize -Size ({sizeGB}GB) | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'KalkiOS'
";
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
                return output;
            }
            catch (Exception ex)
            {
                return $"[EXCEPTION] {ex.Message}";
            }
        }

        // TODO: Integrate with main UI after ISO download
    }
} 