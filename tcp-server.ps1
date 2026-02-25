# PowerShell TCP Socket Server Script

# Define the TCP port to listen on
$port = 8080

# Create a TCP listener on the specified port
$listener = [System.Net.Sockets.TcpListener]::new($port)

# Start listening for incoming connections
$listener.Start()

Write-Host "Listening on port $port..."

try {
    while ($true) {
        # Accept an incoming client connection
        $client = $listener.AcceptTcpClient()
        Write-Host "Client connected!"

        # Get the client's stream
        $stream = $client.GetStream()
        
        # Handle the client connection in a new runspace
        Start-Job -ScriptBlock {
            param($stream)
            # Read data from the client
            $reader = New-Object System.IO.StreamReader($stream)
            $writer = New-Object System.IO.StreamWriter($stream)
            $writer.AutoFlush = $true
            
            # Communicate with the client
            while ($true) {
                $line = $reader.ReadLine()
                if (-not $line) { break }
                Write-Host "Received: $line"
                $writer.WriteLine("Echo: $line")
            }
            $reader.Close()
            $writer.Close()
            $stream.Close()
            $client.Close()
        } -ArgumentList $stream | Out-Null
    }
} catch {
    Write-Host "Error: $_"
} finally {
    # Stop the listener when done
    $listener.Stop()
    Write-Host "Listener stopped."
}