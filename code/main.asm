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
timeBeginPeriod proto
QueryPerformanceFrequency proto
QueryPerformanceCounter proto
Sleep proto
VirtualAlloc proto
GetDC proto
StretchDIBits proto

.const
w32_class_name byte "snake_asm_window_class", 0
w32_window_name byte "snake", 0
w32_window_width dword 1280
w32_window_height dword 720

.data?
WindowHandle qword ?
PerformanceFreq qword ?
MSPerFrame qword ?
RPixels qword ?
RBackBufferWidth dword ?
RBackBufferHeight dword ?
RBackBufferBPP dword ?

.code
WinMainCRTStartup proc
    ; WNDCLASS Struct: 72 bytes
    ; 4 more Local Vars: 32 bytes
    ; 8 more params for CreateWindowExA: 64 bytes
    ; 4 registers: 32 bytes
    ; 72 + 32 + 64 + 32 = 200 bytes
    sub rsp, 216
    
    call SetProcessDPIAware
    
    mov ecx, 1
    call timeBeginPeriod
    
    lea rcx, PerformanceFreq
    call QueryPerformanceFrequency

    mov rax, 1000
    xor rdx, rdx
    mov rcx, 60
    div rcx
    mov qword ptr [MSPerFrame], rax
    
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
    mov WindowHandle, rax
    
    mov rcx, rax
    mov edx, 5
    call ShowWindow

    mov rcx, 0
    mov rdx, 3686400
    mov r8d, 12288
    mov r9d, 4
    call VirtualAlloc
    mov qword ptr [RPixels], rax

    mov dword ptr [RBackBufferWidth], 1280
    mov dword ptr [RBackBufferHeight], 720
    mov dword ptr [RBackBufferBPP], 4
    
    ; at this point, we have
    ; MSG struct located at (rsp + 64) -> (rsp + 112)
    ; LARGE_INTEGER located at (rsp + 112) -> (rsp + 120) - the start performance count
    ; LARGE_INTEGER located at (rsp + 120) -> (rsp + 128)
    ; BITMAPINFO located at (rsp + 128) -> (rsp + 172)
    
    lea rcx, [rsp + 112]
    call QueryPerformanceCounter

EntryApp_Loop:
    ; Collect Some User Input
EntryApp_PeekMessage:
    mov dword ptr [rsp + 32], 1   ; PM_REMOVE
    xor r9, r9                    ; wMsgFilterMax = 0
    xor r8, r8                    ; wMsgFilterMin = 0
    xor rdx, rdx                  ; NULL hWnd
    lea rcx, [rsp + 64]           ; MSG struct
    call PeekMessageA
    test eax, eax
    jz EntryApp_DoWork
    
    lea rcx, [rsp + 64]
    call TranslateMessage
    lea rcx, [rsp + 64]
    call DispatchMessageA
    jmp EntryApp_PeekMessage
    
EntryApp_DoWork:
    ; Game Update And Render Work
    mov ecx, 0
    mov edx, 0
    mov r8, RPixels
    mov r9d, dword ptr [RBackBufferWidth]
    ; is this necessary?
    xor rax, rax
    mov eax, dword ptr [RBackBufferBPP]
    mul r9d
    mov r10, rax
loop_y:
    mov r9, r8
loop_x:
    mov byte ptr [r9 + 0], cl
    mov byte ptr [r9 + 1], dl
    mov byte ptr [r9 + 2], 0
    mov byte ptr [r9 + 3], 0ffh
    mov eax, dword ptr [RBackBufferBPP]
    add r9, rax
loop_x_test:
    inc edx
    cmp edx, dword ptr [RBackBufferWidth] 
    jnae loop_x

    add r8, r10
    xor edx, edx
loop_y_test:
    inc ecx
    cmp ecx, dword ptr [RBackBufferHeight]
    jnae loop_y
    
    ; update screen and clear
    mov rcx, WindowHandle
    call GetDC

    mov rcx, rax
    xor edx, edx
    xor r8d, r8d
    mov r9d, dword ptr [w32_window_width]
    mov eax, dword ptr [w32_window_height]
    mov dword ptr [rsp + 32], eax
    mov dword ptr [rsp + 40], 0
    mov dword ptr [rsp + 48], 0
    mov eax, dword ptr [RBackBufferWidth]
    mov dword ptr [rsp + 56], eax
    mov eax, dword ptr [RBackBufferHeight]
    mov dword ptr [rsp + 64], eax
    mov rax, qword ptr [RPixels]
    mov qword ptr [rsp + 72], rax

    mov dword ptr [rsp + 128], 40
    mov eax, dword ptr [RBackBufferWidth]
    mov dword ptr [rsp + 132], eax
    mov eax, dword ptr [RBackBufferHeight]
    neg eax
    mov dword ptr [rsp + 136], eax
    mov word ptr [rsp + 140], 1
    mov eax, dword ptr [RBackBufferBPP]
    shl ax, 3
    mov word ptr [rsp + 142], ax
    mov dword ptr [rsp + 144], 0
    mov dword ptr [rsp + 148], 0
    mov dword ptr [rsp + 152], 0
    mov dword ptr [rsp + 156], 0
    mov dword ptr [rsp + 160], 0
    mov dword ptr [rsp + 164], 0
    lea rax, [rsp + 128]
    mov qword ptr [rsp + 80], rax
    mov dword ptr [rsp + 88], 0
    mov dword ptr [rsp + 96], 00CC0020h
    call StretchDIBits

    ; Cap FPS
    lea rcx, [rsp + 120]
    call QueryPerformanceCounter
    mov rax, qword ptr [rsp + 120]  ; end count
    sub rax, qword ptr [rsp + 112]  ; end count - start count
    mov rcx, 1000
    mul rcx                         ; (end count - start count) * 1000ms
    div qword ptr [PerformanceFreq] ; ((end count - start count) * 1000) / CountsPerSecond
    cmp rax, qword ptr [MSPerFrame] 
    jge EntryApp_NewLoop            ; rax >= MSPerFrame
    mov rcx, [MSPerFrame]           ; if rax < MSPerFrame, then rcx = MSPerFrame
    sub rcx, rax                    ; rcx = rcx - rax
    call Sleep                      ; Sleep(rcx = MSPerFrame - rax as DWORD)

EntryApp_NewLoop:
    lea rcx, [rsp + 112]
    call QueryPerformanceCounter
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
