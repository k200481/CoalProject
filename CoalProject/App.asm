INCLUDE irvine32.inc
INCLUDE App.inc
INCLUDE User.inc
INCLUDE ToDo.inc
OPTION PROC:PRIVATE

; private funcs
LoginScreen PROTO
SignupScreen PROTO
StartupMenu PROTO
MainMenu PROTO

ToDoAddScreen PROTO
MarkToDoAsDoneScreen PROTO

.data
	; startup menu prompts
	startupMenuOptions	BYTE "1: Login",0Ah, 0Dh
						BYTE "2: Signup", 0Ah, 0Dh
						BYTE "Choice: ",0
	incorrectChoice BYTE "Invalid choice",0Ah,0Dh,0
	
	; Login/Signup screen prompts
	welcomeMsg BYTE "Welcome",0
	usernamePrompt BYTE "Enter username: ",0
	passwordPrompt BYTE "Enter password: ",0
	unameOrPwLenInvalid	BYTE "Username/password may not be empty",0

	; main menu prompts
	mainMenuOptions BYTE "Menu", 0Ah,0Dh
					BYTE "1: See to-dos",0Ah, 0Dh
					BYTE "2: See completed to-dos", 0Ah, 0Dh
					BYTE "3: Add to-do", 0Ah, 0Dh
					BYTE "4: Mark to-do as done", 0Ah, 0Dh
					BYTE "5: Logout",0Ah,0Dh
					BYTE "Enter choice: ",0
	
	; todo adding prompts
	addTodoPrompt	BYTE "Add To-do",0Ah, 0Dh
					BYTE "To-do may be up to 100 characters, enter empty line to exit",0Ah,0Dh
					BYTE "Enter To-do description: ",0Ah,0Dh,0

	; marking todo as done prompt
	markToDoPrompt	BYTE "Enter ID of completed to-do: ",0

	uPTr DWORD 0 ; is a non-zero value when logged in

.code
Run PROC
	
	mov eax, 0
	WHILE1: cmp eax, 0 ; if eax changes, that is seen as an exit signal
	jne ENDWHILE1
		
		call ClrScr
		_IF1:cmp [uPtr], 0 ; if uptr is 0, user has not logged in yet
		jne _ELSEIF1
			INVOKE StartupMenu
		jmp _ENDIF1
		_ELSEIF1:
			INVOKE MainMenu
		_ENDIF1:

	jmp WHILE1
	ENDWHILE1:

	ret
Run ENDP

LoginScreen PROC
	LOCAL username[MAX_NAME_LEN + 1]:BYTE, password[MAX_PW_LEN + 1]:BYTE
	pushad
	mov eax, 0

	mov ecx, MAX_NAME_LEN + 1
	lea edi, username
	REP STOSB

	mov ecx, MAX_PW_LEN + 1
	lea edi, password
	REP STOSB

	mov edx, offset welcomeMsg
	call WriteString
	call crlf

	mov edx, offset usernamePrompt
	call WriteString
	lea edx, username
	mov ecx, MAX_NAME_LEN
	call ReadString

	mov edx, offset passwordPrompt
	call WriteString
	lea edx, password
	mov ecx, MAX_PW_LEN
	call ReadString

	INVOKE Login, ADDR username, ADDR password
	_IF1: cmp eax, -1 ; if -1, there was an error
	jne END_IF1
		call User_DisplayErrorMsg
		call crlf
		jmp RETURN
	END_IF1:
	
	mov uPtr, eax
	INVOKE LoadUser, uPtr

RETURN:
	call WaitMsg
	popad
	ret
LoginScreen ENDP

SignupScreen PROC
	LOCAL username[MAX_NAME_LEN + 1]:BYTE, password[MAX_PW_LEN + 1]:BYTE
	pushad
	mov eax, 0

	mov ecx, MAX_NAME_LEN + 1
	lea edi, username
	REP STOSB

	mov ecx, MAX_PW_LEN + 1
	lea edi, password
	REP STOSB

	mov edx, offset usernamePrompt
	call WriteString
	lea edx, username
	mov ecx, MAX_NAME_LEN
	call ReadString
	_IF1:cmp eax, 0
	jne _ENDIF1
		mov edx, offset unameOrPwLenInvalid
		call  WriteString
		call crlf
		jmp RETURN
	_ENDIF1:

	mov edx, offset passwordPrompt
	call WriteString
	lea edx, password
	mov ecx, MAX_PW_LEN
	call ReadString
	_IF2:cmp eax, 0
	jne _ENDIF2
		mov edx, offset unameOrPwLenInvalid
		call  WriteString
		call crlf
		jmp RETURN
	_ENDIF2:

	INVOKE Signup, ADDR username, ADDR password
	_IF3: cmp eax, 0 ; if 0, there were no errors
	je END_IF3
		call User_DisplayErrorMsg
		call crlf
		jmp RETURN
	END_IF3:
	mov uPtr, eax

