  // bottom scratches eliminated at line ~1160?
unit PATCHnSCRATCH;

interface

uses
  Winapi.Windows,
   Winapi.Messages,
    System.SysUtils,
     System.Variants,
      System.Classes,
       Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
   Vcl.ExtDlgs,
    Vcl.Menus,
     Vcl.StdCtrls,
     strutils,
     Vcl.ComCtrls,

  VclTee.TeeGDIPlus,
  VCLTee.TeEngine,
  Vcl.ExtCtrls,
  VCLTee.TeeProcs,
  VCLTee.Chart,
  VCLTee.Series,
  System.Generics.Collections,
  ClipBrd, shellapi,

  Vcl.Imaging.jpeg, VCLTee.TeCanvas, Vcl.Buttons;
type
  TPatch = class(TForm)
    MainMenu1: TMainMenu;
    file1: TMenuItem;
    ncfile: TFileOpenDialog;
    ncfile1: TMenuItem;
    gcodelist: TRichEdit;
    Chart1: TChart;
    clearlist: TButton;
    clickpoint: TLabel;
    CLR2: TButton;
    Series3: TPointSeries;
    showcuts: TButton;
    Label2: TLabel;
    prev: TButton;
    next: TButton;
    CPBcpy: TButton;
    Patch: TButton;
    clrpatch: TButton;
    Series4: TPointSeries;
    Series5: TPointSeries;
    halt: TEdit;
    Series6: TPointSeries;
    OriginalZlab: TLabel;
    OrigZcut: TLabel;
    ModZlab: TLabel;
    ModZcut: TLabel;
    cutmod: TScrollBar;
    Panel1: TPanel;
    Series1: TLineSeries;
    Series2: TPointSeries;
    Jump: TButton;
    copyselect: TButton;
    ShowMarks: TCheckBox;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    Newdepth: TLabel;
    Series7: TLineSeries;
    Button1: TButton;
    Panel2: TPanel;
    savepatch: TButton;
    workfile: TSaveDialog;
    Remove: TButton;
    patch_list: TMemo;
    Panel3: TPanel;
    SpeedButton1: TSpeedButton;
    ReRoute: TButton;
    Panel4: TPanel;
    SpeedButton2: TSpeedButton;

    procedure ncfile1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function FormCharStr(occurence:integer;startchar,targ,qualifier:string):string;
    procedure Chart1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure clearlistClick(Sender: TObject);
     procedure plotpoint(whichseries:TChartSeries;idx:integer;isnull:boolean);
    procedure CLR2Click(Sender: TObject);
    procedure clickpointClick(Sender: TObject);
    procedure showcutsClick(Sender: TObject);
    procedure prevClick(Sender: TObject);
    procedure nextClick(Sender: TObject);
    procedure CPBcpyClick(Sender: TObject);
    procedure history(idx:integer);
    procedure PatchClick(Sender: TObject);
    function  within(index:integer;var gcidx:integer):boolean;
    procedure clrpatchClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function   out2in(index:integer):string;
    function  in2out(index:integer):string;
    procedure  moveleft(ix:integer);
    procedure  moveright(ix:integer);
    procedure  setlimits;
    function  Append_Gcode(prefix:string;x,y:real):string;
    procedure Chart1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);


   function  crosstop(index:integer;var x_edge_val:real):boolean;


   function  RightCross(index:integer;var y_edge_val:real):boolean;
   function  RightExit(index:integer;var y_edge_val:real):boolean;
   function  RightEntry(index:integer;var y_edge_val:real):boolean;

    function  cross_bottom(index:integer;var x_edge_val:real):boolean;

    function  left_entry(index:integer;var y_edge_val:real):boolean;
    function  left_eXIT(index:integer;var y_edge_val:real):boolean;

    function  cross_left(index:integer;var y_edge_val:real):boolean;

    procedure  show_edge_point(sindex,gindex:integer);
    procedure cutmodChange(Sender: TObject);



    procedure  addintro;
    procedure JumpClick(Sender: TObject);
    procedure copyselectClick(Sender: TObject);
    procedure ShowMarksClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Saverect;
    procedure cut0Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure savepatchClick(Sender: TObject);
    procedure RemoveClick(Sender: TObject);
    procedure patch_listDblClick(Sender: TObject);
    procedure patch_listClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ReRouteClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);

  private
    { Private declarations }


  public
    { Public declarations }
  end;





 const dumbnum:real=98765432.1;


var
  Patch: TPatch;


   ncf:textfile;


   sectioncount,
   crn_rect_ndx,
   gcodeindx,
   lastselectedline,
   numlines,
   segnums,
   numsegs,
   curnindex:integer;

 //pointswithin:array [0..65535] of integer;

// whichfunk:pmethod;

 cutmodtimeout:integer;

   whichfunk:pointer;

 originalzcut,modz,
x0,x1,y0,y1,
slope,
xmax,
xmin,
edge_y,

x_edge_point,
y_edge_point,

ymax,
ymin:real;

crnrect,
crnfilename,
crndirname,
lastioi,
lastinsidepoint,
insidepoint,
priorpoint,
feedXYstr,
feedZstr,
modz_string,
lastprefix,
curfix,
 trace:string;


     gc_entries,intro:  tstringlist;

   patchcodelist,rectlist:tstringlist;


  zup:string;
  keywait:char;
  crnseries:tchartseries;

  GC_VS_ser1,ser1_VS_GC: TDictionary<integer, integer>;

  const  ints = '0123456789'; zeepoz = '2.0000';
      diralfs ='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

implementation

{$R *.dfm}

procedure TPatch.FormClose(Sender: TObject; var Action: TCloseAction);
begin
        gc_entries.Free;
        intro.Free;
        GC_VS_ser1.Free;
        ser1_VS_GC.Free;
     //   segentries.free;
         patchcodelist.Free;
         rectlist.Free;
end;

procedure TPatch.FormCreate(Sender: TObject);
begin
         cutmodtimeout:=1;
         crn_rect_ndx:=-1;
         sectioncount:=0;
         series7.XValues.Order:=loNone;
           crndirname:='';
            FormatSettings.DateSeparator:='_';
            FormatSettings.TimeSeparator:='_';
         gc_entries:= TStringList.Create;
         gc_entries.CaseSensitive:=true;

         intro := TStringList.Create;
         intro .CaseSensitive:=true;

         patchcodelist:=TStringList.Create;
         patchcodelist.CaseSensitive:=true;
         patchcodelist.Duplicates:=dupIgnore;


         rectlist:=TStringList.Create;
         rectlist.CaseSensitive:=true;
         rectlist.Duplicates:=dupError;



         patch_list.Lines.Clear;
         lastselectedline:=-1;



        series1.XValues.Order:=loNone;
        series2.XValues.Order:=loNone;
        series1.coloreachpoint:=true;
        GC_VS_ser1:=  TDictionary<integer, integer>.Create;
        ser1_VS_GC:= TDictionary<integer, integer>.Create;
        zup:=zeepoz;
        clickpoint.Caption:='   ';
        gcodelist.Lines.Clear;

    //    chart1.BackImageMode:=pbmStretch;
