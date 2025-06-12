CREATE PROGRAM bb_upd_qc_schedule_segments:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET modify = predeclare
 DECLARE ninformational = i2 WITH protect, constant(0)
 DECLARE ninsert = i2 WITH protect, constant(1)
 DECLARE nupdate = i2 WITH protect, constant(2)
 DECLARE ndelete = i2 WITH protect, constant(3)
 DECLARE nexists = i2 WITH protect, noconstant(0)
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE nskip = i2 WITH protect, noconstant(0)
 DECLARE ncount1 = i2 WITH protect, noconstant(0)
 DECLARE nstat = i2 WITH protect, noconstant(0)
 DECLARE serror = c132 WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 IF (size(request->segmentlist,5) > 0)
  FOR (ncount1 = 1 TO size(request->segmentlist,5))
    IF ((request->segmentlist[ncount1].save_flag=ndelete))
     DELETE  FROM bb_qc_schedule_segment bbqcss
      WHERE (bbqcss.schedule_segment_id=request->segmentlist[ncount1].schedule_segment_id)
      WITH nocounter
     ;end delete
     IF (error(serror,0) > 0)
      CALL subevent_add("EXECUTE","F","bb_upd_qc_schedule_segments",serror)
      GO TO exit_script
     ENDIF
    ELSEIF ((request->segmentlist[ncount1].save_flag=nupdate))
     SELECT INTO "nl:"
      *
      FROM bb_qc_schedule_segment bbqcss
      WHERE (bbqcss.schedule_segment_id=request->segmentlist[ncount1].schedule_segment_id)
      HEAD REPORT
       nerrorcnt = 0
      DETAIL
       IF ((request->segmentlist[ncount1].updt_cnt != bbqcss.updt_cnt))
        nstat = subevent_add("SELECT","F","bb_qc_schedule_segment",build("schedule segment id=",
          request->segmentlist[ncount1].schedule_segment_id,"with update count=",request->
          segmentlist[ncount1].updt_cnt," has been updated since being loaded by this application.")),
        nerrorcnt = (nerrorcnt+ 1)
       ENDIF
      WITH nocounter, forupdate(bbqcss)
     ;end select
     IF (error(serror,0) > 0)
      CALL subevent_add("EXECUTE","F","bb_upd_qc_schedule_segments",serror)
      GO TO exit_script
     ENDIF
     IF (((error_message(1)) OR (nerrorcnt > 0)) )
      CALL subevent_add("SELECT","F","bb_qc_schedule_segment","Error locking rows for update.")
     ELSE
      UPDATE  FROM bb_qc_schedule_segment bbqcss
       SET bbqcss.segment_seq = request->segmentlist[ncount1].segment_seq, bbqcss.segment_type_flag
         = request->segmentlist[ncount1].segment_type_flag, bbqcss.schedule_cd = request->
        segmentlist[ncount1].schedule_cd,
        bbqcss.time_nbr = request->segmentlist[ncount1].time_nbr, bbqcss.updt_cnt = (request->
        segmentlist[ncount1].updt_cnt+ 1), bbqcss.component1_nbr = request->segmentlist[ncount1].
        component1_nbr,
        bbqcss.component2_nbr = request->segmentlist[ncount1].component2_nbr, bbqcss.component3_nbr
         = request->segmentlist[ncount1].component3_nbr, bbqcss.days_of_week_bit = request->
        segmentlist[ncount1].days_of_week_bit,
        bbqcss.updt_applctx = reqinfo->updt_applctx, bbqcss.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), bbqcss.updt_id = reqinfo->updt_id,
        bbqcss.updt_task = reqinfo->updt_task
       WHERE (bbqcss.schedule_segment_id=request->segmentlist[ncount1].schedule_segment_id)
       WITH nocounter
      ;end update
      IF (error(serror,0) > 0)
       CALL subevent_add("EXECUTE","F","bb_upd_qc_schedule_segments",serror)
       GO TO exit_script
      ENDIF
     ENDIF
    ELSEIF ((request->segmentlist[ncount1].save_flag=ninsert))
     INSERT  FROM bb_qc_schedule_segment bbqcss
      SET bbqcss.schedule_segment_id = request->segmentlist[ncount1].schedule_segment_id, bbqcss
       .segment_seq = request->segmentlist[ncount1].segment_seq, bbqcss.segment_type_flag = request->
       segmentlist[ncount1].segment_type_flag,
       bbqcss.schedule_cd = request->segmentlist[ncount1].schedule_cd, bbqcss.time_nbr = request->
       segmentlist[ncount1].time_nbr, bbqcss.updt_cnt = request->segmentlist[ncount1].updt_cnt,
       bbqcss.component1_nbr = request->segmentlist[ncount1].component1_nbr, bbqcss.component2_nbr =
       request->segmentlist[ncount1].component2_nbr, bbqcss.component3_nbr = request->segmentlist[
       ncount1].component3_nbr,
       bbqcss.days_of_week_bit = request->segmentlist[ncount1].days_of_week_bit, bbqcss.updt_applctx
        = reqinfo->updt_applctx, bbqcss.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bbqcss.updt_id = reqinfo->updt_id, bbqcss.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (error(serror,0) > 0)
      CALL subevent_add("EXECUTE","F","bb_upd_qc_schedule_segments",serror)
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F","bb_upd_qc_schedule_segments",serror)
  GO TO exit_script
 ENDIF
 IF (value(size(request->segmentlist,5))=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("UPDATE","Z","bb_upd_qc_schedule_segments","No schedule segments found.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
