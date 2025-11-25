# Inception – Ambiente de Desenvolvimento

# 1. Baixar a ISO Debian 12.12

> **Por quê Debian 12.12?** O subject do projeto Inception exige a penúltima versão estável para garantir compatibilidade e estabilidade. A versão netinst é mais leve e permite instalação minimalista.

https://cdimage.debian.org/cdimage/archive/12.12.0/amd64/iso-cd/debian-12.12.0-amd64-netinst.iso

# 2. Criar a VM Debian 12.12

## 2.1 Name and OS
- **VM Name:** `Inception_VM`
- **VM Folder:** `/home/dramos-j/sgoinfre`
- **ISO Image:** Debian 12.12 netinst
- **OS:** Linux
- **OS Distribution:** seleciona a ISO baixada
(`debian-12.12.0-amd64-netinst.iso`)
- **OS Version:** Debian (64-bit)
- **[ ] Proceed with Unattended Installation** desmarcado, pois faremos a instalação manualmente, confirmando a instalação apenas do necessário.

## 2.2 Hardware
> **Recursos mínimos:** Docker precisa de recursos adequados. 4GB RAM é o mínimo recomendado para rodar múltiplos containers simultaneamente. 2 CPUs permitem melhor performance na build de imagens. 20GB é suficiente para o sistema base + Docker + imagens do projeto.

- **Base Memory:** **4096 MB**
- **Number of CPUs:** **2**
- **Disk Size:** **20 GB**
- **[ ] Enable EFI** desmarcado, pois o Debian 12.12 funciona bem com BIOS tradicional e evita complicações desnecessárias.

Confirmar configurações no summary e clicar em **Terminar**.

# 3. Instalação manual do Debian 12.12

## 3.1 Iniciar a VM e seguir os passos do instalador:

- **Menu:** Graphical install
- **Select a language:** English
- **Select your location:** Other - Europe - Portugal
- **Configure locales:** English (en_US.UTF-8)
- **Configure the keyboard:** American English
- **Configure the network**
- - **Hostname:** `inception`
- - **Domain name:** deixar vazio
- **Set up users and passwords**
- - **Root password:** deixar vazio (será usado sudo)
  > **Boa prática:** Deixar root sem senha força o uso de sudo, aumentando a segurança e rastreabilidade de comandos administrativos.
- - **Create a user**
- - - **Full name:** Daniela Ramos Jordao
- - - **Username:** dramos-j
- - - **Password:** segura
- **Configure the clock:** Lisbon
- **Partition disks**
- - **Partitioning method:** Guided - use entire disk
- - - **Select disk to partition:** SCSI3 (0,0,0) (sda) - 21.5 GB ATA VBOX HARDDISK
- - **Partitioning scheme:** All files in one partition
- - **Finish partitioning and write changes to disk:** Yes
- - **Write changes to disks:** Yes
  > Não é necessário particionar manualmente para este ambiente simples.
- **Configure the package manager**
- - **Scan extra installation media:** No
- - **Debian archive mirror country:** Portugal
- - **Debian archive mirror:** deb.debian.org
- - **HTTP proxy:** deixar vazio
  > Não é necessário configurar proxy para este ambiente simples.
- **Configuring popularity contest:** No
- **Software selection**
  > **Instalação minimalista:** Selecionamos apenas o essencial. SSH server permite acesso remoto e desenvolvimento confortável. Desktop environment NÃO é necessário e consumiria recursos.
- - **Selecionar apenas:**
- - - SSH server
- - - Standard system utilities
- **Install the GRUB boot loader to your primary drive:** Yes
- - **Device for boot loader installation:** /dev/sda
- - **Finish the installation:** Continue to reboot

# 4. Primeiros passos no sistema

Login:

```
login: dramos-j
password: segura
```

Atualizar:

```
sudo apt update
sudo apt upgrade -y
```

# 5. Instalar Guest Additions

> **O que são Guest Additions?** Conjunto de drivers e aplicações que melhoram a integração entre host e VM: compartilhamento de pastas, clipboard, melhor performance gráfica e de mouse.

**5.1 No VirtualBox (VM ligada)**

- Devices → Insert Guest Additions CD image...

**5.2 Montar o CD na VM**

```
sudo mkdir -p /media/cdrom
sudo mount /dev/cdrom /media/cdrom
sudo apt update
```

**5.3 Instalar dependências:**

```
cd /media/cdrom
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
sudo sh VBoxLinuxAdditions.run
```

### Verificar a instalação:

```
lsmod | grep vbox
```

### Deve mostrar:
- vboxguest (driver principal)
- vboxsf (shared folders)
- vboxvideo (driver de vídeo)


# 6. Configurar Pasta Compartilhada

> **Utilidade:** A pasta compartilhada permite editar código no host e executar na VM, facilitando o desenvolvimento.

## 6.1 No VirtualBox (VM desligada)
Settings → Shared Folders → +

- Folder Path: `C:\Users\danie\shared`
- Folder Name: `shared`
- Read-only: NÃO marcar
- Auto-mount: marcar
- Make Permanent: marcar
- Make Global: NÃO marcar

## 6.2 Verificar dentro da VM

```
ls /media
```

