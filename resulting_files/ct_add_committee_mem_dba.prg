CREATE PROGRAM ct_add_committee_mem:dba
 RECORD reply(
   1 abc = c132
   1 xyz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD date(
   1 begin_date = dq8
   1 end_date = dq8
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(132," ")
 SET xyz = 0
 INSERT  FROM committee_member cm
  SET cm.committee_member_id = seq(protocol_def_seq,nextval), cm.committee_id = request->comt_id, cm
   .role_cd = request->role,
   cm.person_id = request->person_id, cm.organization_id = request->org_id, cm.beg_effective_dt_tm =
   cnvtdatetime(curdate,curtime3),
   cm.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), cm.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), cm.updt_id = reqinfo->updt_id,
   cm.updt_task = reqinfo->updt_task, cm.updt_applctx = reqinfo->updt_applctx, cm.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  CALL echo("failed to insert row for new committee member")
  GO TO exit_script
 ENDIF
 SET xyz = error(errmsg,0)
 SET reply->abc = errmsg
 SET reply->xyz = xyz
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 CALL echo(build("Error Message:",reply->abc))
 SET last_mod = "001"
 SET mod_date = "Aug 27, 2007"
END GO
