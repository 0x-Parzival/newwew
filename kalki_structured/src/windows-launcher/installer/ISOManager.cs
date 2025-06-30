using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace KalkiLauncher
{
    public class ISOManager
    {
        public event Action<int>? DownloadProgressChanged;
        public event Action<string>? DownloadCompleted;
        public event Action<string>? DownloadFailed;

        public async Task DownloadISOAsync(string isoUrl)
        {
            using var client = new HttpClient();
            try
            {
                using var response = await client.GetAsync(isoUrl, HttpCompletionOption.ResponseHeadersRead);
                response.EnsureSuccessStatusCode();
                var total = response.Content.Headers.ContentLength ?? 0;
                using var stream = await response.Content.ReadAsStreamAsync();

                using var sfd = new SaveFileDialog
                {
                    Filter = "ISO files (*.iso)|*.iso",
                    FileName = "KalkiOS-latest.iso"
                };
                if (sfd.ShowDialog() != DialogResult.OK)
                {
                    DownloadFailed?.Invoke("Download cancelled by user.");
                    return;
                }
                var filePath = sfd.FileName;
                using var fs = new FileStream(filePath, FileMode.Create, FileAccess.Write, FileShare.None);
                var buffer = new byte[81920];
                long read = 0;
                int bytesRead;
                while ((bytesRead = await stream.ReadAsync(buffer, 0, buffer.Length)) > 0)
                {
                    await fs.WriteAsync(buffer, 0, bytesRead);
                    read += bytesRead;
                    if (total > 0)
                        DownloadProgressChanged?.Invoke((int)(read * 100 / total));
                }
                DownloadCompleted?.Invoke(filePath);
            }
            catch (Exception ex)
            {
                DownloadFailed?.Invoke($"Download failed: {ex.Message}");
            }
        }

        // TODO: Add checksum verification method
    }
} 