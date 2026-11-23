# Script d'intégration KYC (Vérification d'Identité Utilisateur)

$baseUrl = "http://localhost:8081/api/v1"
$ts = Get-Date -Format "HHmmss"

Write-Host "=== TEST DU WORKFLOW DE VÉRIFICATION D'IDENTITÉ (KYC) ===" -ForegroundColor Cyan

# 1. Inscription utilisateur
$userBody = @{
    nom = "Koffi"
    prenom = "Jean"
    telephone = "+22997$ts"
    email = "kyc_$ts@flex.bj"
    password = "Password123!"
    role = "hote"
} | ConvertTo-Json

$regRes = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $userBody -ContentType "application/json"
$token = $regRes.data.tokens.accessToken
$userId = $regRes.data.user.id
Write-Host "1. Inscription Utilisateur OK - ID: $userId" -ForegroundColor Green

# 2. Soumission des pièces d'identité (CNI + Acte)
$idBody = @{
    idCardUrl = "/uploads/cni_koffi.jpg"
    birthCertificateUrl = "/uploads/acte_koffi.pdf"
} | ConvertTo-Json

$headers = @{ Authorization = "Bearer $token" }
$subRes = Invoke-RestMethod -Uri "$baseUrl/me/identity" -Method Put -Body $idBody -ContentType "application/json" -Headers $headers
Write-Host "2. Soumission Pièces d'Identité OK: $($subRes.message)" -ForegroundColor Green

# 3. Admin liste les identités soumises
$kycList = Invoke-RestMethod -Uri "$baseUrl/admin/users/identity" -Method Get
Write-Host "3. Admin Liste KYC OK - Dossiers trouvés: $($kycList.data.Count)" -ForegroundColor Green

# 4. Admin Valide l'identité de l'utilisateur
$verifyBody = @{ status = "verified" } | ConvertTo-Json
$verRes = Invoke-RestMethod -Uri "$baseUrl/admin/users/$userId/verify" -Method Post -Body $verifyBody -ContentType "application/json"
Write-Host "4. Admin Validation Identité OK: $($verRes.message)" -ForegroundColor Green

# 5. Vérification du profil mis à jour
$profile = Invoke-RestMethod -Uri "$baseUrl/me" -Method Get -Headers $headers
Write-Host "5. Profil Utilisateur Mis à Jour - Statut KYC: $($profile.data.verificationStatus), Certifié: $($profile.data.isVerified)" -ForegroundColor Yellow

Write-Host "=== WORKFLOW KYC VALIDÉ AVEC SUCCÈS ! ===" -ForegroundColor Green
