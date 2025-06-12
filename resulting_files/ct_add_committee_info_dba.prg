CREATE PROGRAM ct_add_committee_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE committee_id = f8 WITH private, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET last_mod = "000"
 SET mod_date = "Feb 1, 1999"
 INSERT  FROM committee cm
  SET cm.committee_id = seq(protocol_def_seq,nextval), cm.committee_name = request->cmt_name, cm
   .email_address = request->email,
   cm.sponsoring_org_id = request->spons_org_id, cm.committee_type_cd = request->cmt_type, cm
   .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   cm.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00"), cm.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), cm.updt_id = reqinfo->updt_id,
   cm.updt_task = reqinfo->updt_task, cm.updt_applctx = reqinfo->updt_applctx, cm.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  CALL echo("failed to insert row for new committee")
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
END GO
