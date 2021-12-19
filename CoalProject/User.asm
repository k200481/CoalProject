INCLUDE irvine32.inc
INCLUDE User.inc
INCLUDE FileHandling.inc
OPTION PROC:PRIVATE

; private function prototypes
FindUser PROTO, username:PTR BYTE

; error codes
NO_ERROR = 0
FILE_ERROR = 1
LOGIN_ERROR = 2
DUPLICATE_USERNAME = 3
USER_DOES_NOT_EXIST = 4
ERROR_RANGE = 5 ; if code is greater or equal, the error come from some func used within this file or is invlalid

User STRUCT
	username BYTE MAX_NAME_LEN DUP(0),0
	password BYTE MAX_PW_LEN DUP(0),0
User ENDS

.data
	ERROR_MSG_LEN = 30
	errorTable	BYTE	"No Errors                    ",0
				BYTE	"Unable To Open File          ",0
				BYTE	"Invalid username or password ",0
				BYTE	"Duplicated Username          ",0
				BYTE	"User does not exist          ",0
	unknownError BYTE	"Unknown error code: ",0

	filename BYTE "UserData.txt",0
	err DWORD 0

	userbuf User <>

.code

; returns ptr to user in eax
; if eax is -1 it indicates an error
; DisplayErrorMsg should be called in this case
Login PROC, username:PTR BYTE, password:PTR BYTE
	LOCAL uPtr:DWORD
	pushad

	; init
	mov err, 0

	INVOKE FindUser, username
	_IF1: cmp eax, false
	jne END_IF1
		mov err, USER_DOES_NOT_EXIST
		mov uPtr, -1
		jmp RETURN
	END_IF1:

	mov esi, offset userbuf.password
	mov edi, password
	_IF2: REPE CMPSB ; if passwords don't match
	je END_IF2
		mov err, LOGIN_ERROR
		mov uPtr, -1
		jmp RETURN
	END_IF2:

	mov uPtr, offset userbuf
	
RETURN:
	popad
	mov eax, uPtr
	ret
Login ENDP

Signup PROC, username:PTR BYTE, password:PTR BYTE
	pushad
	mov err, 0

	INVOKE FindUser, username
	_IF1: cmp eax, true ; if user already exists
	jne END_IF1
		mov err, DUPLICATE_USERNAME
		jmp RETURN
	END_IF1:

	INVOKE AppendFile, ADDR filename, username, MAX_NAME_LEN
	_IF2: cmp eax, 0
	je END_IF2
		mov err, eax
		jmp RETURN
	END_IF2:

	INVOKE AppendFile, ADDR filename, password, MAX_PW_LEN
	_IF3: cmp eax, 0
	je END_IF3
		mov err, eax
		jmp RETURN
	END_IF3:

RETURN:
	popad
	mov eax, err
	ret
Signup ENDP

; returns offset to username in eax
GetName PROC uPtr:DWORD
	mov esi, uPtr
	lea eax, [USER PTR [esi]].username
	ret
GetName ENDP

; returns offset to password in eax
GetPassword PROC uPtr:DWORD
	mov esi, uPtr
	lea eax, [USER PTR [esi]].password
	ret
GetPassword ENDP

User_DisplayErrorMsg PROC
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
User_DisplayErrorMsg ENDP

; updates userbuf and pwbuf with values read from file
; returns 1 in eax if user is found, 0 otherwise
; returns -1 if file error
FindUser PROC PRIVATE, username:PTR BYTE
	LOCAL filehandle:HANDLE, found:BYTE
	pushad

	; init
	mov found, 0 ; initially false

	; open input file
	mov edx, offset filename
	call OpenInputFile
	_IF0:cmp eax, INVALID_HANDLE_VALUE
	jne END_IF0
		mov eax, FILE_ERROR
		je RETURN ; if file failed to open
	END_IF0:
	mov filehandle, eax

	; read every entry in file
	WHILE1: ; while true
		
		; read username
		mov eax, filehandle
		mov edx, offset userbuf.username
		mov ecx, MAX_NAME_LEN
		call ReadFromFile
		_IF1: jnc _ELSEIF1 ; if read was unsuccessful
			call WriteWindowsMsg
			jmp END_WHILE1 ; break
		_ELSEIF1: cmp eax, 0
		jne END_IF1
			jmp END_WHILE1
		END_IF1:

		; read password
		mov eax, filehandle
		mov edx, offset userbuf.password
		mov ecx, MAX_PW_LEN
		call ReadFromFile
		_IF2: jnc _ELSEIF2 ; if read was unsuccessful
			call WriteWindowsMsg
			jmp END_WHILE1 ; break
		_ELSEIF2: cmp eax, 0
		jne END_IF2
			jmp END_WHILE1
		END_IF2:

		mov ecx, MAX_NAME_LEN
		mov esi, username
		lea edi, userbuf.username
		REPE CMPSB
		_IF3: jne END_IF3 ; if usernames match
			mov found, 1 ; set found to true
			jmp END_WHILE1 ; break loop
		END_IF3:

	jmp WHILE1
	END_WHILE1:

	mov eax, filehandle
	call closefile
	
RETURN:
	popad
	movzx eax, found
	ret
FindUser ENDP

END