end;


procedure TPatch.FormResize(Sender: TObject);
begin



  // cut0.Top:=  panel2.Height div 6;// +10;


end;

procedure TPatch.FormShow(Sender: TObject);
begin
      // if Paramstr(1)<>'' then ShowMessage(Paramstr(1));
end;

procedure TPatch.Chart1ClickSeries(Sender: TCustomChart;
Series: TChartSeries;
  ValueIndex: Integer;
  Button: TMouseButton;
  Shift: TShiftState;X, Y: Integer);



  var gcidx,
  xlo,
  xhi,
  ylo,
  yhi,
  ix:integer;

  tstr,
  xstr,
  ystr:string;

  zcut:real;

begin

        if chart1.Zoomed  then
     begin
            if (series=series1){ or  (series=series4)} then
            begin
              gcodelist.Lines.clear;
              series3.Clear;
              GC_VS_ser1.TryGetValue(valueindex,gcidx);      // series1 entry num vs tstringlist index
              clickpoint.Caption:=gc_entries[gcidx];
              curnindex:=gcidx;
              plotpoint(series3,gcidx,false);
              if curnindex<numlines-3 then
               history(curnindex);
          end;

              if (series=series6 )or (series=series5)  or (series=series3) then
              begin
                 gcodelist.Clear;
                  GC_VS_ser1.TryGetValue(valueindex,gcidx);

                 xstr:=  FloatToStrF(series.XValues[valueindex], ffNumber, 4, 4);
                 ystr:=  FloatToStrF(series.YValues[valueindex], ffNumber, 4, 4);



                if lastselectedline>=0 then
                   begin
                     tstr:= patch_list.Lines[lastselectedline];
                     delete(tstr,1,6);
                     patch_list.Lines[lastselectedline]:=tstr;

                   end;

                ix:=0;
                while    ( ix<=patch_list.Lines.Count-1)   and not
                          ( ( containsstr(patch_list.Lines[ix],xstr) ) and
                           ( containsstr(patch_list.Lines[ix],ystr) ))  do
                 inc(ix);

                      if  ix<=patch_list.Lines.Count-1 then

                       clickpoint.caption:=  patch_list.Lines[ix];
                       patch_list.Lines[ix]:='(--->)'+patch_list.Lines[ix];
                       lastselectedline:=ix;
                     //patchlist.set
              end;






    end;

   if button= mbright then

     if series=series7 then
         begin
        // remove.enabled:=true;
         gcodelist.Lines.Clear;
             with series do
             begin
                  crn_rect_ndx := valueindex div 5;
                  crnrect:= rectlist[crn_rect_ndx];

                    x0:=strtofloat(formcharstr(0,'ex0:',crnrect,ints+'.-'));
                    y0:=strtofloat(formcharstr(0,'why0:',crnrect,ints+'.-'));
                    x1:=strtofloat(formcharstr(0,'ex1:',crnrect,ints+'.-'));
                    y1:=strtofloat(formcharstr(0,'why1:',crnrect,ints+'.-'));
                    zcut:=strtofloat(formcharstr(0,'new cut depth: G00 Z',crnrect,ints+'.-'));

                   gcodelist.Lines.Add('X0= ' +floattostr(x0));
                   gcodelist.Lines.Add('Y0= ' +floattostr(y0));
                   gcodelist.Lines.Add('X1= ' +floattostr(x1));
                   gcodelist.Lines.Add('Y1= ' +floattostr(y1));

                   // update cutdepth
              //     cutmod.Position:=trunc((originalzcut-zcut)*1000);




               with  chart1.bottomaxis do
               begin
                   minimum:=x0;
                   maximum:=x1;
               end;

               with  chart1.leftaxis do
               begin
                   minimum:=y0;
                   maximum:=y1;
               end;



             end;
         end;



  end;


procedure        TPatch.history(idx:integer);
var ivx,ivw,ivz:integer; where:string;
begin

                gcodelist.Lines.Clear;
                if (idx+3)<numlines then
              begin

                  ser1_VS_GC.TryGetValue(idx,ivx);

                 for ivw:=idx-9 to idx -1 do
                 gcodelist.Lines.Add( gc_entries[ivw]);

                  if within(ivx,ivz) then where:=',in'
                else  where:=',out';

                 //gcodelist.Lines.Add(gc_entries[idx]+'<-GC'+inttostr(idx)+' ,S:'+inttostr(ivx)+where);
                 gcodelist.Lines.Add('(G'+inttostr(idx)+',)'+gc_entries[idx]+'<-GC,'+where);


                 halt.text:=   inttostr(ivx);

                 for ivw:=idx+1  to idx+9 do
                 gcodelist.Lines.Add( gc_entries[ivw]);

                plotpoint(series3,idx,false);
               // plotpoint(series3,idx+1,false);
                 end;

               clickpoint.Caption:=gc_entries[idx];
               halt.Text:=inttostr(idx);
end;

function plan_a(y_1,Y_0,x_0:real):real;   //plan_a(ymax,Y0,x0);

begin
    if slope=0  then
   result:=x0 else
   result:=(y_1-y_0)/slope+x_0;
end;

procedure plan_b(xbord,ybord,y_0,x_0:real;var x,y:real);

begin
   y:=(xbord-x_0)*slope+y_0;
   x:=xbord;
   if y>ybord then
   begin
      x:= plan_a(ybord,y_0,x_0);
      y:=ybord;
   end;
end;

function plan_c:real;   //plan_a(ymax,Y0,x0);

begin
  result:=(xmax-x0)*slope+y0;//ymin;
end;


function plan_g:real;   //plan_a(ymax,Y0,x0);

begin
  result:=(xmin-x0)*slope+y0;//ymin;
end;




function plan_e(y_1,Y_0,x_0:real):real;

begin
   result:=plan_a(y_1,Y_0,x_0);
end;

procedure plan_f(var x,y:real);

begin
   y:=(xmin-x0)*slope+y0;
   x:=xmin;
   if y<ymin then
   begin
      x:= plan_a(ymin,y0,x0);
      y:=ymin;
   end;
end;



procedure plan_d(var x,y:real);

begin
   y:=(xmax-x0)*slope+y0;
   x:=xmax;
   if y<ymin then
   begin
      x:=plan_a(ymin,y0,x0);     // was plan_e
      y:=ymin;
   end;
end;


procedure plan_h(var x,y:real);

begin
   y:=(xmin-x0)*slope+y0;
   x:=xmin;
   if y>ymax then
   begin
      x:=plan_a(ymax,y0,x0);    // was plan_e
      y:=ymax;
   end;
