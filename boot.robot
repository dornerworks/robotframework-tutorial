*** Settings ***
Library           SerialLibrary    encoding=ascii
Library           String
Force Tags        boot    has-serial
Suite Setup       Open Serial Port
Suite Teardown    Close Serial Port

*** Variables ***
${LOGIN_STR}      raspberrypi login:
${SERIAL_PORT}    /dev/ttyUSB0
${RPI_IP}         10.0.1.22
${USERNAME}       pi
${PASSWORD}       raspberry
${PROMPT}         pi@raspberrypi:

*** Test cases ***
System Boots
    [Timeout]     3m
    Read Until Single    Booting Linux on physical CPU 0x0
    Read Until Single    Mounted root
    Read Until Single    Raspbian
    Read Until Single    ${LOGIN_STR}
    Write Data           \n
    Read Until Single    ${LOGIN_STR}
    Write Data           ${USERNAME}\n
    Read Until Single    Password:
    Write Data           ${PASSWORD}\n
    ${read} =            Read Until Single    ${PROMPT}
    Should Contain       ${read}              ${PROMPT}

Verify RPI IP Address
    [Timeout]     30s
    ${read} =          Run Shell Command    hostname -I
    Should Be Equal    ${read}    ${RPI_IP}

*** Keywords ***
Open Serial Port
    Add Port   ${SERIAL_PORT}
    ...        baudrate=115200
    ...        bytesize=8
    ...        parity=N
    ...        stopbits=1
    ...        timeout=999

Close Serial Port
    Delete All Ports

Read Until Single
    [Arguments]    ${expected}
    ${read} =         Read Until    terminator=${expected}
    Should Contain    ${read}    ${expected}
    Log               ${read}    console=yes
    [Return]       ${read}

Run Shell Command
    [Arguments]    ${command}
    Write Data       ${command}\n
    Read Until       terminator=${command}
    ${result} =      Read Until    terminator=${PROMPT}
    @{words} =       Split String From Right     ${result}    \n    max_split=1
    ${stripped} =    Strip String    ${words}[0]
    Log              ${stripped}    console=yes
    [Return]       ${stripped}