unit ocv_lib;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, ComCtrls,
  ocv.highgui_c,ocv.core_c,ocv.core.types_c,ocv.imgproc_c, ocv.comp.View,
  ocv.imgproc.types_c,ocv.utils,ocv.comp.Types,ocv.comp.ImageOperation
  ;

const
  conicntOcvViewer = 16;//ocv_viewer in frmOCV_UI

type
  TOCV_LIB = class
  private
    idxOcvViewer : Integer;//start from -1, for add image in ocv_viewer of frmOCV_Ui

    //common image object
    img             : pIplImage;
    imgEqHistogram  : pIplImage; // histogram images
    imgGrayHistogram: pIplImage;
    imgGray         : pIplImage;
    imgEq           : pIplImage;
    imgHistEq       : pIplImage;
    imgBlank        : pIplImage;
    lvV1,lvV2,lvV3,lvV4:IocvImage;//ocv.comp.Types

    function  show_image_to_ocv_view(img1:pIplImage):integer;//return current idxOcvViewer
    procedure create_histogram_image(grayImg: pIplImage; histogramImage: pIplImage);

  public
    function  load_image(const stFile:String):Integer;//intger: mat order
    procedure deal_with_image(idxMat:integer; var idxRes1,idxRes2:integer);//idxMat: 0..2
    procedure split_histogram_layer(idxMat:integer);

    procedure show_mat_image(idxMat:Integer);
    procedure zero_all();//reset all

    procedure Writeln(const s: string);
    procedure Readln(var s: string);

    Constructor Create; overload;
    Destructor  Destroy; override;
  end;

var vOCV1 : TOCV_LIB;
     Mat  : array [0..conicntOcvViewer-1] of pIplImage;

implementation

uses ocv_ui,ocv_ui_proc;

function TOCV_LIB.load_image(const stFile:String):Integer;//intger: mat order
var iRes:Integer;
begin
   iRes := -1;

   img := cvLoadImage( PAnsiChar(AnsiString(stFile)),  1);//'pic\board.bmp'

   if (not Assigned(img))  then
    begin Result := iRes; Exit; end; // cvShowImage( 'raw', img); // cvNamedWindow( windowName1, 1);

   iRes := show_image_to_ocv_view(img);
   Result := iRes;
end;

procedure TOCV_LIB.split_histogram_layer(idxMat:integer);
var xdif,iFind,i,j,iSize,x,y,x1,y1:integer; byte1:byte;
begin //debug:show_image_to_ocv_view(Mat[idxMat]);

  //1. find histogram value > 180, only scane 1 row
  y :=180; i := Mat[idxMat].width*y +y;//??? why need plus y ???
  xdif := 0;//prevent too close
  for  x := 0 to Mat[idxMat].width -1   do
   begin
     byte1 := Mat[idxMat].imageData[i];
     //-------------------------------------------------------------------------
     if (byte1 <> 255) and( abs(x - xdif) > 3) then//filiter out near color
      begin
       //-------------------------------------------------------------------------
       //-------------------------------------------------------------------------
          //5.0 get value
          iFind := x;

          //5.1 copy image
          if img <> nil then  cvReleaseImage(img);//release first
          img := cvCloneImage(imgHistEq);

          //5.2 translate image
          j := 0;
          for  x1 := 0 to img.width -1   do
           begin
             for  y1 := 0 to img.height -1   do
              begin
                 if iFind <> img.imageData[j] then
                  begin
                   img.imageData[j] := 255;
                  end;
                j := j + 1;
              end;
           end;

          //5.9 add new image
          show_image_to_ocv_view(img);

          xdif := x;
       //-------------------------------------------------------------------------
       //-------------------------------------------------------------------------
      end;
     //-------------------------------------------------------------------------
     i := i + 1; //if abs(x - xdif) > 5 then xdif := 0;
   end;

end;

procedure TOCV_LIB.deal_with_image(idxMat:integer; var idxRes1,idxRes2:integer);//idxMat: 0..2
begin
  try
    // define required images for intermediate processing
    // (if using a capture object we need to get a frame first to get the size)
    imgGray         := cvCreateImage( cvSize(img^.width, img^.height),img^.depth, 1);
    imgGray^.origin := img^.origin;
    imgEq           := cvCreateImage(cvSize(img^.width, img^.height),img^.depth, 1);
    imgEq^.origin   := img^.origin;

    imgEqHistogram   := cvCreateImage(cvSize(255, 200),8, 1);
    imgGrayHistogram := cvCreateImage(cvSize(255, 200),8, 1);

      // Histogram Equalisation Processing
      if (img^.nChannels > 1) then // if input is not already grayscale, convert to grayscale
           begin cvCvtColor(img,imgGray,CV_BGR2GRAY); end
      else begin imgGray := img; end;
      show_image_to_ocv_view(imgGray);

      // draw histograms
      create_histogram_image( imgGray, imgGrayHistogram); show_image_to_ocv_view(imgGrayHistogram);

      // Simple Histogram Equalization. Added by Shervin Emami, 17Nov2010.
      imgHistEq := cvCreateImage(cvGetSize(imgGray),imgGray^.depth,imgGray^.nChannels);
      cvEqualizeHist(imgGray,imgHistEq); show_image_to_ocv_view(imgHistEq);
      //cvShowImage('Simple Histogram Equalization',imgHistEq);

      //show equalizehist histograms
      create_histogram_image( imgHistEq,  imgEqHistogram);
      idxRes1 := show_image_to_ocv_view(imgEqHistogram); //return mat order
      idxRes2 := -1;

  except
    on E: Exception do
      WriteLn(E.ClassName+': '+E.Message);//org: WriteLn(E.ClassName,': ', E.Message);
  end;

