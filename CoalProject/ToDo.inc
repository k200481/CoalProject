

MAX_DESC_LEN = 100
TODO_SIZE = MAX_DESC_LEN + 4 + 1

LoadUser PROTO, userPtr:DWORD
UnloadUser PROTO
DisplayUnfinished PROTO
DisplayCompleted PROTO

AddNew PROTO, desc:PTR BYTE
MarkAsDone PROTO, ID:DWORD

ToDo_DisplayErrorMsg PROTO
