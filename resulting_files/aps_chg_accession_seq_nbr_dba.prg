CREATE PROGRAM aps_chg_accession_seq_nbr:dba
 RECORD reply(
   1 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET cur_updt_cnt = 0
 SET _acc_assign_date = cnvtdatetimeutc(cnvtdatetime(cnvtdate2(concat("0101",cnvtstring(year(curdate),
      4,0,r)),"mmddyyyy"),0),2)
 IF ((request->accession_ind=1))
  SELECT INTO "nl:"
   aa.acc_assign_pool_id
   FROM accession_assignment aa
   PLAN (aa
    WHERE (request->group_cd=aa.acc_assign_pool_id)
     AND cnvtdatetimeutc(_acc_assign_date,0)=aa.acc_assign_date)
   DETAIL
    cur_updt_cnt = aa.updt_cnt
   WITH nocounter, forupdate(aa)
  ;end select
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  IF ((request->updt_cnt != cur_updt_cnt))
   SET failed = "T"
   GO TO exit_script
  ENDIF
  SET cur_updt_cnt = (cur_updt_cnt+ 1)
  UPDATE  FROM accession_assignment aa
   SET aa.accession_seq_nbr = request->accession_seq_nbr, aa.updt_cnt = cur_updt_cnt, aa.updt_dt_tm
     = cnvtdatetime(curdate,curtime3),
    aa.updt_id = reqinfo->updt_id, aa.updt_task = reqinfo->updt_task, aa.updt_applctx = reqinfo->
    updt_applctx
   WHERE (aa.acc_assign_pool_id=request->group_cd)
    AND cnvtdatetimeutc(_acc_assign_date,0)=aa.acc_assign_date
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSE
  INSERT  FROM accession_assignment aa
   SET aa.acc_assign_pool_id = request->group_cd, aa.acc_assign_date = cnvtdatetimeutc(
     _acc_assign_date,0), aa.accession_seq_nbr = request->accession_seq_nbr,
    aa.last_increment_dt_tm = cnvtdatetime(curdate,curtime3), aa.increment_value = 1, aa.updt_cnt = 0,
    aa.updt_dt_tm = cnvtdatetime(curdate,curtime3), aa.updt_id = reqinfo->updt_id, aa.updt_task =
    reqinfo->updt_task,
    aa.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  SET reply->updt_cnt = 0
  IF (curqual=0)
   SET failed = "T"
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
