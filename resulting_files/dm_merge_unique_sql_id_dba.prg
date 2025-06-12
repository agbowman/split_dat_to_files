CREATE PROGRAM dm_merge_unique_sql_id:dba
 IF (currdb="ORACLE")
  FREE RECORD usi_temp
  RECORD usi_temp(
    1 newname = vc
    1 tmp = vc
    1 temp = vc
    1 addtemp = f8
    1 fchr = f8
    1 ftmp = f8
    1 sqllen = i4
  )
  CALL echo("Calculating unique sql ID...")
  SET usi_reply->err_ind = error(usi_reply->err_msg,1)
  DECLARE y = i4
  IF (value(size(usi_request->qual,5)) > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(usi_request->qual,5)))
    DETAIL
     IF (textlen(trim(usi_request->qual[d.seq].str_from,3)) > 0)
      usi_temp->newname = "", usi_temp->addtemp = 0, usi_temp->tmp = "",
      usi_temp->addtemp = 0, usi_temp->fchr = 0, usi_temp->sqllen = 0,
      usi_temp->ftmp = 0, usi_temp->sqllen = textlen(trim(usi_request->qual[d.seq].str_from,3)),
      usi_temp->newname = cnvtstring(usi_temp->sqllen),
      y = 0
      WHILE ((y < usi_temp->sqllen))
        y = (y+ 1), usi_temp->fchr = ichar(substring(y,1,trim(usi_request->qual[d.seq].str_from,3))),
        usi_temp->ftmp = ((usi_temp->ftmp+ (usi_temp->fchr/ y))+ mod(usi_temp->fchr,y)),
        usi_temp->ftmp = (usi_temp->ftmp+ (usi_temp->ftmp/ y))
        IF (mod(y,2)=0)
         usi_temp->ftmp = (usi_temp->ftmp+ (usi_temp->ftmp/ y)), usi_temp->ftmp = (usi_temp->ftmp+ y)
        ENDIF
      ENDWHILE
      usi_temp->addtemp = usi_temp->ftmp, usi_temp->tmp = cnvtalphanum(format(usi_temp->addtemp,
        "#############.#######;L;F")), usi_temp->newname = trim(concat(usi_temp->newname,usi_temp->
        tmp),3),
      usi_request->qual[d.seq].str_to = usi_temp->newname
     ELSE
      usi_request->qual[d.seq].str_to = ""
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF (currdb="DB2UDB")
  FREE RECORD usi_temp
  RECORD usi_temp(
    1 newname = vc
    1 tmp = vc
    1 temp = vc
    1 addtemp = f8
    1 fchr = i4
    1 ftmp = f8
    1 sqllen = i4
  )
  CALL echo("Calculating unique sql ID...")
  SET usi_reply->err_ind = error(usi_reply->err_msg,1)
  DECLARE y = i4
  IF (value(size(usi_request->qual,5)) > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(usi_request->qual,5)))
    DETAIL
     IF (textlen(trim(usi_request->qual[d.seq].str_from,3)) > 0)
      usi_temp->newname = "", usi_temp->addtemp = 0, usi_temp->tmp = "",
      usi_temp->addtemp = 0, usi_temp->fchr = 0, usi_temp->sqllen = 0,
      usi_temp->ftmp = 0, usi_temp->sqllen = textlen(trim(usi_request->qual[d.seq].str_from,3)),
      usi_temp->newname = cnvtstring(usi_temp->sqllen),
      y = 0
      WHILE ((y < usi_temp->sqllen))
        y = (y+ 1), usi_temp->fchr = ichar(substring(y,1,trim(usi_request->qual[d.seq].str_from,3))),
        usi_temp->ftmp = ((usi_temp->ftmp+ (usi_temp->fchr/ y))+ mod(usi_temp->fchr,y)),
        usi_temp->ftmp = (usi_temp->ftmp+ (usi_temp->ftmp/ y))
        IF (mod(y,2)=0)
         usi_temp->ftmp = (usi_temp->ftmp+ (usi_temp->ftmp/ y)), usi_temp->ftmp = (usi_temp->ftmp+ y)
        ENDIF
      ENDWHILE
      usi_temp->addtemp = usi_temp->ftmp, usi_temp->tmp = cnvtalphanum(format(usi_temp->addtemp,
        "#############.############;L;F")), usi_temp->newname = trim(concat(usi_temp->newname,
        usi_temp->tmp),3),
      usi_request->qual[d.seq].str_to = substring(1,(textlen(usi_temp->newname) - 1),usi_temp->
       newname)
     ELSE
      usi_request->qual[d.seq].str_to = ""
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET usi_reply->err_ind = error(usi_reply->err_msg,0)
END GO
