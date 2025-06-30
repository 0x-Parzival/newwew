using System;
using System.Windows.Forms;
using System.Threading.Tasks;

namespace KalkiLauncher
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }
    }

    public class MainForm : Form
    {
        private ProgressBar progressBar;
        private Label statusLabel;
        private ISOManager isoManager;
        private DiskManager diskManager;
        private IsoDeployer isoDeployer;
        private BcdManager bcdManager;
        private VmLauncher vmLauncher;
        private const string ISO_URL = "https://releases.kalki.os/latest/KalkiOS.iso"; // TODO: Update to real URL
        private string lastInstallType = "";
        private string lastIsoPath = "";
        private string lastTargetDrive = "";

        public MainForm()
        {
            this.Text = "Kalki OS - Easy Installation";
            this.Width = 420;
            this.Height = 400;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;

            var label = new Label
            {
                Text = "🕉️ Install Kalki OS in 3 Steps\n\nChoose your installation type:",
                AutoSize = true,
                Top = 20,
                Left = 20
            };
            this.Controls.Add(label);

            var dualBootBtn = new Button { Text = "Dual Boot (Recommended)", Top = 70, Left = 20, Width = 180 };
            var replaceBtn = new Button { Text = "Replace Windows", Top = 110, Left = 20, Width = 180 };
            var tryVmBtn = new Button { Text = "Try in VM", Top = 150, Left = 20, Width = 180 };

            dualBootBtn.Click += async (s, e) => { lastInstallType = "dualboot"; await StartIsoDownload("dualboot"); };
            replaceBtn.Click += async (s, e) => { lastInstallType = "replace"; await StartIsoDownload("replace"); };
            tryVmBtn.Click += async (s, e) => { lastInstallType = "vm"; await StartTryInVm(); };

            this.Controls.Add(dualBootBtn);
            this.Controls.Add(replaceBtn);
            this.Controls.Add(tryVmBtn);

            progressBar = new ProgressBar { Top = 200, Left = 20, Width = 360, Height = 24, Visible = false };
            this.Controls.Add(progressBar);

            statusLabel = new Label { Top = 230, Left = 20, Width = 360, Height = 30, Text = "", AutoSize = false };
            this.Controls.Add(statusLabel);

            var info = new Label
            {
                Text = "\nAll operations are non-destructive by default.\nYou can undo boot menu changes at any time.",
                AutoSize = true,
                Top = 270,
                Left = 20
            };
            this.Controls.Add(info);

            isoManager = new ISOManager();
            diskManager = new DiskManager();
            isoDeployer = new IsoDeployer();
            bcdManager = new BcdManager();
            vmLauncher = new VmLauncher();
            isoManager.DownloadProgressChanged += (p) => this.Invoke((Action)(() => { progressBar.Value = p; statusLabel.Text = $"Downloading ISO... {p}%"; }));
            isoManager.DownloadCompleted += async (path) => await this.InvokeAsync(async () =>
            {
                progressBar.Visible = false;
                statusLabel.Text = $"Download complete: {path}";
                lastIsoPath = path;
                MessageBox.Show($"ISO downloaded to: {path}");
                if (lastInstallType == "dualboot")
                {
                    await StartDiskManagementDualBoot();
                }
                else if (lastInstallType == "replace")
                {
                    MessageBox.Show("[TODO] Disk wipe and full install not yet implemented.");
                }
                else if (lastInstallType == "vm")
                {
                    await StartTryInVm();
                }
            });
            isoManager.DownloadFailed += (msg) => this.Invoke((Action)(() => {
                progressBar.Visible = false;
                statusLabel.Text = msg;
                MessageBox.Show(msg, "Download Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }));
        }

        private async Task StartIsoDownload(string installType)
        {
            progressBar.Value = 0;
            progressBar.Visible = true;
            statusLabel.Text = "Starting ISO download...";
            await isoManager.DownloadISOAsync(ISO_URL);
        }

        private async Task StartTryInVm()
        {
            // Download ISO if not already downloaded
            if (string.IsNullOrEmpty(lastIsoPath) || !System.IO.File.Exists(lastIsoPath))
            {
                var confirm = MessageBox.Show("Kalki OS ISO not found. Download now?", "Download ISO", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
                if (confirm != DialogResult.Yes) return;
                await StartIsoDownload("vm");
                return;
            }
            progressBar.Value = 0;
            progressBar.Visible = true;
            statusLabel.Text = "Launching Kalki OS in VM...";
            string result;
            if (vmLauncher.IsQemuAvailable())
            {
                result = await vmLauncher.LaunchQemuAsync(lastIsoPath);
            }
            else if (vmLauncher.IsVirtualBoxAvailable())
            {
                result = await vmLauncher.LaunchVirtualBoxAsync(lastIsoPath);
            }
            else
            {
                result = "No supported VM engine (QEMU/VirtualBox) found. Please install QEMU or VirtualBox.";
            }
            progressBar.Visible = false;
            statusLabel.Text = result;
            MessageBox.Show(result, "Try in VM", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private async Task StartDiskManagementDualBoot()
        {
            // Prompt user for shrink size
            var input = Microsoft.VisualBasic.Interaction.InputBox(
                "How much space (in GB) do you want to allocate for Kalki OS?\nRecommended: 40+ GB",
                "Shrink Windows Partition",
                "40");
            if (!int.TryParse(input, out int shrinkGB) || shrinkGB < 10)
            {
                MessageBox.Show("Invalid size. Please enter a number greater than 10.");
                return;
            }
            var confirm = MessageBox.Show($"This will shrink your Windows partition by {shrinkGB} GB and create space for Kalki OS. Continue?",
                "Confirm Partition Shrink", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
            if (confirm != DialogResult.Yes) return;

            progressBar.Value = 0;
            progressBar.Visible = true;
            statusLabel.Text = "Shrinking Windows partition...";
            var shrinkResult = await diskManager.ShrinkWindowsPartitionAsync(shrinkGB);
            statusLabel.Text = shrinkResult;
            if (shrinkResult.Contains("[ERROR]") || shrinkResult.Contains("[EXCEPTION]"))
            {
                MessageBox.Show(shrinkResult, "Partition Shrink Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                progressBar.Visible = false;
                return;
            }
            statusLabel.Text = "Creating new partition for Kalki OS...";
            var createResult = await diskManager.CreateNewPartitionAsync(shrinkGB);
            statusLabel.Text = createResult;
            progressBar.Visible = false;
            if (createResult.Contains("[ERROR]") || createResult.Contains("[EXCEPTION]"))
            {
                MessageBox.Show(createResult, "Partition Creation Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            // Prompt for ISO deployment
            var deploy = MessageBox.Show("Partitioning complete!\n\nDo you want to deploy the ISO to the new partition now?",
                "Deploy ISO", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (deploy == DialogResult.Yes)
            {
                await StartIsoDeployment();
            }
            else
            {
                MessageBox.Show("You can deploy the ISO later from the main menu.");
            }
        }

        private async Task StartIsoDeployment()
        {
            progressBar.Value = 0;
            progressBar.Visible = true;
            statusLabel.Text = "Mounting ISO...";
            var mountResult = await isoDeployer.MountIsoAsync(lastIsoPath);
            if (mountResult.Contains("[ERROR]") || mountResult.Contains("[EXCEPTION]"))
            {
                MessageBox.Show(mountResult, "ISO Mount Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                progressBar.Visible = false;
                return;
            }
            var isoDrive = mountResult.Trim();
            statusLabel.Text = $"ISO mounted at {isoDrive}:\\. Copying files...";
            // Prompt user for target drive letter
            var targetDrive = Microsoft.VisualBasic.Interaction.InputBox(
                "Enter the drive letter of the new Kalki OS partition (e.g., D, E, F):",
                "Target Partition Drive Letter",
                "D");
            lastTargetDrive = targetDrive.Trim().ToUpper();
            var copyResult = await isoDeployer.CopyIsoContentsAsync(isoDrive, lastTargetDrive);
            statusLabel.Text = copyResult;
            if (copyResult.Contains("[ERROR]") || copyResult.Contains("[EXCEPTION]"))
            {
                MessageBox.Show(copyResult, "ISO Copy Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                await isoDeployer.UnmountIsoAsync(lastIsoPath);
                progressBar.Visible = false;
                return;
            }
            statusLabel.Text = "Unmounting ISO...";
            var unmountResult = await isoDeployer.UnmountIsoAsync(lastIsoPath);
            progressBar.Visible = false;
            if (unmountResult.Contains("[ERROR]") || unmountResult.Contains("[EXCEPTION]"))
            {
                MessageBox.Show(unmountResult, "ISO Unmount Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            // Prompt for BCD boot menu setup
            var bcd = MessageBox.Show("ISO deployment complete!\n\nDo you want to add Kalki OS to the Windows boot menu now?",
                "Add to Boot Menu", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (bcd == DialogResult.Yes)
            {
                await StartBcdSetup();
            }
            else
            {
                MessageBox.Show("You can add Kalki OS to the boot menu later from the main menu.");
            }
        }

        private async Task StartBcdSetup()
        {
            progressBar.Value = 0;
            progressBar.Visible = true;
            statusLabel.Text = "Adding Kalki OS to Windows boot menu...";
            var bcdResult = await bcdManager.AddKalkiEntryAsync(lastTargetDrive);
            progressBar.Visible = false;
            statusLabel.Text = bcdResult;
            if (bcdResult.Contains("[ERROR]") || bcdResult.Contains("[EXCEPTION]"))
            {
                MessageBox.Show(bcdResult, "BCD Setup Failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            var undo = MessageBox.Show("Kalki OS was added to the Windows boot menu!\n\nWould you like to add an undo option (remove Kalki entry)?",
                "Undo Boot Menu", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (undo == DialogResult.Yes)
            {
                var removeResult = await bcdManager.RemoveKalkiEntryAsync();
                MessageBox.Show(removeResult, "Undo Boot Menu", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            MessageBox.Show("Installation complete! You can now reboot and select Kalki OS from the boot menu.",
                "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            // Optionally, prompt to reboot
            var reboot = MessageBox.Show("Would you like to reboot now?", "Reboot", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
            if (reboot == DialogResult.Yes)
            {
                System.Diagnostics.Process.Start("shutdown", "/r /t 0");
            }
        }
    }

    // Helper for async Invoke
    public static class ControlExtensions
    {
        public static Task InvokeAsync(this Control control, Func<Task> func)
        {
            var tcs = new TaskCompletionSource<object?>();
            control.BeginInvoke(async () =>
            {
                try { await func(); tcs.SetResult(null); }
                catch (Exception ex) { tcs.SetException(ex); }
            });
            return tcs.Task;
        }
    }
} 