end;




procedure TPatch.Chart1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if button=mbMiddle  then
        begin
          series5.clear;
          series6.Clear;
        end;
  with series1 do

  begin
       if  marks.Visible then
       begin
            marks.Visible:=false;
            series3.Marks.Visible:=false;

       end;



  end;


end;

procedure TPatch.clearlistClick(Sender: TObject);
begin
        gcodelist.Lines.Clear;
end;


procedure TPatch.clickpointClick(Sender: TObject);
begin
       Clipboard.AsText := clickpoint.Caption;

end;

procedure TPatch.CLR2Click(Sender: TObject);
begin



    series3.clear;
    series4.clear;
    series5.clear;
    series6.Clear;
 //   series7.clear;
end;

procedure TPatch.clrpatchClick(Sender: TObject);
var btnsel:integer;
begin


 //  if patch_list.lines.count>20 then

    begin
       btnsel := MessageDlg('Cannot be undone. '+SLINEBREAK  +

                           'Continue?',mtCustom, [mbYes,mbCancel], 0);

       if btnsel =mryes then
       begin
          patch.Caption:='New Section';
          sectioncount:=0;
          patch_list.Lines.Clear;

         // AssignFile(rect_file,crndirname+'/cutrecs.dat');
        //  if not fileexists(crndirname+'/cutrecs.dat') then     rewrite(rect_file);
          DeleteFile ( crndirname+'/cutrecs.dat' );
          series7.Clear;
          clr2.Click;
          cutmod.Position:=0;
           rectlist.Clear;
        //  modz_string:='';
       end;

    end;
end;

procedure TPatch.copyselectClick(Sender: TObject);
begin
       patch_list.SelText;
       patch_list.CopyToClipboard;
       patch_list.SetFocus;
end;

procedure TPatch.CPBcpyClick(Sender: TObject);
begin

     //https://borland.public.delphi.oleautomation.narkive.com/saBKtMv7/paste-text-from-delphi-richedit-into-word
       gcodelist.SelectAll;
       gcodelist.CopyToClipboard;
end;

procedure TPatch.showcutsClick(Sender: TObject);
      var rect_file:textfile;  rect_entry:string;  x0,x1,y0,y1,newcut:string;

begin
       if not fileexists(crndirname+'/cutrecs.dat') then
       begin
        showmessage('No records');
         exit;

       end;

  if series7.Count=0 then
  begin

     Chart1.ZoomPercent(99.99);
     rectlist.clear;
     series7.Clear;
     assignfile(rect_file,  crndirname+'/cutrecs.dat');
     reset(rect_file);
     gcodelist.Lines.Clear;
    while not eof(rect_file) do
      begin
          readln(rect_file,rect_entry) ;
          rectlist.Add(rect_entry);
          x0:=formcharstr(0,'ex0:',rect_entry,ints+'.-');
          y0:=formcharstr(0,'why0:',rect_entry,ints+'.-');
          x1:=formcharstr(0,'ex1:',rect_entry,ints+'.-');
          y1:=formcharstr(0,'why1:',rect_entry,ints+'.-');
          newcut:=formcharstr(0,'new cut depth: G00 Z',rect_entry,ints+'.-');
      with series7 do
      begin
          
          AddXY( strtofloat(x0),  strtofloat(y0));
          AddXY( strtofloat(x1),  strtofloat(y0));
          AddXY( strtofloat(x1),  strtofloat(y1));
          AddXY( strtofloat(x0),  strtofloat(y1));
          AddXY( strtofloat(x0),  strtofloat(y0));
        //  gcodelist.Lines.add(inttostr(count));

          //hooray! We found invisible ink!!!
          if count>5  then  ValueColor[count-5]:=clWindowFrame;
         //  if count>5  then  transparency:=10;


      end;
        //  gcodelist.Lines.add(x0 +','+y0+','+x1+','+y1+','+newcut);




    end;

         closefile(rect_file);
          gcodelist.Lines.add( 'Rt. click on black border to zoom.');
  end
  else series7.Clear;
       //  ex0:6.7240, why0:9.6840, ex1:7.7780, why1:11.2800, new cut depth: G00 Z-0.2346


end;

function tPatch.within(index:integer;var gcidx:integer):boolean;

begin
             result:=false;

             if (series1.XValue[index]>=chart1.BottomAxis.Minimum) and
                (series1.XValue[index]<=chart1.BottomAxis.Maximum) then

             if (series1.yValue[index]>=chart1.leftaxis.Minimum) and
                (series1.yValue[index]<=chart1.leftaxis.Maximum) then


             result:=true;

             if result then   GC_VS_ser1.TryGetValue(index,gcidx);

end;

procedure  setslope;
begin
       if x1=x0 then slope:=dumbnum else
                      slope := (Y1-Y0) / (X1-X0);
end;


function  tpatch.crosstop(index:integer;var x_edge_val:real):boolean;
     var iy,ing:integer;
begin
         moveleft(index);
         setslope;
         x_edge_val:= plan_a(ymax,y0,x0);     //     plan_a(y_1,Y_0,x_0:real):real;
         result:=  (x_edge_val>xmin) and  (x_edge_val<xmax)   // x within xmin & max
           // make sure both end points are off screen, above & below
         and ((y1>ymax) and (y0<ymax) or  (y1<ymax) and (y0>ymax) )
         and  not within(index,iy)     //  and not from inside
         and not within(index-1,ing);   //  and not from inside

         if  GC_VS_ser1.TryGetValue(index,ing)   then
         if containsstr(gc_entries[ing],'G00 X') then  result:=false;
end;


  procedure TPatch.RemoveClick(Sender: TObject);
begin
         if (crn_rect_ndx>=rectlist.Count )
           or (crn_rect_ndx<0) then  exit;

         rectlist.Delete(crn_rect_ndx);
         rectlist.SaveToFile(crndirname+'/cutrecs.dat');
         series7.Clear;
          showcuts.Click;

      //  remove.Enabled:=false;

        crn_rect_ndx:=-1;
end;

procedure TPatch.ReRouteClick(Sender: TObject);
var buttonSelected,ix:integer;
begin
         if rectlist.Count=0 then  exit;


         if   modz >strtofloat(formcharstr(0,'G00 Z',rectlist[0],ints+'.-')) then

         begin
          MessageDlg ('New cut should be > old cut',mtcustom, [mbCancel], 0);
           exit;
         end;
          speedbutton1.Click;
          Chart1.ZoomPercent(101);   //

         for ix:=0 to  rectlist.Count-1 do
         begin
              gcodelist.Lines.Add(rectlist[ix]);
              crnrect:= rectlist[ix];
              x0:=strtofloat(formcharstr(0,'ex0:',crnrect,ints+'.-'));
              y0:=strtofloat(formcharstr(0,'why0:',crnrect,ints+'.-'));
              x1:=strtofloat(formcharstr(0,'ex1:',crnrect,ints+'.-'));
              y1:=strtofloat(formcharstr(0,'why1:',crnrect,ints+'.-'));

                with  chart1.bottomaxis do
               begin
                   minimum:=x0;
                   maximum:=x1;
               end;

               with  chart1.leftaxis do
               begin
                   minimum:=y0;
                   maximum:=y1;
               end;

               patch.Click;


         end;

            
