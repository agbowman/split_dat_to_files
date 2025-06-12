CREATE PROGRAM bb_get_qc_schedule_segments:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 segmentlist[*]
      2 schedule_cd = f8
      2 schedule_segment_id = f8
      2 segment_seq = i4
      2 segment_type_flag = i2
      2 time_nbr = i4
      2 active_ind = i2
      2 updt_cnt = i4
      2 component1_nbr = i4
      2 component2_nbr = i4
      2 component3_nbr = i4
      2 days_of_week_bit = i4
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
 DECLARE serror = c132 WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM bb_qc_schedule_segment bbqcss
  PLAN (bbqcss
   WHERE (((bbqcss.schedule_cd=request->schedule_cd)
    AND (request->schedule_cd > 0)) OR ((request->schedule_cd=0)
    AND bbqcss.schedule_segment_id > 0)) )
  HEAD REPORT
   ncount1 = 0, stat = alterlist(reply->segmentlist,10)
  DETAIL
   ncount1 = (ncount1+ 1)
   IF (mod(ncount1,10)=1
    AND ncount1 != 1)
    stat = alterlist(reply->segmentlist,(ncount1+ 9))
   ENDIF
   reply->segmentlist[ncount1].schedule_cd = bbqcss.schedule_cd, reply->segmentlist[ncount1].
   schedule_segment_id = bbqcss.schedule_segment_id, reply->segmentlist[ncount1].segment_seq = bbqcss
   .segment_seq,
   reply->segmentlist[ncount1].segment_type_flag = bbqcss.segment_type_flag, reply->segmentlist[
   ncount1].time_nbr = bbqcss.time_nbr, reply->segmentlist[ncount1].active_ind = 1,
   reply->segmentlist[ncount1].component1_nbr = bbqcss.component1_nbr, reply->segmentlist[ncount1].
   component2_nbr = bbqcss.component2_nbr, reply->segmentlist[ncount1].component3_nbr = bbqcss
   .component3_nbr,
   reply->segmentlist[ncount1].days_of_week_bit = bbqcss.days_of_week_bit
  FOOT REPORT
   stat = alterlist(reply->segmentlist,ncount1)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F","bb_get_qc_schedule_segments",serror)
  GO TO exit_script
 ENDIF
 IF (value(size(reply->segmentlist,5))=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("SELECT","Z","bb_get_qc_schedule_segments","No schedule segments found.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
