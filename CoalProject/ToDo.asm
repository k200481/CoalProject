INCLUDE irvine32.inc
INCLUDE User.inc
INCLUDE ToDo.inc
INCLUDE FileHandling.inc

TODO STRUCT
	ID DWORD ?
	description BYTE MAX_DESC_LEN DUP(0)
	completed BYTE 1
TODO ENDS

; private func
CountToDos PROTO

; error codes
NO_ERROR = 0
FILE_ERROR = 1
USER_NOT_LOADED = 2
ERROR_RANGE = 3

.data
	ERROR_MSG_LEN = 30

	errorTable	BYTE "No Errors                     ",0
				BYTE "Error loading file            ",0
				BYTE "No user loaded to the database",0
	unknownError BYTE "Unkown error code",0

	; headings
	tdlHeading BYTE "To-do list",0Ah,0Dh,0

	uPtr DWORD 0
	err DWORD 0

	count DWORD 0

.code

LoadUser PROC, userPtr:DWORD
	push eax
	
	mov eax, userPtr
	mov uPtr, eax

	INVOKE CountToDos
	
	pop eax
	ret
LoadUser ENDP

UnloadUser PROC
	mov uPtr, 0
	mov count, 0
	ret
UnloadUser ENDP

DisplayUnfinished PROC
	LOCAL filehandle:HANDLE, username:PTR BYTE

	LOCAL td:TODO
	pushad
	mov err, 0
	
	INVOKE GetName, uPtr
	mov username, eax

	mov edx, offset tdlHeading
	call WriteString

	mov edx, username
	call OpenInputFile
	_IF1: cmp eax, INVALID_HANDLE_VALUE
	jne _ENDIF1
		mov err, FILE_ERROR
		jmp RETURN
	_ENDIF1:
	mov filehandle, eax

	WHILE1:
		lea edx, td
		mov ecx, TODO_SIZE
		mov eax, filehandle
		call ReadFromFile
		cmp eax, 0 ; if eax is 0, eof was reached
		je ENDWHILE1

		_IF2:cmp [td.completed],0
		jne _ENDIF2
			mov eax, td.ID
			call WriteDec
			mov eax, ' '
			call WriteChar
			lea edx, td.description
			call WriteString
			call crlf
		_ENDIF2:

	jmp WHILE1
	ENDWHILE1:
	
	mov eax, filehandle
	call CloseFile

RETURN:
	popad
	mov eax, err
	ret
DisplayUnfinished ENDP

DisplayCompleted PROC
	LOCAL filehandle:HANDLE, username:PTR BYTE

	LOCAL td:TODO
	pushad
	mov err, 0
	
	INVOKE GetName, uPtr
	mov username, eax

	mov edx, offset tdlHeading
	call WriteString

	mov edx, username
	call OpenInputFile
	_IF1: cmp eax, INVALID_HANDLE_VALUE
	jne _ENDIF1
		mov err, FILE_ERROR
		jmp RETURN
	_ENDIF1:
	mov filehandle, eax

	WHILE1:
		lea edx, td
		mov ecx, TODO_SIZE
		mov eax, filehandle
		call ReadFromFile
		cmp eax, 0 ; if eax is 0, eof was reached
		je ENDWHILE1

		_IF2:cmp [td.completed],1
		jne _ENDIF2
			mov eax, td.ID
			call WriteDec
			mov eax, ' '
			call WriteChar
			lea edx, td.description
			call WriteString
			call crlf
		_ENDIF2:

	jmp WHILE1
	ENDWHILE1:
	
	mov eax, filehandle
	call CloseFile

RETURN:
	popad
	mov eax, err
	ret
DisplayCompleted ENDP

AddNew PROC, desc:PTR BYTE
	LOCAL username:PTR BYTE, td:TODO
	pushad

	mov err, 0

	_IF1:cmp uPTr, 0
	jne _ENDIF1
		mov err, USER_NOT_LOADED
		jmp RETURN
	_ENDIF1:

	INVOKE GetName, uPtr
	mov username, eax

	mov esi, desc
	lea edi, td.description
	mov ecx, MAX_DESC_LEN
	REP MOVSB

	mov td.completed, 0
	mov eax, count
	mov td.ID, eax
	inc count

	INVOKE AppendFile, username, ADDR td, TODO_SIZE
	_IF2: cmp eax, 0
	jne _ENDIF2
		mov err, FILE_ERROR
		jmp RETURN
	_ENDIF2:

RETURN:
	popad
	mov eax, err
	ret
AddNew ENDP

MarkAsDone PROC, ID:PTR BYTE
	ret
MarkAsDone ENDP

ToDo_DisplayErrorMsg PROC
	pushad
	
	mov eax, err
	cmp eax, 0
	jl RETURN
	_IF1:cmp eax, ERROR_RANGE
	jl _ENDIF1
		mov edx, offset unknownError
		call WriteString
		mov eax, err
		call WriteDec
		jmp RETURN
	_ENDIF1:

	mov eax, err
	mov ebx, ERROR_MSG_LEN
	mul ebx
	mov esi, offset errortable
	lea edx, [esi + eax]

	call WriteString

RETURN:
	popad
	ret
ToDo_DisplayErrorMsg ENDP

CountToDos PROC
	LOCAL filehandle:HANDLE, username:PTR BYTE

	LOCAL td:TODO
	pushad
	mov err, 0
	
	INVOKE GetName, uPtr
	mov username, eax

	mov edx, username
	call OpenInputFile
	_IF1: cmp eax, INVALID_HANDLE_VALUE
	jne _ENDIF1
		jmp RETURN
	_ENDIF1:
	mov filehandle, eax

	WHILE1:
		lea edx, td
		mov ecx, TODO_SIZE
		mov eax, filehandle
		call ReadFromFile
		cmp eax, 0 ; if eax is 0, eof was reached
		je ENDWHILE1

		inc count

	jmp WHILE1
	ENDWHILE1:

	mov eax, filehandle
	call CloseFile

RETURN:
	popad
	mov eax, err
	ret
CountToDos ENDP

END