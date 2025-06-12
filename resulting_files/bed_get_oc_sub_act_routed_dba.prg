CREATE PROGRAM bed_get_oc_sub_act_routed:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 subactivity_type_code_value = f8
     2 subactivity_type_display = c40
     2 subactivity_type_cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_scount = 0
 SET scount = 0
 SELECT DISTINCT INTO "NL:"
  o.catalog_type_cd, o.activity_type_cd, o.activity_subtype_cd
  FROM order_catalog o,
   code_value c5801,
   orc_resource_list orl
  PLAN (o
   WHERE (((o.catalog_type_cd=request->catalog_type_code_value)) OR ((request->
   catalog_type_code_value=0.0)))
    AND (((o.activity_type_cd=request->activity_type_code_value)) OR ((request->
   activity_type_code_value=0.0)))
    AND o.resource_route_lvl=1)
   JOIN (orl
   WHERE orl.catalog_cd=o.catalog_cd)
   JOIN (c5801
   WHERE c5801.code_value=outerjoin(o.activity_subtype_cd))
  ORDER BY o.activity_subtype_cd, c5801.display_key
  HEAD REPORT
   stat = alterlist(reply->slist,50)
  DETAIL
   tot_scount = (tot_scount+ 1), scount = (scount+ 1)
   IF (scount > 50)
    stat = alterlist(reply->slist,(tot_scount+ 50)), scount = 0
   ENDIF
   IF (o.activity_subtype_cd > 0)
    reply->slist[tot_scount].subactivity_type_code_value = o.activity_subtype_cd, reply->slist[
    tot_scount].subactivity_type_display = c5801.display, reply->slist[tot_scount].
    subactivity_type_cdf_meaning = c5801.cdf_meaning
   ELSE
    reply->slist[tot_scount].subactivity_type_code_value = 0, reply->slist[tot_scount].
    subactivity_type_display = "Not Defined", reply->slist[tot_scount].subactivity_type_cdf_meaning
     = " "
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->slist,tot_scount)
  WITH nocounter
 ;end select
 IF (validate(request->check_dta_level_routing_ind))
  IF ((request->check_dta_level_routing_ind=1))
   SELECT DISTINCT INTO "NL:"
    o.catalog_type_cd, o.activity_type_cd, o.activity_subtype_cd
    FROM order_catalog o,
     profile_task_r ptr,
     assay_resource_list asl,
     code_value c5801
    PLAN (o
     WHERE (((o.catalog_type_cd=request->catalog_type_code_value)) OR ((request->
     catalog_type_code_value=0.0)))
      AND (((o.activity_type_cd=request->activity_type_code_value)) OR ((request->
     activity_type_code_value=0.0)))
      AND o.resource_route_lvl=2)
     JOIN (ptr
     WHERE ptr.catalog_cd=o.catalog_cd
      AND ptr.active_ind=1)
     JOIN (asl
     WHERE asl.task_assay_cd=ptr.task_assay_cd
      AND asl.active_ind=1)
     JOIN (c5801
     WHERE c5801.code_value=outerjoin(o.activity_subtype_cd))
    ORDER BY o.activity_subtype_cd, c5801.display_key
    HEAD REPORT
     stat = alterlist(reply->slist,50)
    DETAIL
     found_ind = 0
     FOR (x = 1 TO tot_scount)
       IF ((reply->slist[x].subactivity_type_code_value=o.activity_subtype_cd))
        found_ind = 1
       ENDIF
     ENDFOR
     IF (found_ind=0)
      tot_scount = (tot_scount+ 1), scount = (scount+ 1)
      IF (scount > 50)
       stat = alterlist(reply->slist,(tot_scount+ 50)), scount = 0
      ENDIF
      IF (o.activity_subtype_cd > 0)
       reply->slist[tot_scount].subactivity_type_code_value = o.activity_subtype_cd, reply->slist[
       tot_scount].subactivity_type_display = c5801.display, reply->slist[tot_scount].
       subactivity_type_cdf_meaning = c5801.cdf_meaning
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->slist,tot_scount)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (tot_scount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
