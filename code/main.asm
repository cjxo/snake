ExitProcess proto
MessageBoxA proto
RegisterClassA proto
GetModuleHandleA proto
LoadIconA proto
LoadCursorA proto
GetStockObject proto
CreateWindowExA proto
DefWindowProcA proto
DestroyWindow proto
PostQuitMessage proto
GetLastError proto
ShowWindow proto
PeekMessageA proto
SetProcessDPIAware proto
TranslateMessage proto
DispatchMessageA proto
AdjustWindowRect proto

.const
w32_class_name byte "snake_asm_window_class", 0
w32_window_name byte "snake", 0
w32_window_width dword 720
w32_window_height dword 1280

.data?
w32_window_handle qword ?

.code
WinMainCRTStartup proc
    ; WNDCLASS Struct: 72 bytes
    ; 4 more Local Vars: 32 bytes
    ; 8 more params for CreateWindowExA: 64 bytes
    ; 4 registers: 32 bytes
    ; 72 + 32 + 64 + 32 = 200 bytes
    sub rsp, 200
    
    call SetProcessDPIAware
    
    mov ecx, 4
    call GetStockObject
    mov qword ptr [rsp + 120], rax
    
    xor rcx, rcx
    mov edx, 32512
    call LoadIconA
    mov qword ptr [rsp + 112], rax
    
    xor rcx, rcx
    mov edx, 32512
    call LoadCursorA
    mov qword ptr [rsp + 104], rax

    xor rcx, rcx
    call GetModuleHandleA
    mov qword ptr [rsp + 96], rax
    
    lea rcx, [rsp + 128]                      ; WNDCLASS into rcx
    
    mov dword ptr [rcx + 0], 23h              ; style = CS_HREDRAW | CS_OWNDC | CS_VREDRAW;

    lea rax, [WindowProc]
    mov qword ptr [rcx + 8], rax              ; lpfnWndProc = WindowProc;
    
    mov dword ptr [rcx + 16], 0               ; WindowClass.cbClsExtra = 0;
    mov dword ptr [rcx + 20], 0               ; WindowClass.cbClsExtra = 0;
    
    mov rax, qword ptr [rsp + 96]
    mov qword ptr [rcx + 24], rax             ; WindowClass.hInstance = ModuleInstance;
    
    mov rax, qword ptr [rsp + 112]
    mov qword ptr [rcx + 32], rax             ; WindowClass.hIcon = LoadIcon(0, MAKEINTRESOURCE(32512));
    
    mov rax, qword ptr [rsp + 104]
    mov qword ptr [rcx + 40], rax             ; WindowClass.hCursor = LoadCursor(0, MAKEINTRESOURCE(32512));

    mov rax, qword ptr [rsp + 120]
    mov qword ptr [rcx + 48], rax             ; WindowClass.hbrBackground = GetStockObject(BLACK_BRUSH);
    
    mov qword ptr [rcx + 56], 0               ; WindowClass.lpszMenuName = 0;
    
    lea rax, w32_class_name
    mov qword ptr [rcx + 64], rax             ; WindowClass.lpszClassName = WindowClassName;
    
    call RegisterClassA
    
    lea rcx, [rsp + 128]
    mov dword ptr [rcx + 0], 0
    mov dword ptr [rcx + 4], 0
    mov dword ptr [rcx + 8], 1280
    mov dword ptr [rcx + 12], 720
    mov edx, 0cf0000h
    xor r8d, r8d
    call AdjustWindowRect
    
    mov eax, dword ptr [rsp + 128]
    sub dword ptr [rsp + 136], eax
    mov eax, dword ptr [rsp + 132]
    sub dword ptr [rsp + 140], eax
    
    xor ecx, ecx
    lea rdx, w32_class_name
    lea r8, w32_window_name
    mov r9d, 0cf0000h
    mov dword ptr [rsp + 32], 0
    mov dword ptr [rsp + 40], 0
    mov eax, dword ptr [rsp + 136]
    mov dword ptr [rsp + 48], eax
    mov eax, dword ptr [rsp + 140]
    mov dword ptr [rsp + 56], eax
    mov qword ptr [rsp + 64], 0
    mov qword ptr [rsp + 72], 0
    mov rax, qword ptr [rsp + 96]
    mov qword ptr [rsp + 80], rax
    mov qword ptr [rsp + 88], 0
    call CreateWindowExA
    mov w32_window_handle, rax
    
    mov rcx, rax
    mov edx, 5
    call ShowWindow
    
EntryApp_Loop:
EntryApp_PeekMessage:
    mov dword ptr [rsp + 32], 1    ; PM_REMOVE
    xor r9, r9                    ; wMsgFilterMax = 0
    xor r8, r8                    ; wMsgFilterMin = 0
    xor rdx, rdx                  ; NULL hWnd
    lea rcx, [rsp + 40]           ; MSG struct
    call PeekMessageA
    test eax, eax
    jz EntryApp_DoWork
    
    lea rcx, [rsp + 40]           ; MSG struct
    call TranslateMessage
    lea rcx, [rsp + 40]           ; MSG struct
    call DispatchMessageA
    jmp EntryApp_PeekMessage
    
EntryApp_DoWork:
    jmp EntryApp_Loop
    
    xor rcx, rcx
    call ExitProcess
WinMainCRTStartup endp

WindowProc proc 
    sub rsp, 40
    
    cmp edx, 010h
    je WindowProc_WM_CLOSE
    
    cmp edx, 02h
    je WindowProc_WM_DESTROY
    
    call DefWindowProcA
    jmp WindowProc_Done
    
WindowProc_WM_CLOSE:
    call DestroyWindow
    jmp WindowProc_Done
    
WindowProc_WM_DESTROY:
    mov ecx, 0
    call ExitProcess
    jmp WindowProc_Done
    
WindowProc_Done:
    add rsp, 40
    ret
WindowProc endp

end