end;

procedure TOCV_LIB.zero_all();//reset all
var i:Integer;
begin
  //0. reset drault image
    idxOcvViewer := -1;//start from -1, for add image in ocv_viewer of frmOCV_Ui

    cvReleaseImage(img);
    cvReleaseImage(imgEqHistogram);
    cvReleaseImage(imgGrayHistogram);
    cvReleaseImage(imgGray);
    cvReleaseImage(imgEq);
    cvReleaseImage(imgHistEq);
    cvReleaseImage(imgBlank);
    lvV1 := nil;
    lvV2 := nil;
    lvV3 := nil;
    lvV4 := nil;

  //1. reset mat image
   for  i := 0 to conicntOcvViewer -1   do
    begin
     if Mat[i] <> nil then cvReleaseImage(Mat[i]);
    end;

  //9. reset all ocvView at frmOCV_Ui
  oup_ocv_viewer_reset(frmOCV_Ui.scrollboxOCV);
end;

procedure TOCV_LIB.Writeln(const s: string);
begin
  frmOCV_UI.listLog.Items.Add(s);
  //debugoutput.output.Lines.Add(S);
  //debugoutput.Visible := True;
end;

procedure TOCV_LIB.Readln(var s: string);
begin
  s := InputBox('Input', '', '');//STR_INPUTBOX_TITLE: Script
end;

function  TOCV_LIB.show_image_to_ocv_view(img1:pIplImage):integer;//return current idxOcvViewer
begin
  //0. get index
  idxOcvViewer := idxOcvViewer + 1;
  if idxOcvViewer >= conicntOcvViewer  then begin result:= idxOcvViewer; Exit; end;

  //1.
   lvV1:= TocvImage.CreateClone(img1) as IocvImage; //test:  ShowMessage(frmOCV_UI.scrollboxOCV.Controls[idxOcvViewer].name);
   if frmOCV_UI.scrollboxOCV.Controls[idxOcvViewer] is TocvView then
    begin
      TocvView(frmOCV_UI.scrollboxOCV.Controls[idxOcvViewer]).DrawImage(lvV1);
    end;  //test: frmOCV_UI.ocvView1.DrawImage(lvV1); cvShowImage('test',img1);

  //2. copy to mat array
  if Mat[idxOcvViewer] <> nil then  cvReleaseImage(Mat[idxOcvViewer]);//release first
  Mat[idxOcvViewer] := cvCloneImage(img1);

  //9. return idex of OcvViewer
  result:= idxOcvViewer;
end;

procedure TOCV_LIB.show_mat_image(idxMat:Integer);
begin
  cvShowImage(c_str('s-'+inttostr(idxMat)),Mat[idxMat]);
end;

procedure TOCV_LIB.create_histogram_image(grayImg: pIplImage; histogramImage: pIplImage);
Var
  hist     : pCvHistogram; // pointer to histogram object
  max_value: Float;        // max value in histogram
  hist_size: Integer;      // size of histogram (number of bins)
  bin_w    : Integer;      // initial width to draw bars
  range_0  : array [0 .. 1] of Float;
  ranges   : pFloat;
  i        : Integer;
begin
  hist       := Nil; // pointer to histogram object
  max_value  := 0;   // max value in histogram
  hist_size  := 256; // size of histogram (number of bins)
  bin_w      := 0;   // initial width to draw bars
  range_0[0] := 0;
  range_0[1] := 256;
  ranges     := @range_0;

  hist := cvCreateHist(1,@hist_size,CV_HIST_ARRAY, @ranges,1);

  cvCalcHist(grayImg,hist,0,nil);
  cvGetMinMaxHistValue(hist, 0, @max_value);
  cvScale(hist^.bins,hist^.bins,histogramImage^.height / max_value,0);
  cvSet(histogramImage,cvScalarAll(255), 0);
  bin_w := cvRound(histogramImage^.width / hist_size);

  for i := 0 to hist_size - 1 do
  begin
    cvRectangle( histogramImage,
      cvPoint(i * bin_w, histogramImage^.height),
      cvPoint((i + 1) * bin_w, histogramImage^.height - cvRound(cvGetReal1D(hist^.bins, i))),
      cvScalarAll(0),-1, 8,0);
  end;

  cvReleaseHist(hist);
end;

constructor TOCV_LIB.Create;
begin

  inherited;
end;

destructor TOCV_LIB.Destroy;
begin
  inherited;
end;

end.



