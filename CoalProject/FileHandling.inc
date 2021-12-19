
; appends given date at the end of an existing file, or
; creates a new file if one does not exist
AppendFile PROTO, filename:PTR BYTE, data:PTR BYTE, len:DWORD

; searches file for given data
SearchFile PROTO, filename:PTr BYTE, data:PTR BYTE, len:DWORD
