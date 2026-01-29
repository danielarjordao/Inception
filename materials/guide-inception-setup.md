
# Inception – Development Environment (Debian 12)

This guide provides a complete, step-by-step setup for the Inception project.

## 1. Prepare the Debian 12.12 ISO

**Version:** Debian 12.12.0 amd64 (netinst)

**Download:** [Debian 12.12 ISO](https://cdimage.debian.org/cdimage/archive/12.12.0/amd64/iso-cd/debian-12.12.0-amd64-netinst.iso)

> **Why Debian 12.12?** The subject requires the penultimate stable version.

## 2. Create the Debian 12.12 VM in VirtualBox

**Name:** `Inception_VM`
**Folder:** `/home/dramos-j/sgoinfre` (Essential at 42 to avoid quota limits)

**Hardware:**

- **RAM:** 5120 MB (5GB) – Recommended for GNOME + Docker
- **CPUs:** 2
- **Disk:** 25-30 GB (Dynamically allocated)

**Settings:**

- [ ] **Enable EFI:** Unchecked
- [ ] **Proceed with Unattended Installation:** Unchecked

**ISO:** Select the downloaded Debian 12.12 netinst ISO

Confirm the settings and create the VM.

## 3. Manual Installation of Debian 12.12

**Language/Location:** English / Portugal
**Hostname:** `inception`
**Domain:** (leave blank)
**Root Password:** Leave blank (enables sudo automatically)
**User:** `dramos-j`
**Partitioning:** Guided – use entire disk (all files in one partition)
**Software Selection:**

- [x] Debian desktop environment
- [x] GNOME (only this)
- [x] SSH server
- [x] Standard system utilities
**GRUB:** Install to `/dev/sda`

> **Best practice:** Leaving root without a password forces the use of sudo, increasing security and traceability of administrative commands.

Complete the installation and reboot.

## 4. First Steps and Guest Additions

Login with your user (`dramos-j`).

### 4.1 Update the System

```bash
sudo apt update && sudo apt upgrade -y
```

### 4.2 Enable Integration Features

- Devices → Shared Clipboard → Bidirectional
- Devices → Drag and Drop → Bidirectional

### 4.3 Install VirtualBox Guest Additions

In VirtualBox (with the VM running):

- Devices → Insert Guest Additions CD image…

In the VM terminal:

```bash
sudo mkdir -p /media/cdrom
sudo mount /dev/cdrom /media/cdrom
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
sudo sh /media/cdrom/VBoxLinuxAdditions.run
sudo adduser dramos-j vboxsf
sudo reboot
```

> **What are Guest Additions?** A set of drivers and applications that improve integration between host and VM: shared folders, clipboard, better graphics and mouse performance.

#### Verify installation

```bash
lsmod | grep vbox
```

Should show:

- vboxguest (main driver)
- vboxsf (shared folders)
- vboxvideo (video driver)

## 5. Configure Shared Folder (Host <-> VM)

### 5.1 In VirtualBox (VM off)

Settings → Shared Folders → Add

- **Folder Path:** Path to your shared folder (e.g., `C:\Users\danie\shared` or your own path)
- **Folder Name:** `shared`
- **Options:** Auto-mount and Make Permanent (do not check Read-only or Make Global)

### 5.2 Check inside the VM

```bash
ls /media/sf_shared
```

Should show the shared folder contents.

### 5.3 Copying Files (Host <-> VM)

**From host to VM:**

```bash
cp /media/sf_shared/yourfile.txt ~/Documents/
cp -r /media/sf_shared/yourfolder ~/Documents/
```

**From VM to host:**
Copy files into `/media/sf_shared` and check on the host.

### 5.4 Drag and Drop

With the VM off:

- VirtualBox → Settings → General → Advanced
- **Drag'n'Drop:** Bidirectional
- **Shared Clipboard:** Bidirectional

After reboot, you can drag files between host and VM windows.

### 5.5 Add user to vboxsf group

> **Why vboxsf?** Only users in the vboxsf group have permission to access shared folders. A reboot is required to apply the group change.

```bash
sudo adduser dramos-j vboxsf
sudo reboot
```

### 5.6 Test the shared folder

```bash
echo "ok" > /media/sf_shared/test_vm.txt
```

Check on the host if the file `test_vm.txt` appeared in the shared folder.

Write something in the file `test_pc.txt` inside the shared folder on the host and check in the VM:

```bash
cat /media/sf_shared/test_pc.txt
```

### 5.7 GUI Environment Verification Checklist

Before proceeding with Docker, check if everything is working:

**✓ Graphical Interface:**

- [ ] Desktop (GNOME) loads correctly after login
- [ ] Mouse and keyboard work smoothly (no lag)
- [ ] Screen resolution adjusts automatically when resizing window

**✓ Guest Additions:**

- [ ] `lsmod | grep vbox` shows vboxguest, vboxsf, vboxvideo
- [ ] Copy/paste works between host and VM
- [ ] Drag and drop works between host and VM

**✓ Shared Folder:**

- [ ] `/media/sf_shared` exists and is accessible
- [ ] Files created in the VM appear on the host
- [ ] Files created on the host appear in the VM

**✓ Browser:**

- [ ] Able to browse basic web pages

> **Note:** If any item does not work, review the previous steps before continuing.

## 6. Install Docker and Docker Compose (Official Repository)

> **Complete preparation:** Install the official Docker from the Docker repository (more up-to-date than Debian's) and all tools needed for development and building the project.

### 6.1 Install all necessary dependencies

```bash
sudo apt install -y curl wget git make ca-certificates gnupg lsb-release apt-transport-https
```

### 6.2 Add Docker repository GPG key

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

### 6.3 Add Docker repository

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
```

### 6.4 Install Docker and plugins

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 6.5 Enable Docker service

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### 6.6 Test Docker installation

```bash
sudo docker run hello-world
```

Should display: Hello from Docker!

### 6.7 Verify installation

```bash
docker --version
docker compose version
docker ps
```

Should show the installed versions and the list of containers (empty).

### 6.8 Allow user to use Docker without sudo

```bash
sudo usermod -aG docker dramos-j
sudo reboot
```

### 6.9 Test basic Docker commands

```bash
docker run hello-world
docker run -it debian bash
docker ps -a
docker rm -f <container_id>
docker volume ls
docker network ls
```

## 7. Network and Hostname Configuration

### 7.1 Configure Network Adapter in VirtualBox

With the VM off:

- VirtualBox → Settings → Network → Adapter 1:
  - **Attached to:** Bridged Adapter
  - **Name:** Select your physical network card (Wi-Fi or Ethernet)

This allows other computers on the network to access your VM.

### 7.2 Find the VM's IP address

After starting the VM:

```bash
ip addr show | grep inet
```

Note the IP (e.g., `10.12.248.36`).

### 7.3 Configure /etc/hosts in the VM

To access WordPress via `dramos-j.42.fr` (as required by the subject), map this domain to localhost in `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Add the line:

```bash
127.0.0.1 dramos-j.42.fr
```

### 7.4 Configure /etc/hosts on the Evaluator's Machine

For the evaluator to access from outside, they must add to their `/etc/hosts`:

**On Linux/Mac:**

```bash
echo "10.12.248.36  dramos-j.42.fr" | sudo tee -a /etc/hosts
```

**On Windows (as Administrator):**

```bash
echo 10.12.248.36  dramos-j.42.fr >> C:\Windows\System32\drivers\etc\hosts
```

## 8. Project Directory Structure (Subject 2026)

> **Organization:** The directory structure as per the project subject makes it easier to develop, build, and deploy Docker services.

**Location:** `/home/dramos-j/Documents/Inception/shared/inception/` (shared folder)

Create the structure and ensure the documentation files exist:

```bash
cd /home/dramos-j/Documents/Inception
mkdir -p shared/inception/srcs/requirements/{mariadb,nginx,wordpress}
mkdir -p shared/inception/secrets
cd shared/inception
touch Makefile README.md USER_DOC.md DEV_DOC.md srcs/docker-compose.yml srcs/.env
```

**Expected structure:**

```console
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

## 9. Maintenance and Disk Compaction

To keep your sgoinfre clean, use this procedure before leaving school:

### 9.1 Inside the VM (Cleanup Script)

```bash
# Clean up Docker and system junk
docker system prune -a --volumes -f
sudo apt-get clean

# Zero out free space so VirtualBox can compact the disk
sudo dd if=/dev/zero of=/zerofile bs=1M
sudo rm /zerofile
sudo shutdown now
```

### 9.2 On the Host (Physical Machine Terminal)

```bash
VBoxManage modifymedium disk "/home/dramos-j/sgoinfre/Inception_VM/Inception_VM.vdi" --compact
```

**Note:** Adjust the `.vdi` path as needed for your actual disk location.

## 10. Final Snapshot

With the VM shut down and cleaned:

- **Name:** `Inception_Ready_To_Code`
- **Description:** Debian 12, GNOME, Docker + Compose, and network configured.
