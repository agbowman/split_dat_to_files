CREATE PROGRAM dcp_get_syn_witness_req_data:dba
 SET modify = predeclare
 RECORD reply(
   1 synonym_id_list[*]
     2 synonym_id = f8
     2 qual[*]
       3 facility_cd = f8
       3 facility_disp = c40
       3 facility_desc = vc
       3 facility_mean = c12
       3 value = f8
       3 string_value = vc
       3 group_id = f8
       3 col_name_cd = f8
       3 col_name_disp = c40
       3 col_name_desc = vc
       3 col_name_mean = c12
       3 attrib_list[*]
         4 object_cd = f8
         4 object_disp = c40
         4 object_desc = vc
         4 object_mean = c12
         4 object_type_cd = f8
         4 object_type_disp = c40
         4 object_type_desc = vc
         4 object_type_mean = c12
     2 qual_cnt = i4
   1 execution_notes[*]
     2 note = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE synexpandidx = i4 WITH protect, noconstant(0)
 DECLARE facexpandidx = i4 WITH protect, noconstant(0)
 DECLARE qualidx = i4 WITH protect, noconstant(0)
 DECLARE objidx = i4 WITH protect, noconstant(0)
 DECLARE synidx = i4 WITH protect, noconstant(0)
 DECLARE tempidx = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE tenantmatch = i2 WITH protect, noconstant(0)
 DECLARE synlistcnt = i4 WITH protect, noconstant(0)
 DECLARE synfinalcnt = i4 WITH protect, noconstant(0)
 DECLARE tempcnt = i4 WITH protect, noconstant(0)
 DECLARE attributesforfacilitycd(null) = null
 DECLARE attributesforallfacilities(null) = null
 SET synlistcnt = size(request->synonym_id_list,5)
 IF (synlistcnt > 0)
  CALL attributesforfacilitycd(null)
  SET synfinalcnt = synidx
  IF (validate(request->is_charting_wnd_mrd))
   IF ((request->is_charting_wnd_mrd=1))
    CALL attributesforallfacilities(null)
   ENDIF
  ENDIF
  SET stat = alterlist(reply->synonym_id_list,synfinalcnt)
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = concat("Select - ",errmsg)
 ELSEIF (size(reply->synonym_id_list,5)=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "Zero qual in Select"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "Success"
 ENDIF
 SUBROUTINE attributesforfacilitycd(null)
   DECLARE faclistcnt = i4 WITH protect, noconstant(0)
   SET faclistcnt = size(request->facility_cd_list,5)
   IF (faclistcnt > 0)
    SELECT INTO "nl:"
     FROM ocs_attr_xcptn oax
     WHERE expand(synexpandidx,1,synlistcnt,oax.synonym_id,request->synonym_id_list[synexpandidx].
      synonym_id)
      AND expand(facexpandidx,1,faclistcnt,oax.facility_cd,request->facility_cd_list[facexpandidx].
      facility_cd)
      AND (oax.ocs_col_name_cd=request->col_name_cd)
     ORDER BY oax.synonym_id, cnvtupper(uar_get_code_display(oax.facility_cd)), oax
      .ocs_attr_xcptn_group_id
     HEAD oax.synonym_id
      synidx += 1
      IF (mod(synidx,100)=1)
       stat = alterlist(reply->synonym_id_list,(synidx+ 99))
      ENDIF
      reply->synonym_id_list[synidx].synonym_id = oax.synonym_id
     HEAD oax.ocs_attr_xcptn_group_id
      qualidx += 1
      IF (mod(qualidx,100)=1)
       stat = alterlist(reply->synonym_id_list[synidx].qual,(qualidx+ 99))
      ENDIF
      reply->synonym_id_list[synidx].qual[qualidx].facility_cd = oax.facility_cd, reply->
      synonym_id_list[synidx].qual[qualidx].value = oax.flex_nbr_value, reply->synonym_id_list[synidx
      ].qual[qualidx].string_value = oax.flex_str_value_txt,
      reply->synonym_id_list[synidx].qual[qualidx].group_id = oax.ocs_attr_xcptn_group_id, reply->
      synonym_id_list[synidx].qual[qualidx].col_name_cd = oax.ocs_col_name_cd
     DETAIL
      objidx += 1
      IF (mod(objidx,100)=1)
       stat = alterlist(reply->synonym_id_list[synidx].qual[qualidx].attrib_list,(objidx+ 99))
      ENDIF
      reply->synonym_id_list[synidx].qual[qualidx].attrib_list[objidx].object_cd = oax.flex_obj_cd,
      reply->synonym_id_list[synidx].qual[qualidx].attrib_list[objidx].object_type_cd = oax
      .flex_obj_type_cd
     FOOT  oax.ocs_attr_xcptn_group_id
      stat = alterlist(reply->synonym_id_list[synidx].qual[qualidx].attrib_list,objidx), objidx = 0
     FOOT  oax.synonym_id
      stat = alterlist(reply->synonym_id_list[synidx].qual,qualidx), reply->synonym_id_list[synidx].
      qual_cnt = qualidx, qualidx = 0
     WITH nocounter, expand = 2
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE attributesforallfacilities(null)
  SET synidx = 0
  SELECT INTO "nl:"
   FROM ocs_attr_xcptn oax,
    location l,
    organization o
   PLAN (oax
    WHERE expand(synexpandidx,1,synlistcnt,oax.synonym_id,request->synonym_id_list[synexpandidx].
     synonym_id)
     AND (oax.ocs_col_name_cd=request->col_name_cd)
     AND oax.facility_cd=0.0)
    JOIN (l
    WHERE (l.location_cd=request->facility_cd_list[0].facility_cd))
    JOIN (o
    WHERE o.organization_id=l.organization_id)
   ORDER BY oax.synonym_id, oax.facility_cd, oax.ocs_attr_xcptn_group_id
   HEAD REPORT
    tenantmatch = 0
   HEAD oax.logical_domain_id
    IF (oax.logical_domain_id=o.logical_domain_id)
     tenantmatch = 1
    ENDIF
   HEAD oax.synonym_id
    IF (tenantmatch)
     tempcnt = 0
     FOR (num = 1 TO synfinalcnt)
       IF ((reply->synonym_id_list[num].synonym_id=oax.synonym_id))
        synidx = num, tempcnt += 1
       ENDIF
     ENDFOR
     IF (tempcnt=0)
      synidx = (synfinalcnt+ 1)
     ENDIF
     IF (mod(synidx,100)=1)
      stat = alterlist(reply->synonym_id_list,(synidx+ 99))
     ENDIF
     reply->synonym_id_list[synidx].synonym_id = oax.synonym_id, qualidx = reply->synonym_id_list[
     synidx].qual_cnt
     IF (synidx > synfinalcnt)
      synfinalcnt = synidx
     ENDIF
    ENDIF
   HEAD oax.ocs_attr_xcptn_group_id
    IF (tenantmatch)
     qualidx += 1, stat = alterlist(reply->synonym_id_list[synidx].qual,qualidx), reply->
     synonym_id_list[synidx].qual[qualidx].facility_cd = oax.facility_cd,
     reply->synonym_id_list[synidx].qual[qualidx].value = oax.flex_nbr_value, reply->synonym_id_list[
     synidx].qual[qualidx].string_value = oax.flex_str_value_txt, reply->synonym_id_list[synidx].
     qual[qualidx].group_id = oax.ocs_attr_xcptn_group_id,
     reply->synonym_id_list[synidx].qual[qualidx].col_name_cd = oax.ocs_col_name_cd
    ENDIF
   DETAIL
    IF (tenantmatch)
     objidx += 1
     IF (mod(objidx,100)=1)
      stat = alterlist(reply->synonym_id_list[synidx].qual[qualidx].attrib_list,(objidx+ 99))
     ENDIF
     reply->synonym_id_list[synidx].qual[qualidx].attrib_list[objidx].object_cd = oax.flex_obj_cd,
     reply->synonym_id_list[synidx].qual[qualidx].attrib_list[objidx].object_type_cd = oax
     .flex_obj_type_cd
    ENDIF
   FOOT  oax.ocs_attr_xcptn_group_id
    IF (tenantmatch)
     stat = alterlist(reply->synonym_id_list[synidx].qual[qualidx].attrib_list,objidx), objidx = 0
    ENDIF
   FOOT  oax.synonym_id
    IF (tenantmatch)
     stat = alterlist(reply->synonym_id_list[synidx].qual,qualidx), qualidx = 0
    ELSE
     CALL addexecutionnote(build("Tenant Match Not Found, Synonym ID-",oax.synonym_id,
      " | oax.logical_domain_id:",oax.logical_domain_id," | o.logical_domain_id:",
      o.logical_domain_id))
    ENDIF
   FOOT  oax.logical_domain_id
    IF (tenantmatch)
     tenantmatch = 0
    ENDIF
   WITH nocounter, expand = 2
  ;end select
 END ;Subroutine
 SUBROUTINE (addexecutionnote(snoteln=vc) =null)
   DECLARE lnotecnt = i4 WITH protect, noconstant(0)
   SET lnotecnt = (size(reply->execution_notes,5)+ 1)
   SET stat = alterlist(reply->execution_notes,lnotecnt)
   SET reply->execution_notes[lnotecnt].note = snoteln
 END ;Subroutine
 SET modify = nopredeclare
 SET last_mod = "005"
 SET mod_date = "03/29/2023"
END GO
