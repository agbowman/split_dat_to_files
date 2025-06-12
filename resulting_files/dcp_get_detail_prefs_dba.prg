CREATE PROGRAM dcp_get_detail_prefs:dba
 RECORD reply(
   1 detail_prefs_id = f8
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
   1 person_id = f8
   1 view_name = c12
   1 view_seq = i4
   1 comp_name = c12
   1 comp_seq = i4
   1 updt_cnt = i4
   1 nv_cnt = i4
   1 nv[*]
     2 name_value_prefs_id = f8
     2 nv_type_flag = i2
     2 pvc_name = c32
     2 pvc_value = vc
     2 updt_cnt = i4
     2 merge_name = vc
     2 merge_id = f8
     2 sequence = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->nv_cnt = 0
 DECLARE predefined_prefs_id = f8 WITH noconstant(0.0)
 DECLARE prsnl_prefs_id = f8 WITH noconstant(0.0)
 DECLARE psn_prefs_id = f8 WITH noconstant(0.0)
 DECLARE prsnl_prefs_id = f8 WITH noconstant(0.0)
 DECLARE sys_prefs_id = f8 WITH noconstant(0.0)
 DECLARE nvi = i4 WITH noconstant(0)
 DECLARE nv_type_flag = i4 WITH noconstant(0)
 DECLARE dont_get_predefined = i4 WITH noconstant(0)
 SET prsnl_prefs_id = - (1)
 SET psn_prefs_id = - (1)
 SET sys_prefs_id = - (1)
 IF ((request->dont_get_predefined != 1))
  SET dont_get_predefined = 0
 ELSE
  SET dont_get_predefined = 1
 ENDIF
 SET reply->application_number = request->application_number
 SET reply->position_cd = request->position_cd
 SET reply->prsnl_id = request->prsnl_id
 SET reply->person_id = request->person_id
 SET reply->view_name = request->view_name
 SET reply->view_seq = request->view_seq
 SET reply->comp_name = request->comp_name
 SET reply->comp_seq = request->comp_seq
 IF ((request->prsnl_id > 0))
  SELECT INTO "nl:"
   FROM detail_prefs dp
   PLAN (dp
    WHERE (dp.application_number=request->application_number)
     AND (dp.prsnl_id=request->prsnl_id)
     AND dp.position_cd=0
     AND (dp.view_name=request->view_name)
     AND (dp.view_seq=request->view_seq)
     AND (dp.comp_name=request->comp_name)
     AND (dp.comp_seq=request->comp_seq)
     AND dp.active_ind=1)
   DETAIL
    prsnl_prefs_id = dp.detail_prefs_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->position_cd > 0))
  SELECT INTO "nl:"
   FROM detail_prefs dp
   PLAN (dp
    WHERE (dp.application_number=request->application_number)
     AND dp.prsnl_id=0
     AND (dp.position_cd=request->position_cd)
     AND (dp.view_name=request->view_name)
     AND (dp.view_seq=request->view_seq)
     AND (dp.comp_name=request->comp_name)
     AND (dp.comp_seq=request->comp_seq)
     AND dp.active_ind=1)
   DETAIL
    psn_prefs_id = dp.detail_prefs_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->application_number > 0))
  SELECT INTO "nl:"
   FROM detail_prefs dp
   PLAN (dp
    WHERE (dp.application_number=request->application_number)
     AND dp.prsnl_id=0
     AND dp.position_cd=0
     AND (dp.view_name=request->view_name)
     AND (dp.view_seq=request->view_seq)
     AND (dp.comp_name=request->comp_name)
     AND (dp.comp_seq=request->comp_seq)
     AND dp.active_ind=1)
   DETAIL
    sys_prefs_id = dp.detail_prefs_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  sortseq =
  IF (nv.parent_entity_id=prsnl_prefs_id) 1
  ELSEIF (nv.parent_entity_id=psn_prefs_id) 2
  ELSE 3
  ENDIF
  , nv.name_value_prefs_id, nv.pvc_name,
  x = concat(trim(nv.pvc_name),trim(nv.merge_name),trim(cnvtstring(nv.sequence)))
  FROM name_value_prefs nv
  PLAN (nv
   WHERE ((nv.parent_entity_id=prsnl_prefs_id) OR (((nv.parent_entity_id=psn_prefs_id) OR (nv
   .parent_entity_id=sys_prefs_id)) ))
    AND nv.parent_entity_name="DETAIL_PREFS"
    AND nv.active_ind=1)
  ORDER BY nv.pvc_name, nv.merge_name, nv.sequence,
   sortseq
  HEAD x
   nvi += 1
   IF (nvi > size(reply->nv,5))
    stat = alterlist(reply->nv,(nvi+ 10))
   ENDIF
   reply->nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->nv[nvi].pvc_name = nv.pvc_name,
   reply->nv[nvi].pvc_value = nv.pvc_value,
   reply->nv[nvi].updt_cnt = nv.updt_cnt, reply->nv[nvi].merge_name = nv.merge_name, reply->nv[nvi].
   merge_id = nv.merge_id,
   reply->nv[nvi].sequence = nv.sequence
   IF (sortseq=1)
    reply->nv[nvi].nv_type_flag = 2
   ELSEIF (sortseq=2)
    reply->nv[nvi].nv_type_flag = 1
   ELSE
    reply->nv[nvi].nv_type_flag = 0
   ENDIF
   IF (nv.pvc_name="PREDEFINED_PREFS")
    predefined_prefs_id = cnvtreal(nv.pvc_value)
   ENDIF
  DETAIL
   row + 0
  FOOT REPORT
   IF (nvi > 0)
    stat = alterlist(reply->nv,nvi)
   ENDIF
   reply->nv_cnt = nvi
  WITH nocounter
 ;end select
 IF (predefined_prefs_id > 0
  AND dont_get_predefined != 1)
  SELECT INTO "nl:"
   nv.pvc_name
   FROM name_value_prefs nv
   WHERE nv.parent_entity_name="PREDEFINED_PREFS"
    AND nv.parent_entity_id=predefined_prefs_id
    AND nv.active_ind=1
   DETAIL
    nvi += 1
    IF (nvi > size(reply->nv,5))
     stat = alterlist(reply->nv,(nvi+ 10))
    ENDIF
    reply->nv[nvi].name_value_prefs_id = nv.name_value_prefs_id, reply->nv[nvi].pvc_name = nv
    .pvc_name, reply->nv[nvi].pvc_value = nv.pvc_value,
    reply->nv[nvi].updt_cnt = nv.updt_cnt, reply->nv[nvi].nv_type_flag = nv_type_flag, reply->nv[nvi]
    .merge_name = nv.merge_name,
    reply->nv[nvi].merge_id = nv.merge_id, reply->nv[nvi].sequence = nv.sequence
   FOOT REPORT
    IF (nvi > 0)
     stat = alterlist(reply->nv,nvi)
    ENDIF
    reply->nv_cnt = nvi
   WITH nocounter
  ;end select
 ENDIF
#exit_program
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
