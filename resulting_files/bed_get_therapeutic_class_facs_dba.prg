CREATE PROGRAM bed_get_therapeutic_class_facs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 facilities[*]
      2 code_value = f8
      2 organization_id = f8
      2 display = vc
      2 defined_ind = i2
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET list_request
 RECORD list_request(
   1 search_txt = vc
   1 search_type_flag = vc
   1 max_reply_limit = i2
   1 show_inactive_ind = i2
   1 load_bldg_cnt_ind = i2
   1 load_only_facs_with_units_ind = i2
   1 org_alias_pool_types[*]
     2 code_value = f8
   1 load_only_effective_facs_ind = i2
 )
 FREE SET list_reply
 RECORD list_reply(
   1 facility[*]
     2 location_code_value = f8
     2 fac_short_description = vc
     2 fac_full_description = vc
     2 organization_id = f8
     2 bldg_cnt = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE lsize = i4 WITH protect
 SET list_request->search_txt = request->search_txt
 SET list_request->search_type_flag = request->search_type_flag
 SET list_request->max_reply_limit = request->max_reply
 SET list_request->load_only_facs_with_units_ind = 1
 SET list_request->load_only_effective_facs_ind = 1
 EXECUTE bed_get_facility_list  WITH replace("REQUEST",list_request), replace("REPLY",list_reply)
 IF ((list_reply->status_data.status="F"))
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "error in facility list"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = list_reply->status_data.
  subeventstatus[1].targetobjectvalue
  CALL echorecord(list_reply)
  GO TO exit_script
 ENDIF
 SET lsize = size(list_reply->facility,5)
 IF (((lsize=0) OR ((list_reply->too_many_results_ind=1))) )
  SET reply->too_many_results_ind = list_reply->too_many_results_ind
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->facilities,lsize)
 FOR (x = 1 TO lsize)
   SET reply->facilities[x].display = list_reply->facility[x].fac_full_description
   SET reply->facilities[x].code_value = list_reply->facility[x].location_code_value
   SET reply->facilities[x].organization_id = list_reply->facility[x].organization_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(lsize)),
   cms_critical_location l,
   cms_critical_category c,
   mltm_drug_categories m
  PLAN (d)
   JOIN (l
   WHERE (l.organization_id=list_reply->facility[d.seq].organization_id)
    AND (l.location_cd=reply->facilities[d.seq].code_value))
   JOIN (c
   WHERE c.cms_critical_location_id=l.cms_critical_location_id)
   JOIN (m
   WHERE m.multum_category_id=c.multum_category_id)
  ORDER BY d.seq
  HEAD d.seq
   reply->facilities[d.seq].defined_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error on thera select")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
