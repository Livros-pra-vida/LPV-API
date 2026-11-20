# configurar_banco.ps1 - Configura o PostgreSQL do Livros pra Vida no seu PC.
# O que faz: cria o .env (conexão + chaves de criptografia), instala as gems,
# cria/atualiza as tabelas, coloca os dados iniciais, criptografa os dados antigos e roda os testes.
# Tudo que aparece na tela fica em configurar_banco.log (a senha NÃO aparece no log).

# "Continue": avisos do Ruby no stderr não derrubam o script (o código de saída é que decide).
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$Host.UI.RawUI.WindowTitle = "Livros pra Vida - configurando o banco"
[Console]::OutputEncoding = [Text.Encoding]::UTF8
Start-Transcript -Path (Join-Path $PSScriptRoot "configurar_banco.log") -Force | Out-Null

function Passo($texto) { Write-Host ""; Write-Host "==> $texto" -ForegroundColor Cyan }
function Falhou($texto) { Write-Host ""; Write-Host "ERRO: $texto" -ForegroundColor Red; Stop-Transcript | Out-Null; Read-Host "Aperte Enter para fechar"; exit 1 }
function Rodar($descricao, [scriptblock]$comando) {
    Passo $descricao
    & $comando 2>&1 | ForEach-Object { Write-Host "$_" }
    if ($LASTEXITCODE -ne 0) { Falhou "$descricao (código $LASTEXITCODE). Veja as mensagens acima." }
}
function NovaChave {
    $bytes = New-Object byte[] 32
    [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    return ([Convert]::ToBase64String($bytes) -replace '[+/=]', '')
}
function GravarSemBom($caminho, $texto) {
    [IO.File]::WriteAllText($caminho, $texto, (New-Object Text.UTF8Encoding $false))
}

Write-Host "=== Livros pra Vida: configuração do banco de dados ===" -ForegroundColor Green

Passo "Conferindo o Ruby"
if (-not (Get-Command ruby -ErrorAction SilentlyContinue)) { Falhou "Ruby não encontrado. Instale o Ruby (rubyinstaller.org) e rode de novo." }
ruby -v 2>&1 | ForEach-Object { Write-Host "$_" }

$envPath = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envPath)) {
    Passo "Criando o arquivo .env (dados da conexão com o PostgreSQL)"
    $usuario = Read-Host "Usuário do PostgreSQL (Enter = postgres)"
    if (-not $usuario) { $usuario = "postgres" }
    $senhaSegura = Read-Host "Senha do PostgreSQL (não aparece enquanto digita)" -AsSecureString
    $senha = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($senhaSegura))
    $porta = Read-Host "Porta do PostgreSQL (Enter = 5432)"
    if (-not $porta) { $porta = "5432" }
    $u = [Uri]::EscapeDataString($usuario)
    $s = [Uri]::EscapeDataString($senha)

    $conteudo = @"
# Gerado por configurar_banco.ps1. NÃO envie este arquivo para o GitHub (já está no .gitignore).
DATABASE_URL=postgresql://${u}:${s}@localhost:${porta}/library_development
TEST_DATABASE_URL=postgresql://${u}:${s}@localhost:${porta}/library_test

# Chaves da criptografia do banco. GUARDE UMA CÓPIA EM LUGAR SEGURO:
# sem elas, as mensagens do chat, CPF, telefone e endereços não podem mais ser lidos.
# Use as MESMAS chaves no Render (Environment) só se for copiar este banco para lá.
ENCRYPTION_PRIMARY_KEY=$(NovaChave)
ENCRYPTION_DETERMINISTIC_KEY=$(NovaChave)
ENCRYPTION_KEY_DERIVATION_SALT=$(NovaChave)

CORS_ORIGINS=https://livros-pra-vida.github.io
"@
    GravarSemBom $envPath $conteudo
    Write-Host ".env criado (com chaves de criptografia novas)." -ForegroundColor Green
} else {
    Passo "Usando o .env que já existe"
    $atual = Get-Content $envPath -Raw
    if ($atual -notmatch "ENCRYPTION_PRIMARY_KEY=\S") {
        $extra = "`nENCRYPTION_PRIMARY_KEY=$(NovaChave)`nENCRYPTION_DETERMINISTIC_KEY=$(NovaChave)`nENCRYPTION_KEY_DERIVATION_SALT=$(NovaChave)`n"
        GravarSemBom $envPath (($atual -replace "(?m)^ENCRYPTION_[A-Z_]+=\s*$", "") + $extra)
        Write-Host "Chaves de criptografia adicionadas ao .env." -ForegroundColor Green
    }
}

Rodar "Instalando as gems (pode demorar alguns minutos na primeira vez)" { bundle install }
Rodar "Criando o banco (se ainda não existir)" { ruby bin/rails db:create }
Rodar "Criando/atualizando as tabelas (migrações)" { ruby bin/rails db:migrate }
Rodar "Colocando os dados iniciais (catálogo, autores, anúncios de exemplo)" { ruby bin/rails db:seed }
Rodar "Criptografando dados antigos (chat, CPF, telefone)" { ruby bin/rails lpv:criptografar }

Passo "Rodando os testes automáticos"
ruby bin/rails db:test:prepare 2>&1 | ForEach-Object { Write-Host "$_" }
ruby bin/rails test 2>&1 | ForEach-Object { Write-Host "$_" }
$testesOk = ($LASTEXITCODE -eq 0)

Passo "Tabelas do banco"
ruby bin/rails runner "puts ActiveRecord::Base.connection.tables.sort.join(', ')" 2>&1 | ForEach-Object { Write-Host "$_" }

Write-Host ""
if ($testesOk) {
    Write-Host "PRONTO! Banco configurado e todos os testes passaram." -ForegroundColor Green
} else {
    Write-Host "Banco configurado, mas algum teste falhou (veja acima)." -ForegroundColor Yellow
}
Write-Host "Para ligar a API no seu PC: ruby bin/rails server"
Stop-Transcript | Out-Null
Read-Host "Aperte Enter para fechar"
