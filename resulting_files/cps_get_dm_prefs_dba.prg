CREATE PROGRAM cps_get_dm_prefs:dba
 RECORD reply(
   1 qual[*]
     2 pref_id = f8
     2 application_nbr = i4
     2 person_id = f8
     2 pref_domain = vc
     2 pref_section = vc
     2 pref_name = vc
     2 pref_nbr = i4
     2 pref_cd = f8
     2 pref_dt_tm = dq8
     2 pref_str = vc
     2 parent_entity_id = f8
     2 parent_entity_name = c32
     2 reference_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 SET errcode = 1
 SET errmsg = fillstring(132," ")
 SET errcnt = 0
 SET wherestring = fillstring(2000," ")
 SET bfound = false
 SET x = 0
 SET reply->status_data.status = "F"
 SET count1 = 0
 FOR (x = 1 TO value(size(request->qual,5)))
   SET wherestring = concat(trim(wherestring)," (")
   IF ((request->qual[x].pref_id > 0))
    SET bfound = true
    SET wherestring = concat(trim(wherestring)," dp.pref_id = ",cnvtstring(request->qual[x].pref_id))
   ENDIF
   IF ((request->qual[x].application_nbr > 0))
    IF (bfound=true)
     SET wherestring = concat(trim(wherestring)," and ")
    ENDIF
    SET bfound = true
    SET wherestring = concat(trim(wherestring)," dp.application_nbr = ",cnvtstring(request->qual[x].
      application_nbr))
   ENDIF
   IF ((request->qual[x].person_id > 0))
    IF (bfound=true)
     SET wherestring = concat(trim(wherestring)," and ")
    ENDIF
    SET bfound = true
    SET wherestring = concat(trim(wherestring)," dp.person_id = ",cnvtstring(request->qual[x].
      person_id))
   ENDIF
   IF ((request->qual[x].pref_domain > " "))
    IF (bfound=true)
     SET wherestring = concat(trim(wherestring)," and ")
    ENDIF
    SET bfound = true
    SET wherestring = concat(trim(wherestring)," dp.pref_domain = '",request->qual[x].pref_domain,"'"
     )
   ENDIF
   IF ((request->qual[x].pref_section > " "))
    IF (bfound=true)
     SET wherestring = concat(trim(wherestring)," and ")
    ENDIF
    SET bfound = true
    SET wherestring = concat(trim(wherestring)," dp.pref_section = '",request->qual[x].pref_section,
     "'")
   ENDIF
   IF ((request->qual[x].pref_name > " "))
    IF (bfound=true)
     SET wherestring = concat(trim(wherestring)," and ")
    ENDIF
    SET wherestring = concat(trim(wherestring)," dp.pref_name = '",request->qual[x].pref_name,"'")
   ENDIF
   SET bfound = false
   IF (x < value(size(request->qual,5)))
    SET wherestring = concat(trim(wherestring)," ) or ")
   ELSE
    SET wherestring = concat(trim(wherestring)," ) ")
   ENDIF
 ENDFOR
 IF (trim(wherestring)=" ")
  SET reply->status_data.subeventstatus[1].operationname = "NOTHING TO BUILD"
  SET reply->status_data.subeventstatus[1].operationstatus = "FAIL"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BUILD WHERE STRING"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "FAIL"
  SET failed = "T"
  SET reply->status_data.status = "Z"
  GO TO script_error
 ENDIF
 SELECT INTO "NL:"
  dp.pref_id
  FROM dm_prefs dp
  WHERE parser(wherestring)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].pref_id = dp
   .pref_id,
   reply->qual[count1].application_nbr = dp.application_nbr, reply->qual[count1].pref_domain = dp
   .pref_domain, reply->qual[count1].pref_section = dp.pref_section,
   reply->qual[count1].pref_name = dp.pref_name, reply->qual[count1].parent_entity_id = dp
   .parent_entity_id, reply->qual[count1].parent_entity_name = dp.parent_entity_name,
   reply->qual[count1].person_id = dp.person_id, reply->qual[count1].pref_cd = dp.pref_cd, reply->
   qual[count1].pref_dt_tm = dp.pref_dt_tm,
   reply->qual[count1].pref_nbr = dp.pref_nbr, reply->qual[count1].pref_str = dp.pref_str, reply->
   qual[count1].reference_ind = dp.reference_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET PREFERENCES"
  SET reply->status_data.subeventstatus[1].operationstatus = "FAIL"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DM_PREFS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ZERO"
  SET failed = "T"
  IF ((errors->err_cnt > 1))
   SET reply->status_data.status = "F"
   GO TO error_checking
  ELSE
   SET reply->status_data.status = "Z"
   GO TO script_error
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#error_checking
 WHILE (errcode != 0)
   SET errcode = error(errmsg,0)
   SET errcnt = (errcnt+ 1)
   SET stat = alterlist(errors->err,errcnt)
   SET errors->err_cnt = errcnt
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
 ENDWHILE
#script_error
 CALL echo("-->Script Problem!!")
 CALL echo(concat("-->Status:         <",reply->status_data.status,">"))
 CALL echo(concat("-->Op Name:        <",reply->status_data.subeventstatus[1].operationname,">"))
 CALL echo(concat("-->Op Status:      <",reply->status_data.subeventstatus[1].operationstatus,">"))
 CALL echo(concat("-->Target Name:    <",reply->status_data.subeventstatus[1].targetobjectname,">"))
 CALL echo(concat("-->Target Value:   <",reply->status_data.subeventstatus[1].targetobjectvalue,">"))
#exit_script
 SET last_mod = "000"
END GO
