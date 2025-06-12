CREATE PROGRAM bed_get_rx_sets:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 sets[*]
      2 item_id = f8
      2 description = vc
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
 SET cnt = 0
 SET rcnt = 0
 DECLARE desc_cd = f8
 DECLARE inpt_cd = f8
 DECLARE ord_cd = f8
 DECLARE system_cd = f8
 DECLARE syspkg_cd = f8
 DECLARE oedef_cd = f8
 SET desc_cd = uar_get_code_by("MEANING",11000,"DESC")
 SET inpt_cd = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET ord_cd = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET system_cd = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET syspkg_cd = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET oedef_cd = uar_get_code_by("MEANING",4063,"OEDEF")
 SET max_cnt = 1000000
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ENDIF
 SET wcard = "*"
 DECLARE mi_parse = vc
 DECLARE ingred_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_string) > " ")
  IF ((request->search_type_string="S"))
   SET search_string = concat(trim(cnvtupper(request->search_string)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_string)),wcard)
  ENDIF
  SET mi_parse = concat("cnvtupper(mi.value_key) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET mi_parse = concat("cnvtupper(mi.value_key) = '",search_string,"'")
 ENDIF
 IF (trim(request->ingredient_description) > " ")
  SET search_string = concat(trim(cnvtupper(request->ingredient_description)),wcard)
  SET ingred_parse = concat("cnvtupper(mi2.value_key) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET ingred_parse = concat("cnvtupper(mi2.value_key) = '",search_string,"'")
 ENDIF
 FREE SET temp
 RECORD temp(
   1 sets[*]
     2 id = f8
     2 description = vc
     2 flex_id = f8
     2 add_ind = i2
     2 fac[*]
       3 cd = f8
 )
 SELECT INTO "nl:"
  FROM med_identifier mi,
   medication_definition md,
   med_def_flex mdf,
   med_ingred_set mis,
   med_identifier mi2
  PLAN (mi
   WHERE mi.pharmacy_type_cd=inpt_cd
    AND parser(mi_parse)
    AND mi.med_identifier_type_cd=desc_cd
    AND ((mi.med_product_id+ 0)=0)
    AND ((mi.active_ind+ 0)=1)
    AND mi.primary_ind=1)
   JOIN (md
   WHERE md.item_id=mi.item_id
    AND ((md.med_type_flag+ 0)=request->med_type_flag))
   JOIN (mdf
   WHERE mdf.item_id=mi.item_id
    AND mdf.flex_type_cd=syspkg_cd
    AND mdf.sequence=0
    AND mdf.active_ind=1)
   JOIN (mis
   WHERE mis.parent_item_id=mi.item_id)
   JOIN (mi2
   WHERE mi2.item_id=mis.child_item_id
    AND parser(ingred_parse)
    AND mi2.med_identifier_type_cd=desc_cd)
  ORDER BY mi.item_id
  HEAD mi.item_id
   cnt = (cnt+ 1), stat = alterlist(temp->sets,cnt), temp->sets[cnt].id = mi.item_id,
   temp->sets[cnt].description = mi.value, temp->sets[cnt].flex_id = mi.med_def_flex_id, temp->sets[
   cnt].add_ind = 1
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting on med")
 IF (cnt > 0)
  IF ((request->skip_facility_check_ind=0))
   SET fcnt = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cnt)),
     med_def_flex mdf,
     med_flex_object_idx mfoi
    PLAN (d)
     JOIN (mdf
     WHERE (mdf.item_id=temp->sets[d.seq].id)
      AND mdf.flex_type_cd=syspkg_cd
      AND mdf.sequence=0
      AND mdf.active_ind=1)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=ord_cd
      AND mfoi.active_ind=1)
    ORDER BY d.seq, mfoi.parent_entity_id DESC
    HEAD d.seq
     fcnt = 0
    DETAIL
     fcnt = (fcnt+ 1), stat = alterlist(temp->sets[d.seq].fac,fcnt), temp->sets[d.seq].fac[fcnt].cd
      = mfoi.parent_entity_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error selecting on facility flexing")
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(cnt)),
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_oe_defaults mod
    PLAN (d)
     JOIN (mdf
     WHERE (mdf.item_id=temp->sets[d.seq].id)
      AND mdf.flex_type_cd=system_cd
      AND mdf.sequence=0
      AND mdf.active_ind=1)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=oedef_cd
      AND mfoi.active_ind=1)
     JOIN (mod
     WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id)
    ORDER BY d.seq, mfoi.parent_entity_id DESC
    HEAD d.seq
     IF ((request->dispense_category_code_value > 0))
      IF ((mod.dispense_category_cd != request->dispense_category_code_value))
       temp->sets[d.seq].add_ind = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error selecting on oe defaults")
   FOR (x = 1 TO cnt)
    SET fcnt = size(temp->sets[x].fac,5)
    IF (((size(request->facilities,5)=0) OR ((request->facilities[1].code_value=0))) )
     FOR (y = 1 TO fcnt)
       IF ((temp->sets[x].fac[y].cd=0)
        AND (temp->sets[x].add_ind != 0))
        SET temp->sets[x].add_ind = 1
       ELSE
        SET temp->sets[x].add_ind = 0
       ENDIF
     ENDFOR
    ELSE
     FOR (z = 1 TO size(request->facilities,5))
       SET fac_found = 0
       IF (fcnt=0)
        SET fac_found = 1
       ENDIF
       FOR (y = 1 TO fcnt)
         IF ((temp->sets[x].fac[y].cd IN (request->facilities[z].code_value, 0)))
          SET fac_found = 1
         ELSE
          IF (fac_found != 1)
           SET fac_found = 0
          ENDIF
         ENDIF
       ENDFOR
       IF (fac_found=0)
        SET temp->sets[x].add_ind = 0
       ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
  FOR (x = 1 TO cnt)
    IF ((temp->sets[x].add_ind=1))
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->sets,rcnt)
     SET reply->sets[rcnt].item_id = temp->sets[x].id
     SET reply->sets[rcnt].description = temp->sets[x].description
    ENDIF
  ENDFOR
  IF (rcnt > max_cnt)
   SET stat = alterlist(reply->sets,0)
   SET reply->too_many_results_ind = 1
  ENDIF
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