RETURN:
	call WaitMsg
	popad
	ret
SignupScreen ENDP

StartupMenu PROC
	push eax
	push edx
	
	WHILE1:
		mov edx, offset startupMenuOptions
		call WriteString
		call Readint
		_IF1: cmp eax, 1
		jne _ELSEIF1
			call ClrScr
			INVOKE LoginScreen
			jmp END_WHILE1 ; break
		jmp _ENDIF1
		_ELSEIF1: cmp eax, 2
		jne _ENDIF1
			call ClrScr
			INVOKE SignupScreen
			jmp END_WHILE1 ; break
		_ENDIF1:
		
		call writechar
		call crlf
		mov edx, offset incorrectChoice
		call WriteString
		call WaitMsg
		call ClrScr
	jmp WHILE1
	END_WHILE1:

RETURN:
	pop edx
	pop eax
	ret
StartupMenu ENDP

MainMenu PROC
	push eax
	push edx
	
	WHILE1: cmp [uPtr], 0
	je END_WHILE1
		call ClrScr
		mov edx, offset mainMenuOptions
		call WriteString
		call Readint

		SWITCH:
		CASE1: cmp eax, 1
		jne CASE2
			call Clrscr
			INVOKE DisplayUnfinished
			_IF1:cmp eax, 0
			je _ENDIF1
				INVOKE ToDo_DisplayErrorMsg
				call crlf
			_ENDIF1:
			jmp ENDSWITCH ; break
		CASE2: cmp eax, 2
		jne CASE3
			call Clrscr
			INVOKE DisplayCompleted
			_IF2:cmp eax, 0
			je _ENDIF1
				INVOKE ToDo_DisplayErrorMsg
				call crlf
			_ENDIF2:
			jmp ENDSWITCH ; break
		CASE3: cmp eax, 3
		jne CASE4
			call Clrscr
			INVOKE ToDoAddScreen
			jmp ENDSWITCH ; break
		CASE4: cmp eax, 4
		jne CASE5
			call Clrscr
			INVOKE MarkToDoAsDoneScreen
			jmp ENDSWITCH ; break
		CASE5: cmp eax, 5
		jne DEFAULT
			INVOKE UnloadUser
			mov uPtr, 0 ; log user out
			jmp ENDSWITCH ; exit
		DEFAULT:
			mov edx, offset incorrectChoice
			call WriteString
		ENDSWITCH:

		call WaitMsg

	jmp WHILE1
	END_WHILE1:

RETURN:
	pop edx
	pop eax
	ret
MainMenu ENDP

ToDoAddScreen PROC
	LOCAL desc[MAX_DESC_LEN + 1]:BYTE
	pushad

	mov eax, 0
	mov ecx, MAX_DESC_LEN + 1
	lea edi, desc
	REP STOSB

	mov edx, offset addToDoPrompt
	call WriteString
	lea edx, desc
	mov ecx, MAX_DESC_LEN
	call ReadString
	cmp eax, 0
	je RETURN

	INVOKE AddNew, ADDR desc
	_IF1: cmp eax, 0
	jne _ENDIF1
		INVOKE ToDo_DisplayErrorMsg
		jmp RETURN
	_ENDIF1:

RETURN:
	popad
	ret
ToDoAddScreen ENDP

MarkToDoAsDoneScreen PROC
	pushad

	mov edx, offset markToDoPrompt
	call WriteString
	call ReadDec

	INVOKE MarkAsDone, eax
	_IF1:cmp eax, 0
	je _ENDIF
		INVOKE ToDo_DisplayErrorMsg
		call crlf
		jmp RETURN
	_ENDIF:

RETURN:
	popad
	ret
MarkToDoAsDoneScreen ENDP

END