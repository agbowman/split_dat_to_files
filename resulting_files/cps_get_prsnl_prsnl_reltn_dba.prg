CREATE PROGRAM cps_get_prsnl_prsnl_reltn:dba
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
   1 person_id = f8
   1 prsnl_qual = i4
   1 prsnl[*]
     2 prsnl_id = f8
     2 prsnl_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->person_id = request->person_id
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE pab_cd = f8 WITH public, noconstant(0.0)
 SET code_set = 375
 SET cdf_meaning = "PAB"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pab_cd)
 IF (pab_cd < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("Failed to retrieve the code_value for cdf_meaning ",trim(cdf_meaning),
   " from code_set ",trim(cnvtstring(code_set)))
  GO TO exit_script
 ENDIF
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "NL:"
  ppr.person_id, p.name_full_formatted
  FROM prsnl_prsnl_reltn ppr,
   prsnl p
  PLAN (ppr
   WHERE (ppr.person_id=request->person_id)
    AND ppr.prsnl_prsnl_reltn_cd=pab_cd
    AND ppr.active_ind=true
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=ppr.related_person_id
    AND p.username > " "
    AND p.active_ind=true
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
  HEAD REPORT
   knt = 0, stat = alterlist(reply->prsnl,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->prsnl,(knt+ 9))
   ENDIF
   reply->prsnl[knt].prsnl_id = p.person_id, reply->prsnl[knt].prsnl_name = p.name_full_formatted
  FOOT REPORT
   reply->prsnl_qual = knt, stat = alterlist(reply->prsnl,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PRSNL_PRSNL_RELTN"
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
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
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
 SET cps_script_version = "001 11/11/02 SF3151"
END GO