end;

function  tpatch.RightCross(index:integer;var y_edge_val:real):boolean;
   var ing:integer;
  begin
         setslope;
         y_edge_val:=plan_c;     //  result:=(xmax-x0)*slope+y0;//ymin;
         result:=  (y_edge_val>ymin) and  (y_edge_val<ymax)   // x within xmin & max
         and  (x0<xmax) and (x1>xmax)
         and not within(index,ing)
         and not within(index-1,ing);

         if  GC_VS_ser1.TryGetValue(index,ing)   then
         if containsstr(gc_entries[ing],'G00 X') then  result:=false;
  end;



 function  tpatch.RightEntry(index:integer;var y_edge_val:real):boolean;

begin
         moveright(index);
         result:= RightCross(index,y_edge_val);
end;


function  tpatch.RightExit(index:integer;var y_edge_val:real):boolean;

begin
        moveleft(index);
        result:= RightCross(index,y_edge_val);
end;



procedure TPatch.savepatchClick(Sender: TObject);

begin

       if patch_list.Lines.Count<10  then
        begin
              showmessage('Workspace is empty');
              exit;
        end;
       if workfile.Execute then
       begin

       with patch_list do
       begin
           // add parting shots--return to xy 0 if not already
           if not containsstr(lines[lines.count-1],'G00 X0.000 Y0.000')  then
             begin
                 lines.Add('M5');
                 lines.Add('G00 X0.000 Y0.000');
             end;


           patch_list.lines.SaveToFile(workfile.FileName );

            ShellExecute(Application.Handle,
                            nil,
                            'explorer.exe',
 //   PChar(sourcedir), //wherever you want the window to open to
    // PChar(netdir),
                            PChar(crndirname),
                            nil,
                            SW_NORMAL     //see other possibilities by ctrl+clicking on SW_NORMAL
                          );

        //   winapi.Windows.Sleep(250);  ShellExecute( Handle,'explore',  pchar(workfile.FileName), nil, nil, SW_SHOWNORMAL);

      end;





    end ;
  end;




procedure TPatch.Saverect;
     var rect_file:textfile;  rect_entry:string;

     ex0 ,why0,ex1,why1:double;

     bs:integer;


function check4dupes:integer;
var ix,ap:integer; r1,rent1:string;
begin

// no dupes if 0 entries
    if rectlist.count <1 then
    begin
       result:=-1;
       exit;

    end;


    for Ix := 0 to  rectlist.Count-1 do

       begin
             ap:=ansipos(', new',rectlist[ix]);
             r1:=AnsiLeftStr(rectlist[ix],ap-1 );
             gcodelist.Lines.Add(r1);
             ap:=ansipos(', new',rect_entry);
             rent1:=AnsiLeftStr(rect_entry,ap-1);
             gcodelist.Lines.Add(rent1);

              if r1=rent1 then
             begin       // dupe found, returning its index
               result:=ix;
               break;
             end
             else result:=-1;     // not found

       end;


end;


begin
     if crndirname='' then exit;

        with chart1 do
          begin
            ex0:=chart1.BottomAxis.Minimum;
            why0 := chart1.LeftAxis.Minimum;
            ex1:=chart1.BottomAxis.Maximum;
            why1:=chart1.LeftAxis.Maximum;
          end;

       AssignFile(rect_file,crndirname+'/cutrecs.dat');
       if not fileexists(crndirname+'/cutrecs.dat') then     rewrite(rect_file);

       rect_entry:='ex0:'+FloatToStrF(ex0, ffNumber, 4, 4) +', why0:'+
            FloatToStrF(why0 , ffNumber, 4, 4)+', ex1:'+
            FloatToStrF(ex1, ffNumber, 4, 4)+ ', why1:'+
            FloatToStrF( why1, ffNumber, 4, 4)+', new cut depth: '+modz_string;


      bs:=check4dupes;
       if  bs>=0   then
       begin
       // overwrite dupe
           rectlist[bs]:=rect_entry;
           rectlist.SaveToFile(crndirname+'/cutrecs.dat');
           statusbar1.Panels[1].Text:='"'+rect_entry+'" overwritten';
           exit;
       end;



         Append(rect_file);
         rectlist.Add(rect_entry);
         writeln(rect_file,rect_entry);
         statusbar1.Panels[1].Text:='"'+rect_entry+'" written';
         closefile(rect_file);


 end;







 procedure TPatch.cut0Click(Sender: TObject);
begin
     cutmod.Position:=0;
end;

procedure TPatch.cutmodChange(Sender: TObject);
var ix:integer;
begin

       cutmodtimeout:=5;


     modz:=originalzcut-cutmod.Position/1000;
     modzcut.Caption:=floattostr(modz);
     newdepth.caption:= floattostrf(modz-originalzcut  , ffNumber, 5, 5);
     modz_string:='G00 Z'+newdepth.Caption;



end;

function  tpatch.cross_bottom(index:integer;var x_edge_val:real):boolean;
var ing:integer;
begin
         moveleft(index);
         setslope;
         x_edge_val:= plan_a(ymin,y0,x0);
         result:=  (x_edge_val>xmin) and  (x_edge_val<xmax)   // x within xmin & max
         and ((y0>ymin) and (y1<ymin) or  (y1>ymin) and (y0<ymin))
         and not within(index,ing)
         and not within(index-1,ing) ;


        if  GC_VS_ser1.TryGetValue(index,ing)   then
        if result=true then
        if containsstr(gc_entries[ing],'G00 X') then  result:=false;


end;

function tpatch.cross_left(index:integer;var y_edge_val:real):boolean;
  var ing:integer;
begin
        setslope;
      y_edge_val:=plan_g;
      result:=  (y_edge_val>ymin) and  (y_edge_val<ymax)   // x within xmin & max
      and  (x0<xmin) and (x1>xmin)
      and not within(index,ing)
      and not within(index-1,ing) ;

      if  GC_VS_ser1.TryGetValue(index,ing)   then
      if containsstr(gc_entries[ing],'G00 X') then
         result:=false;


end;


function  tpatch.left_entry(index:integer;var y_edge_val:real):boolean;

begin
      moveRIGHT(index);
      result:=  cross_left(index,y_edge_val);


end;


function  tpatch.left_eXIT(index:integer;var y_edge_val:real):boolean;

