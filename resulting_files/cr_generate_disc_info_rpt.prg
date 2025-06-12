CREATE PROGRAM cr_generate_disc_info_rpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "ID" = "",
  "password" = ""
  WITH outdev, id, password
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE query1(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE detailsection(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE detailsectionabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE _hi18nhandle = i4 WITH noconstant(0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant( $OUTDEV), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_pdf), protect
 DECLARE _remfieldname0 = i4 WITH noconstant(1), protect
 DECLARE _remfieldname5 = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontdetailsection = i2 WITH noconstant(0), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE query1(dummy)
   SELECT
    FROM (dummyt d1  WITH seq = 1)
    HEAD REPORT
     _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom)
    HEAD PAGE
     IF (curpage > 1)
      dummy_val = pagebreak(0)
     ENDIF
    DETAIL
     _bcontdetailsection = 0, bfirsttime = 1
     WHILE (((_bcontdetailsection=1) OR (bfirsttime=1)) )
       _bholdcontinue = _bcontdetailsection, _fdrawheight = detailsection(rpt_calcheight,(_fenddetail
         - _yoffset),_bholdcontinue)
       IF (((_yoffset+ _fdrawheight) > _fenddetail))
        BREAK
       ELSEIF (_bholdcontinue=1
        AND _bcontdetailsection=0)
        BREAK
       ENDIF
       dummy_val = detailsection(rpt_render,(_fenddetail - _yoffset),_bcontdetailsection), bfirsttime
        = 0
     ENDWHILE
    WITH nocounter, separator = " ", format
   ;end select
 END ;Subroutine
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE detailsection(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = detailsectionabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE detailsectionabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(10.000000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_fieldname0 = f8 WITH noconstant(0.0), private
   DECLARE drawheight_fieldname5 = f8 WITH noconstant(0.0), private
   DECLARE __fieldname0 = vc WITH noconstant(build2(uar_i18ngetmessage(_hi18nhandle,
      "DetailSection_FieldName0",build2("Report Request ID:",char(0))),char(0))), protect
   DECLARE __fieldname5 = vc WITH noconstant(build2(uar_i18ngetmessage(_hi18nhandle,
      "DetailSection_FieldName5",build2("Password:",char(0))),char(0))), protect
   DECLARE __fieldname7 = vc WITH noconstant(build2( $2,char(0))), protect
   DECLARE __fieldname8 = vc WITH noconstant(build2( $3,char(0))), protect
   IF (bcontinue=0)
    SET _remfieldname0 = 1
    SET _remfieldname5 = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremfieldname0 = _remfieldname0
   IF (_remfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname0,((size(
        __fieldname0) - _remfieldname0)+ 1),__fieldname0)))
    SET drawheight_fieldname0 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname0 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname0,((size(__fieldname0) -
       _remfieldname0)+ 1),__fieldname0)))))
     SET _remfieldname0 = (_remfieldname0+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname0 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname0)
   ENDIF
   SET rptsd->m_flags = 5
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremfieldname5 = _remfieldname5
   IF (_remfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remfieldname5,((size(
        __fieldname5) - _remfieldname5)+ 1),__fieldname5)))
    SET drawheight_fieldname5 = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remfieldname5 = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remfieldname5,((size(__fieldname5) -
       _remfieldname5)+ 1),__fieldname5)))))
     SET _remfieldname5 = (_remfieldname5+ rptsd->m_drawlength)
    ELSE
     SET _remfieldname5 = 0
    ENDIF
    SET growsum = (growsum+ _remfieldname5)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.250)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_fieldname0
   IF (ncalc=rpt_render
    AND _holdremfieldname0 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname0,((size(
        __fieldname0) - _holdremfieldname0)+ 1),__fieldname0)))
   ELSE
    SET _remfieldname0 = _holdremfieldname0
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.750)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = drawheight_fieldname5
   IF (ncalc=rpt_render
    AND _holdremfieldname5 > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremfieldname5,((size(
        __fieldname5) - _holdremfieldname5)+ 1),__fieldname5)))
   ELSE
    SET _remfieldname5 = _holdremfieldname5
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.500)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times140)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname7)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 1.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.250
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fieldname8)
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.500)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_FieldName12",build2("Instructions For Windows:",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 1.750)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 3.000
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_FieldName13",build2(concat("1. Insert provided disk into your computer",_crlf,
         '2. An Auto-Play window is displayed. Double-click the option to "Open folder to view files" and the contents of ',
         "the CD are ",_crlf,
         "displayed",_crlf,
         "Please note: If an auto-play window does not display, click the start button located in the lower left hand port",
         "ion of the ",_crlf,
         "computer screen, click My Computer (Windows XP, Vista) or Computer (Windows 7), and double-click the CD/DVD driv",
         "e",_crlf,"3. A window opens displaying the file RecordAccess.exe",_crlf,
         "4. Double-click the file RecordAccess.exe. You will be prompted with a welcome screen",
         _crlf,"5. Click Continue",_crlf,
         "6. You will be prompted for a location to save the included files. Click the ellipses () button to the right of",
         " the box. A window",_crlf,"allowing you to browse folders on your computer is displayed",
         _crlf,"7. Click Desktop and then OK",
         _crlf,
         "8. Click OK once again to confirm that you would like to save the selected files to your desktop",
         _crlf,
         "9. You will be prompted for your password that was provided to you. Enter the password exactly as it is depicted",
         _crlf,
         "Please note: the password is case sensitive",_crlf,
         "10. Click OK confirming the password was entered in correctly",_crlf,
         "11. If the password was entered correctly the file or files are saved to your desktop and you are prompted with ",
         "a confirmation ",_crlf,
         'message stating "All files were successfully unzipped". Click OK to close the window',_crlf,
         "Please note: If the password entered is incorrect, you will continue to be prompted for the correct password. If",
         " you click Skip or",_crlf,
         "Always Skip, your files will not be saved and an error message will be displayed explaining they were not succes",
         "sfully extracted",_crlf,
         "12. Locate the file or files on your desktop. Double click the file to view it"),char(0))),
      char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 5.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_FieldName14",build2("Instructions For Mac OS X:",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 5.250)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 3.750
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_FieldName15",build2(concat(
         "Please ensure you have WinZip Mac Edition installed or a compatible unzipping utility that is capable of unzip",
         "ping password ",_crlf,"protected .ZIP files",_crlf,
         _crlf,"1. Insert provided disk into your computer",_crlf,
         "2. Double-click your disk drive. A window opens displaying the file RecordAccess.exe",_crlf,
         "3. Click the file RecordAccess.exe and drag the file to your desktop",_crlf,
         "4. Ensure the file RecordAccess.exe is still selected on your desktop and click the File menu. Next, click the G",
         "et Info menu",_crlf,
         "5. A window opens displaying information about the RecordAccess.exe file",_crlf,
         "6. In the Name & Extension box, click to the right of the file name so that the cursor is immediately to the rig",
         "ht of the last ",_crlf,
         "character",_crlf,
         "7. Press the Delete key three times to remove the EXE portion of the filename. With the cursor now to the right ",
         "of the period, ",_crlf,
         "type ZIP. The filename should now read RecordAccess.zip. Press Enter",_crlf,
         "8. A message appears asking if you are sure you want to change the extension from .EXE to .ZIP. Confirm by click",
         "ing the Use .ZIP ",_crlf,
         "button",_crlf,"9. Close the file Info window",_crlf,
         "10. Double-click the file, RecordAccess.zip",
         _crlf,
         "11. Your computer's default unzipping application opens displaying the file or files located within the .ZIP fil",
         "e",_crlf,"12. Double-click the desired file to view",
         _crlf,
         "13. You will be prompted for your password that was provided to you. Enter the password exactly as it is depicte",
         "d",_crlf,"Please note: the password is case sensitive",
         _crlf,"14. Click OK confirming the password was entered correctly",_crlf,
         "15. If the password was entered correctly the file will open",_crlf,
         "Please note: if the password entered is incorrect, you will continue to be prompted for the correct password"
         ),char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 9.000)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.250
   SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_FieldName16",build2("Warning:",char(0))),char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety+ 9.250)
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 7.500
   SET rptsd->m_height = 0.563
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(uar_i18ngetmessage(_hi18nhandle,
       "DetailSection_FieldName17",build2(concat(
         "You should consider permanently deleting any files saved on public computer's in order to protect your privacy.",
         " Simply deleting",_crlf,
         "the file may not be enough. You may be required to empty the computers recycle bin as well. Please consider shre",
         "dding this ",
         _crlf,"document when it is no longer needed."),char(0))),char(0)))
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "CR_GENERATE_DISC_INFO_RPT"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
 CALL initializereport(0)
 CALL query1(0)
 CALL finalizereport(_sendto)
END GO
