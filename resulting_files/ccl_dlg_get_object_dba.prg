CREATE PROGRAM ccl_dlg_get_object:dba
 PROMPT
  "search pattern " = "",
  "object type ind " = "T",
  "showmb" = 0
  WITH srctbl, objtype, emsg
 EXECUTE ccl_prompt_api_dataset "dataset", "autoset"
 DECLARE _ccl_object_group_number_ = i2 WITH protect, noconstant(- (1))
 DECLARE getgroup(arg=vc) = i2 WITH protect
 SET strname = getprogramname(trim(cnvtupper( $SRCTBL)))
 SET _ccl_object_group_number_ = getgroup(trim( $SRCTBL))
 SET static = setstatus("Z")
 IF ( NOT (cnvtupper( $OBJTYPE) IN ("*", "D", "M", "P", "T",
 "V", "E")))
  CALL setmessageboxex(concat("Invalid object type code '",trim( $SRCTBL),"'"),"Get Object Type",
   _mb_error_)
  RETURN
 ENDIF
 IF (isvalidationquery(0))
  CALL setvalidation(false)
  IF ((_ccl_object_group_number_=- (1)))
   SELECT DISTINCT INTO "nl:"
    dp.object_name, dp.group, dp.app_major_version,
    dp.app_minor_version, dp.datestamp
    FROM dprotect dp
    WHERE (dp.object= $OBJTYPE)
     AND dp.object_name=patstring(strname)
    ORDER BY dp.object_name
    HEAD REPORT
     stat = makedataset(100)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH nocounter, reporthelp, check,
     maxqual(dp,1)
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    dp.object_name, dp.group, dp.app_major_version,
    dp.app_minor_version, dp.datestamp
    FROM dprotect dp
    WHERE (dp.object= $OBJTYPE)
     AND dp.object_name=patstring(strname)
     AND dp.group=_ccl_object_group_number_
    ORDER BY dp.object_name
    HEAD REPORT
     stat = makedataset(100)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH nocounter, reporthelp, check,
     maxqual(dp,1)
   ;end select
  ENDIF
  IF (recordcount(0) > 0)
   CALL setvalidation(true)
  ENDIF
  IF ( NOT (isvalid(0))
   AND ( $EMSG=1))
   CALL setmessageboxex(concat("No object name matching '",trim(strname),"'"),
    "Object Validation Check",_mb_warn_)
  ENDIF
 ELSE
  IF (trim(strname)="\*")
   CALL setmessageboxex("Please narrow the search","Get Object",_mb_error_)
   CALL setstatus("S")
   RETURN
  ENDIF
  IF ((_ccl_object_group_number_=- (1)))
   SELECT DISTINCT INTO "nl:"
    dp.object_name, dp.group, dp.app_major_version,
    dp.app_minor_version, dp.datestamp
    FROM dprotect dp
    WHERE (dp.object= $OBJTYPE)
     AND dp.object_name=patstring(strname)
    ORDER BY dp.object_name
    HEAD REPORT
     stat = makedataset(100)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH nocounter, reporthelp, check,
     nullreport
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    dp.object_name, dp.group, dp.app_major_version,
    dp.app_minor_version, dp.datestamp
    FROM dprotect dp
    WHERE (dp.object= $OBJTYPE)
     AND dp.object_name=patstring(strname)
     AND dp.group=_ccl_object_group_number_
    ORDER BY dp.object_name
    HEAD REPORT
     stat = makedataset(100)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH nocounter, reporthelp, check,
     nullreport
   ;end select
  ENDIF
  SET statc = setstatus("S")
 ENDIF
 SUBROUTINE getprogramname(arg)
   SET pos = findstring(":",arg)
   IF (pos > 1)
    RETURN(substring(0,(pos - 1),arg))
   ENDIF
   RETURN(arg)
 END ;Subroutine
 SUBROUTINE getgroup(arg)
   DECLARE pos = i2 WITH private
   DECLARE grp = vc WITH private
   DECLARE grpn = vc WITH private
   SET pos = findstring(":",arg)
   IF (pos > 1)
    SET grp = substring((pos+ 1),(textlen(arg) - pos),arg)
    IF (cnvtupper(grp)="DBA")
     RETURN(0)
    ENDIF
    IF (cnvtupper(substring(1,5,grp))="GROUP")
     SET grpn = substring(6,textlen(grp),grp)
     IF (textlen(grpn) > 0)
      RETURN(cnvtint(grpn))
     ENDIF
    ENDIF
   ENDIF
   RETURN(- (1))
 END ;Subroutine
END GO
