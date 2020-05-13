*** Settings ***
Library           SSHLibrary

*** Variables ***
${RPI_IP}               10.0.1.22
${USERNAME}             pi
${PASSWORD}             raspberry

*** Keywords ***
Open Connection And Log In
    Open Connection     ${RPI_IP}
    Login               ${USERNAME}    ${PASSWORD}