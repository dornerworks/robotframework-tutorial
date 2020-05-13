*** Settings ***
Library           SSHLibrary
Library           String
Force Tags        perf
Suite Setup       Open Connection And Log In
Suite Teardown    Close All Connections

*** Variables ***
${RPI_IP}               10.0.1.22
${USERNAME}             pi
${PASSWORD}             raspberry
${EXPECTED_AVG_TIME}    35.00
${EXPECTED_MAX_TIME}    40.00
${PERF_TEST_TIME}       10s
@{SYSBENCH_CMD}         sysbench
...                     --num-threads=4
...                     --test=cpu
...                     --max-time=${PERF_TEST_TIME}
...                     run

*** Test cases ***
Test CPU Performance
    [Timeout]    30s
    Run Sysbench
    Per request average should be less than expected
    Per request maximum should be less than expected

*** Keywords ***
Run Sysbench
    ${cmd} =             Catenate    @{SYSBENCH_CMD}
    ${PERF_RESULTS} =    Execute Command    ${cmd}
    Log                  ${PERF_RESULTS}    console=yes
    Set Test Variable    ${PERF_RESULTS}

Per request average should be less than expected
    ${avg} =          Get Per Request Val    ${PERF_RESULTS}     avg:
    Should Be True    ${avg} < ${EXPECTED_AVG_TIME}

Per request maximum should be less than expected
    ${max} =          Get Per Request Val    ${PERF_RESULTS}     max:
    Should Be True    ${max} < ${EXPECTED_MAX_TIME}

Get Per Request Val
    [Arguments]    ${test_results}    ${val_type}
    ${str} =    Get Lines Containing String    ${test_results}    ${val_type}
    ${str} =    Get Regexp Matches    ${str}    ([\\d\\.]*)ms    1
    ${val} =    Convert To Number    ${str[0]}
    [Return]    ${val}

Open Connection And Log In
    Open Connection     ${RPI_IP}
    Login               ${USERNAME}    ${PASSWORD}