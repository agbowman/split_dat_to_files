CREATE PROGRAM dcp_add_section_ref:dba
 RECORD reply(
   1 dcp_section_ref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 DECLARE dcp_section_ref_id = f8 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  j = seq(carenet_seq,nextval)
  FROM dual
  DETAIL
   dcp_section_ref_id = j
  WITH format, nocounter
 ;end select
 INSERT  FROM dcp_section_ref d
  SET d.dcp_section_ref_id = dcp_section_ref_id, d.description = request->description, d
   .task_assay_cd = request->task_assay_cd,
   d.event_cd = request->event_cd, d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), d
   .end_effective_dt_tm = cnvtdatetime("31-Dec-2100"),
   d.active_ind = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id,
   d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->updt_applctx, d.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "dcp_section_ref table"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to insert into table"
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->dcp_section_ref_id = dcp_section_ref_id
 ELSE
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ENDIF
END GO
