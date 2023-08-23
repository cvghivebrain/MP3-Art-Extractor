program PMP3ArtEx;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  FileFunc in 'FileFunc.pas';

var
  i, n: integer;
  outfolder: string;

function IntToStrPad(i, minlen: integer): string; // Integer to string with leading 0s.
begin
  result := IntToStr(i);
  while Length(result) < minlen do result := '0'+result; // Add leading 0s.
end;

procedure GetAPIC(a: integer; mime, ext: string); // Extract image from APIC section.
begin
  ClipFile(a+$E+Length(mime),GetDword(a+4)-4-Length(mime),outfolder+'image.'+IntToStrPad(n,3)+'.'+ext);
  Inc(n); // Next output file number.
end;

begin
  { Program start }

  if ParamCount < 1 then // Check if program was run with parameters.
    begin
    WriteLn('Usage: mp3artex {mp3file}');
    exit;
    end;
  outfolder := ParamStr(2);
  if outfolder <> '' then
    begin
    if not DirectoryExists(outfolder) then CreateDir(outfolder); // Create output folder if needed.
    outfolder := outfolder+'\'; // Append backslash.
    end;

  LoadFile(ParamStr(1)); // Load MP3 file to memory.
  n := 0; // Start numbering at 0.
  for i := 0 to fs-4 do
    begin
    if (GetString(i,4) = 'APIC') then
      begin
      if GetString(i+$B,10) = 'image/jpeg' then GetAPIC(i,'image/jpeg','jpg')
      else if GetString(i+$B,10) = 'image/webp' then GetAPIC(i,'image/webp','webp')
      else if GetString(i+$B,9) = 'image/bmp' then GetAPIC(i,'image/bmp','bmp')
      else if GetString(i+$B,9) = 'image/png' then GetAPIC(i,'image/png','png')
      else if GetString(i+$B,9) = 'image/tif' then GetAPIC(i,'image/tif','tiff')
      else if GetString(i+$B,9) = 'image/gif' then GetAPIC(i,'image/gif','gif');
      end;
    end;
end.