begin
         moveLEFT(index);
         result:=  cross_left(index,y_edge_val);

end;



function tpatch.Append_Gcode(prefix:string;x,y:real):string;
var tmp:string;
begin
       begin
            tmp:= prefix+' X'+FloatToStrF(x, ffNumber, 4, 4)+
                ' Y'+FloatToStrF(y, ffNumber, 4, 4);

            if    prefix='G00'  then

                    begin
                      tmp:= tmp+
                      slinebreak+ feedZstr +
                      slinebreak+modz_string+     // cut
                      slinebreak+feedXYstr;
                    //  tmp:='G00 Z2.0000'+slinebreak+tmp
                    end


                    else
               if prefix='G01'  then

                    begin
                       tmp:=tmp+slinebreak+'G00 Z2.0000';
                    end;



               result:=slinebreak+'(***insertion*of*)'+slinebreak
            //    +'('+tmp+')'
             //  +slinebreak
                +tmp+slinebreak
                 +'(****endof insertion*****)'
                 +slinebreak;
              //   application.ProcessMessages;
       end;
end;




procedure TPatch.Button1Click(Sender: TObject);
begin

     gcodelist.CopyToClipboard;
     gcodelist.SetFocus;
end;

procedure tpatch.setlimits;
begin
    with chart1 do
    begin
        xmin:=BottomAxis.Minimum;
        xmax:=BottomAxis.Maximum;
        ymin:=LeftAxis.Minimum;
        ymax:=leftAxis.Maximum;
    end;
end;



procedure TPatch.ShowMarksClick(Sender: TObject);
var ix,gnum:integer;
begin
      winapi.Windows.Sleep(5);
      if showmarks.Checked then
      begin
         series1.Marks.Visible:=true;
         series3.Marks.Visible:=true;
         series5.Marks.Visible:=true;
         for ix:=0 to series1.Count-1 do

         begin
             GC_VS_ser1.TryGetValue(ix,gnum);
          //   series1.Marks.item[ix].text:=inttostr(gnum);
           //    series1.OnGetMarkText
         end;

      end
      else
      begin
         series1.Marks.Visible:=false;
         series3.Marks.Visible:=false;
         series5.Marks.Visible:=false;

      end;


end;

procedure tpatch.moveright(ix:integer);

  begin
     with series1 do
      begin
         x0:=xvalue[ix-1];  // x in box
         x1:=xvalue[ix];     // x outside of box
         y0:=yvalue[ix-1];
         y1:=yvalue[ix];
      end;
  end;

procedure tpatch.moveleft(ix:integer);         //   (xvalue[index]<xmin)
                          //xvalue[index-1]>xmax
  begin
       with series1 do
         begin
           x0:=xvalue[ix];  // x in box
           x1:=xvalue[ix-1];     // x outside of box
           y0:=yvalue[ix];
           y1:=yvalue[ix-1];
          end;
  end;

function sub_area_y_mid:boolean;
begin
          result:=(y1>ymin) and (y1<ymax);
end;


function sub_area_xtween:boolean;
begin
          result:=(x1>xmin) and (x1<xmax);
end;


function loc_A:boolean;
begin
            result:=sub_area_xtween and (y1>ymax);
          IF RESULT THEN
          begin
            whichfunk:=@plan_a;
          end;

end;

function loc_B:boolean;
begin
            result:=(x1>xmax) and (y1>ymax);
            IF RESULT THEN
            begin
          //   trace:=trace+'B-kilroy';
             whichfunk:=@plan_b;
            end;

end;


function loc_C:boolean;
begin
            result:=(x1>xmax) and  sub_area_y_mid;
           IF RESULT THEN

           begin
          //   trace:=trace+'c-kilroy';
             whichfunk:=@plan_c;
           end;




end;


function loc_D:boolean;
begin
            result:=(x1>xmax) and (y1<ymin);
             IF RESULT THEN
             begin
            //  trace:=trace+'D-kilroy';
              whichfunk:=@plan_d;
            end;


end;


function loc_E:boolean;
begin
            result:=sub_area_xtween and   (y1<ymin);
             IF RESULT THEN
             begin
             whichfunk:=@plan_e;
            //  trace:=trace+'E-kilroy';
             end;
end;


function loc_F:boolean;
begin
            result:=(x1<xmin) and  (y1<ymin);
            IF RESULT THEN
             begin
              whichfunk:=@plan_f;
            //  trace:=trace+'F-kilroy';
             end;


end;


function loc_G:boolean;
begin
            result:=(x1<xmin) and   sub_area_y_mid;

             IF RESULT THEN
             begin
              whichfunk:=@plan_g;
            //  trace:=trace+'G-kilroy';
             end;



end;

function loc_H:boolean;
begin
            result:=(x1<xmin) and  (y1>ymax);
             IF RESULT THEN
             begin
              whichfunk:=@plan_h;
          //    trace:=trace+'H-kilroy';
             end;


end;



procedure getedgepoints(var xedge, yedge:real);
begin
        if whichfunk=@plan_a then
           BEGIN
                   xedge:=plan_a(ymax,Y0,x0);
                   yedge:=YMAX;


                  {function plan_a(y_1,Y_0,x_0:real):real;   //plan_a(ymax,Y0,x0);

                  begin
                        if slope=0  then
                        result:=x0 else
                   result:=(ymax-y0)/slope+x0;
                  end;}



           END
           else
           if whichfunk=@plan_b then

            plan_b(xmax,ymax,y0,x0,xedge,yedge)

            else if whichfunk=@plan_c then
           begin

                yedge:=plan_c;

                xedge:=xmax;
           end

            else if whichfunk=@plan_d then
           begin
               plan_d(xedge,yedge);
           end



           else if whichfunk=@plan_e then
           begin
                xedge:=plan_e(ymin,Y0,x0);
                yedge:=Ymin;

           end


            else if whichfunk=@plan_g then
           begin
               yedge:=plan_g;
               xedge:=xmin;
           end
            else if whichfunk=@plan_f then
           plan_f(xedge,yedge)

             else if whichfunk=@plan_h then
           plan_h(xedge,yedge);


 end;




procedure whichloc;
begin
                    setslope;
                    whichfunk:=nil;
                    if not loc_a then
                    if not loc_b then
                    if not loc_c then
                    if not loc_d then
                    if not loc_e then
                    if not loc_f then
                    if not loc_g then
                    loc_h;

               getedgepoints(x_edge_point, y_edge_point);


end;



function tPatch.out2in(index:integer):string;
 var idx:integer;       curfix:string;
