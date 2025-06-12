CREATE PROGRAM bed_get_power_plan_subphases:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 subphases[*]
      2 power_plan_id = f8
      2 display_description = vc
      2 vv_all_facilities_ind = i2
      2 vv_facility[*]
        3 id = f8
        3 display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET power_plan_facility
 RECORD power_plan_facility(
   1 power_plan_facility[*]
     2 id = f8
 )
 FREE SET temp_reply
 RECORD temp_reply(
   1 subphases[*]
     2 power_plan_id = f8
     2 display_description = vc
     2 vv_facility[*]
       3 id = f8
       3 display = vc
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE search_string = vc
 SET search_string = concat("*",cnvtupper(trim(request->search_string)),"*")
 DECLARE temp_cnt = i4
 DECLARE total_cnt = i4
 DECLARE facility_cnt = i4
 DECLARE total_facility_cnt = i4
 SET temp_cnt = 0
 SET total_cnt = 0
 SET facility_cnt = 0
 SET total_facility_cnt = 0
 SELECT INTO "nl:"
  FROM pathway_catalog p,
   pw_cat_flex pcf,
   code_value cv1
  PLAN (p
   WHERE p.active_ind=1
    AND cnvtupper(p.display_description)=patstring(search_string)
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p.type_mean IN ("CAREPLAN")
    AND p.ref_owner_person_id=0
    AND p.sub_phase_ind=1)
   JOIN (pcf
   WHERE p.pathway_catalog_id=pcf.pathway_catalog_id
    AND pcf.parent_entity_name="CODE_VALUE")
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(pcf.parent_entity_id)
    AND cv1.active_ind=outerjoin(1))
  HEAD REPORT
   temp_cnt = 10, total_cnt = 0, stat = alterlist(temp_reply->subphases,temp_cnt)
  HEAD p.pathway_catalog_id
   temp_cnt = (temp_cnt+ 1), total_cnt = (total_cnt+ 1)
   IF (temp_cnt > 10)
    temp_cnt = 1, stat = alterlist(temp_reply->subphases,(total_cnt+ 10))
   ENDIF
   temp_reply->subphases[total_cnt].power_plan_id = p.pathway_catalog_id, temp_reply->subphases[
   total_cnt].display_description = p.display_description, stat = alterlist(temp_reply->subphases[
    total_cnt].vv_facility,5),
   facility_cnt = 0, total_facility_cnt = 0
  DETAIL
   facility_cnt = (facility_cnt+ 1), total_facility_cnt = (total_facility_cnt+ 1)
   IF (facility_cnt > 5)
    stat = alterlist(temp_reply->subphases[total_cnt].vv_facility,(total_facility_cnt+ 5)),
    facility_cnt = 1
   ENDIF
   temp_reply->subphases[total_cnt].vv_facility[total_facility_cnt].id = pcf.parent_entity_id,
   temp_reply->subphases[total_cnt].vv_facility[total_facility_cnt].display = cv1.display
  FOOT  p.pathway_catalog_id
   stat = alterlist(temp_reply->subphases[total_cnt].vv_facility,total_facility_cnt)
  FOOT REPORT
   stat = alterlist(temp_reply->subphases,total_cnt)
  WITH nocounter
 ;end select
 CALL echorecord(temp_reply)
 IF ((request->virtual_view_ind=0))
  CALL handlenovirtualview(1)
 ELSE
  SET facility_count = 0
  SET alter_facility_count = 0
  SELECT INTO "NL:"
   FROM pw_cat_flex p
   WHERE (p.pathway_catalog_id=request->power_plan_id)
    AND p.parent_entity_name="CODE_VALUE"
   HEAD REPORT
    stat = alterlist(power_plan_facility->power_plan_facility,10), facility_count = 0,
    alter_facility_count = 0
   DETAIL
    facility_count = (facility_count+ 1), alter_facility_count = (alter_facility_count+ 1)
    IF (alter_facility_count > 10)
     stat = alterlist(power_plan_facility->power_plan_facility,(facility_count+ 10)),
     alter_facility_count = 1
    ENDIF
    power_plan_facility->power_plan_facility[facility_count].id = p.parent_entity_id
   FOOT REPORT
    stat = alterlist(power_plan_facility->power_plan_facility,facility_count)
   WITH nocounter
  ;end select
  IF (facility_count=0)
   CALL handlenovirtualview(1)
   GO TO exit_script
  ENDIF
  IF ((request->virtual_view_ind=1))
   IF (size(power_plan_facility->power_plan_facility,5)=1)
    IF ((power_plan_facility->power_plan_facility[1].id=0))
     SET powerplan_cnt = size(temp_reply->subphases,5)
     FOR (x = 1 TO powerplan_cnt)
       SET vv_facility_count = size(temp_reply->subphases[x].vv_facility,5)
       SET fac_num = 0
       SET fac_start = 0
       SET fac_found = 0
       SET fac_found = locateval(fac_num,fac_start,vv_facility_count,0.0,temp_reply->subphases[x].
        vv_facility[fac_num].id)
       IF (fac_found > 0)
        CALL addsynonymtoreply(x)
       ENDIF
     ENDFOR
     GO TO exit_script
    ENDIF
   ENDIF
   SET sp_count = size(temp_reply->subphases,5)
   FOR (x = 1 TO sp_count)
     SET vv_facility_count = size(temp_reply->subphases[x].vv_facility,5)
     SET fac_num = 0
     SET fac_start = 0
     SET fac_found = 0
     SET vv_plan_count = size(power_plan_facility->power_plan_facility,5)
     SET found = locateval(fac_num,fac_start,vv_facility_count,0.0,temp_reply->subphases[x].
      vv_facility[fac_num].id)
     IF (found > 0)
      SET fac_found = 0
      SET vv_plan_count = 0
     ENDIF
     FOR (z = 1 TO vv_plan_count)
      SET found = locateval(fac_num,fac_start,vv_facility_count,power_plan_facility->
       power_plan_facility[z].id,temp_reply->subphases[x].vv_facility[fac_num].id)
      IF (found=0)
       SET z = vv_plan_count
      ELSE
       SET fac_found = (fac_found+ 1)
      ENDIF
     ENDFOR
     IF (fac_found=vv_plan_count)
      CALL addsynonymtoreply(x)
     ENDIF
   ENDFOR
  ELSEIF ((request->virtual_view_ind=2))
   IF (size(power_plan_facility->power_plan_facility,5)=1)
    IF ((power_plan_facility->power_plan_facility[1].id=0))
     SET total_cnt = size(temp_reply->subphases,5)
     FOR (x = 1 TO total_cnt)
      SET vv_facility_count = size(temp_reply->subphases[x].vv_facility,5)
      IF (vv_facility_count > 0)
       CALL addsynonymtoreply(x)
      ENDIF
     ENDFOR
     GO TO exit_script
    ENDIF
   ENDIF
   SET total_cnt = size(temp_reply->subphases,5)
   FOR (x = 1 TO total_cnt)
     SET vv_facility_count = size(temp_reply->subphases[x].vv_facility,5)
     SET fac_num = 0
     SET fac_start = 0
     SET fac_found = 0
     SET found = locateval(fac_num,fac_start,vv_facility_count,0.0,temp_reply->subphases[x].
      vv_facility[fac_num].id)
     IF (found > 0)
      SET fac_found = (fac_found+ 1)
     ELSE
      SET vv_plan_count = size(power_plan_facility->power_plan_facility,5)
      FOR (z = 1 TO vv_plan_count)
        SET found = 0
        SET found = locateval(fac_num,fac_start,vv_facility_count,power_plan_facility->
         power_plan_facility[z].id,temp_reply->subphases[x].vv_facility[fac_num].id)
        IF (found > 0)
         SET fac_found = (fac_found+ 1)
         SET z = vv_plan_count
        ENDIF
      ENDFOR
     ENDIF
     IF (fac_found > 0)
      CALL addsynonymtoreply(x)
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SUBROUTINE addsynonymtoreply(sp_index)
   SET subphase_cnt = size(reply->subphases,5)
   SET num = 0
   SET start = 0
   SET found = locateval(num,start,subphase_cnt,temp_reply->subphases[sp_index].power_plan_id,reply->
    subphases[num].power_plan_id)
   IF (found=0)
    SET subphase_cnt = (subphase_cnt+ 1)
    SET stat = alterlist(reply->subphases,subphase_cnt)
    SET reply->subphases[subphase_cnt].power_plan_id = temp_reply->subphases[sp_index].power_plan_id
    SET reply->subphases[subphase_cnt].display_description = temp_reply->subphases[sp_index].
    display_description
    SET vv_count = size(temp_reply->subphases[sp_index].vv_facility,5)
    SET stat = alterlist(reply->subphases[subphase_cnt].vv_facility,vv_count)
    FOR (y = 1 TO vv_count)
      IF ((temp_reply->subphases[sp_index].vv_facility[y].id=0.0))
       SET reply->subphases[subphase_cnt].vv_all_facilities_ind = 1
      ENDIF
      SET reply->subphases[subphase_cnt].vv_facility[y].id = temp_reply->subphases[sp_index].
      vv_facility[y].id
      SET reply->subphases[subphase_cnt].vv_facility[y].display = temp_reply->subphases[sp_index].
      vv_facility[y].display
    ENDFOR
    SET found = subphase_cnt
   ENDIF
 END ;Subroutine
 SUBROUTINE handlenovirtualview(dummyv)
   SET total_cnt = size(temp_reply->subphases,5)
   SET stat = alterlist(reply->subphases,total_cnt)
   FOR (x = 1 TO total_cnt)
     SET reply->subphases[x].power_plan_id = temp_reply->subphases[x].power_plan_id
     SET reply->subphases[x].display_description = temp_reply->subphases[x].display_description
     SET vv_count = size(temp_reply->subphases[x].vv_facility,5)
     SET stat = alterlist(reply->subphases[x].vv_facility,vv_count)
     FOR (y = 1 TO vv_count)
       IF ((temp_reply->subphases[x].vv_facility[y].id=0.0))
        SET reply->subphases[x].vv_all_facilities_ind = 1
       ENDIF
       SET reply->subphases[x].vv_facility[y].id = temp_reply->subphases[x].vv_facility[y].id
       SET reply->subphases[x].vv_facility[y].display = temp_reply->subphases[x].vv_facility[y].
       display
     ENDFOR
   ENDFOR
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
