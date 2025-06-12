CREATE PROGRAM ccl_get_image
 IF (validate(reply)=0)
  RECORD reply(
    1 imagedata = gvc
    1 imagedatasize = i4
    1 errorstatus = i4
    1 errorstatustext = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 DECLARE _output = vc WITH protect
 DECLARE _errstatus = i4 WITH protect
 DECLARE _errstatustext = vc WITH protect
 DECLARE _i18nhandle = i4 WITH protect
 DECLARE _lretval = i4 WITH protect
 SET modify maxvarlen 50000000
 SET _lretval = uar_i18nlocalizationinit(_i18nhandle,nullterm(curprog),nullterm(""),curcclrev)
 SET reply->status_data.status = "S"
 SET reply->status_data.subeventstatus.operationname = "CCL_GET_IMAGE"
 IF (validate(request)=1)
  IF (checkprg(cnvtupper(request->imageprogram)) > 0)
   CALL echo("found the program")
   SET reply->status_data.subeventstatus[1].targetobjectname = "errStatusText"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("EXECUTE ",cnvtupper(request->
     imageprogram)," ",request->params," go ")
   CALL parser(concat("EXECUTE ",cnvtupper(request->imageprogram)," ",request->params," go "))
   RETURN(0)
  ELSEIF (size(trim(request->imageprogram)) > 0)
   SET _errstatus = 3
   SET _errstatustext = concat(uar_i18ngetmessage(_i18nhandle,"errProgramNotFound",
     "No program found "),"(",request->imageprogram,")")
   SET reply->status_data.status = "F"
  ENDIF
 ELSE
  CALL echo(uar_i18ngetmessage(_i18nhandle,"req_rep_needed","need a request to run this program"))
  RETURN(1)
 ENDIF
 SET frec->file_name = build(request->imagelocation,request->imagename)
 IF (findfile(frec->file_name,4)=0)
  IF (findfile(frec->file_name) != 0)
   SET _errstatus = 2
   SET _errstatustext = uar_i18ngetmessage(_i18nhandle,"errReadPriv","No read permission on file")
  ELSEIF ((reply->status_data.status != "F"))
   SET _errstatus = 1
   SET _errstatustext = concat(uar_i18ngetmessage(_i18nhandle,"errNoFile","File not found: ")," (",
    frec->file_name,")")
  ENDIF
  SET reply->status_data.status = "F"
 ELSEIF ((reply->status_data.status="S"))
  CALL echo(frec->file_name)
  SET frec->file_buf = "rb"
  SET _lretval = cclio("OPEN",frec)
  IF (_lretval > 0
   AND (frec->file_desc != 0))
   SET frec->file_dir = 2
   SET _lretval = cclio("SEEK",frec)
   CALL echo(_lretval)
   IF (_lretval=0)
    SET filelen = cclio("TELL",frec)
    SET _lretval = memrealloc(_output,1,build("C",filelen))
    IF (_lretval > 0)
     SET frec->file_dir = 0
     SET _lretval = cclio("SEEK",frec)
     SET frec->file_buf = notrim(_output)
     SET _output = " "
     IF (_lretval=0)
      SET reply->imagedatasize = cclio("READ",frec)
      SET reply->imagedata = notrim(frec->file_buf)
      SET frec->file_buf = " "
     ELSE
      SET _errstatus = 40
      SET _errstatustext = uar_i18ngetmessage(_i18nhandle,"err40",
       "Error seeking file beginning (SEEK)")
     ENDIF
    ELSE
     SET _errstatus = 30
     SET _errstatustext = uar_i18ngetmessage(_i18nhandle,"err30",
      "Allocating memory for file read (MEMALLOC)")
    ENDIF
   ELSE
    SET _errstatus = 20
    SET _errstatustext = uar_i18ngetmessage(_i18nhandle,"err20","Error seeking file end (SEEK)")
   ENDIF
  ELSE
   SET _errstatus = 10
   SET _errstatustext = uar_i18ngetmessage(_i18nhandle,"err10","Error opening file (OPEN)")
  ENDIF
  IF ((frec->file_desc != 0))
   SET _lretval = cclio("CLOSE",frec)
   IF (_lretval=0)
    SET _errstatus = 60
    SET _errstatustext = uar_i18ngetmessage(_i18nhandle,"err99","Error opening file (close)")
   ENDIF
  ENDIF
 ENDIF
 CALL echo(_errstatus)
 SET reply->errorstatus = _errstatus
 SET reply->errorstatustext = _errstatustext
 SET reply->status_data.subeventstatus[1].targetobjectname = "errStatusText"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = _errstatustext
 RETURN(0)
END GO
