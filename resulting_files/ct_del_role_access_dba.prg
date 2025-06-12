CREATE PROGRAM ct_del_role_access:dba
 RECORD reply(
   1 qual[*]
     2 id = f8
     2 debug = vc
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
 SET primary_id = 0.0
 SET num_to_del = size(request->qual,5)
 SET cur_updt_cnt = 0
 SET failed = "Z"
 CALL echo("num to del")
 CALL echo(num_to_del)
 FOR (i = 1 TO num_to_del)
   SET failed = "N"
   SELECT INTO "nl:"
    pr.*
    FROM prot_role_access pr
    WHERE (pr.functionality_cd=request->qual[i].functionality_cd)
     AND (pr.prot_role_cd=request->qual[i].prot_role_cd)
     AND pr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND (pr.logical_domain_id=domain_reply->logical_domain_id)
    DETAIL
     cur_updt_cnt = pr.updt_cnt
    WITH nocounter, forupdate(pr)
   ;end select
   CALL echo(build("curqual",curqual))
   CALL echo(build("curupdtcnt",cur_updt_cnt))
   IF (curqual > 0
    AND (cur_updt_cnt=request->qual[i].updt_cnt))
    CALL echo("before update")
    UPDATE  FROM prot_role_access pr
     SET pr.end_effective_dt_tm = cnvtdatetime(sysdate), pr.updt_dt_tm = cnvtdatetime(curdate,curtime
       ), pr.updt_id = reqinfo->updt_id,
      pr.updt_cnt = (pr.updt_cnt+ 1)
     WHERE (pr.functionality_cd=request->qual[i].functionality_cd)
      AND (pr.prot_role_cd=request->qual[i].prot_role_cd)
      AND pr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND (pr.logical_domain_id=domain_reply->logical_domain_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
    ENDIF
   ELSE
    SET failed = "T"
   ENDIF
   CALL echo("after ids")
 ENDFOR
 SET reqinfo->commit_ind = 1
 IF (failed="Z")
  SET reply->status_data.status = "Z"
 ELSE
  IF (failed="T")
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL echo(build("status",reply->status_data.status))
 SET last_mod = "002"
 SET mod_date = "September 16, 2020"
END GO
