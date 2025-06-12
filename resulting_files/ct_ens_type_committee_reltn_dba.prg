CREATE PROGRAM ct_ens_type_committee_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH protect, noconstant("S")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cur_committee_cnt = i2 WITH protect, noconstant(0)
 DECLARE update_cnt = i2 WITH protect, noconstant(0)
 DECLARE insert_cnt = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE index = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE batch_size = i2 WITH protect, noconstant(20)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_committee_cnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE bfound = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET last_mod = "002"
 SET mod_date = "May 2, 2006"
 SET cur_committee_cnt = size(request->committees,5)
 SET loop_cnt = ceil((cnvtreal(cur_committee_cnt)/ batch_size))
 SET new_committee_cnt = (batch_size * loop_cnt)
 SET stat = alterlist(request->committees,new_committee_cnt)
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 FOR (i = 1 TO cur_committee_cnt)
   IF ((request->committees[i].action_type=1))
    SET insert_cnt = (insert_cnt+ 1)
   ENDIF
 ENDFOR
 FOR (i = (cur_committee_cnt+ 1) TO new_committee_cnt)
   SET request->committees[i].committee_id = request->committees[cur_committee_cnt].committee_id
 ENDFOR
 SELECT INTO "nl:"
  FROM ct_type_committee_reltn ctcr,
   (dummyt d  WITH seq = value(loop_cnt))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (ctcr
   WHERE expand(num,nstart,((nstart+ batch_size) - 1),ctcr.committee_id,request->committees[num].
    committee_id)
    AND (ctcr.participation_type_cd=request->participation_type_cd))
  DETAIL
   index = locateval(num,1,cur_committee_cnt,ctcr.committee_id,request->committees[num].committee_id)
   IF ((request->committees[index].action_type=1)
    AND ctcr.active_ind=0)
    request->committees[index].action_type = 2, insert_cnt = (insert_cnt - 1)
   ENDIF
   IF ((request->committees[index].action_type > 1))
    update_cnt = (update_cnt+ 1)
   ENDIF
   bfound = 1
  WITH nocounter, forupdate(ctcr)
 ;end select
 SET stat = alterlist(request->committees,cur_committee_cnt)
 IF (curqual=0
  AND bfound=1)
  CALL report_failure("SELECT","F","CT_ENS_TYPE_COMMITTEE_RELTN",
   "Error finding committee/amendment relationships to update.")
  GO TO exit_script
 ENDIF
 CALL echo(update_cnt)
 CALL echo(insert_cnt)
 IF (cur_committee_cnt > 0)
  IF (update_cnt > 0)
   SET count = 0
   UPDATE  FROM ct_type_committee_reltn ctcr,
     (dummyt d  WITH seq = value(cur_committee_cnt))
    SET ctcr.edit_ind = request->committees[d.seq].edit_ind, ctcr.active_ind =
     IF ((request->committees[d.seq].action_type=2)) 1
     ELSE 0
     ENDIF
     , ctcr.amd_validate_ind = request->committees[d.seq].amd_validate_ind,
     ctcr.rev_validate_ind = request->committees[d.seq].rev_validate_ind, ctcr.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), ctcr.updt_id = reqinfo->updt_id,
     ctcr.updt_applctx = reqinfo->updt_applctx, ctcr.updt_task = reqinfo->updt_task, ctcr.updt_cnt =
     (ctcr.updt_cnt+ 1),
     count = (count+ 1)
    PLAN (d
     WHERE (request->committees[d.seq].action_type > 1))
     JOIN (ctcr
     WHERE (ctcr.committee_id=request->committees[d.seq].committee_id)
      AND (ctcr.participation_type_cd=request->participation_type_cd))
    WITH nocounter
   ;end update
   IF (count=0)
    CALL report_failure("UPDATE","F","CT_ENS_TYPE_COMMITTEE_RELTN",
     "Error updating committee/amendment relationships.")
    GO TO exit_script
   ENDIF
  ENDIF
  IF (insert_cnt > 0)
   SET count = 0
   INSERT  FROM ct_type_committee_reltn ctcr,
     (dummyt d  WITH seq = value(cur_committee_cnt))
    SET ctcr.ct_type_committee_id = seq(protocol_def_seq,nextval), ctcr.committee_id = request->
     committees[d.seq].committee_id, ctcr.participation_type_cd = request->participation_type_cd,
     ctcr.amd_validate_ind = request->committees[d.seq].amd_validate_ind, ctcr.rev_validate_ind =
     request->committees[d.seq].rev_validate_ind, ctcr.edit_ind = request->committees[d.seq].edit_ind,
     ctcr.active_ind = 1, ctcr.updt_dt_tm = cnvtdatetime(curdate,curtime3), ctcr.updt_id = reqinfo->
     updt_id,
     ctcr.updt_applctx = reqinfo->updt_applctx, ctcr.updt_task = reqinfo->updt_task, ctcr.updt_cnt =
     0,
     count = (count+ 1)
    PLAN (d
     WHERE (request->committees[d.seq].action_type=1))
     JOIN (ctcr
     WHERE (ctcr.committee_id=request->committees[d.seq].committee_id)
      AND (ctcr.participation_type_cd=request->participation_type_cd))
   ;end insert
   IF (count=0)
    CALL report_failure("INSERT","F","CT_ENS_TYPE_COMMITTEE_RELTN",
     "Error inserting committee/amendment relationships.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
