CREATE PROGRAM ccl_readfile:dba
 PROMPT
  "Enter MINE/CRT/printer/file:" = "MINE",
  "Enter string log name:" = "*",
  "Orientation:" = 0,
  "Page Height(in):" = 11,
  "Page Width(in):" = 8.5
  WITH outdev, filename, orientation,
  pgheight, pgwidth
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4
 DECLARE i18n_file_not_found = vc
 SET i18nhandle = 0
 SET lretval = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET i18n_file_not_found = uar_i18ngetmessage(i18nhandle,"KeyGet1",
  "File does not exist or cannot be opened: ")
 DECLARE pcount1 = i4
 DECLARE stat = i4
 DECLARE pos = i4
 RECORD frec(
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 RECORD rec1(
   1 qual[*]
     2 line = vc
 )
 IF (findfile(trim( $FILENAME,3))=1)
  SET frec->file_name = value( $FILENAME)
  SET frec->file_buf = "r"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = notrim(fillstring(2000," "))
  IF ((frec->file_desc != 0))
   SET stat = 1
   SET stat2 = alterlist(rec1->qual,100)
   SET pcount1 = 0
   WHILE (stat > 0)
    SET stat = cclio("GETS",frec)
    IF (stat > 0)
     SET pos = findstring(char(0),frec->file_buf)
     SET pcount1 += 1
     IF (mod(pcount1,10)=1
      AND pcount1 > 100)
      SET stat2 = alterlist(rec1->qual,(pcount1+ 9))
     ENDIF
     SET rec1->qual[pcount1].line = trim(substring(1,pos,frec->file_buf))
    ENDIF
   ENDWHILE
   SET stat = cclio("CLOSE",frec)
  ENDIF
  SET stat1 = alterlist(rec1->qual,pcount1)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = value(size(rec1->qual,5)))
   DETAIL
    rec1->qual[d.seq].line, row + 1
   WITH nocounter, format = variable, maxcol = 2003,
    maxrow = 1
  ;end select
  SET rptreport->m_reportname =  $FILENAME
  SET rptreport->m_pagewidth =  $PGWIDTH
  SET rptreport->m_pageheight =  $PGHEIGHT
  SET rptreport->m_orientation =  $ORIENTATION
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   DETAIL
    col 0, i18n_file_not_found,  $FILENAME
   WITH nocounter
  ;end select
 ENDIF
END GO
