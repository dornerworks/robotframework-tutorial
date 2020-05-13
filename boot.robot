*** Settings ***
Library           SerialLibrary    encoding=ascii
Library           String
Resource          resource.robot
Force Tags        boot    has-serial
Suite Setup       Open Serial Port
Suite Teardown    Close Serial Port

*** Variables ***
${LOGIN_STR}      raspberrypi login:
${SERIAL_PORT}    /dev/ttyUSB0
${PROMPT}         pi@raspberrypi:

*** Test cases ***
System Boots
    [Timeout]     3m
    Check Linux Boots
    Login To Linux

Verify RPI IP Address
    [Timeout]     30s
    Get Host IP
    RPI IP Address Is Correct

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
    ${read} =         SerialLibrary.Read Until    terminator=${expected}
    Should Contain    ${read}    ${expected}
    Log               ${read}    console=yes
    [Return]       ${read}

Run Shell Command
    [Arguments]    ${command}
    SerialLibrary.Write Data    ${command}\n
    SerialLibrary.Read Until    terminator=${command}
    ${result} =                 SerialLibrary.Read Until    terminator=${PROMPT}
    @{words} =                  Split String From Right     ${result}    \n    max_split=1
    ${stripped} =               Strip String    ${words}[0]
    Log                         ${stripped}    console=yes
    [Return]       ${stripped}

Check Linux Boots
    Read Until Single    Booting Linux on physical CPU 0x0
    Read Until Single    Mounted root
    Read Until Single    Raspbian
    Read Until Single    ${LOGIN_STR}

Login To Linux
    SerialLibrary.Write Data    \n
    Read Until Single           ${LOGIN_STR}
    SerialLibrary.Write Data    ${USERNAME}\n
    Read Until Single           Password:
    SerialLibrary.Write Data    ${PASSWORD}\n
    ${read} =                   Read Until Single    ${PROMPT}
    Should Contain              ${read}              ${PROMPT}

Get Host IP
    ${HOST_IP} =         Run Shell Command    hostname -I
    Set Test Variable    ${HOST_IP}

RPI IP Address Is Correct
    Should Be Equal    ${HOST_IP}    ${RPI_IP}