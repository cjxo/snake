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
GGridData dword 256 dup(?)

.code
    ; rcx - mem
    ; rdx - size
ClearMemory proc
    xor r8, r8
    jmp loop_clear_test
loop_clear:
    mov byte ptr [rcx], 0
    inc r8
    inc rcx
loop_clear_test:
    cmp r8, rdx
    jnae loop_clear
    ret
ClearMemory endp

; all signed, but colouru32 is unsigned
; ecx - x
; edx - y
; r8d - w
; r9d - h
; colouru32
FillRectangle proc
    sub rsp, 40

    mov eax, dword ptr [RBackBufferWidth]
    ;dec eax
    mov dword ptr [rsp + 0], eax

    mov eax, dword ptr [RBackBufferHeight]
    ;dec eax
    mov dword ptr [rsp + 4], eax

    add r8d, ecx ; EndX
    add r9d, edx ; EndY

    xor rax, rax
    ; if StartX < 0, StartX = 0
    cmp ecx, 0
    cmovl ecx, eax
    ; if StartX > OneMinusMaxWidth, StartX = OneMinusMaxWidth
    cmp ecx, dword ptr [rsp + 0]
    cmovnle ecx, dword ptr [rsp + 0]

    ; if StartY < 0, StartY = 0
    cmp edx, 0
    cmovl edx, eax
    ; if StartY > OneMinusMaxHeight, StartY = OneMinusMaxHeight
    cmp edx, dword ptr [rsp + 4]
    cmovnle edx, dword ptr [rsp + 4]

    ; if EndX < 0, EndX = 0
    cmp r8d, 0
    cmovl r8d, r8d
    ; if EndX > OneMinusMaxWidth, EndX = OneMinusMaxWidth
    cmp r8d, dword ptr [rsp + 0]
    cmovnle r8d, dword ptr [rsp + 0]

    ; if EndY < 0, EndY = 0
    cmp r9d, 0
    cmovl r9d, eax
    ; if EndY > OneMinusMaxHeight, EndY = OneMinusMaxHeight
    cmp r9d, dword ptr [rsp + 4]
    cmovnle r9d, dword ptr [rsp + 4]

    ; Double Loop Counts
    sub r8d, ecx
    sub r9d, edx

	cmp r8d, 0
	jle done
	cmp r9d, 0
	jle done

    mov dword ptr [rsp + 8], r8d

    mov eax, [rsp + 80]
    mov byte ptr [rsp + 12], al
    shr eax, 8
    mov byte ptr [rsp + 13], al
    shr eax, 8
    mov byte ptr [rsp + 14], al
    shr eax, 8
    mov byte ptr [rsp + 15], al

    mov eax, dword ptr [RBackBufferWidth]
    mul edx
    add eax, ecx
    mul dword ptr [RBackBufferBPP]
    mov rcx, RPixels
    add rcx, rax

    mov eax, dword ptr [RBackBufferWidth]
    mul dword ptr [RBackBufferBPP]
    mov rdx, rax

    jmp draw_rect_loop_y_test
draw_rect_loop_y:
    mov rax, rcx
    dec r9d
    jmp draw_rect_loop_x_test
draw_rect_loop_x:
    mov r10b, byte ptr [rsp + 12]
    mov byte ptr [rax + 3], r10b
    mov r10b, byte ptr [rsp + 13]
    mov byte ptr [rax + 2], r10b
    mov r10b, byte ptr [rsp + 14]
    mov byte ptr [rax + 1], r10b
    mov r10b, byte ptr [rsp + 15]
    mov byte ptr [rax + 0], r10b
    add rax, 4
    dec r8d
draw_rect_loop_x_test:
    cmp r8d, 0
    jg draw_rect_loop_x
    mov r8d, dword ptr [rsp + 8]
    add rcx, rdx
draw_rect_loop_y_test:
    cmp r9d, 0
    jg draw_rect_loop_y

done:
    add rsp, 40
    ret
FillRectangle endp

