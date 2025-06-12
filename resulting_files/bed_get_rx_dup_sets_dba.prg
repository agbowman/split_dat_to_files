CREATE PROGRAM bed_get_rx_dup_sets:dba
 FREE SET reply
 RECORD reply(
   1 duplicate_iv_set_ind = i2
   1 duplicates[*]
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE inpatient_cd = f8
 DECLARE oedef_cd = f8
 DECLARE syspkg_cd = f8
 DECLARE desc_cd = f8
 DECLARE ord_cd = f8
 SET inpatient_cd = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET oedef_cd = uar_get_code_by("MEANING",4063,"OEDEF")
 SET syspkg_cd = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET desc_cd = uar_get_code_by("MEANING",11000,"DESC")
 SET ord_cd = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET dup_ind = 0
 SET ingred_dup_ind = 0
 DECLARE ingred_dup_name = vc
 SELECT INTO "nl:"
  FROM med_identifier m
  PLAN (m
   WHERE (m.value=request->description)
    AND m.med_identifier_type_cd=desc_cd
    AND (m.med_type_flag=request->med_type_flag))
  DETAIL
   dup_ind = 1
  WITH nocounter
 ;end select
 IF (dup_ind=1)
  GO TO exit_script
 ENDIF
 FREE SET iv
 RECORD iv(
   1 qual[*]
     2 id = f8
     2 name = vc
     2 dup_ind = i2
     2 ingred[*]
       3 id = f8
       3 found_ind = i2
       3 dup_ind = i2
     2 fac[*]
       3 cd = f8
 )
 RECORD req_ing(
   1 ingredients[*]
     2 id = f8
     2 dose = f8
     2 dose_unit_code_value = f8
     2 strength_ind = i2
     2 volume_ind = i2
     2 match_ind = i2
 )
 SET rcnt = size(request->ingredients,5)
 SET stat = alterlist(req_ing->ingredients,rcnt)
 FOR (x = 1 TO rcnt)
   SET req_ing->ingredients[x].id = request->ingredients[x].id
   SET req_ing->ingredients[x].dose = request->ingredients[x].dose
   SET req_ing->ingredients[x].dose_unit_code_value = request->ingredients[x].dose_unit_code_value
   SET req_ing->ingredients[x].strength_ind = request->ingredients[x].strength_ind
   SET req_ing->ingredients[x].volume_ind = request->ingredients[x].volume_ind
   SET req_ing->ingredients[x].match_ind = 0
 ENDFOR
 SET ivcnt = 0
 SET ingcnt = 0
 SELECT INTO "nl:"
  FROM med_identifier mi,
   med_ingred_set mis,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   med_oe_defaults mod
  PLAN (mi
   WHERE mi.pharmacy_type_cd=inpatient_cd
    AND mi.med_identifier_type_cd=desc_cd
    AND ((mi.med_product_id+ 0)=0)
    AND ((mi.med_type_flag+ 0)=request->med_type_flag)
    AND ((mi.active_ind+ 0)=1))
   JOIN (mis
   WHERE mis.parent_item_id=mi.item_id)
   JOIN (mdf
   WHERE mdf.item_id=mi.item_id
    AND mdf.flex_type_cd=syspkg_cd
    AND mdf.sequence=mis.sequence
    AND mdf.active_ind=1)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=oedef_cd
    AND mfoi.active_ind=1)
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi.parent_entity_id
    AND mod.active_ind=1)
  ORDER BY mis.parent_item_id
  HEAD mis.parent_item_id
   ingcnt = 0, ivcnt = (ivcnt+ 1), stat = alterlist(iv->qual,ivcnt),
   iv->qual[ivcnt].id = mis.parent_item_id, iv->qual[ivcnt].name = mi.value, iv->qual[ivcnt].dup_ind
    = 1
  HEAD mis.child_item_id
   ingcnt = (ingcnt+ 1), stat = alterlist(iv->qual[ivcnt].ingred,ingcnt), iv->qual[ivcnt].ingred[
   ingcnt].id = mis.child_item_id,
   ingred_found = 0
   FOR (x = 1 TO size(req_ing->ingredients,5))
     IF ((mis.child_item_id=req_ing->ingredients[x].id))
      ingred_found = 1, iv->qual[ivcnt].ingred[ingcnt].found_ind = 1
      IF ((req_ing->ingredients[x].strength_ind=1))
       IF ((round(mod.strength,4)=req_ing->ingredients[x].dose)
        AND (mod.strength_unit_cd=req_ing->ingredients[x].dose_unit_code_value))
        iv->qual[ivcnt].ingred[ingcnt].dup_ind = 1, req_ing->ingredients[x].match_ind = 1
       ENDIF
      ENDIF
      IF ((req_ing->ingredients[x].volume_ind=1))
       IF ((round(mod.volume,4)=req_ing->ingredients[x].dose)
        AND (mod.volume_unit_cd=req_ing->ingredients[x].dose_unit_code_value))
        iv->qual[ivcnt].ingred[ingcnt].dup_ind = 1, req_ing->ingredients[x].match_ind = 1
       ENDIF
      ENDIF
      IF ((req_ing->ingredients[x].strength_ind=0)
       AND (req_ing->ingredients[x].volume_ind=0))
       IF ((round(mod.strength,4)=req_ing->ingredients[x].dose)
        AND (mod.strength_unit_cd=req_ing->ingredients[x].dose_unit_code_value))
        iv->qual[ivcnt].ingred[ingcnt].dup_ind = 1, req_ing->ingredients[x].match_ind = 1
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   IF (ingred_found=0)
    iv->qual[ivcnt].dup_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET dcnt = 0
 FOR (x = 1 TO ivcnt)
  IF ((iv->qual[x].dup_ind=1))
   IF (size(request->ingredients,5) != size(iv->qual[x].ingred,5))
    SET iv->qual[x].dup_ind = 0
   ENDIF
   SET iv_dup = 1
   FOR (y = 1 TO size(iv->qual[x].ingred,5))
    IF ((iv->qual[x].ingred[y].found_ind=0))
     SET iv_dup = 0
    ENDIF
    IF ((iv->qual[x].ingred[y].found_ind=1)
     AND (iv->qual[x].ingred[y].dup_ind != 1))
     SET iv_dup = 0
    ENDIF
   ENDFOR
   IF (iv_dup=0)
    SET iv->qual[x].dup_ind = 0
   ENDIF
  ENDIF
  IF ((iv->qual[x].dup_ind=1))
   SET fac_found = 0
   SET faccnt = size(request->facilities,5)
   IF (faccnt=0)
    SET faccnt = 1
    SET stat = alterlist(request->facilities,1)
    SET request->facilities[1].code_value = 0
   ENDIF
   SET fcnt = 0
   SELECT INTO "nl:"
    FROM med_def_flex mdf,
     med_flex_object_idx mfoi
    PLAN (mdf
     WHERE (mdf.item_id=iv->qual[x].id)
      AND mdf.flex_type_cd=syspkg_cd
      AND mdf.sequence=0
      AND mdf.active_ind=1)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=ord_cd
      AND mfoi.active_ind=1)
    DETAIL
     fcnt = (fcnt+ 1), stat = alterlist(iv->qual[x].fac,fcnt), iv->qual[x].fac[fcnt].cd = mfoi
     .parent_entity_id
     FOR (y = 1 TO faccnt)
       IF ((((request->facilities[y].code_value=mfoi.parent_entity_id)) OR (mfoi.parent_entity_id=0
       )) )
        fac_found = 1
       ENDIF
     ENDFOR
     IF (faccnt=0)
      fac_found = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (fac_found=1)
    SET dcnt = (dcnt+ 1)
    SET stat = alterlist(reply->duplicates,dcnt)
    SET reply->duplicates[dcnt].name = iv->qual[x].name
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (((dup_ind=1) OR (ingred_dup_ind=1)) )
  IF (dup_ind=1)
   SET reply->duplicate_iv_set_ind = 1
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
