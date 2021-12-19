INCLUDE irvine32.inc
INCLUDE FileHandling.inc

.code
AppendFile PROC, filename:PTR BYTE, data:PTR BYTE, len:DWORD
	LOCAL filehandle:HANDLE, numWritten:DWORD, err:DWORD
	pushad
	mov err, 0

	INVOKE CreateFile, 
		filename, GENERIC_WRITE, DO_NOT_SHARE, NULL, 
		OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0

	_IF1:cmp eax, INVALID_HANDLE_VALUE
	jne END_IF1
		mov err, -1
		INVOKE CreateFile, 
			filename, GENERIC_WRITE, DO_NOT_SHARE, NULL, 
			OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
		cmp eax, INVALID_HANDLE_VALUE
		je RETURN
		mov err, 0
	END_IF1:

	mov filehandle, eax

	INVOKE SetFilePointer, filehandle, 0, 0, FILE_END
	_IF2: cmp eax, INVALID_HANDLE_VALUE
	jne END_IF2
		mov err, eax
		jmp RETURN
	END_IF2:

	INVOKE WriteFile, filehandle, data, len, ADDR numWritten, NULL
	_IF3: cmp eax, INVALID_HANDLE_VALUE
	jne END_IF3
		mov err, eax
		jmp RETURN
	END_IF3:

	INVOKE CloseHandle, filehandle
	_IF4: cmp eax, INVALID_HANDLE_VALUE
	jne END_IF4
		mov err, eax
		jmp RETURN
	END_IF4:

RETURN:
	popad
	mov eax, err
	ret
AppendFile ENDP

SearchFile PROC, filename:PTr BYTE, data:PTR BYTE, len:DWORD
	LOCAL filehandle:HANDLE, numRead:DWORD, err:DWORD
	pushad
	mov err, 0

	INVOKE CreateFile,
		filename, GENERIC_READ, DO_NOT_SHARE, NULL,
		OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0

	_IF1:cmp eax, INVALID_HANDLE_VALUE
	jne END_IF1
		mov err, eax
		jmp RETURN
	END_IF1:

	WHILE1: ; while true
		
		;INVOKE ReadFile, filehandle, 
		_IF2:
			
		END_IF2:

	END_WHILE1:

RETURN:
	popad
	mov eax, err
	ret
SearchFile ENDP

END