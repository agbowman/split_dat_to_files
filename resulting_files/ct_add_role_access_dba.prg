CREATE PROGRAM ct_add_role_access:dba
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
 SET primary_id = 0.0
 SET num_to_add = size(request->qual,5)
 CALL echo("num to add")
 CALL echo(num_to_add)
 FOR (i = 1 TO num_to_add)
   SELECT INTO "nl:"
    num = seq(protocol_def_seq,nextval)"########################;rpO"
    FROM dual
    DETAIL
     primary_id = cnvtreal(num)
    WITH format, counter
   ;end select
   CALL echo("before id")
   CALL echo(primary_id)
   INSERT  FROM prot_role_access ps
    SET ps.prot_role_access_id = primary_id, ps.functionality_cd = request->qual[i].functionality_cd,
     ps.access_mask = request->qual[i].access_mask,
     ps.prot_role_cd = request->qual[i].prot_role_cd, ps.updt_dt_tm = cnvtdatetime(curdate,curtime),
     ps.updt_id = reqinfo->updt_id,
     ps.updt_task = reqinfo->updt_task, ps.updt_applctx = reqinfo->updt_applctx, ps.updt_cnt = 0,
     ps.beg_effective_dt_tm = cnvtdatetime(curdate,curtime), ps.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00:00.00"), ps.logical_domain_id = domain_reply->logical_domain_id
    WITH nocounter
   ;end insert
   CALL echo("after dates")
   SET stat = alterlist(reply->qual,i)
   SET reply->qual[i].id = primary_id
   CALL echo("after ids")
   CALL echo(primary_id)
 ENDFOR
 SET reqinfo->commit_ind = 0
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "February 8, 2019"
END GO
