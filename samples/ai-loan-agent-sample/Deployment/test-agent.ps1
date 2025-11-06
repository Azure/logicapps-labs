<#
.SYNOPSIS
    Test AI Loan Agent with 4 loan application scenarios

.PARAMETER ResourceGroupName
    Azure resource group containing the Logic App

.PARAMETER LogicAppName
    Name of the Logic App Standard resource

.PARAMETER WorkflowName
    Name of the workflow to test (default: LoanApprovalAgent)

.EXAMPLE
    .\test-agent.ps1 -ResourceGroupName "rg-ailoan" -LogicAppName "ailoan-logicapp"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$LogicAppName,
    
    [Parameter(Mandatory=$false)]
    [string]$WorkflowName = "LoanApprovalAgent"
)

Write-Host "`n=== Testing AI Loan Agent ===" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName"
Write-Host "Logic App: $LogicAppName"
Write-Host "Workflow: $WorkflowName`n"

# Get workflow callback URL
Write-Host "Getting workflow callback URL..." -ForegroundColor Yellow
$subscriptionId = (Get-AzContext).Subscription.Id

try {
    $tokenObj = Get-AzAccessToken -ResourceUrl "https://management.azure.com"
    
    # Handle both SecureString (Az 14.x) and plain text (Az 13.x)
    if ($tokenObj.Token -is [System.Security.SecureString]) {
        $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tokenObj.Token)
        try {
            $token = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
        } finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
        }
    } else {
        $token = $tokenObj.Token
    }
    
    $uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$LogicAppName/hostruntime/runtime/webhooks/workflow/api/management/workflows/$WorkflowName/triggers/manual/listCallbackUrl?api-version=2023-12-01"
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers
    $callbackUrl = $response.value
    
    if ([string]::IsNullOrEmpty($callbackUrl)) {
        throw "Callback URL is empty"
    }
    
    Write-Host "✓ Callback URL retrieved" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to get callback URL: $_" -ForegroundColor Red
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Verify workflows are deployed to Logic App"
    Write-Host "2. Check workflow name is correct: $WorkflowName"
    Write-Host "3. Ensure you're logged into Azure: Connect-AzAccount"
    exit 1
}

# Test Case 1: Auto-Approval (High credit, standard vehicle, within limits)
Write-Host "\n--- Test Case 1: Auto-Approval Scenario ---" -ForegroundColor Cyan
$payload1 = @{
    applicationId = "APP-AUTO-APPROVE-001"
    name = "Applicant A"
    email = "applicant.a@example.com"
    loanAmount = 25000
    vehicleMake = "Toyota"
    vehicleModel = "Camry"
    salary = 75000
    employmentYears = 5
    creditScore = 780
    bankruptcies = 0
} | ConvertTo-Json

try {
    Invoke-RestMethod -Method Post -Uri $callbackUrl -Body $payload1 -ContentType "application/json"
    Write-Host "✓ Test Case 1 Submitted" -ForegroundColor Green
} catch {
    Write-Host "✗ Test Case 1 Failed: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 15

# Test Case 2: Human Review Required (Exceeds loan limit, good credit)
Write-Host "\n--- Test Case 2: Human Review Scenario ---" -ForegroundColor Cyan
$payload2 = @{
    applicationId = "APP-REVIEW-REQUIRED-002"
    name = "Applicant B"
    email = "applicant.b@example.com"
    loanAmount = 55000
    vehicleMake = "BMW"
    vehicleModel = "X5"
    salary = 95000
    employmentYears = 3
    creditScore = 720
    bankruptcies = 0
} | ConvertTo-Json

try {
    Invoke-RestMethod -Method Post -Uri $callbackUrl -Body $payload2 -ContentType "application/json"
    Write-Host "✓ Test Case 2 Submitted" -ForegroundColor Green
} catch {
    Write-Host "✗ Test Case 2 Failed: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 15

# Test Case 3: Auto-Rejection (Poor credit + bankruptcy)
Write-Host "\n--- Test Case 3: Auto-Rejection Scenario ---" -ForegroundColor Cyan
$payload3 = @{
    applicationId = "APP-AUTO-REJECT-003"
    name = "Applicant C"
    email = "applicant.c@example.com"
    loanAmount = 30000
    vehicleMake = "Honda"
    vehicleModel = "Accord"
    salary = 45000
    employmentYears = 0.5
    creditScore = 580
    bankruptcies = 1
} | ConvertTo-Json

try {
    Invoke-RestMethod -Method Post -Uri $callbackUrl -Body $payload3 -ContentType "application/json" | Out-Null
    Write-Host "✓ Test Case 3 Submitted" -ForegroundColor Green
} catch {
    Write-Host "✗ Test Case 3 Failed: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 15

# Test Case 4: Luxury Vehicle Review (Excellent credit but exotic vehicle)
Write-Host "\n--- Test Case 4: Luxury Vehicle Review Scenario ---" -ForegroundColor Cyan
$payload4 = @{
    applicationId = "APP-LUXURY-REVIEW-004"
    name = "Applicant D"
    email = "applicant.d@example.com"
    loanAmount = 80000
    vehicleMake = "Ferrari"
    vehicleModel = "F8 Tributo"
    salary = 120000
    employmentYears = 4
    creditScore = 750
    bankruptcies = 0
} | ConvertTo-Json

try {
    Invoke-RestMethod -Method Post -Uri $callbackUrl -Body $payload4 -ContentType "application/json"
    Write-Host "✓ Test Case 4 Submitted" -ForegroundColor Green
} catch {
    Write-Host "✗ Test Case 4 Failed: $_" -ForegroundColor Red
}

# Summary
Write-Host "`n=== Testing Complete ===" -ForegroundColor Cyan
Write-Host "`nTest Results Summary:" -ForegroundColor Yellow
Write-Host "  Test Case 1 (Auto-Approval):     Excellent applicant → Expected: APPROVED"
Write-Host "  Test Case 2 (Human Review):      Borderline case → Expected: Simulated decision"
Write-Host "  Test Case 3 (Auto-Rejection):    Poor credit + bankruptcy → Expected: REJECTED"
Write-Host "  Test Case 4 (Luxury Vehicle):    Special vehicle → Expected: Human review"

Write-Host "`n📊 View in Azure Portal:" -ForegroundColor Cyan
Write-Host "https://portal.azure.com/#@/resource/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$LogicAppName/logicApp"

Write-Host "`n💡 Note: Human approval is currently simulated. See README for Teams integration." -ForegroundColor Gray
