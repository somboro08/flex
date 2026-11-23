# Script pour tester toutes les fonctionnalites POST critiques de Flex API

$baseUrl = "http://localhost:8081/api/v1"

function Format-Result($name, $status, $response) {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "TEST: $name" -ForegroundColor Yellow
    if ($status -eq 200 -or $status -eq 201) {
        Write-Host "STATUS: $status SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "STATUS: $status ERROR" -ForegroundColor Red
    }
    Write-Host "RESPONSE:" -ForegroundColor White
    $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Gray
}

# 1. Health Check
Write-Host "Checking API Health..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/health" -Method Get
    Write-Host "Health Check OK: $($health | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "Health check failed: $_" -ForegroundColor Red
}

$ts = Get-Date -Format "HHmmss"

# 2. Register Host
$hostBody = @{
    nom = "Kouandete"
    prenom = "Bio"
    telephone = "+22997$ts"
    email = "hote_$ts@flex.bj"
    password = "Password123!"
    role = "hote"
} | ConvertTo-Json

try {
    $resHostReg = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $hostBody -ContentType "application/json"
    Format-Result "Register Host" 201 $resHostReg
} catch {
    Write-Host "Register Host failed: $_" -ForegroundColor Red
}

# 3. Login Host
$hostLoginBody = @{
    telephone = "+22997$ts"
    password = "Password123!"
} | ConvertTo-Json

$hostToken = ""
$hostId = ""
try {
    $resHostLogin = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $hostLoginBody -ContentType "application/json"
    Format-Result "Login Host" 200 $resHostLogin
    $hostToken = $resHostLogin.data.tokens.accessToken
    $hostId = $resHostLogin.data.user.id
} catch {
    Write-Host "Login Host failed: $_" -ForegroundColor Red
}

# 4. Register Voyageur
$tsV = Get-Date -Format "HHmms2"
$voyageurBody = @{
    nom = "Sossou"
    prenom = "Marc"
    telephone = "+22996$tsV"
    email = "voyageur_$tsV@flex.bj"
    password = "Password123!"
    role = "voyageur"
} | ConvertTo-Json

try {
    $resVReg = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $voyageurBody -ContentType "application/json"
    Format-Result "Register Voyageur" 201 $resVReg
} catch {
    Write-Host "Register Voyageur failed: $_" -ForegroundColor Red
}

# 5. Login Voyageur
$vLoginBody = @{
    telephone = "+22996$tsV"
    password = "Password123!"
} | ConvertTo-Json

$voyageurToken = ""
$voyageurId = ""
try {
    $resVLogin = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $vLoginBody -ContentType "application/json"
    Format-Result "Login Voyageur" 200 $resVLogin
    $voyageurToken = $resVLogin.data.tokens.accessToken
    $voyageurId = $resVLogin.data.user.id
} catch {
    Write-Host "Login Voyageur failed: $_" -ForegroundColor Red
}

# 6. Register Agent
$tsA = Get-Date -Format "HHmms3"
$agentBody = @{
    nom = "Tossou"
    prenom = "Carine"
    telephone = "+22995$tsA"
    email = "agent_$tsA@flex.bj"
    password = "Password123!"
    role = "agent"
} | ConvertTo-Json

try {
    $resAReg = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $agentBody -ContentType "application/json"
    Format-Result "Register Agent" 201 $resAReg
} catch {
    Write-Host "Register Agent failed: $_" -ForegroundColor Red
}

# 7. Login Agent
$aLoginBody = @{
    telephone = "+22995$tsA"
    password = "Password123!"
} | ConvertTo-Json

$agentToken = ""
try {
    $resALogin = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $aLoginBody -ContentType "application/json"
    Format-Result "Login Agent" 200 $resALogin
    $agentToken = $resALogin.data.tokens.accessToken
} catch {
    Write-Host "Login Agent failed: $_" -ForegroundColor Red
}

# 8. Send OTP
$otpSendBody = @{
    identifier = "+22997$ts"
    purpose = "verification"
} | ConvertTo-Json

try {
    $resOtpSend = Invoke-RestMethod -Uri "$baseUrl/auth/otp/send" -Method Post -Body $otpSendBody -ContentType "application/json"
    Format-Result "Send OTP" 200 $resOtpSend
} catch {
    Write-Host "Send OTP failed: $_" -ForegroundColor Red
}

# 9. Create Listing (Host)
$listingId = ""
if ($hostToken) {
    $listingBody = @{
        titre = "Studio Moderne Residentiel Parakou"
        description = "Bel appartement equipe avec clim et groupe electrogene"
        typeLogement = "appartement"
        ville = "Parakou"
        quartier = "Zongo"
        adresse = "Avenue de l Independance"
        latitude = 9.337
        longitude = 2.630
        prixParNuit = 15000
        nombreChambres = 2
        equipements = @("wifi", "clim", "parking", "generateur")
        photos = @("https://images.unsplash.com/photo-1522708323590-d24dbb6b0267")
    } | ConvertTo-Json

    $headersHost = @{ Authorization = "Bearer $hostToken" }
    try {
        $resListing = Invoke-RestMethod -Uri "$baseUrl/listings" -Method Post -Body $listingBody -ContentType "application/json" -Headers $headersHost
        Format-Result "Create Listing (Host)" 201 $resListing
        $listingId = $resListing.data.id
    } catch {
        Write-Host "Create Listing failed: $_" -ForegroundColor Red
    }
}

