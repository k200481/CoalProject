

MAX_DESC_LEN = 100

LoadUser PROTO, userPtr:DWORD
UnloadUser PROTO
DisplayUnfinished PROTO
DisplayCompleted PROTO

AddNew PROTO, desc:PTR BYTE
MarkAsDone PROTO, ID:DWORD

ToDo_DisplayErrorMsg PROTO
