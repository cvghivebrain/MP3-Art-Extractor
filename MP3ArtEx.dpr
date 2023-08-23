program PMP3ArtEx;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  FileFunc in 'FileFunc.pas';

var
  i, n: integer;

begin
  { Program start }

  if ParamCount < 1 then // Check if program was run with parameters.
    begin
    WriteLn('Usage: mp3artex {mp3file}');
    exit;
    end;

  LoadFile(ParamStr(1)); // Load MP3 file to memory.
  n := 0;
  for i := 0 to fs-4 do
    begin
    if (GetString(i,4) = 'APIC') and (GetString(i+$B,10) = 'image/jpeg') then
      begin
      ClipFile(i+$18,GetDword(i+4)-$E,'image'+IntToStr(n)+'.jpg'); // Export JPEG.
      Inc(n);
      end;
    end;
end.