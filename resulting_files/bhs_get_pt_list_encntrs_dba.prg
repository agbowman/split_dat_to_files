CREATE PROGRAM bhs_get_pt_list_encntrs:dba
 DECLARE ml_ecnt = i4 WITH protect, noconstant(0)
 EXECUTE ccl_prompt_api_dataset "DATASET"
 SET createdataset = 0
 FREE RECORD dgapl_request
 RECORD dgapl_request(
   1 prsnl_id = f8
 )
 SET dgapl_request->prsnl_id = reqinfo->updt_id
 FREE RECORD dgapl_reply
 RECORD dgapl_reply(
   1 patient_lists[*]
     2 patient_list_id = f8
     2 name = vc
     2 description = vc
     2 patient_list_type_cd = f8
     2 owner_id = f8
     2 list_access_cd = f8
     2 arguments[*]
       3 argument_name = vc
       3 argument_value = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 encntr_type_filters[*]
       3 encntr_type_cd = f8
       3 encntr_class_cd = f8
     2 proxies[*]
       3 prsnl_id = f8
       3 prsnl_group_id = f8
       3 list_access_cd = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE dcp_get_available_pat_lists  WITH replace(request,dgapl_request), replace(reply,dgapl_reply)
 RECORD dgp_reply(
   1 patient_list_id = f8
   1 name = vc
   1 description = vc
   1 patient_list_type_cd = f8
   1 owner_id = f8
   1 prsnl_access_cd = f8
   1 execution_dt_tm = dq8
   1 execution_status_cd = f8
   1 execution_status_disp = vc
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
   1 patients[*]
     2 person_id = f8
     2 person_name = vc
     2 encntr_id = f8
     2 priority = i4
     2 active_ind = i2
     2 filter_ind = i2
     2 responsible_prsnl_id = f8
     2 responsible_prsnl_name = vc
     2 responsible_reltn_cd = f8
     2 responsible_reltn_disp = vc
     2 responsible_reltn_id = f8
     2 responsible_reltn_flag = i2
     2 organization_id = f8
     2 confid_level_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD dgp_request
 RECORD dgp_request(
   1 patient_list_id = f8
   1 patient_list_type_cd = f8
   1 best_encntr_flag = i4
   1 arguments[*]
     2 argument_name = vc
     2 argument_value = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 encntr_type_filters[*]
     2 encntr_type_cd = f8
     2 encntr_class_cd = f8
 )
 DECLARE selection = i4
 FOR (i = 1 TO size(dgapl_reply->patient_lists,5))
   IF ((dgapl_reply->patient_lists[i].patient_list_id=cnvtreal( $1)))
    SET selection = i
    SET i = (size(dgapl_reply->patient_lists,5)+ 1)
   ENDIF
 ENDFOR
 SET dgp_request->patient_list_id = dgapl_reply->patient_lists[selection].patient_list_id
 SET dgp_request->patient_list_type_cd = dgapl_reply->patient_lists[selection].patient_list_type_cd
 SET num_arguments = size(dgapl_reply->patient_lists[selection].arguments,5)
 SET stat = alterlist(dgp_request->arguments,num_arguments)
 FOR (i = 1 TO num_arguments)
   SET dgp_request->arguments[i].argument_name = dgapl_reply->patient_lists[selection].arguments[i].
   argument_name
   SET dgp_request->arguments[i].argument_value = dgapl_reply->patient_lists[selection].arguments[i].
   argument_value
   SET dgp_request->arguments[i].parent_entity_name = dgapl_reply->patient_lists[selection].
   arguments[i].parent_entity_name
   SET dgp_request->arguments[i].parent_entity_id = dgapl_reply->patient_lists[selection].arguments[i
   ].parent_entity_id
 ENDFOR
 SET num_filters = size(dgapl_reply->patient_lists[selection].encntr_type_filters,5)
 SET stat = alterlist(dgp_request->encntr_type_filters,num_filters)
 FOR (i = 1 TO num_filters)
  SET dgp_request->encntr_type_filters[i].encntr_type_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_type_cd
  SET dgp_request->encntr_type_filters[i].encntr_class_cd = dgapl_reply->patient_lists[selection].
  encntr_type_filters[i].encntr_class_cd
 ENDFOR
 SET dgp_reply->status_data.status = "F"
 DECLARE listtype = vc WITH constant(uar_get_code_meaning(dgp_request->patient_list_type_cd))
 DECLARE encntr_org_sec_ind = i2 WITH noconstant(0)
 DECLARE confid_ind = i2 WITH noconstant(0)
 DECLARE logstatistics(seconds=f8) = null
 DECLARE begin_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE finish_time = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE pagebreak = vc WITH noconstant(" "), public
 CALL echo(build("ListType:",listtype))
 SET ccldminfo->sec_org_reltn = 0
 SET ccldminfo->sec_confid = 0
 CASE (listtype)
  OF "CUSTOM":
   EXECUTE dcp_get_pl_custom  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  OF "CARETEAM":
   EXECUTE bhs_dcp_get_pl_careteam2
  OF "LOCATION":
   SET ml_ndx = 0
   SELECT DISTINCT INTO "nl:"
    e.encntr_id
    FROM encntr_domain ed,
     encounter e
    PLAN (ed
     WHERE ed.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
      AND expand(ml_ndx,1,size(dgp_request->arguments,5),ed.loc_nurse_unit_cd,dgp_request->arguments[
      ml_ndx].parent_entity_id))
     JOIN (e
     WHERE ed.encntr_id=e.encntr_id)
    ORDER BY e.encntr_id
    HEAD REPORT
     ml_cnt = 0
    DETAIL
     ml_cnt += 1, stat = alterlist(dgp_reply->patients,ml_cnt), dgp_reply->patients[ml_cnt].encntr_id
      = e.encntr_id
    WITH nocounter
   ;end select
  OF "LOCATIONGRP":
   EXECUTE dcp_get_pl_location_grp  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  OF "VRELTN":
   EXECUTE dcp_get_pl_visit_reltn  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  OF "LRELTN":
   EXECUTE dcp_get_pl_lifetime_reltn  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  OF "PROVIDERGRP":
   EXECUTE dcp_get_pl_provider_group  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  OF "SERVICE":
   EXECUTE dcp_get_pl_service  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  OF "ASSIGNMENT":
   EXECUTE dcp_get_pl_asgmt  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  OF "ANC_ASGMT":
   EXECUTE dcp_get_pl_ancillary_asgmt  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  OF "QUERY":
   EXECUTE dcp_get_pl_query  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  OF "SCHEDULE":
   EXECUTE dcp_get_pl_schedule  WITH replace(request,dgp_request), replace(reply,dgp_reply)
  ELSE
   GO TO error
 ENDCASE
 SELECT INTO "nl:"
  p.person_id, p.name_full_formatted
  FROM (dummyt d  WITH seq = size(dgp_reply->patients,5)),
   encounter e,
   person p
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=dgp_reply->patients[d.seq].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY p.name_last_key, p.name_first_key, p.person_id,
   e.encntr_id
  HEAD REPORT
   ml_ecnt = 0, d0 = makedataset(10), veid = addrealfield("EID","Encntr_ID:",1),
   vname = addstringfield("Name","Name:",1,100), vunit = addstringfield("Unit","Unit:",1,100),
   CALL echo(build2("vEid: ",veid)),
   CALL echo(build2("vName: ",vname)),
   CALL echo(build2("vUnit: ",vunit))
  HEAD p.name_last_key
   null
  HEAD p.name_first_key
   null
  HEAD p.person_id
   null
  HEAD e.encntr_id
   null
  DETAIL
   ml_ecnt = getnextrecord(0), d0 = setrealfield(ml_ecnt,veid,e.encntr_id), d0 = setstringfield(
    ml_ecnt,vname,trim(p.name_full_formatted)),
   d0 = setstringfield(ml_ecnt,vunit,build(uar_get_code_display(e.loc_nurse_unit_cd)))
  FOOT REPORT
   stat = closedataset(0)
  WITH check, nocounter
 ;end select
 IF (curqual=0)
  SET stat = setmessagebox("No patient list encounters found.")
 ENDIF
 SET reply->status_data.status = "S"
END GO
