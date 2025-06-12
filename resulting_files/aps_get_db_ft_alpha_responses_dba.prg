CREATE PROGRAM aps_get_db_ft_alpha_responses:dba
 RECORD reply(
   1 qual[10]
     2 reference_range_factor_id = f8
     2 nomenclature_id = f8
     2 tracking_type_cd = f8
     2 initial_interval = i4
     2 init_null_ind = i2
     2 first_interval = i4
     2 first_null_ind = i2
     2 final_interval = i4
     2 final_null_ind = i2
     2 termination_interval = i4
     2 term_null_ind = i2
     2 updt_cnt = i4
     2 nomenclature_disp = c40
     2 sequence = i4
     2 future_act_ind = c1
   1 service_resource_qual[*]
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 service_resource_desc = c60
     2 service_resource_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nerrorcount = i2 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nerrorcheck = i2 WITH protect, noconstant(error(serrmsg,1))
 DECLARE nserviceresourcecount = i2 WITH protect, noconstant(0)
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  dta.mnemonic_key_cap, cas.followup_tracking_type_cd, init_null_ind = nullind(cas
   .followup_initial_interval),
  first_null_ind = nullind(cas.followup_first_interval), final_null_ind = nullind(cas
   .followup_final_interval), term_null_ind = nullind(cas.followup_termination_interval),
  cas.updt_cnt, ar.reference_range_factor_id, ar.nomenclature_id,
  cas.reference_range_factor_id, cas.nomenclature_id
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   alpha_responses ar,
   dummyt d,
   cyto_alpha_security cas,
   nomenclature n
  PLAN (dta
   WHERE (dta.mnemonic_key_cap=request->mnemonic_key))
   JOIN (rrf
   WHERE dta.task_assay_cd=rrf.task_assay_cd
    AND rrf.active_ind=1)
   JOIN (ar
   WHERE rrf.reference_range_factor_id=ar.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
   JOIN (d)
   JOIN (cas
   WHERE cas.reference_range_factor_id=ar.reference_range_factor_id
    AND cas.nomenclature_id=ar.nomenclature_id
    AND (cas.service_resource_cd=request->service_resource_cd))
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].nomenclature_disp = n.mnemonic, reply->qual[cnt].sequence = ar.sequence, reply->
   qual[cnt].tracking_type_cd = cas.followup_tracking_type_cd,
   reply->qual[cnt].initial_interval = cas.followup_initial_interval, reply->qual[cnt].first_interval
    = cas.followup_first_interval, reply->qual[cnt].final_interval = cas.followup_final_interval,
   reply->qual[cnt].termination_interval = cas.followup_termination_interval, reply->qual[cnt].
   init_null_ind = init_null_ind, reply->qual[cnt].first_null_ind = first_null_ind,
   reply->qual[cnt].final_null_ind = final_null_ind, reply->qual[cnt].term_null_ind = term_null_ind,
   reply->qual[cnt].updt_cnt = cas.updt_cnt,
   reply->qual[cnt].reference_range_factor_id = ar.reference_range_factor_id, reply->qual[cnt].
   nomenclature_id = ar.nomenclature_id
   IF (ar.reference_range_factor_id != cas.reference_range_factor_id
    AND ar.nomenclature_id != cas.nomenclature_id)
    reply->qual[cnt].future_act_ind = "A", reply->qual[cnt].init_null_ind = 1, reply->qual[cnt].
    first_null_ind = 1,
    reply->qual[cnt].final_null_ind = 1, reply->qual[cnt].term_null_ind = 1
   ELSE
    reply->qual[cnt].future_act_ind = "C"
   ENDIF
  WITH outerjoin = d, nocounter
 ;end select
 SET nerrorcheck = error(serrmsg,1)
 IF (nerrorcheck != 0)
  CALL errorhandler("SELECT","F","CYTO_ALPHA_SECURITY",serrmsg)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSEIF (curqual=0)
  CALL errorhandler("SELECT","Z","TABLE","CYTO_ALPHA_SECURITY")
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alter(reply->qual,cnt)
 SELECT INTO "nl:"
  cas.service_resource_cd
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   cyto_alpha_security cas
  PLAN (dta
   WHERE (dta.mnemonic_key_cap=request->mnemonic_key))
   JOIN (rrf
   WHERE rrf.task_assay_cd=dta.task_assay_cd)
   JOIN (cas
   WHERE cas.reference_range_factor_id=rrf.reference_range_factor_id
    AND ((cas.service_resource_cd+ 0) > 0.0)
    AND cas.definition_ind IN (0, 2))
  ORDER BY cas.service_resource_cd
  HEAD REPORT
   row + 0
  HEAD cas.service_resource_cd
   nserviceresourcecount += 1
   IF (nserviceresourcecount > size(reply->service_resource_qual,5))
    stat = alterlist(reply->service_resource_qual,(nserviceresourcecount+ 9))
   ENDIF
   reply->service_resource_qual[nserviceresourcecount].service_resource_cd = cas.service_resource_cd
  DETAIL
   row + 0
  FOOT REPORT
   stat = alterlist(reply->service_resource_qual,nserviceresourcecount)
  WITH nocounter
 ;end select
 SET nerrorcheck = error(serrmsg,1)
 IF (nerrorcheck != 0)
  CALL errorhandler("Select","F","service resources",serrmsg)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 GO TO exit_script
 SUBROUTINE (errorhandler(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc) =null)
   SET nerrorcount += 1
   IF (nerrorcount > 1)
    SET stat = alter(reply->status_data.subeventstatus,nerrorcount)
   ENDIF
   SET reply->status_data.subeventstatus[nerrorcount].operationname = operationname
   SET reply->status_data.subeventstatus[nerrorcount].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[nerrorcount].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[nerrorcount].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#exit_script
 IF (nerrorcount=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
