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

procedure GetAPIC(a: integer; mime, ext: string); // Extract image from APIC frame.
begin
  ClipFile(a+$E+Length(mime),GetDword(a+4)-4-Length(mime),outfolder+'image.'+IntToStrPad(n,3)+'.'+ext);
  Inc(n); // Next output file number.
end;

procedure GetFLAC(a: integer; mime, ext: string); // Extract image from FLAC block.
begin
  ClipFile(a+$18+Length(mime),GetDword(a+$14+Length(mime)),outfolder+'image.'+IntToStrPad(n,3)+'.'+ext);
  Inc(n); // Next output file number.
end;

procedure GetOGG(mime, ext: string); // Extract image from OGG metadata.
begin
  ClipFileOutput($20+Length(mime),GetDword($1C+Length(mime)),outfolder+'image.'+IntToStrPad(n,3)+'.'+ext);
  Inc(n); // Next output file number.
end;

begin
  { Program start }

  if ParamCount < 1 then // Check if program was run with parameters.
    begin
    WriteLn('Usage: mp3artex file.mp3 [outputfolder]');
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
  if GetString(0,3) = 'ID3' then
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
  if GetString(0,4) = 'fLaC' then
    for i := 0 to fs-6 do
      begin
      if (GetString(i,6) = 'image/') then
        begin
        if GetString(i,10) = 'image/jpeg' then GetFLAC(i,'image/jpeg','jpg')
        else if GetString(i,10) = 'image/webp' then GetFLAC(i,'image/webp','webp')
        else if GetString(i,9) = 'image/bmp' then GetFLAC(i,'image/bmp','bmp')
        else if GetString(i,9) = 'image/png' then GetFLAC(i,'image/png','png')
        else if GetString(i,9) = 'image/tif' then GetFLAC(i,'image/tif','tiff')
        else if GetString(i,9) = 'image/gif' then GetFLAC(i,'image/gif','gif');
        end;
      end;
  if GetString(0,4) = 'OggS' then
    for i := 0 to fs-$17 do
      begin
      if (GetString(i,$17) = 'METADATA_BLOCK_PICTURE=') then
        begin
        NewFileOutput(0); // Clear output file array.
        GetBase64(i+$17,0); // Read base64 data.
        if GetStringOutput(8,10) = 'image/jpeg' then GetOGG('image/jpeg','jpg')
        else if GetStringOutput(8,10) = 'image/webp' then GetOGG('image/webp','webp')
        else if GetStringOutput(8,9) = 'image/bmp' then GetOGG('image/bmp','bmp')
        else if GetStringOutput(8,9) = 'image/png' then GetOGG('image/png','png')
        else if GetStringOutput(8,9) = 'image/tif' then GetOGG('image/tif','tiff')
        else if GetStringOutput(8,9) = 'image/gif' then GetOGG('image/gif','gif')
        else
          begin
          SaveFileOutput(outfolder+'image.'+IntToStrPad(n,3)+'.bin'); // Save output file as raw.
          Inc(n);
          end;
        end;
      end;
end.