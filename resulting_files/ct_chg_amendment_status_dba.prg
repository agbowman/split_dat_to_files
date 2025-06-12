CREATE PROGRAM ct_chg_amendment_status:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cur_updt_cnt = 0
 SET amendment_num = 0
 SET amendment_status_cd = 0
 SET last_amendment_status_cd = 0
 SET prot_master_id = 0
 SELECT INTO "NL:"
  code_value.code_value
  FROM code_value cv
  WHERE cv.code_set=17274
   AND (cv.cdf_meaning=request->amendment_status_cdf)
  DETAIL
   amendment_status_cd = cv.code_value
  WITH nocounter
 ;end select
 SET lastamdnbr = 0
 SET lastamdid = 0
 SET pmid = prot_master_id
 EXECUTE ct_get_last_a_nbr
 IF ((lastamdnbr != - (9)))
  SELECT INTO "NL:"
   code_value.code_value
   FROM code_value cv
   WHERE cv.code_set=17274
    AND cv.cdf_meaning="SUPERCEDED"
   DETAIL
    last_amendment_status_cd = cv.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pa.*
   FROM prot_amendment pa
   WHERE pa.prot_amendment_id=lastamdid
   WITH nocounter, forupdate(pa)
  ;end select
  CALL echo("checking curqual - last amendment")
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  CALL echo("before update - last amendment")
  UPDATE  FROM prot_amendment pa
   SET pa.amendment_status_cd = last_amendment_status_cd
   WHERE pa.prot_amendment_id=lastamdid
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("before select - amend")
 SELECT INTO "nl:"
  pa.*
  FROM prot_amendment pa
  WHERE (pa.prot_amendment_id=request->prot_amendment_id)
  DETAIL
   cur_updt_cnt = pa.updt_cnt, prot_master_id = pa.prot_master_id
  WITH nocounter, forupdate(pa)
 ;end select
 CALL echo(build("prot_master_id:",prot_master_id))
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF ((cur_updt_cnt != request->prot_amendment_updt_cnt))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 CALL echo("before update - amend")
 UPDATE  FROM prot_amendment pa
  SET pa.amendment_status_cd = amendment_status_cd
  WHERE (pa.prot_amendment_id=request->prot_amendment_id)
 ;end update
 IF (curqual=0)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 CALL echo("before select - master")
 CALL echo(build("status_ind",request->prot_status_ind))
 IF ((request->prot_status_ind=1))
  SELECT INTO "nl:"
   pr.*
   FROM prot_master pr
   WHERE pr.prot_master_id=prot_master_id
   DETAIL
    cur_updt_cnt = pr.updt_cnt
   WITH nocounter, forupdate(pr)
  ;end select
  CALL echo("checking curqual- master")
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  CALL echo(build("checking updtcnt- master",cur_updt_cnt))
  IF ((cur_updt_cnt != request->prot_master_updt_cnt))
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  CALL echo("before update - master")
  UPDATE  FROM prot_master pr
   SET pr.prot_status_cd = amendment_status_cd
   WHERE pr.prot_master_id=prot_master_id
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reqinfo->commit_ind = 0
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
