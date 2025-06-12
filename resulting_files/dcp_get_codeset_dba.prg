CREATE PROGRAM dcp_get_codeset:dba
 RECORD reply(
   1 code_set_qual[*]
     2 code_set = i4
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4
 DECLARE temp_code_set = c40
 SET reply->status_data.status = "F"
 SET count = 0
 SET temp_code_set = fillstring(255," ")
 SET temp_code_set = build(cnvtstring(request->code_set),"*")
 IF ((request->entered_ind=1))
  IF ((request->code_set > 0))
   SELECT INTO "nl:"
    cs.code_set
    FROM code_value_set cs
    WHERE (cs.code_set=request->code_set)
    ORDER BY cs.code_set
    DETAIL
     count = (count+ 1)
     IF (count > size(reply->code_set_qual,5))
      stat = alterlist(reply->code_set_qual,(count+ 2))
     ENDIF
     reply->code_set_qual[count].code_set = cs.code_set, reply->code_set_qual[count].display = cs
     .display
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET count = (count+ 1)
    IF (count > size(reply->code_set_qual,5))
     SET stat = alterlist(reply->code_set_qual,(count+ 2))
    ENDIF
    SET reply->code_set_qual[count].code_set = 0
    SET reply->code_set_qual[count].display = " "
   ENDIF
   SET stat = alterlist(reply->code_set_qual,count)
  ELSEIF ((request->display != "  "))
   SELECT INTO "nl:"
    cs.display
    FROM code_value_set cs
    WHERE cnvtupper(cs.display)=cnvtupper(request->display)
    ORDER BY cs.display
    DETAIL
     count = (count+ 1)
     IF (count > size(reply->code_set_qual,5))
      stat = alterlist(reply->code_set_qual,(count+ 2))
     ENDIF
     reply->code_set_qual[count].code_set = cs.code_set, reply->code_set_qual[count].display = cs
     .display
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET count = (count+ 1)
    IF (count > size(reply->code_set_qual,5))
     SET stat = alterlist(reply->code_set_qual,(count+ 2))
    ENDIF
    SET reply->code_set_qual[count].code_set = 0
    SET reply->code_set_qual[count].display = " "
   ENDIF
  ENDIF
  SET stat = alterlist(reply->code_set_qual,count)
 ELSE
  IF ((request->code_set > 0))
   SELECT INTO "nl:"
    cs.code_set
    FROM code_value_set cs
    WHERE cnvtstring(cs.code_set)=patstring(temp_code_set)
    ORDER BY cs.code_set
    DETAIL
     count = (count+ 1)
     IF (count > size(reply->code_set_qual,5))
      stat = alterlist(reply->code_set_qual,(count+ 2))
     ENDIF
     reply->code_set_qual[count].code_set = cs.code_set, reply->code_set_qual[count].display = cs
     .display
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->code_set_qual,count)
  ELSEIF ((request->display != "  "))
   SET temp_display = fillstring(255," ")
   SET temp_display = build(cnvtupper(request->display),"*")
   SELECT INTO "nl:"
    cs.display
    FROM code_value_set cs
    WHERE cnvtupper(cs.display)=patstring(temp_display)
    ORDER BY cs.display
    DETAIL
     count = (count+ 1)
     IF (count > size(reply->code_set_qual,5))
      stat = alterlist(reply->code_set_qual,(count+ 2))
     ENDIF
     reply->code_set_qual[count].code_set = cs.code_set, reply->code_set_qual[count].display = cs
     .display
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->code_set_qual,count)
  ENDIF
 ENDIF
 IF (count > 0)
  SET reply->status_data.status = "S"
 ELSEIF (count=0)
  SET reply->status_data.status = "Z"
 ENDIF
END GO
