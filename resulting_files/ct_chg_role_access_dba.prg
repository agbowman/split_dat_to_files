CREATE PROGRAM ct_chg_role_access:dba
 RECORD reply(
   1 qual[*]
     2 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_to_chg = size(request->qual,5)
 SET failures = 0
 SET cur_updt_cnt = 0
 SET x = 1
 SET next_code = 0.0
 SET found = 0
 CALL echo("number:")
 CALL echo(nbr_to_chg)
#start_loop
 FOR (x = x TO nbr_to_chg)
   SET failed = "F"
   CALL echo("before select - updtcnt")
   SELECT INTO "nl:"
    pr.*
    FROM prot_role_access pr
    WHERE (pr.prot_role_cd=request->qual[x].prot_role_cd)
     AND (pr.functionality_cd=request->qual[x].functionality_cd)
     AND pr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND (pr.logical_domain_id=domain_reply->logical_domain_id)
    DETAIL
     cur_updt_cnt = pr.updt_cnt
    WITH nocounter, forupdate(pr)
   ;end select
   IF (curqual=0)
    GO TO next_row
   ENDIF
   CALL echo(build("before select - curqual - cur updt cnt:",cur_updt_cnt))
   CALL echo(build("before select - curqual - updt cnt:",request->qual[x].updt_cnt))
   IF ((cur_updt_cnt != request->qual[x].updt_cnt))
    SET failed = "T"
    GO TO next_row
   ENDIF
   CALL echo("before update")
   UPDATE  FROM prot_role_access pr
    SET pr.access_mask = request->qual[x].access_mask, pr.updt_dt_tm = cnvtdatetime(sysdate), pr
     .updt_id = reqinfo->updt_id,
     pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo->updt_task, pr.updt_cnt = (pr
     .updt_cnt+ 1)
    WHERE (pr.prot_role_cd=request->qual[x].prot_role_cd)
     AND (pr.functionality_cd=request->qual[x].functionality_cd)
     AND pr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND (pr.logical_domain_id=domain_reply->logical_domain_id)
    WITH nocounter
   ;end update
   CALL echo("after update")
   IF (curqual=0)
    GO TO next_row
   ENDIF
 ENDFOR
 GO TO exit_script
#next_row
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET x += 1
  GO TO start_loop
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 SET last_mod = "002"
 SET mod_date = "February 7, 2019"
END GO
