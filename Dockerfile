# Usamos la imagen oficial de OpenJDK desde Docker Hub
FROM openjdk:11-jdk

# Instalar paquetes y dependencias necesarias
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Variables de entorno para el SDK de Android
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# Descargar e instalar las Command-Line Tools de Android
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && cd ${ANDROID_SDK_ROOT}/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O commandlinetools.zip \
    && unzip commandlinetools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm commandlinetools.zip

# Aceptar licencias e instalar herramientas de Android, incluyendo el NDK requerido por Unreal Engine
RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-32" "build-tools;32.0.0" "ndk;21.3.6528147"

# Configurar el proyecto de Unreal Engine
# (asumiendo que lo clonarás desde un repositorio o ya está en tu máquina local)
RUN git clone https://github.com/yourusername/your-unreal-engine-project.git /usr/src/app

# Directorio de trabajo
WORKDIR /usr/src/app

# Hacer ejecutable el script gradlew (en caso de tener uno para Android)
RUN chmod +x ./gradlew

# Preinstalar dependencias del proyecto para acelerar el primer build
# Esto depende del proyecto específico; ajusta según sea necesario
RUN ./gradlew build --no-daemon || true

# Comando por defecto al iniciar el contenedor
CMD ["./gradlew", "assembleDebug"]
