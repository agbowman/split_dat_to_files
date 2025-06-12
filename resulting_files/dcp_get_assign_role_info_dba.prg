CREATE PROGRAM dcp_get_assign_role_info:dba
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
 RECORD reply(
   1 assignment_type_cd = f8
   1 role_qual[*]
     2 clin_role_type_cd = f8
     2 pos_qual[*]
       3 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM assign_clinrole_r acr,
   position_role_type prt
  PLAN (acr
   WHERE (acr.assignment_type_cd=request->assignment_type_cd))
   JOIN (prt
   WHERE prt.role_type_cd=outerjoin(acr.clin_role_type_cd)
    AND prt.active_ind=outerjoin(1)
    AND prt.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND prt.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
  HEAD REPORT
   reply->assignment_type_cd = request->assignment_type_cd, rknt = 0, stat = alterlist(reply->
    role_qual,10)
  HEAD acr.clin_role_type_cd
   rknt = (rknt+ 1)
   IF (mod(rknt,10)=1
    AND rknt != 1)
    stat = alterlist(reply->role_qual,(rknt+ 9))
   ENDIF
   reply->role_qual[rknt].clin_role_type_cd = acr.clin_role_type_cd, pknt = 0, stat = alterlist(reply
    ->role_qual[rknt].pos_qual,10)
  DETAIL
   IF (prt.position_role_type_id > 0)
    pknt = (pknt+ 1)
    IF (mod(pknt,10)=1
     AND pknt != 1)
     stat = alterlist(reply->role_qual[rknt].pos_qual,(pknt+ 9))
    ENDIF
    reply->role_qual[rknt].pos_qual[pknt].position_cd = prt.position_cd
   ENDIF
  FOOT  acr.clin_role_type_cd
   stat = alterlist(reply->role_qual[rknt].pos_qual,pknt)
  FOOT REPORT
   stat = alterlist(reply->role_qual,rknt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ASSIGN_CLINROLE_R"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
  ELSEIF (failed=exe_error)
   SET reply->status_data.subeventstatus[1].operationname = "EXECUTION"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSEIF (size(reply->role_qual,5) < 1)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_ver = "000 03/29/05 SF3151"
END GO
