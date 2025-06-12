CREATE PROGRAM dcp_upd_form_activity_comp:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET compcnt = size(request->req_list,5)
 DECLARE textrendcd = f8 WITH noconstant(uar_get_code_by("MEANING",18189,nullterm("TEXTREND")))
 DECLARE seteventidforcomponent(idxitem=i4) = i2
 DECLARE dummy_void = i4 WITH constant(0)
 DECLARE retval = i2 WITH noconstant(0)
 SET retval = seteventidforcomponent(dummy_void)
 IF (retval=0)
  SET reply->status_data.subeventstatus[1].targetobjectname = "Clinical Event Server"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "insert/update"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "4-unable"
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO compcnt)
  SELECT INTO "nl:"
   FROM dcp_forms_activity_comp comp
   WHERE (comp.dcp_forms_activity_id=request->req_list[x].dcp_forms_activity_id)
    AND ((comp.parent_entity_id+ 0)=request->req_list[x].parent_entity_id)
    AND ((comp.component_cd+ 0)=request->req_list[x].component_cd)
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM dcp_forms_activity_comp comp
    SET comp.dcp_forms_activity_comp_id = seq(carenet_seq,nextval), comp.dcp_forms_activity_id =
     request->req_list[x].dcp_forms_activity_id, comp.parent_entity_name = request->req_list[x].
     parent_entity_name,
     comp.parent_entity_id = request->req_list[x].parent_entity_id, comp.component_cd = request->
     req_list[x].component_cd, comp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     comp.updt_id = reqinfo->updt_id, comp.updt_task = reqinfo->updt_task, comp.updt_applctx =
     reqinfo->updt_applctx,
     comp.updt_cnt = 0
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 SUBROUTINE seteventidforcomponent(idxitem)
  IF (validate(event_rep,0))
   IF ((event_rep->sb.severitycd > 2))
    RETURN(0)
   ENDIF
   DECLARE eventid = f8 WITH noconstant(0.0)
   DECLARE event_cnt = i4 WITH noconstant(0)
   DECLARE found_value = i2 WITH noconstant(0)
   SET event_cnt = size(event_rep->rb_list,5)
   IF (event_cnt=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(event_cnt))
    PLAN (d1
     WHERE (((event_rep->rb_list[d1.seq].event_id=event_rep->rb_list[d1.seq].parent_event_id)) OR ((
     event_rep->rb_list[d1.seq].reference_nbr=request->req_list[idxitem].reference_nbr))) )
    DETAIL
     IF (found_value=0)
      eventid = event_rep->rb_list[d1.seq].event_id, found_value = 1
     ENDIF
    WITH nocounter, outerjoin = d1
   ;end select
   SET found_value = 0
   DECLARE comp_cnt = i4 WITH noconstant(size(request->req_list,5))
   SELECT INTO "nl:"
    FROM (dummyt d2  WITH seq = value(comp_cnt))
    PLAN (d2
     WHERE (request->req_list[d2.seq].parent_entity_name="CLINICAL_EVENT")
      AND (request->req_list[d2.seq].component_cd=textrendcd))
    DETAIL
     IF ((request->req_list[d2.seq].parent_entity_id=0))
      request->req_list[d2.seq].parent_entity_id = eventid
     ENDIF
    WITH nocounter, outerjoin = d2
   ;end select
  ENDIF
  RETURN(1)
 END ;Subroutine
END GO
