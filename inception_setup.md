## ⚙️ 1. Criação da Máquina Virtual (Debian 12.12)

### 📥 Baixar a ISO
Baixa a imagem oficial do Debian **12.12 (Bookworm)**, versão netinst (leve e estável):

🔗 [Download Debian 12.12 (64-bit netinst)](https://cdimage.debian.org/cdimage/archive/12.12.0/amd64/iso-cd/debian-12.12.0-amd64-netinst.iso)

### 🧩 Criar a máquina no VirtualBox

1. **Abrir o VirtualBox** e clicar em **New**.
2. Preencher os campos:
   - **Name:** `Inception_VM`
   - **Folder:** `/home/dramos-j/sgoinfre`)
   - **ISO Image:** seleciona a ISO baixada (`debian-12.12.0-amd64-netinst.iso`)
   - **Type:** Linux  
   - **Version:** Debian (64-bit)
   - **Username:** `dramos-j`
   - **Password:** cria uma senha segura  
   - **Hostname:** `inception`
   - **Domain Name:** deixa vazio (não é necessário)
   - **Install Guest Additions:** *desmarca se quiser instalar manualmente*
   - ✅ **Skip Unattended Installation:** *desmarca se quiser instalar manualmente*
3. **Disco rígido virtual:**
   - Marca **Create a Virtual Hard Disk Now**
   - **Tipo:** VDI (VirtualBox Disk Image)
   - **Dynamically Allocated**
   - **Tamanho:** 20 GB (suficiente pro projeto Inception)

### ⚙️ Configurações recomendadas antes de iniciar

Depois de criar, seleciona a VM → **Settings** e ajusta:

- **System → Motherboard**
  - Memory (RAM): **4096 MB**
  - Enable EFI: ✅ *opcional (pode deixar desligado se quiser boot mais simples)*  
- **Processor**
  - CPUs: **2**

### ▶️ Iniciar a VM
1. Clica em **Start**.  
2. O instalador Debian inicia automaticamente.  
3. Segue as instruções (instalação automática é suficiente).  
4. Quando a instalação terminar, remove a ISO (VirtualBox → *Devices → Optical Drives → Remove disk from virtual drive*).  
5. Reinicia a máquina.

Após o primeiro boot:
```bash
sudo apt update && sudo apt upgrade -y
```

## 👤 2. Usuário com permissão sudo

Durante a instalação automática, o usuário `dramos-j` foi criado sem privilégios administrativos.  
Após o primeiro login, foi concedido acesso sudo:

```bash
su -
usermod -aG sudo dramos-j
exit
groups dramos-j
# Saída esperada: dramos-j : dramos-j sudo users
sudo ls /root   # Teste para confirmar acesso
```

## 💿 3. Instalar Guest Additions (para pasta compartilhada e clipboard)

1. No menu do VirtualBox da VM:  
   **Devices → Insert Guest Additions CD image…**

2. Dentro da VM:
```bash
   sudo mkdir -p /media/cdrom
   sudo mount /dev/cdrom /media/cdrom
   cd /media/cdrom
   sudo apt update
   sudo apt install -y dkms build-essential linux-headers-$(uname -r)
   sudo sh VBoxLinuxAdditions.run
```

3. Alternativamente, método oficial Debian:
```bash
   sudo apt install -y virtualbox-guest-utils virtualbox-guest-dkms
```

4. Reiniciar e verificar grupos:
```bash
   sudo reboot
   groups
   # Esperado: dramos-j : dramos-j sudo users vboxsf
```

## 📂 4. Configurar pasta compartilhada

**No VirtualBox Manager:**
```
Settings → Shared Folders → + (Add new shared folder)
```
| Campo | Valor |
|--------|--------|
| **Folder Path** | `~/VM_share` |
| **Folder Name** | `share` |
| **Auto-mount** | ✅ |
| **Read-only** | ❌ |
| **Make Permanent** | ✅ |

**Dentro da VM:**
```bash
sudo adduser $USER vboxsf
sudo reboot
ls /media
# Deve aparecer: sf_share
```

**Teste bidirecional:**
```bash
echo "teste da VM" > /media/sf_share/teste.txt
```
O arquivo `teste.txt` deve aparecer em `~/VM_share` no host.

## 🧩 4.1. Ajustando permissões da pasta compartilhada

Por padrão, o VirtualBox monta a pasta compartilhada (`/media/sf_share`) como somente leitura para o usuário comum.  
Isso ocorre porque o sistema de arquivos **vboxsf** ignora comandos `chmod` e `chown`.  
As permissões precisam ser definidas no momento da montagem.

### ❌ Por que `chmod` não funciona

O VirtualBox não cria um sistema de arquivos Linux real dentro da VM — ele apenas **espelha** o conteúdo da pasta do host através de um driver virtual.  
Esse driver ignora modificações locais de permissão.  
Por isso, o comando abaixo **não tem efeito**:
```bash
sudo chmod 777 /media/sf_share
```

### ✅ Solução: remontar com permissões corretas

Para liberar leitura e escrita para o seu usuário:

```bash
sudo umount /media/sf_share
sudo mount -t vboxsf -o rw,uid=$(id -u),gid=$(id -g),umask=000 share /media/sf_share
```

- `rw`: habilita leitura e escrita  
- `uid` e `gid`: definem o dono como o usuário atual  
- `umask=000`: libera leitura, escrita e execução para todos  

Verificar o resultado:
```bash
ls -ld /media/sf_share
```
Saída esperada:
```
drwxrwxrwx 1 dramos-j vboxsf 4096 Nov  8 14:00 /media/sf_share
```

### ♻️ Tornar permanente (montagem automática no boot)

Para não precisar rodar o comando manualmente toda vez, adicione esta linha no final do arquivo `/etc/fstab`:

```bash
share  /media/sf_share  vboxsf  rw,uid=1000,gid=1000,umask=000,auto  0  0
```

> 💡 Confirme se seu usuário tem UID 1000 com `id -u`.  
> Normalmente, o primeiro usuário criado no sistema possui esse número.

Após salvar o arquivo:
```bash
sudo reboot
```

A pasta será montada automaticamente com as permissões corretas a cada inicialização.


### 🧪 Teste final

```bash
cd /media/sf_share
echo "teste de escrita" > teste.txt
```

O arquivo deve ser criado sem erro e também aparecer na pasta compartilhada do host (`~/VM_share`).

## 🔧 5. Preparar sistema para Docker e Compose

### Atualizar pacotes e instalar dependências
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y vim curl wget git make ca-certificates lsb-release apt-transport-https gnupg
ping -c 3 google.com   # Teste de conectividade
```

### Adicionar repositório oficial da Docker
```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg]   https://download.docker.com/linux/debian $(lsb_release -cs) stable"   | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
```

### Instalar Docker Engine + Compose plugin
```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Verificar versões
```bash
docker --version
docker compose version
```

### Ativar serviço Docker
```bash
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
# Active: active (running)
```
(pressionar `q` para sair)

### Testar instalação
```bash
sudo docker run hello-world
```
Saída esperada:
> *Hello from Docker! This message shows that your installation appears to be working correctly.*

### Permitir usar Docker sem sudo (opcional)
```bash
sudo usermod -aG docker $USER
sudo reboot
docker ps
```

## 🗂 6. Estrutura base para o projeto Inception
Organizar arquivos no diretório compartilhado:
```
/media/sf_share/inception/
 ├── srcs/
 ├── secrets/
 ├── Makefile
 ├── docker-compose.yml
 └── README.md
```