begin
   setlimits;
   trace:='out->in,';
   //result:='(****out_to_in*****)';
   moveleft(index);



  if  GC_VS_ser1.TryGetValue(index,idx)   then
  // *************  ********
  if

   (containsstr(gc_entries[idx],'G00 X') and
   containsstr(gc_entries[idx+1],'G00 Z2.0000'))
   // *************to prevent edge points at raised tool inbound traverse ********

     or
     (containsstr(gc_entries[idx],'G00 X') and
   containsstr(gc_entries[idx-1],'G00 Z2.0000'))



      then
  begin
   result:='';
    exit;
  end;
  // *****END OF 'to prevent edge points at raised tool traverses'*********
  //****************(seems to work)********

   whichloc;
   series5.addxy(x_edge_point, y_edge_point);
   // if the last (exit/entry) was 'G00' then the next (entry/exit) must be 'G01' & vice versa


  //  if lastprefix='G00' then  curfix:='G01'
   //    else curfix:='G00';

    curfix:='G00';

   result:=Append_Gcode(curfix,x_edge_point, y_edge_point);
   lastprefix:=curfix;

end;


function tPatch.in2out(index:integer):string;
  var curfix:string;
begin
       setlimits;
       trace:='in->out,';
       moveright(index);
       whichloc;
       series5.addxy(x_edge_point, y_edge_point);


       // if the last (exit/entry) was 'G00' then the next (entry/exit) must be 'G01' & vice versa
    //   if lastprefix='G00' then  curfix:='G01'
    //   else curfix:='G00';
         curfix:='G01';
       result:=Append_Gcode(curfix,x_edge_point, y_edge_point);

       lastprefix:=curfix;
end;

 procedure TPatch.JumpClick(Sender: TObject);
 var linenum:integer;  fcr:string;
begin
       if containsstr(halt.text,'G') then
        fcr:=formcharstr(0,'G',halt.text,ints)
        else fcr:=halt.text;


      linenum:= StrToIntDef(fcr, -1);
       if linenum>0 then
        begin
            series3.clear;
            history(linenum);
            curnindex:= linenum;
        end;


end;

procedure SetCheckedState(const checkBox : TCheckBox; const check : boolean) ;

var
   onClickHandler : TNotifyEvent;

 begin

   with checkBox do
   begin
     onClickHandler := OnClick;
     OnClick := nil;
     Checked := check;
     OnClick := onClickHandler;
end;


end;

procedure TPatch.show_edge_point(sindex,gindex:integer);
begin


     GC_VS_ser1.TryGetValue(sindex,gindex);
     patch_list.Lines.Add(trace+ '(G'+inttostr(gindex)+')');


end;





procedure TPatch.SpeedButton1Click(Sender: TObject);
begin
      chart1.UndoZoom;
end;

procedure TPatch.SpeedButton2Click(Sender: TObject);
begin
           //   patch_list.Lines.Add('M5');
      //   patch_list.Lines.Add('G00 X0.000 Y0.000');

        with patch_list do
       begin
           // add parting shots--return to xy 0 if not already
           if not containsstr(lines[lines.count-1],'G00 X0.000 Y0.000')  then
          begin
       if  lines.Count>50 then
              begin
                 lines.Add('M5');
                 lines.Add('G00 X0.000 Y0.000');
              end;
             end;
           patch_list.lines.SaveToFile(workfile.FileName );
        end ;


         patch_list.SelectAll;
         patch_list.CopyToClipboard;
         patch_list.SetFocus;
         shellexecute(handle,'open','https://ncviewer.com/',nil,nil,sw_shownormal);
end;

procedure TPatch.Timer1Timer(Sender: TObject);
var ix:integer;
begin
      if showmarks.Checked then
         showmarks.OnClick(nil);

         statusbar1.Panels[0].Text:='FILE:'+crnfilename;
       //  newdepth.caption:= floattostrf( modz - originalzcut, ffNumber, 4, 4);

         if series7.Count=0 then  patch.Caption:='New Section'
          else    patch.Caption:='Add a Section';
       if cutmodtimeout>0  then  dec( cutmodtimeout);


    if cutmodtimeout=1  then
    begin
    {
     modz:=originalzcut-cutmod.Position/1000;
     modzcut.Caption:=floattostr(modz);
     newdepth.caption:= floattostrf(modz-originalzcut  , ffNumber, 5, 5);
      modz_string:='G00 Z'+newdepth.Caption;
      }

      for ix := 0 to  patch_list.Lines.Count do
      // gcodelist.Lines.Add(inttostr(ix));
      begin
          if  containsstr(patch_list.Lines[ix],'G00 Z-')
                or
               containsstr(patch_list.Lines[ix],'G00 Z0.00000')

           then

           patch_list.Lines[ix]:='G00 Z'+newdepth.Caption;

      end;
    end;

end;

procedure TPatch.PatchClick(Sender: TObject);
var ix,vi:integer;



 pointfound,prevpoint:boolean;

tmp:string;

begin

