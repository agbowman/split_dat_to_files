CREATE PROGRAM dcp_chk_dynamic_dta:dba
 RECORD reply(
   1 resultspresentondta = i2
   1 resultspresentondg = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_b(
   1 qual[*]
     2 event_cd = f8
 )
 DECLARE list_count = i2 WITH noconstant(size(request->qual,5))
 DECLARE expand_index = i4 WITH protect, noconstant(0)
 DECLARE ec_counter = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE eventcdtoremove = f8 WITH protect, noconstant(0.0)
 IF (((list_count=0) OR (list_count=null)) )
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  dta.event_cd
  FROM discrete_task_assay dta
  WHERE expand(expand_index,1,list_count,dta.task_assay_cd,request->qual[expand_index].task_assay_cd)
  HEAD REPORT
   ec_counter = 1, stat = alterlist(temp_b->qual,list_count)
  DETAIL
   temp_b->qual[ec_counter].event_cd = dta.event_cd, ec_counter += 1
   IF ((dta.task_assay_cd=request->dta_to_remove))
    eventcdtoremove = dta.event_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  wv.display_name
  FROM working_view wv,
   working_view_section wvs,
   working_view_item wvi,
   v500_event_code v5ec,
   v500_event_set_explode v5esp,
   v500_event_set_code v5esc
  PLAN (wv
   WHERE wv.active_ind=1)
   JOIN (wvs
   WHERE wv.working_view_id=wvs.working_view_id)
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
   JOIN (v5esc
   WHERE v5esc.event_set_name=wvi.primitive_event_set_name)
   JOIN (v5esp
   WHERE v5esp.event_set_cd=v5esc.event_set_cd)
   JOIN (v5ec
   WHERE v5ec.event_cd=v5esp.event_cd
    AND v5ec.event_cd=eventcdtoremove)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSEIF (curqual > 0)
  SELECT INTO "nl:"
   ce.event_id
   FROM clinical_event ce
   WHERE ce.event_cd=eventcdtoremove
   WITH nocounter, maxrec = 1
  ;end select
  IF (curqual > 0)
   SET reply->resultspresentondta = 1
   SET reply->status_data.status = "S"
  ELSE
   SELECT INTO "nl:"
    ce.event_id
    FROM clinical_event ce
    WHERE expand(expand_index,1,list_count,ce.event_cd,temp_b->qual[expand_index].event_cd)
    WITH nocounter, maxrec = 1
   ;end select
   IF (curqual > 0)
    SET reply->resultspresentondg = 1
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
END GO
