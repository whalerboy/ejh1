param(
    [string]$serverHost = "localhost",
    [int]$port = 8080,
    [string]$message = "Hello from PowerShell client!"
)

# Create a TCP client
$client = [System.Net.Sockets.TcpClient]::new()

try {
    # Connect to the server
    Write-Host "Connecting to $serverHost on port $port..."
    $client.Connect($serverHost, $port)
    Write-Host "Connected!"

    # Get the network stream
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true

    # Send messages in a loop
    while ($true) {
        # Prompt user for input
        $userInput = Read-Host "Enter message (or 'quit' to exit)"
        
        if ($userInput -eq "quit") {
            Write-Host "Closing connection..."
            break
        }

        # Send the message to the server
        Write-Host "Sending: $userInput"
        $writer.WriteLine($userInput)

        # Read the response from the server
        $response = $reader.ReadLine()
        Write-Host "Received: $response"
    }

    $reader.Close()
    $writer.Close()
} catch {
    Write-Host "Error: $_"
} finally {
    # Close the connection
    $stream.Close()
    $client.Close()
    Write-Host "Client closed."
}