if modz_string<>''  then

  begin

  if chart1.Zoomed then

     begin
      if sectioncount =0 then
      begin
       clr2.Click;
     //  clrpatch.Click;
       addintro;
      end
      else
      begin
      // remove 'spindle off and 'return to 0
      with patch_list do
         begin
            if containsstr(lines[lines.count-1],'G00 X0.000 Y0.000') then
               lines.Delete(lines.count-1);
               lines.Delete(lines.count-1);

         end;
      end;



         //**********now a list of sets of contiguous points must be formed

              ix:=0;

     if sectioncount =0 then
     begin

         patchcodelist.Clear;
       //  patch_list.Lines.Add('G00 Z5.0000'); //dummy so it will look like a flatcam file
         patch_list.Lines.Add('(************************)') ;
         patch_list.Lines.Add('(************************)') ;
         patch_list.Lines.Add('(******re-cut start********)') ;
         patch_list.Lines.Add('(************************)') ;
         patch_list.Lines.Add('(************************)') ;

     end;



      patch.Caption:='Add section';



         prevpoint:=true;


       repeat

         if (containsstr(gc_entries[ix],'G00 X')) or (containsstr(gc_entries[ix],'G01 X')) then



         begin

             // ************************ // ************************// ************************
             // ***********check for tool excursions into or out of chosen rectangle***********
             // ************************ // ************************// ************************
          { if }ser1_VS_GC.TryGetValue(ix,gcodeindx);{ then  }   // get the series valueindex gcodeindx

         //       begin


                   if within(gcodeindx,vi) then
                      begin
                        insidepoint:= '(G'+inttostr(ix)+')'+gc_entries[ix];


                        // add a 'tool down for any 'G00 X'
                        if containsstr( insidepoint,'G00 X') then
                        begin
                            insidepoint:=insidepoint + slinebreak  + modz_string;
                            insidepoint:=gc_entries[ix-1]  + slinebreak+ insidepoint;

                        end;


                        plotpoint(series4,ix,false);
                        pointfound:=true;

                      end else

                      begin
                       pointfound:=false;

                      end;



                        if  pointfound and prevpoint then

                         BEGIN

                             if CONTAINSSTR(insidepoint,'G00 X')
                             then
                              begin

                                  insidepoint:='(adding) '{+ slinebreak  + 'G00 Z2.0000'}+ slinebreak+insidepoint;
                                  insidepoint:=slinebreak+insidepoint+
                                  slinebreak+ feedZstr +
                               //   slinebreak+modz_string+     // cut
                                //  slinebreak+feedXYstr+
                                  slinebreak+'(/\ /\end /\ /\)';
                              end;


                             patch_list.Lines.Add('(int)'+insidepoint);


                           //   patch_list.Lines.Add('(end of internal [from pointfound])');

                         END;



                    if prevpoint  and  not pointfound    // outbound
                           // if the present outside point is 'G00 X'
                           // then no line is drawn to it, hence no point
                           // at the edge
                          and not containsstr(gc_entries[ix],'G00 X')
                       //   and not containsstr(gc_entries[ix-1],'G01 F')
                           then
                           begin
                             tmp:= in2out(gcodeindx);
                             if tmp<>'' then
                               begin
                                  patch_list.Lines.Add(insidepoint);
                                  lastioi:='(I2O)'+ tmp;
                                  patch_list.Lines.Add(lastioi);


                              end;



                           end;




              if  pointfound and not prevpoint
                 //     and not firstpass
                      then


                      begin
                            tmp:= out2in(gcodeindx);
                             if tmp<>'' then
                               begin
                                  patch_list.Lines.Add('G00 Z2.000');
                                  lastioi:= '(O2I)'+ tmp;
                                  patch_list.Lines.Add(lastioi);
                                //  patch_list.lines.add(insidepoint);
                              end;

                             patch_list.lines.add(insidepoint);
                        end;




                       lastinsidepoint:=insidepoint;
                       prevpoint:=pointfound;
                       inc(ix);

            end else inc(ix);


       until   ix>=gc_entries.Count-1;




     // ************************ // ************************// ************************
     // ************************LOOK FOR FLY_OVERs*************************************
     // ************************ // ************************// ************************




      setlimits;    // est. x,y min's and max's : may not have been done if
                     // no 'within's in previous routine

      patch_list.Lines.Add('G00 Z2.000');


      lastprefix:='G01';

       for ix :=1 {0}  to series1.Count-1 do   // numlines =# of file entries, that,s all

          begin

              if crosstop(ix,x_edge_point) then
              begin
                    trace:=chr(13)+'(TOP crossing)' ;
                    show_edge_point(ix,gcodeindx);
                    series6.AddXY(x_edge_point,ymax);
                    if lastprefix='G00' then  curfix:='G01'
                        else curfix:='G00';
                     patch_list.Lines.Add(append_Gcode(curfix,x_edge_point,ymax));
                     lastprefix:=curfix;
              end;




              if RightExit(ix,y_edge_point) then
              begin
                    trace:=chr(13)+'(right exit)';
                    show_edge_point(ix,gcodeindx);
                    series5.AddXY(xmax,y_edge_point);
                    if lastprefix='G00' then  curfix:='G01'
                        else curfix:='G00';
                    patch_list.Lines.Add(append_Gcode(curfix,xmax,y_edge_point));
                   lastprefix:=curfix;


              end;

              if RightEntry(ix,y_edge_point) then
              begin
                    trace:=(chr(13)+'(right entry)');
                    show_edge_point(ix,gcodeindx);
                    series6.AddXY(xmax,y_edge_point);
                    if lastprefix='G00' then  curfix:='G01'
                        else curfix:='G00';
                    patch_list.Lines.Add(append_Gcode(curfix,xmax,y_edge_point));
                    lastprefix:=curfix;
              end;


            if cross_bottom(ix,x_edge_point) then
              begin
                     trace:=chr(13)+'(bottom crossing)';
                     show_edge_point(ix,gcodeindx);
                     series5.AddXY(x_edge_point,ymin) ;
                      if lastprefix='G00' then  curfix:='G01'
                        else curfix:='G00';
                     patch_list.Lines.Add(append_Gcode(curfix,x_edge_point,ymin));
                     lastprefix:=curfix;

              end;

              if left_entry(ix,y_edge_point) then
              begin
                   trace:=chr(13)+'(left entry:)';
                   show_edge_point(ix,gcodeindx);
                   series5.AddXY(xmin,y_edge_point);
                   if lastprefix='G00' then  curfix:='G01'
                        else curfix:='G00';
                   patch_list.Lines.Add(append_Gcode(curfix,xmin,y_edge_point));
                   lastprefix:=curfix;


              end;

              IF left_exit(ix,y_edge_point) then
               begin
                   trace:=chr(13)+'(left exit)';
                   show_edge_point(ix,gcodeindx);
                   series6.AddXY(xmin,y_edge_point);
                     if lastprefix='G00' then  curfix:='G01'
                        else curfix:='G00';
                    patch_list.Lines.Add(append_Gcode(curfix,xmin,y_edge_point));
                     lastprefix:=curfix;
               end;


          end;

           inc( sectioncount);
           saverect;
           series7.Clear;
           showcuts.Click;


    end

         else showmessage('Zoom to desired area');
  end

  else
  begin
       panel2.Color:=clred;
       showmessage('Select new Z cut');
        panel2.Color:=clblue;
  end;

end;

procedure TPatch.patch_listClick(Sender: TObject);

begin
      //
end;

procedure TPatch.patch_listDblClick(Sender: TObject);
var gnum,tmp,strx,stry:string;
begin


        clickpoint.Caption:=patch_list.SelText;

          if containsstr(patch_list.SelText,'G') then
               gnum:=formcharstr(0,'G',patch_list.SelText,ints+'.')
               else exit;

          series3.clear;
          curnindex:= strtoint(gnum);
          plotpoint(series3,curnindex,false);
          history(curnindex);



end;

procedure tPatch.plotpoint(whichseries:TChartSeries;idx:integer;isnull:boolean);
var  strx,stry,tmp:string;
begin
           tmp:= gc_entries[idx];

          strx:=formcharstr(0,'X',tmp,ints+'.'+'-');
          stry:=formcharstr(0,'Y',tmp,ints+'.'+'-');
         if (strx<>'') and (stry<>'') then
          begin
      // https://docwiki.embarcadero.com/CodeExamples/Sydney/en/Generics_Collections_TDictionary_(Delphi)

            if whichseries=series4  then
            begin
                    whichseries.AddXY(strtofloat(strx),strtofloat(stry));
                        exit;

            end;



                if containsstr(tmp,'G00 X') then
                begin
                    if whichseries=series3 then
                    begin
                        whichseries.AddXY(strtofloat(strx),strtofloat(stry));
                        exit;

                    end;


                   // whichseries:=;
                     series1.AddXY(strtofloat(strx),strtofloat(stry));
                     series1.ValueColor[series1.count-1]:=cllime;

                end
                else
                begin
                  if   isnull then


                             whichseries.AddnullXY(strtofloat(strx),strtofloat(stry))
                      else   whichseries.addXY(strtofloat(strx),strtofloat(stry));//


                      if whichseries=series1 then
                      begin
                           if containsstr(tmp,'G01 X') then

                           series1.ValueColor[series1.count-1]:=clred;



                      end;
                end;



                if whichseries=series1 then
                begin
                     GC_VS_ser1.add(whichseries.Count-1,idx);
                     ser1_VS_GC.add(idx,whichseries.Count-1);

                end;


          end;



