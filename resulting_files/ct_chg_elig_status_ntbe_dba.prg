CREATE PROGRAM ct_chg_elig_status_ntbe:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 SET reply->status_data.status = "F"
 SET x = 0
 SET y = 0
 SET false = 0
 SET mrn = 0.0
 SET enrolling = 0.0
 SET eligible = 0.0
 SET pending = 0.0
 SET elig_ntbe = 0.0
 SET pend_ntbe = 0.0
 SET new_ntbe = 0.0
 SET numofprotocols = size(request->protocols,5)
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 SET cset = 17285
 SET cmean = "PEND_NTBE"
 EXECUTE ct_get_cv
 SET pend_ntbe = cval
 SET cset = 17285
 SET cmean = "ELIG_NTBE"
 EXECUTE ct_get_cv
 SET elig_ntbe = cval
 SET cset = 17285
 SET cmean = "PENDING"
 EXECUTE ct_get_cv
 SET pending = cval
 SET cset = 17285
 SET cmean = "ELIGIBLE"
 EXECUTE ct_get_cv
 SET ineligible = cval
 CALL echo(build("ECHO   lock  row to update"))
 SELECT INTO "nl:"
  pt_elig_tracking.*
  FROM pt_elig_tracking pet
  WHERE (pet.pt_elig_tracking=request->pteligtrackingid)
  DETAIL
   IF (pet.elig_status_cd=eligible)
    new_ntbe = elig_ntbe
   ELSE
    IF (pet.elig_status_cd=pending)
     new_ntbe = pend_ntbe
    ENDIF
   ENDIF
  WITH nocounter, forupdate(pet)
 ;end select
 IF (curqual=1)
  IF (new_ntbe != 0)
   UPDATE  FROM pt_elig_tracking pet
    SET pet.elig_status_cd = new_ntbe, pet.reason_ineligible_ce = request->reasoncd, pet.updt_cnt = (
     pet.updt_cnt+ 1),
     pet.updt_applctx = reqinfo->updt_applctx, pet.updt_task = reqinfo->updt_task, pet.updt_id =
     reqinfo->updt_id,
     pet.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE (pet.elig_status_cd=request->pteligtrackingid)
    WITH nocounter
   ;end update
   IF (curqual=1)
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SET reply->status_data.status = "F"
  ENDIF
 ELSE
  SET reply->status_data.status = "L"
 ENDIF
 CALL echo(build("Reply->status_data->status =",reply->status_data.status))
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd = (debug_code_cntd+ 1)
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
