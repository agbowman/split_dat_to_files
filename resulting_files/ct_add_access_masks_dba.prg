CREATE PROGRAM ct_add_access_masks:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE num_to_add = i2 WITH private, noconstant(0)
 DECLARE cur_updt_cnt = i2 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH private, noconstant("F")
 SET last_mod = "003"
 SET mod_date = "July 20, 2006"
 SET reply->status_data.status = "F"
 SET num_to_add = size(request->qual,5)
 SET failed = "F"
 FOR (i = 1 TO num_to_add)
   IF ((request->qual[i].updt_cnt=- (1)))
    CALL echo("new row")
    INSERT  FROM entity_access ro
     SET ro.entity_access_id = seq(protocol_def_seq,nextval), ro.prot_amendment_id = request->qual[i]
      .amendment_id, ro.person_id = request->qual[i].person_id,
      ro.functionality_cd = request->qual[i].functionality_cd, ro.access_mask = request->qual[i].
      access_mask, ro.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      ro.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), ro.updt_dt_tm = cnvtdatetime(
       curdate,curtime3), ro.updt_id = reqinfo->updt_id,
      ro.updt_applctx = reqinfo->updt_applctx, ro.updt_task = reqinfo->updt_task, ro.updt_cnt = 0
     WITH nocounter
    ;end insert
   ELSE
    CALL echo("change req")
    SELECT INTO "nl:"
     pr.*
     FROM entity_access pr
     WHERE (pr.entity_access_id=request->qual[i].entity_access_id)
     DETAIL
      cur_updt_cnt = pr.updt_cnt
     WITH nocounter, forupdate(pr)
    ;end select
    IF (curqual > 0)
     IF ((cur_updt_cnt=request->qual[i].updt_cnt))
      CALL echo("before update")
      UPDATE  FROM entity_access pr
       SET pr.access_mask = request->qual[i].access_mask, pr.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), pr.updt_id = reqinfo->updt_id,
        pr.updt_applctx = reqinfo->updt_applctx, pr.updt_task = reqinfo->updt_task, pr.updt_cnt = (pr
        .updt_cnt+ 1)
       WHERE (pr.entity_access_id=request->qual[i].entity_access_id)
       WITH nocounter
      ;end update
     ELSE
      SET failed = "T"
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 CALL echo("after endfor")
 IF (curqual > 0
  AND failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
  IF (failed="T")
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echo(reply->status_data.status)
END GO
