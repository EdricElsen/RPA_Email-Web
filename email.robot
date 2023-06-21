*** Settings ***
Library    String
Library    Selenium2Library    run_on_failure=Nothing
Library    CryptoLibrary     variable_decryption=True
Library    Collections
Library    DateTime

*** Variables ***
# ${ePWD}     crypt:m0Egwc009SXESIr1H3JTUHoBl3x/aWilNBZxDJtpKjZTrR6NMtfOUGfdHrskQ/icL34S+P1Tf/s5cg==
# ${ePWD1}     crypt:AfwApFGX1INK205OCPyKf8JsAV7UXqGcljznYLutyEi23DO6DXXWopC3uCTnaEyWsx8K3qS+
${ePWD}        edric03212
${ePWD1}       mayora   
${websiteEmail}      https://192.168.0.110/
${web}     https://portal.mayora.co.id/Login
${unread}    Zhrow Unread

${listemailbody}
${listemailsender}

${webHelpDesk}    https://portal.mayora.co.id/Portal/QRH/HelpDesk/CreateIssue


*** Test Cases ***
testing
    Open Login Page
    Login with Encrypted Credential
    Make a List
    Loop Condition

*** Keywords ***
Open Login Page
    Set Selenium Timeout       2m 30s
    Open Browser    ${websiteEmail}    Chrome     options=add_argument("--incognito")
    Maximize Browser Window
    Click Element   id:details-button
    Click Element   id:proceed-link
    
Login with Encrypted Credential
    Input Text      id:username     edric.elsen@mayora.co.id
    Input Password      id:password     ${ePWD}
    Click Element      name:zrememberme
    sleep     2s
    Click Element       class:ZLoginButton

Make a List
    ${listemailbody}=   Create List
    Set Suite Variable       ${listemailbody}
    ${listemailsender}=   Create List
    Set Suite Variable       ${listemailsender}

Loop Condition
    ${length}=      get length      ${listemailbody}
    sleep    1s
    ${date}=	Get Current Date
    ${time} =	Convert Date	${date}	    result_format=%H.%M
    ${present}=     Run Keyword And Return Status    Element Should Be Visible      class:Unread
    Run Keyword If     ${time}>=17.00      Full Stop
    ...     ELSE IF    ${present}    Click Unread Message
    ...     ELSE IF    ${length}<=0    Get More Email
    ...     ELSE IF    ${length}>0    Go to Portal


Loop Condition 2
    ${length}=      get length      ${listemailbody}
    ${present}=     Run Keyword And Return Status    Element Should Be Visible      class:ZmRowDoubleHeader.Unread
    ${date}=	Get Current Date
    ${time}=	Convert Date	${date}	    result_format=%H.%M
    Run Keyword If     ${time}>=17.00     Full Stop
    ...     ELSE IF    ${present}    Click Unread Message
    ...     ELSE IF    ${length}<=0    Get More Email
    ...     ELSE IF    ${length}>0    Go to HelpDesk Website

Click Unread Message
    Click Element    class:Unread
    # Click Element    class:Collapsed.Last
    sleep   1s
    Get the Body of Email

Get the Body of Email
    Wait Until Element Is Visible    xpath:/html/body
    ${from}=    Get Text      class:MsgHdrValue
    Append To List    ${listemailsender}    ${from}
    ${text}=    Get Text      class:MsgBody
    Append To List    ${listemailbody}    ${text}
    Log     ${listemailsender}
    Log     ${listemailbody}
    sleep     2s
    Loop Condition


Get More Email
    sleep    2s
    Click Element    class:ImgRefreshAll
    Loop Condition

Go to portal
    Go to   ${web}
    Input Credential

Input Credential
    sleep     8s
    Input Text      id:username     mm04993
    Input Password      id:password     ${ePWD1}
    Click Element       xpath://*[@id="root"]/main/div[1]/div/div[1]/form/div[3]/button
    Go to HelpDesk Website

Go to HelpDesk Website
    FOR    ${body}    ${sender}    IN ZIP    ${listemailbody}    ${listemailsender}
        sleep    10s
        Go to    ${webHelpDesk}
        sleep    10s
        @{senderEmail0} =   split string    ${sender}    <
        ${senderEmail} =    remove string     ${senderEmail0}[1]    >
        Input Text    name:email    ${senderEmail}
        sleep   1s
        Input Text    name:descIssue    Testing Robot Framework - ${body}
        sleep   10s
        Click Element       xpath:/html/body/div[1]/div[5]/main/div[2]/div/div[1]/div/div[6]/button
        sleep   3s
        Click Element       xpath:/html/body/div[4]/div[3]/div/div[4]/button[2]
        sleep   5s
        Click Element       xpath:/html/body/div[1]/div[5]/main/div[2]/div/div/div/a
    END
    FOR     ${elem}    IN     @{listemailbody}
        Remove values from list    ${listemailbody}    ${elem}
    END
    FOR     ${elem}    IN     @{listemailsender}
        Remove values from list    ${listemailsender}    ${elem}
    END
    Go to zimbra after Login

Go to kanban after Login
    Go to    https://portal.mayora.co.id/Portal/Dashboard/IT/Kanban


Go to zimbra after Login
    Go to    https://192.168.0.110/#1/search?mesg=welcome&init=true
    Loop Condition 2

Full Stop
   Close Browser