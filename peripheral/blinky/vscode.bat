rem Location of Nordic SDK
set NRF_SDK=C:/Nordic/nRF5_SDK_12.3.0

rem Location of Nordic Command Line tools (nrfjprog) 
set NRF_TOOLS=C:/Nordic/nrf_CommandLine_Tool/bin

rem location of GCC Cross-compiler https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads
set GNU_GCC=C:/Nordic/gcc-arm-none-eabi-7-2018-q2-update-win32/bin

rem Location of Gnu Tools (make) https://github.com/gnu-mcu-eclipse/windows-build-tools/releases
set GNU_TOOLS=C:/Nordic/GNU/Tools/2.11-20180428-1604/bin

rem Location of SEGGER JLink tools
set SEGGER_TOOLS=C:/Nordic/SEGGER/JLink_V640

rem Location of java
set JAVA=C:/Nordic/Java/jdk-11.0.1/bin/java.exe

rem Serial numbers of nRF development boards
set PCA10028_SN=681676308

"C:/Program Files/Microsoft VS Code/Code.exe" blinky.code-workspace
