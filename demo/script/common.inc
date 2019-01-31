//2019/01/30 zadeh
//declare common variant of OCV app at here

type
  TMatRec = record
   idx: Integer;//index
   v1,v2,v3: Integer;//control bar value
  end;

var
  Mat1,Mat2,Mat3,Mat4,Mat5,Mat6:TMatRec;//declare 6 mat recond
  
procedure TestProc;
begin
  Writeln('Test Proc Called');
  {$IFDEF ERROR}
  Error!
  {$ENDIF}
end;  