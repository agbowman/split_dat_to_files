CREATE PROGRAM dcp_del_apache_subencntr:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 dlist[*]
     2 rad_id = f8
 )
 DECLARE meaning_code(p1,p1) = f8
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_process TO 2099_process_exit
 GO TO 9999_exit_program
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,mc_text,1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
#1000_initialize
 SET reply->status_data.status = "F"
 SET cnt = 0
#1099_initialize_exit
#2000_process
 SELECT INTO "nl:"
  FROM risk_adjustment_day rad
  PLAN (rad
   WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
    AND rad.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->dlist,cnt), temp->dlist[cnt].rad_id = rad
   .risk_adjustment_day_id
  WITH nocounter
 ;end select
 IF ((request->risk_adjustment_id > 0))
  IF (cnt > 0)
   FOR (x = 1 TO cnt)
     UPDATE  FROM risk_adjustment_outcomes rao
      SET rao.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rao.active_ind = 0, rao
       .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
       rao.updt_dt_tm = cnvtdatetime(curdate,curtime3), rao.updt_task = reqinfo->updt_task, rao
       .updt_applctx = reqinfo->updt_applctx,
       rao.updt_id = reqinfo->updt_id, rao.updt_cnt = (rao.updt_cnt+ 1)
      WHERE (rao.risk_adjustment_day_id=temp->dlist[x].rad_id)
      WITH nocounter
     ;end update
   ENDFOR
  ENDIF
  UPDATE  FROM risk_adjustment_day rad
   SET rad.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_ind = 0, rad
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    rad.updt_dt_tm = cnvtdatetime(curdate,curtime3), rad.updt_task = reqinfo->updt_task, rad
    .updt_applctx = reqinfo->updt_applctx,
    rad.updt_id = reqinfo->updt_id, rad.updt_cnt = (rad.updt_cnt+ 1)
   WHERE (rad.risk_adjustment_id=request->risk_adjustment_id)
    AND rad.active_ind=1
   WITH nocounter
  ;end update
  DELETE  FROM risk_adjustment_event rae
   WHERE (rae.risk_adjustment_id=request->risk_adjustment_id)
   WITH nocounter
  ;end delete
  DELETE  FROM risk_adj_tiss rat
   WHERE (rat.risk_adjustment_id=request->risk_adjustment_id)
   WITH nocounter
  ;end delete
  UPDATE  FROM risk_adjustment ra
   SET ra.valid_until_dt_tm = cnvtdatetime(curdate,curtime3), ra.active_ind = 0, ra
    .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
    ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra.updt_task = reqinfo->updt_task, ra
    .updt_applctx = reqinfo->updt_applctx,
    ra.updt_id = reqinfo->updt_id, ra.updt_cnt = (ra.updt_cnt+ 1)
   WHERE (ra.risk_adjustment_id=request->risk_adjustment_id)
   WITH nocounter
  ;end update
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#2099_process_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
