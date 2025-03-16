source "yandex" "debian_docker" {
  disk_type           = "network-hdd"
  folder_id           = "b1gl1jlokpp0fb08pgic9"
  image_description   = "my custom debian with docker"
  image_name          = "debian-11-docker2"
  source_image_family = "debian-11"
  ssh_username        = "debian"
  subnet_id           = "e9bultefjvfdqik8gq5r9"
  token               = "XX__XXXXXXXX_XXXXXXXXXXXXXXX7RP"
  use_ipv4_nat        = true
  zone                = "ru-central1-a"
}


build {
  sources = ["source.yandex.debian_docker"]

  provisioner "shell" {
    inline = [
      # Обновление списка пакетов
      "sudo apt-get update",

      # Установка необходимых пакетов
      "sudo apt-get install -y ca-certificates curl",

      # Создание каталога для ключей
      "sudo install -m 0755 -d /etc/apt/keyrings",

      # Загрузка и установка GPG-ключа Docker
      "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",

      # Добавление репозитория Docker
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      # Обновление списка пакетов с учётом нового репозитория
      "sudo apt-get update",

      # Установка Docker
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",

      # Включение и запуск службы Docker
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "echo 'Docker installed successfully'",
      # Проверка версии Docker
      "docker --version",
      
      # Проверка пользователя
      "ls -l /home/",
      
      # Проверка пользователя
      "ls -l /home/debian/.ssh",

      # Установка htop и tmux
      "sudo apt-get install -y htop tmux",

      # Установка SSH-сервера (если его еще нет)
      "sudo apt-get install -y openssh-server",

      # Проверка статуса SSH-сервера
      "sudo systemctl status ssh | grep 'Active: active (running)' && echo 'SSH server is running' || echo 'SSH server is NOT running'",

      # Проверка порта, на котором работает SSH
      "sudo ss -tuln | grep -E '0.0.0.0:22|:::22' && echo 'SSH is listening on port 22' || echo 'SSH port check failed - checking config...'",
      
      # Вывод конфигурации порта из sshd_config (если порт отличается от 22)
      "sudo grep '^Port' /etc/ssh/sshd_config || echo 'SSH uses default port 22 (no custom Port in config)'"
    ]
  }
}