; all signed, but colouru32 is unsigned
; ecx - x
; edx - y
; r8d - w
; r9d - h
; colouru32
; Very sure this can be improved immensely, this function looks so bad. Embarrassing
WireRectangle proc
    sub rsp, 40

    mov eax, dword ptr [RBackBufferWidth]
;    dec eax
    mov dword ptr [rsp + 0], eax

    mov eax, dword ptr [RBackBufferHeight]
;    dec eax
    mov dword ptr [rsp + 4], eax

    add r8d, ecx ; EndX
    add r9d, edx ; EndY

    xor rax, rax
    ; if StartX < 0, StartX = 0
    cmp ecx, 0
    cmovl ecx, eax
    ; if StartX > OneMinusMaxWidth, StartX = OneMinusMaxWidth
    cmp ecx, dword ptr [rsp + 0]
    cmovnle ecx, dword ptr [rsp + 0]

    ; if StartY < 0, StartY = 0
    cmp edx, 0
    cmovl edx, eax
    ; if StartY > OneMinusMaxHeight, StartY = OneMinusMaxHeight
    cmp edx, dword ptr [rsp + 4]
    cmovnle edx, dword ptr [rsp + 4]

    ; if EndX < 0, EndX = 0
    cmp r8d, 0
    cmovl r8d, r8d
    ; if EndX > OneMinusMaxWidth, EndX = OneMinusMaxWidth
    cmp r8d, dword ptr [rsp + 0]
    cmovnle r8d, dword ptr [rsp + 0]

    ; if EndY < 0, EndY = 0
    cmp r9d, 0
    cmovl r9d, eax
    ; if EndY > OneMinusMaxHeight, EndY = OneMinusMaxHeight
    cmp r9d, dword ptr [rsp + 4]
    cmovnle r9d, dword ptr [rsp + 4]

    ; Double Loop Counts
    sub r8d, ecx
    sub r9d, edx

	cmp r8d, 0
	jle done
	cmp r9d, 0
	jle done

    mov dword ptr [rsp + 8], r8d
    mov dword ptr [rsp + 16], r9d
    mov dword ptr [rsp + 20], ecx
    mov dword ptr [rsp + 24], edx

    mov eax, dword ptr [RBackBufferWidth]
    mul dword ptr [rsp + 24]
    add eax, dword ptr [rsp + 20]
    mul dword ptr [RBackBufferBPP]
    add rax, RPixels
    mov qword ptr [rsp + 28], rax

    mov eax, [rsp + 80]
    mov byte ptr [rsp + 12], al
    shr eax, 8
    mov byte ptr [rsp + 13], al
    shr eax, 8
    mov byte ptr [rsp + 14], al
    shr eax, 8
    mov byte ptr [rsp + 15], al

    mov eax, dword ptr [RBackBufferWidth]
    mul dword ptr [RBackBufferBPP] 
    mov r9, rax

    mov rax, qword ptr [rsp + 28]
    jmp loop_hori_upper_test
loop_hori_upper:
    mov r10b, byte ptr [rsp + 12]
    mov byte ptr [rax + 3], r10b
    mov r10b, byte ptr [rsp + 13]
    mov byte ptr [rax + 2], r10b
    mov r10b, byte ptr [rsp + 14]
    mov byte ptr [rax + 1], r10b
    mov r10b, byte ptr [rsp + 15]
    mov byte ptr [rax + 0], r10b
    add rax, 4
    dec r8d
loop_hori_upper_test:
    cmp r8d, 0
    jg loop_hori_upper

    mov rax, qword ptr [rsp + 28]
    mov r8d, dword ptr [rsp + 16]
    jmp loop_vert_left_test
loop_vert_left:
    mov r10b, byte ptr [rsp + 12]
    mov byte ptr [rax + 3], r10b
    mov r10b, byte ptr [rsp + 13]
    mov byte ptr [rax + 2], r10b
    mov r10b, byte ptr [rsp + 14]
    mov byte ptr [rax + 1], r10b
    mov r10b, byte ptr [rsp + 15]
    mov byte ptr [rax + 0], r10b
    add rax, r9
    dec r8d
