*** Settings ***
Library           SSHLibrary
Library           Process
Resource          resource.robot
Force Tags        webserver
Suite Setup       Open Connection And Log In
Suite Teardown    Close All Connections

*** Variables ***

*** Test cases ***
Verify Hostname
    [Timeout]    30s
    Get Hostname
    Hostname Is Correct

Verify Nginx
    [Timeout]    1m
    [Documentation]    Nginx is started on boot, so we don't need to start it in the test case.
    Check Nginx Is Running
    Check Nginx Output

*** Keywords ***
Get Hostname
    ${HOSTNAME} =      Execute Command    hostname
    Set Test Variable    ${HOSTNAME}

Hostname Is Correct
    Should Be Equal    ${HOSTNAME}    raspberrypi

Check Nginx Is Running
    ${result} =       Execute Command    systemctl status nginx
    Should Contain    ${result}    Active: active (running)

Check Nginx Output
    ${result} =       Run Process    curl    ${RPI_IP}
    Should Contain    ${result.stdout}    Welcome to nginx!
    Should Contain    ${result.stdout}    the nginx web server is successfully installed