;INCLUDE irvine32.inc

; these restrictions make it so that all data values in the file are of equal length
; makes it easier to read/write data
MAX_NAME_LEN = 30
MAX_PW_LEN = 30

Login PROTO, username:PTR BYTE, password:PTR BYTE
Signup PROTO, username:PTR BYTE, password:PTR BYTE
User_DisplayErrorMsg PROTO

GetName PROTO uPtr:DWORD
GetPassword PROTO uPtr:DWORD