loop_vert_left_test:
    cmp r8d, 0
    jg loop_vert_left

    mov r8, qword ptr [rsp + 28]
    mov eax, dword ptr [rsp + 8]
    dec eax
    mul dword ptr [RBackBufferBPP]
    add rax, r8

    mov r8d, dword ptr [rsp + 16]
    jmp loop_vert_right_test
loop_vert_right:
    mov r10b, byte ptr [rsp + 12]
    mov byte ptr [rax + 3], r10b
    mov r10b, byte ptr [rsp + 13]
    mov byte ptr [rax + 2], r10b
    mov r10b, byte ptr [rsp + 14]
    mov byte ptr [rax + 1], r10b
    mov r10b, byte ptr [rsp + 15]
    mov byte ptr [rax + 0], r10b
    add rax, r9
    dec r8d
loop_vert_right_test:
    cmp r8d, 0
    jg loop_vert_right

    mov eax, dword ptr [rsp + 16]
    dec eax
    mul r9d
    mov r9, rax

    mov rax, qword ptr [rsp + 28]
    add rax, r9

    mov r8d, dword ptr [rsp + 8]
    jmp loop_hori_lower_test
loop_hori_lower:
    mov r10b, byte ptr [rsp + 12]
    mov byte ptr [rax + 3], r10b
    mov r10b, byte ptr [rsp + 13]
    mov byte ptr [rax + 2], r10b
    mov r10b, byte ptr [rsp + 14]
    mov byte ptr [rax + 1], r10b
    mov r10b, byte ptr [rsp + 15]
    mov byte ptr [rax + 0], r10b
    add rax, 4
    dec r8d
loop_hori_lower_test:
    cmp r8d, 0
    jg loop_hori_lower

done:
    add rsp, 40
    ret
WireRectangle endp

; rcx - x,
; rdx - y,
; r8d - colourU32
DrawSquare proc
    sub rsp, 56
    
    mov dword ptr [rsp + 40], ecx
    mov dword ptr [rsp + 44], edx
    mov dword ptr [rsp + 48], r8d

    mov r8d, 40
    mov r9d, 40
    mov eax, dword ptr [rsp + 48]
    mov dword ptr [rsp + 32], eax
    call WireRectangle
   
    mov eax, dword ptr [rsp + 48]
    mov ecx, dword ptr [rsp + 40]
    mov edx, dword ptr [rsp + 44]
	add ecx, 4
	add edx, 4
    mov r8d, 32
    mov r9d, 32
    mov dword ptr [rsp + 32], eax
    call FillRectangle

    add rsp, 56
    ret
DrawSquare endp

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
    ; Draw Grid

    mov dword ptr [rsp + 128], 0
    jmp draw_grid_y_test
draw_grid_y:
    mov dword ptr [rsp + 132], 0
	jmp draw_grid_x_test
draw_grid_x:
    mov eax, dword ptr [rsp + 132]
    mov ecx, 40
    mul ecx
    mov ecx, eax
    mov eax, 4
    mul dword ptr [rsp + 132]
    add ecx, eax

    mov eax, dword ptr [rsp + 128]
    mov r9d, 40
    mul r9d
    mov r9d, eax
    mov eax, 4
    mul dword ptr [rsp + 128]
    add r9d, eax
    mov edx, r9d

    mov r8d, 0324032ffh
    call DrawSquare

    inc dword ptr [rsp + 132]
draw_grid_x_test:
    cmp dword ptr [rsp + 132], 16
    jl draw_grid_x
    inc dword ptr [rsp + 128]
draw_grid_y_test:
    cmp dword ptr [rsp + 128], 16
    jl draw_grid_y

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

    mov rcx, RPixels
    mov eax, dword ptr [RBackBufferWidth]
    mul dword ptr [RBackBufferHeight]
    mul dword ptr [RBackBufferBPP]
    mov rdx, rax
    call ClearMemory

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