# 10. Create Booking (Voyageur)
$bookingId = ""
if ($voyageurToken -and $listingId) {
    $today = (Get-Date).ToString("yyyy-MM-dd")
    $nextWeek = (Get-Date).AddDays(3).ToString("yyyy-MM-dd")
    $bookingBody = @{
        listingId = $listingId
        dateArrivee = $today
        dateDepart = $nextWeek
    } | ConvertTo-Json

    $headersV = @{ Authorization = "Bearer $voyageurToken" }
    try {
        $resBooking = Invoke-RestMethod -Uri "$baseUrl/bookings" -Method Post -Body $bookingBody -ContentType "application/json" -Headers $headersV
        Format-Result "Create Booking (Voyageur)" 201 $resBooking
        $bookingId = $resBooking.data.id
    } catch {
        Write-Host "Create Booking failed: $_" -ForegroundColor Red
    }
}

# 11. Create Payment (Mobile Money MTN MoMo)
$paymentId = ""
if ($voyageurToken -and $bookingId) {
    $paymentBody = @{
        bookingId = $bookingId
        method = "mtn_momo"
        phoneNumber = "+22996$tsV"
    } | ConvertTo-Json

    $headersV = @{ Authorization = "Bearer $voyageurToken" }
    try {
        $resPayment = Invoke-RestMethod -Uri "$baseUrl/payments" -Method Post -Body $paymentBody -ContentType "application/json" -Headers $headersV
        Format-Result "Create Payment MTN MoMo" 201 $resPayment
        $paymentId = $resPayment.data.id
    } catch {
        Write-Host "Create Payment failed: $_" -ForegroundColor Red
    }
}

# 12. Confirm Booking (Host)
if ($hostToken -and $bookingId) {
    $headersHost = @{ Authorization = "Bearer $hostToken" }
    try {
        $resConfirm = Invoke-RestMethod -Uri "$baseUrl/bookings/$bookingId/confirm" -Method Post -ContentType "application/json" -Headers $headersHost
        Format-Result "Confirm Booking (Host)" 200 $resConfirm
    } catch {
        Write-Host "Confirm Booking failed: $_" -ForegroundColor Red
    }
}

# 13. Create Visit Request (Voyageur)
if ($voyageurToken -and $listingId) {
    $tomorrow = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
    $visitBody = @{
        listingId = $listingId
        dateVisite = $tomorrow
        timeSlot = "10:00-12:00"
        message = "Je souhaite visiter demain matin"
    } | ConvertTo-Json

    $headersV = @{ Authorization = "Bearer $voyageurToken" }
    try {
        $resVisit = Invoke-RestMethod -Uri "$baseUrl/visits" -Method Post -Body $visitBody -ContentType "application/json" -Headers $headersV
        Format-Result "Create Visit Request" 201 $resVisit
    } catch {
        Write-Host "Create Visit Request failed: $_" -ForegroundColor Red
    }
}

# 14. Create Agent Audit Checklist (Agent)
if ($agentToken -and $listingId) {
    $auditBody = @{
        listingId = $listingId
        serrure = $true
        literie = $true
        sanitaires = $true
        eclairage = $true
        identite = $true
        photosFideles = $true
        adresse = $true
        commentaires = "Logement parfait, certifie par l agent."
    } | ConvertTo-Json

    $headersAgent = @{ Authorization = "Bearer $agentToken" }
    try {
        $resAudit = Invoke-RestMethod -Uri "$baseUrl/audits" -Method Post -Body $auditBody -ContentType "application/json" -Headers $headersAgent
        Format-Result "Create Field Agent Audit Checklist" 201 $resAudit
    } catch {
        Write-Host "Create Agent Audit failed: $_" -ForegroundColor Red
    }
}

# 15. Send Chat Message (Voyageur -> Host)
if ($voyageurToken -and $hostId) {
    $msgBody = @{
        recipientId = $hostId
        listingId = $listingId
        content = "Bonjour M. Bio, est-ce que le groupe electrogene demarre automatiquement ?"
    } | ConvertTo-Json

    $headersV = @{ Authorization = "Bearer $voyageurToken" }
    try {
        $resMsg = Invoke-RestMethod -Uri "$baseUrl/messages" -Method Post -Body $msgBody -ContentType "application/json" -Headers $headersV
        Format-Result "Send Chat Message" 201 $resMsg
    } catch {
        Write-Host "Send Message failed: $_" -ForegroundColor Red
    }
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "TOUS LES TESTS POST SONT TERMINES !" -ForegroundColor Green
