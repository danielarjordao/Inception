# Inception – Roteiro de Instalação e Configuração (Debian 12)

## 1. Preparação da ISO

**Versão:** Debian 12.12.0 amd64 (netinst)

**Download:** [ISO Debian 12.12](https://cdimage.debian.org/cdimage/archive/12.12.0/amd64/iso-cd/debian-12.12.0-amd64-netinst.iso)

**Por quê?** Atende à regra da "penúltima versão estável" exigida pelo subject.

## 2. Criação da VM no VirtualBox

**Nome:** `Inception_VM`

**Pasta:** `/home/dramos-j/sgoinfre` (Essencial na 42 para evitar limite de quota)

**Hardware:**
- **RAM:** 5120 MB (5GB) - Recomendado para rodar GNOME + Docker
- **CPUs:** 2
- **Disco:** 25-30 GB (Dinamicamente alocado)

**Configurações:**
- [ ] **Enable EFI:** Desmarcado
- [ ] **Proceed with Unattended Installation:** Desmarcado

## 3. Instalação Manual do OS

**Language/Location:** English / Portugal

**Hostname:** `inception`

**Domain:** (vazio)

**Root Password:** Deixar vazio (ativa o sudo automaticamente)

**User:** `dramos-j`

**Partitioning:** Guided - use entire disk (All files in one partition)

**Software Selection:**
- [x] Debian desktop environment
- [x] GNOME (apenas este)
- [x] SSH server
- [x] Standard system utilities

**GRUB:** Instalar em `/dev/sda`

## 4. Primeiros Passos e Guest Additions

### 4.1. Atualizar Sistema

Após o primeiro login:

```bash
sudo apt update && sudo apt upgrade -y
```

### 4.2. Instalar Drivers do VirtualBox

**No menu do VirtualBox:** Devices -> Insert Guest Additions CD image

**No terminal da VM:**

```bash
sudo mount /dev/cdrom /media/cdrom
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
sudo sh /media/cdrom/VBoxLinuxAdditions.run
sudo adduser dramos-j vboxsf
sudo reboot
```
## 5. Pasta Compartilhada (Host <-> VM)

**VirtualBox (Desligada):** Settings -> Shared Folders -> Adicionar

**Configuração:**
- **Path:** `C:\Users\danie\shared` (ou caminho no seu PC)
- **Name:** `shared`
- **Opções:** Auto-mount e Make Permanent

**Teste na VM:**

```bash
ls /media/sf_shared
```

## 5.1. Copiar Arquivos do Host para a VM

### Método 1: Usando a Pasta Compartilhada (Recomendado)

Após configurar a pasta compartilhada acima, basta copiar arquivos da VM para o host:

```bash
# Copiar arquivo do host para dentro da VM
cp /media/sf_shared/arquivo.txt ~/Documents/

# Copiar diretório inteiro
cp -r /media/sf_shared/meu_projeto ~/Documents/
```

### Método 2: Drag and Drop (Arrastar e Soltar)

**Habilitar na VM desligada:**
- VirtualBox -> Settings -> General -> Advanced
- **Drag'n'Drop:** Bidirectional
- **Shared Clipboard:** Bidirectional

Após reiniciar, você pode arrastar arquivos da sua máquina diretamente para a janela da VM.

## 6. Instalação do Docker (Repositório Oficial)

```bash
# Dependências
sudo apt install -y curl wget git make ca-certificates gnupg lsb-release apt-transport-https

# Chave GPG e Repositório
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalação
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Permissões (evita usar sudo docker)
sudo usermod -aG docker dramos-j
sudo systemctl enable docker
sudo reboot
```
## 7. Configuração de Rede e Hostname

### 7.1. Configurar Adaptador de Rede no VirtualBox
**Com a VM desligada:**

VirtualBox -> Settings -> Network -> Adapter 1:
- **Attached to:** Bridged Adapter
- **Name:** Selecione sua placa de rede física (Wi-Fi ou Ethernet)

Isso permite que outros computadores na rede acessem sua VM.

### 7.2. Encontrar o IP da VM
Após iniciar a VM, descubra o IP:

```bash
ip addr show | grep inet
```

Anote o IP (exemplo: `10.12.248.36`)

### 7.3. Configurar /etc/hosts na VM
Conforme exigido pelo subject para o domínio login.42.fr:

```bash
sudo nano /etc/hosts
```

Adicione a linha:
```
127.0.0.1 dramos-j.42.fr
```

### 7.4. Configurar /etc/hosts no Avaliador
Para que o avaliador acesse de fora, ele precisará adicionar no `/etc/hosts` dele:

```bash
# No computador do avaliador (Linux/Mac)
echo "10.12.248.36  dramos-j.42.fr" | sudo tee -a /etc/hosts

# Windows (como Administrador)
echo 10.12.248.36  dramos-j.42.fr >> C:\Windows\System32\drivers\etc\hosts
```

## 8. Nova Estrutura de Arquivos (Subject 2026)

**Localização:** `/home/dramos-j/Documents/Inception/shared/inception/` (pasta compartilhada)

Crie a estrutura garantindo que os novos arquivos de documentação existam:

```bash
cd /home/dramos-j/Documents/Inception
mkdir -p shared/inception/srcs/requirements/{mariadb,nginx,wordpress}
mkdir -p shared/inception/secrets
cd shared/inception

touch Makefile
touch README.md
touch USER_DOC.md
touch DEV_DOC.md
touch srcs/docker-compose.yml
touch srcs/.env
```

**Estrutura esperada:**
```
shared/inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── pass_mariadb.txt
│   ├── admin_pass_wp.txt
│   └── user_pass_wp.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```
## 9. Manutenção e Compactação de Espaço

Para manter o sgoinfre limpo, utilize este procedimento antes de sair da escola:

### 9.1. Dentro da VM (Script de limpeza)

```bash
# Limpeza de Docker e lixo do sistema
docker system prune -a --volumes -f
sudo apt-get clean

# Zera o espaço livre para o VirtualBox entender o que pode compactar
sudo dd if=/dev/zero of=/zerofile bs=1M
sudo rm /zerofile
sudo shutdown now
```

### 9.2. No Host (Terminal da máquina física)

```bash
VBoxManage modifymedium disk "/home/dramos-j/sgoinfre/Inception_VM/Inception_VM.vdi" --compact
```

**Nota:** Ajuste o caminho do `.vdi` conforme a localização real do disco na sua máquina.

## 10. Snapshot Final

Com a VM desligada e limpa:

**Nome:** `Inception_Ready_To_Code`

**Descrição:** Debian 12, GNOME, Docker + Compose e Rede configurados.
