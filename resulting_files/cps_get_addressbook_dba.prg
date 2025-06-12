CREATE PROGRAM cps_get_addressbook:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 prsnl_qual = i4
   1 prsnl[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 name_last = vc
     2 name_first = vc
     2 name_last_key = vc
     2 name_first_key = vc
     2 email = vc
   1 status_data
     2 status = c1
     2 subeventstatus[0]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET status_cd = 0.0
 SET active_cd = 0.0
 IF ((reqdata->active_status_cd < 1))
  SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_cd)
  IF (active_cd < 1)
   SET failed = select_error
   SET tabe_name = "CODE_VALUE"
   SET serrmsg = "Failure finding the code_value for ACTIVE from code_set 48"
   GO TO exit_script
  ENDIF
 ELSE
  SET active_cd = reqdata->active_status_cd
 ENDIF
 IF ((reqdata->auth_auth_cd < 1))
  SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,status_cd)
  IF (status_cd < 1)
   SET failed = select_error
   SET tabe_name = "CODE_VALUE"
   SET serrmsg = "Failure finding the code_value for AUTH from code_set 8"
   GO TO exit_script
  ENDIF
 ELSE
  SET status_cd = reqdata->auth_auth_cd
 ENDIF
 CALL echorecord(request)
 CALL echo(build("***   active_cd :",active_cd))
 CALL echo(build("***   status_cd :",status_cd))
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  p.person_id, p.name_last_key, p.name_first_key,
  p.name_full_formatted
  FROM prsnl p
  PLAN (p
   WHERE ((p.person_id+ 0) > 0)
    AND p.position_cd > 0
    AND trim(p.name_last_key) > " "
    AND trim(p.name_first_key) > " "
    AND p.name_full_formatted > " "
    AND (p.prsnl_type_cd=request->prsnl_type_cd)
    AND p.active_ind=1
    AND p.data_status_cd=status_cd
    AND p.active_status_cd=active_cd
    AND trim(p.username) > " "
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY p.name_last_key, p.name_first_key, p.name_full_formatted,
   p.person_id
  HEAD REPORT
   kount = 0, stat = alterlist(reply->prsnl,1000)
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,1000)=1
    AND kount != 1)
    stat = alterlist(reply->prsnl,(kount+ 999))
   ENDIF
   reply->prsnl[kount].person_id = p.person_id, reply->prsnl[kount].name_last_key = p.name_last_key,
   reply->prsnl[kount].name_first_key = p.name_first_key,
   reply->prsnl[kount].name_full_formatted = p.name_full_formatted, reply->prsnl[kount].name_last = p
   .name_last, reply->prsnl[kount].name_first = p.name_first,
   reply->prsnl[kount].email = p.email
  FOOT REPORT
   stat = alterlist(reply->prsnl,kount), reply->prsnl_qual = kount
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PRSNL"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "PCO_SEQ GENERATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->prsnl_qual > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET pco_script_version = "007 01/05/05 SF3151"
END GO
