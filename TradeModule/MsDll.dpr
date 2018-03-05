library MsDll;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }



{$R 'SendMail.res' 'SendMail.rc'}

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Dm_TLB in '..\Comm\Dm_TLB.pas',
  HPSocketSDKUnit in '..\Comm\HPSocketSDKUnit.pas',
  SuperObject in '..\Comm\SuperObject.pas',
  uCommand in '..\Comm\uCommand.pas',
  uGlobal in '..\Comm\uGlobal.pas',
  uJsonClass in '..\Comm\uJsonClass.pas',
  uLogger in '..\Comm\uLogger.pas',
  uOrderInfo in '..\Comm\uOrderInfo.pas',
  ManSoy.Encode in '..\Global\ManSoy.Encode.pas',
  ManSoy.Global in '..\Global\ManSoy.Global.pas',
  ManSoy.IniFiles in '..\Global\ManSoy.IniFiles.pas',
  ManSoy.MsgBox in '..\Global\ManSoy.MsgBox.pas',
  VerySimple.Lua.Lib in '..\Lua\VerySimple.Lua.Lib.pas',
  VerySimple.Lua in '..\Lua\VerySimple.Lua.pas',
  uCommFuns in '..\Comm\uCommFuns.pas',
  uAutoSend in 'uAutoSend.pas',
  uFrmLogs in 'uFrmLogs.pas' {FrmLogs},
  uTradeClient in 'uTradeClient.pas',
  HideModuleUnit in '..\Comm\HideModuleUnit.pas',
  uLuaFuns in '..\Comm\uLuaFuns.pas',
  uMsVpn in '..\Comm\uMsVpn.pas',
  uMemLoadLibrary in '..\Comm\uMemLoadLibrary.pas',
  VMProtectSDK in '..\Comm\VMProtectSDK.pas',
  uWinIO in '..\Comm\uWinIO.pas';

{$R *.res}

var
  hHk:HHOOK=0;
  hThread:Cardinal;

procedure DelayThread(P: Pointer); stdcall;
begin
  Sleep(3000);
  if FrmLogs = nil then
  begin
    DebugInf('MS - ������־����', []);
    FrmLogs := TFrmLogs.Create(Application);
  end;
  DebugInf('MS - ��ʾ��־����', []);
  FrmLogs.Show;
  DebugInf('MS - ��־������ʾ���', []);
end;

function HookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  //----
  if hThread = 0 then
  begin
    DebugInf('MS - HookProc 2', []);
    ManSoy.Global.DebugInf('MS - ������, �ȴ����ᱬ����!', []);
    DebugInf('MS - HookProc 3', []);
    hThread := 1; //CreateThread(nil, 0, @DelayThread, nil, 0, dwTID);
  end;
  Result := CallNextHookEx(hHk, nCode, wParam, lParam);
end;

procedure DLLEntryPoint(dwReason : DWord);
var
  szFileName: array[0..255] of Char;
begin
  case dwReason of
    DLL_PROCESS_ATTACH :
    begin
      ManSoy.Global.DebugInf('MS - ӳ�䵽���̵�ַ�ռ�', []);
      GetModuleFileName(HInstance, szFileName, 255);
      ManSoy.Global.DebugInf('MS - �������� %s', [string(szFileName)]);
      ManSoy.Global.DebugInf('MS - �������� %s', [string(GetProcessName(GetCurrentProcessId))]);
      if GetProcessName(GetCurrentProcessId) = 'WinRAR.exe' then
      begin
        if FrmLogs = nil then
        begin
          DebugInf('MS - ������־����', []);
          FrmLogs := TFrmLogs.Create(Application);
        end;
        DebugInf('MS - ��ʾ��־����', []);
        FrmLogs.Show;
        DebugInf('MS - ��־������ʾ���', []);
      end;
    end;
    DLL_PROCESS_DETACH : {ManSoy.Global.DebugInf('MS - �ӽ��̵ĵ�ַ�ռ�������', [])};
    DLL_THREAD_ATTACH :  {ManSoy.Global.DebugInf('MS - ������һ�����߳�', [])};
    DLL_THREAD_DETACH : {ManSoy.Global.DebugInf('MS - һ���߳������˳�', [])};
  end;
end;

procedure MyEntry;
begin
  DebugInf('MS - ��־������ʾ���', []);
end;

exports
   MyEntry;

begin
  HideModule(GetModuleHandle('dm.dll'));
  {���ȣ���һ�����̵�ָ�븳��DLLProc����}
  DLLProc := @DLLEntryPoint;
  {�����������}
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.