Deve aparecer: `sf_shared`

## 6.3 Adicionar usuário ao grupo vboxsf

> **Por que vboxsf?** Apenas usuários do grupo vboxsf têm permissão para acessar pastas compartilhadas. O reboot é necessário para aplicar a mudança de grupo.

```
sudo adduser dramos-j vboxsf
sudo reboot
```

## 6.4 Teste da pasta compartilhada

```
echo "ok" > /media/sf_shared/teste_vm.txt
```

Checar no host se o arquivo `teste_vm.txt` apareceu na pasta compartilhada.

Escrever algo no arquivo `teste_pc.txt` dentro da pasta compartilhada no host e verificar na VM:

```
cat /media/sf_shared/teste_pc.txt
```

# 7. Preparar Sistema para Docker e Docker Compose

> **Preparação completa:** Instalamos Docker oficial do repositório Docker (mais atualizado que o do Debian) e todas as ferramentas necessárias para desenvolvimento e build do projeto.

## 7.1 Instalar todas as dependências necessárias de uma vez:
> **Cada ferramenta:** vim (editor), curl/wget (downloads), git (versionamento), make (automação), ca-certificates/gnupg (segurança), lsb-release/apt-transport-https (gerenciamento de repos)

```
sudo apt install -y vim curl wget git make ca-certificates lsb-release apt-transport-https gnupg
```

## 7.2 Adicionar chave GPG do repositório Docker:

> **Segurança:** A chave GPG garante que os pacotes baixados são autênticos e não foram adulterados.

```
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

## 7.3 Adicionar repositório Docker:
> **Repositório oficial:** Usar o repositório oficial do Docker garante acesso às versões mais recentes e estáveis.

```
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg]   https://download.docker.com/linux/debian $(lsb_release -cs) stable"   | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
```

## 7.4 Instalar Docker + plugins:

> **Componentes:** docker-ce (engine), docker-ce-cli (cliente), containerd.io (runtime), docker-buildx-plugin (builds avançados), docker-compose-plugin (orquestração - essencial para o projeto).

```
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 7.5 Ativar:
> **Serviço Docker:** Ativar o serviço garante que o Docker inicie automaticamente com o sistema, permitindo uso imediato após reinicializações.

```
sudo systemctl enable docker
sudo systemctl start docker
```

## 7.6 Testar:
> **Teste básico:** Rodar o container hello-world verifica se o Docker está instalado e funcionando corretamente.
```
sudo docker run hello-world
```

### Deve mostrar:
Hello from Docker!

## 7.7 Verificar instalação:
> **Verificação:** Conferir as versões instaladas e o status do Docker garante que tudo está configurado corretamente.
```
docker --version
docker compose version
docker ps
```

### Deve mostrar as versões instaladas e a lista de containers (vazia).


## 7.8 Permitir usuário usar Docker sem sudo
> **Facilidade:** Adicionar usuário ao grupo docker permite rodar comandos docker sem sudo. O comando `newgrp` aplica a mudança imediatamente sem precisar fazer logout.

```
sudo usermod -aG docker dramos-j
newgrp docker
```

## 7.9 Testar comandos básicos do Docker
> **Comandos essenciais:** Testar comandos básicos do Docker garante que o ambiente está pronto para desenvolvimento.

```
docker run hello-world
docker run -it debian bash
docker ps -a
docker rm -f <container_id>
docker volume ls
docker network ls
```

# 8. Configurar hosts para acesso ao site

> **Acesso ao WordPress:** Para acessar o site via `dramos-j.42.fr` (conforme exigido pelo subject), é necessário mapear este domínio para localhost no arquivo `/etc/hosts`.

## 8.1 Editar o arquivo hosts:

```
sudo vim /etc/hosts
```

## 8.2 Adicionar a linha:

```
127.0.0.1       dramos-j.42.fr
```

O arquivo deve ficar assim:

```
127.0.0.1       localhost
127.0.0.1       dramos-j.42.fr
127.0.1.1       inception
...
```

## 8.3 Salvar e testar:

```
ping dramos-j.42.fr
```

Deve responder de `127.0.0.1`.

> **Nota:** Na avaliação, o avaliador deve conseguir acessar `https://dramos-j.42.fr` no navegador. Se você instalar um navegador na VM (firefox-esr), poderá testar diretamente. Alternativamente, pode testar com `curl https://dramos-j.42.fr` após configurar o NGINX.

# 9. Estrutura base para o projeto Inception

> **Organização:** A estrutura de diretórios conforme o subject do projeto facilita o desenvolvimento, build e deploy dos serviços Docker.

```
inception/
├── Makefile
├── secrets/
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   └── Dockerfile
        ├── nginx/
        │   └── Dockerfile
        └── wordpress/
            └── Dockerfile
```

# 10. Fazer um snapshot da VM
> **Snapshot:** Tirar um snapshot da VM neste ponto permite retornar a este estado limpo e funcional a qualquer momento, facilitando testes e desenvolvimento.

- Desligar a VM
- No VirtualBox: Right Click na VM → Snapshots → Take Snapshot
- Nome: `Inception_Base_Setup`
- Description: "Base setup of Debian with Docker and shared folder configured."

