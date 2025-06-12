CREATE PROGRAM aps_get_cyto_slide_counts:dba
 RECORD reply(
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 slide_count = f8
     2 unscreen_slide_count = f8
     2 screened_slide_count = f8
     2 unscreen_slides[*]
       3 slide_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
#script
 DECLARE update_slide_count(slide_type=i4,half_ind=i2) = null
 DECLARE error_cnt = i4
 DECLARE cnt = i4
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET error_cnt = 0
 SET cnt = 0
 SELECT INTO "nl:"
  join_path = decode(s.seq,"S",c.seq,"C"," ")
  FROM case_specimen cs,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   slide s,
   ap_task_assay_addl ataa,
   cassette c,
   slide s2,
   ap_task_assay_addl ataa2
  PLAN (cs
   WHERE (cs.case_id=request->case_id)
    AND cs.cancel_cd IN (null, 0.0))
   JOIN (((d1)
   JOIN (s
   WHERE cs.case_specimen_id=s.case_specimen_id)
   JOIN (ataa
   WHERE s.task_assay_cd=ataa.task_assay_cd)
   ) ORJOIN ((d2)
   JOIN (c
   WHERE cs.case_specimen_id=c.case_specimen_id)
   JOIN (s2
   WHERE c.cassette_id=s2.cassette_id)
   JOIN (ataa2
   WHERE s2.task_assay_cd=ataa2.task_assay_cd)
   ))
  ORDER BY cs.case_specimen_id
  HEAD REPORT
   sc_cnt = 0, cnt = 0
  HEAD cs.case_specimen_id
   cnt = (cnt+ 1), stat = alterlist(reply->spec_qual,cnt), reply->spec_qual[cnt].case_specimen_id =
   cs.case_specimen_id,
   sc_cnt = 0
  DETAIL
   IF (join_path="S")
    IF (s.slide_id != 0)
     IF (s.screening_ind=0)
      sc_cnt = (sc_cnt+ 1), stat = alterlist(reply->spec_qual[cnt].unscreen_slides,sc_cnt), reply->
      spec_qual[cnt].unscreen_slides[sc_cnt].slide_id = s.slide_id
     ENDIF
     CALL update_slide_count(s.screening_ind,ataa.half_slide_ind)
    ENDIF
   ELSEIF (join_path="C")
    IF (s2.slide_id != 0)
     IF (s2.screening_ind=0)
      sc_cnt = (sc_cnt+ 1), stat = alterlist(reply->spec_qual[cnt].unscreen_slides,sc_cnt), reply->
      spec_qual[cnt].unscreen_slides[sc_cnt].slide_id = s2.slide_id
     ENDIF
     CALL update_slide_count(s2.screening_ind,ataa2.half_slide_ind)
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  CALL handle_errors("SELECT","Z","TABLE","CASE_SPECIMEN")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SUBROUTINE update_slide_count(slide_type,half_ind)
   IF (slide_type=1)
    IF (half_ind=1)
     SET reply->spec_qual[cnt].screened_slide_count = (reply->spec_qual[cnt].screened_slide_count+
     0.5)
    ELSE
     SET reply->spec_qual[cnt].screened_slide_count = (reply->spec_qual[cnt].screened_slide_count+ 1)
    ENDIF
   ELSE
    IF (half_ind=1)
     SET reply->spec_qual[cnt].unscreen_slide_count = (reply->spec_qual[cnt].unscreen_slide_count+
     0.5)
    ELSE
     SET reply->spec_qual[cnt].unscreen_slide_count = (reply->spec_qual[cnt].unscreen_slide_count+ 1)
    ENDIF
   ENDIF
   SET reply->spec_qual[cnt].slide_count = (reply->spec_qual[cnt].screened_slide_count+ reply->
   spec_qual[cnt].unscreen_slide_count)
   RETURN
 END ;Subroutine
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
END GO