end;

procedure TPatch.prevClick(Sender: TObject);
begin
              if curnindex<=3 then exit;
              series3.clear;
              dec(curnindex);
              history(curnindex);
end;

function TPatch.FormCharStr(occurence:integer;startchar,targ,qualifier:string):string;
var ps,ps1 ,len,ix:integer; tm:string;
//const strn ='0123456789.';
begin
   {
     if not containsstr(targ,startchar) then
     begin
        result:='0';
        exit;

     end;
    }


     ix:=0;
     // trim left off targ up to the 'occurence'-th position of 'startchar'
     repeat
         ps1:=AnsiPos(startchar,targ) +length(startchar)-1;
       //  getdir.batchwin.Lines.Add('p '+ targ+'>'+inttostr(ix));
            if ps1>0 then
               begin
                  targ:=AnsiRightStr(targ,length(targ)-ps1);
                  inc(ix);
               end;
     until (ps1=0) or (ix>occurence) ;

   //  getdir.batchwin.Lines.Add(targ);
     ps:=1;
     len:=length(targ);         //  new
     result:='';
     repeat
             tm:= midstr(targ,ps,1);
             inc(ps);
             if containsstr(qualifier,tm) then  result:=result+tm;
        //    getdir.batchwin.Lines.Add(result+','+tm);
     until   (ps>len) or (not containsstr(qualifier,tm));

end;

procedure tpatch.addintro;
var ix:integer;
begin

         for ix:=0 to intro.Count-1 do
           patch_list.Lines.Add(intro[ix]);


end;




procedure TPatch.ncfile1Click(Sender: TObject);
var   nc:string;  iy: long; airer:integer;


begin     ncfile.FileName:='*.nc';
          gcodelist.Lines.Clear;
          segnums:=0;
         if ncfile.Execute  then
        begin

            series1.Clear;
            series2.Clear;
            series3.clear;
            series4.Clear;
            series5.clear;
            series6.Clear;
            gc_entries.Clear;
            GC_VS_ser1.Clear;
            ser1_VS_GC.Clear;


           if  containsstr(ncfile.filename ,'__work_over__.nc')    then
           begin
               showmessage('Unresolved issues with inbreeding at this time.');
               exit;
           end;

            if  containsstr(ncfile.filename ,'.drd')    then
           begin
               showmessage('No drill files');
               exit;
           end;

            if ncfile.filename<>'' then
            begin
                     if fileexists(ncfile.filename) then
                     begin
                          series7.Clear;
                          // create a subfolder based on filename
                          // this folder will contain chosen rectangle coords
                          crnfilename:=ExtractFileName(ncfile.filename);
                //          crndirname:=formcharstr(1,' ',' '+crnfilename,diralfs+'_');
                           crndirname:=ExtractFileDir ( ncfile.filename) ;
                       //   crndirname:=crndirname+'['+DateToStr(now)+']';
                           {$IOChecks off}
                          MkDir(crndirname);
                          airer:=  IOResult;


                          gcodelist.Lines.clear;
                          assignfile(ncf,ncfile.filename);
                          reset(ncf);
                          numlines:=0;
                         while not eof(ncf) do
                            begin
                              readln(ncf,nc);
                              gc_entries.Add(nc);

                                   if     containsstr(gc_entries[numlines],'G00 X')    then
                                          inc (segnums);

                                   if     containsstr(gc_entries[numlines],'Z_Cut:')     then
                                   begin
                                          OrigZcut.Caption:=formcharstr(0,' ',nc,ints+'.'+'-');
                                          if OrigZcut.Caption<>'' then
                                          originalzcut:=strtofloat(OrigZcut.Caption);
                                          modzcut.Caption:=OrigZcut.Caption;
                                   end;

                                   if     containsstr(gc_entries[numlines],'Feedrate_XY:')     then
                                      feedXYstr:='G01 F'+formcharstr(0,' ',nc,ints+'.'+'-');

                                   if     containsstr(gc_entries[numlines],'Feedrate_Z:')     then
                                      feedZstr:='G01 F'+formcharstr(0,' ',nc,ints+'.'+'-');


                               inc(numlines);
                            end;
                            closefile(ncf);
                        end;
                         gcodelist.Lines.Add(inttostr(segnums)+' segments');
                         gcodelist.Lines.Add(inttostr(numlines)+' lines');
               end;

          end else exit;
          iy:=3;


                       // searching for the start
                       // does the key fit the lock
                       while not  (containsstr(gc_entries[iy-3],'M03')  and
                                   containsstr(gc_entries[iy-2],'G01')  and
                                   containsstr(gc_entries[iy-1],'G00'))

                      do
                       begin
                           // filter out 'M0' & 'T1'
                          if not  (containsstr(gc_entries[iy-1],'M6')
                                or    ( gc_entries[iy-1]='M0')
                                or    ( gc_entries[iy-1]='T1')
                                )
                           then  intro.Add(gc_entries[iy-1]);


                           if iy>150 then

                                 begin
                                    showmessage('Does not seem to be a  Flatcam file') ;
                                    gc_entries.Clear;


                                    iy:=0;
                                    exit;

                                 end;
                             inc(iy);
                       end;



  //  ****************************************************************************
  //  ****************************************************************************
   //  ******************read 1st segment***************


                    gcodelist.lines.add (' **found '+gc_entries[iy-1]);
                    gcodelist.lines.add ('first point is ' +gc_entries[iy-4]);
      // show flatcam tracks
                   numsegs:=0;
                 repeat

                   while (iy<numlines-1 ) {or  (containsstr(gc_entries[iy],'G00 X'))} do

                  begin
                       plotpoint(series1,iy , false);
                       inc(iy);
                  end;



                    inc(numsegs);
                  until numsegs>=segnums;

         // chart1.ZoomPercent(99);

             if airer<>0 then   if not airer=183  then   showmessagefmt('Dir not created: Error %d',[airer]);
                            //  showmessage(crndirname+'already exists')


end;

procedure TPatch.nextClick(Sender: TObject);

begin
                if curnindex<=3 then exit;
                series3.clear;
                inc(curnindex);
                history(curnindex);
end;

end.
