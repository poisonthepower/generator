FROM ubuntu:latest
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y sudo curl nano git software-properties-common && \
    add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update

RUN mkdir ~/bin && \
    PATH=~/bin:$PATH && \
    cd ~/bin && \
    curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo && \
    chmod a+x ~/bin/repo

RUN git clone https://github.com/akhilnarang/scripts.git scripts && \
    cd scripts && \
    bash setup/android_build_env.sh

RUN cd && \
    mkdir ev && \
    cd ev && \
    repo init -u https://github.com/Evolution-X/manifest -b tiramisu && \
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

RUN git clone https://github.com/kibria5/device_xiaomi_violet.git -b 13 device/xiaomi/violet

RUN echo "Stuffs to rm -rf" && \
    rm -rf hardware/qcom-caf/sm8150/audio && \
    rm -rf hardware/qcom-caf/sm8150/media && \
    rm -rf hardware/qcom-caf/sm8150/display && \
    rm -rf packages/resources/devicesettings

RUN echo "Cloning Hals" && \
    git clone --depth 1 https://github.com/SuperiorOS/android_hardware_qcom_audio.git -b thirteen-caf-sm8150  hardware/qcom-caf/sm8150/audio && \
    git clone --depth 1 https://github.com/SuperiorOS/android_hardware_qcom_media.git -b twelve-caf-sm8150 hardware/qcom-caf/sm8150/media && \
    git clone --depth 1 https://github.com/SuperiorOS/android_hardware_qcom_display.git -b twelve-caf-sm8150 hardware/qcom-caf/sm8150/display && \
    git clone --depth 1 https://github.com/LineageOS/android_packages_resources_devicesettings -b lineage-20.0 packages/resources/devicesettings

RUN echo "Cloning Vendor tree" && \
    git clone --depth 1 https://github.com/kibria5/android_vendor_xiaomi_violet.git -b thirteen vendor/xiaomi/violet

RUN echo "Cloning Kernel tree" && \
    git clone --depth 1 https://github.com/kibria5/android_kernel_xiaomi_violet.git -b thirteen kernel/xiaomi/violet

RUN echo "Firmware tree" && \
    git clone --depth 1 https://gitlab.pixelexperience.org/android/vendor-blobs/vendor_xiaomi-firmware.git -b thirteen vendor/xiaomi-firmware

RUN echo "Cloning MiuiCamera tree" && \
    git clone --depth 1 https://gitlab.com/kibria5/android_vendor_miuicamera.git -b thirteen vendor/MiuiCamera

RUN echo "Cloning Dolby Tree" && \
    git clone --depth 1 https://github.com/danhancach/vendor_dolby.git -b dolby-1.0-d1 vendor/dolby

RUN echo "Cloning Proton clang" && \
    git clone --depth 1 https://github.com/kdrag0n/proton-clang.git -b master prebuilts/clang/host/linux-x86/clang-proton

# Set up environment
RUN . build/envsetup.sh

# Choose a target
RUN lunch evolution_violet-userdebug

# Build the code
CMD mka evolution
