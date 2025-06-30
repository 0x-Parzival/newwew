using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace KalkiLauncher
{
    public class VmLauncher
    {
        private string qemuPath = "qemu-system-x86_64.exe"; // Assume in PATH or bundled
        private string vboxPath = "VirtualBox.exe";

        // Check for QEMU in PATH or bundled directory
        public bool IsQemuAvailable()
        {
            return File.Exists(qemuPath) || FindInPath(qemuPath) != null;
        }

        // Check for VirtualBox in PATH
        public bool IsVirtualBoxAvailable()
        {
            return FindInPath(vboxPath) != null;
        }

        // Launch ISO in QEMU
        public async Task<string> LaunchQemuAsync(string isoPath)
        {
            if (!IsQemuAvailable())
                return "QEMU not found. Please install or bundle QEMU.";
            string qemuExe = File.Exists(qemuPath) ? qemuPath : FindInPath(qemuPath);
            if (qemuExe == null)
                return "QEMU executable not found.";
            string args = $"-m 2048 -smp 2 -cdrom \"{isoPath}\" -boot d -enable-kvm -net nic -net user";
            var psi = new ProcessStartInfo
            {
                FileName = qemuExe,
                Arguments = args,
                UseShellExecute = false,
                CreateNoWindow = false
            };
            try
            {
                using var proc = Process.Start(psi);
                return "QEMU launched. Close the VM window to return.";
            }
            catch (Exception ex)
            {
                return $"[EXCEPTION] {ex.Message}";
            }
        }

        // Launch ISO in VirtualBox (if available)
        public async Task<string> LaunchVirtualBoxAsync(string isoPath)
        {
            string vboxExe = FindInPath(vboxPath);
            if (vboxExe == null)
                return "VirtualBox not found.";
            string args = $"--startvm KalkiVM --cdrom \"{isoPath}\"";
            var psi = new ProcessStartInfo
            {
                FileName = vboxExe,
                Arguments = args,
                UseShellExecute = false,
                CreateNoWindow = false
            };
            try
            {
                using var proc = Process.Start(psi);
                return "VirtualBox launched. Close the VM window to return.";
            }
            catch (Exception ex)
            {
                return $"[EXCEPTION] {ex.Message}";
            }
        }

        // Helper to find executable in PATH
        private string? FindInPath(string exe)
        {
            var paths = Environment.GetEnvironmentVariable("PATH")?.Split(';');
            if (paths == null) return null;
            foreach (var path in paths)
            {
                var full = Path.Combine(path.Trim(), exe);
                if (File.Exists(full)) return full;
            }
            return null;
        }

        // TODO: Integrate with main UI when user selects "Try in VM"
    }
} 