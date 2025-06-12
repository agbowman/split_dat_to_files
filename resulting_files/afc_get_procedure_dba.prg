CREATE PROGRAM afc_get_procedure:dba
 DECLARE afc_get_procedure_vrsn = vc
 SET afc_get_procedure_vrsn = "FT.323720.014"
 RECORD reply(
   1 bill_item_qual = i2
   1 bill_item[*]
     2 bill_item_id = f8
     2 ext_description = vc
     2 ext_short_desc = vc
     2 ext_owner_cd = f8
     2 ext_owner_disp = c40
     2 ext_owner_desc = c60
     2 ext_owner_mean = c12
     2 misc_ind = i2
     2 priv_ind = i2
     2 bill_item_mod_id = f8
     2 key6 = vc
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 bill_item_mod_qual = i4
     2 bill_item_mods[*]
       3 bill_item_mod_id = f8
       3 bill_item_type_cd = f8
       3 key1_id = f8
       3 bim_ind = i2
       3 bim1_int = f8
   1 ref_cont_cd = f8
   1 batch_charge_entry_seq = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD cdm(
   1 arr[*]
     2 code_value = f8
 )
 RECORD cpt(
   1 arr[*]
     2 code_value = f8
 )
 RECORD hcpcs(
   1 arr[*]
     2 code_value = f8
 )
 RECORD dcp_request(
   1 chk_prsnl_ind = i2
   1 prsnl_id = f8
   1 chk_psn_ind = i2
   1 position_cd = f8
   1 chk_ppr_ind = i2
   1 ppr_cd = f8
   1 plist[*]
     2 privilege_cd = f8
     2 privilege_mean = c12
 )
 RECORD dcp_reply(
   1 qual[*]
     2 privilege_cd = f8
     2 privilege_disp = c40
     2 privilege_desc = c60
     2 privilege_mean = c12
     2 priv_status = c1
     2 priv_value_cd = f8
     2 priv_value_disp = c40
     2 priv_value_desc = c60
     2 priv_value_mean = c12
     2 restr_method_cd = f8
     2 restr_method_disp = c40
     2 restr_method_desc = c60
     2 restr_method_mean = c12
     2 except_cnt = i4
     2 excepts[*]
       3 exception_entity_name = c40
       3 exception_type_cd = f8
       3 exception_type_disp = c40
       3 exception_type_desc = c60
       3 exception_type_mean = c12
       3 exception_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE userhasprivs(dactivitytypecd) = i2
 DECLARE userhasprivsreturnvalue = i2
 DECLARE meaningforvalue = c12
 DECLARE inexceptionlist = i2
 DECLARE checkbisecurity(dbillitemid) = i2
 DECLARE checkbisecreturnvalue = i2
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE 6016_chargeentry_cd = f8
 DECLARE 26078_bill_item = f8
 SET code_set = 6016
 SET cdf_meaning = "CHARGEENTRY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,6016_chargeentry_cd)
 CALL echo(build("6016_CHARGEENTRY_CD: ",6016_chargeentry_cd))
 DECLARE 6016_chargevient_cd = f8
 SET code_set = 6016
 SET cdf_meaning = "CHARGEVI&ENT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,6016_chargevient_cd)
 CALL echo(build("6016_CHARGEVIENT_CD: ",6016_chargevient_cd))
 SET count1 = 0
 DECLARE bill_code = f8
 SET code_set = 13019
 SET cdf_meaning = "BILL CODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,bill_code)
 CALL echo(concat("bill_code: ",cnvtstring(bill_code,17,2)))
 DECLARE lcvcount = i4
 DECLARE codevalue = f8
 DECLARE total_remaining = i4
 DECLARE start_index = i4
 DECLARE occurances = i4
 DECLARE meaningval = c12
 SET meaningval = "CDM_SCHED"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(cdm->arr,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET cdm->arr[lcvcount].code_value = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(cdm)
 ELSE
  CALL echo("Failure.")
 ENDIF
 SET meaningval = "CPT4"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(cpt->arr,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET cpt->arr[lcvcount].code_value = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(cpt)
 ELSE
  CALL echo("Failure.")
 ENDIF
 SET meaningval = "HCPCS"
 SET start_index = 1
 SET occurances = 1
 SET iret = uar_get_meaning_by_codeset(14002,nullterm(meaningval),occurances,codevalue)
 IF (iret=0
  AND occurances > 0)
  CALL echo(build("Success.  Count: ",occurances))
  DECLARE code_list[value(occurances)] = f8
  CALL uar_get_code_list_by_meaning(14002,nullterm(meaningval),start_index,occurances,total_remaining,
   code_list)
  SET stat = alterlist(hcpcs->arr,occurances)
  FOR (lcvcount = 1 TO size(code_list,5))
    SET hcpcs->arr[lcvcount].code_value = code_list[lcvcount]
  ENDFOR
  FREE SET code_list
  CALL echorecord(hcpcs)
 ELSE
  CALL echo("Failure.")
 ENDIF
 DECLARE bar_code_type_cd = f8
 SET code_set = 13019
 SET cdf_meaning = "BARCODE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,bar_code_type_cd)
 SET code_set = 13016
 SET cdf_meaning = "CHARGE ENTRY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,reply->ref_cont_cd)
 DECLARE prompt_cd = f8
 SET codeset = 13019
 SET cdf_meaning = "PROMPT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(13019,"PROMPT",1,prompt_cd)
 CALL echo(build("PROMPT_CD: ",cnvtstring(prompt_cd,17,2)))
 SET stat = uar_get_meaning_by_codeset(26078,"BILL_ITEM",1,26078_bill_item)
 CALL echo(build("BILL_ITEM: ",26078_bill_item))
 SET ibisec = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="CHARGE SERVICES"
   AND di.info_name="BILL ITEM SECURITY"
   AND di.info_char="Y"
  DETAIL
   CALL echo("Bill Item Security = 1"), ibisec = 1
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->bill_item,(count1+ 10))
 SELECT INTO "nl:"
  b.ext_description
  FROM bill_item b
  WHERE (b.bill_item_id=request->bill_item_id)
   AND b.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->bill_item,count1), reply->bill_item[count1].
   bill_item_id = b.bill_item_id,
   reply->bill_item[count1].ext_description = b.ext_description, reply->bill_item[count1].
   ext_short_desc = b.ext_short_desc, reply->bill_item[count1].ext_owner_cd = b.ext_owner_cd,
   reply->bill_item[count1].ext_parent_reference_id = b.ext_parent_reference_id, reply->bill_item[
   count1].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->bill_item[count1].
   ext_child_contributor_cd = b.ext_child_contributor_cd,
   reply->bill_item[count1].ext_child_reference_id = b.ext_child_reference_id, reply->bill_item[
   count1].misc_ind = b.misc_ind,
   CALL echo("Found Bill Item")
  WITH nocounter
 ;end select
 SET reply->bill_item_qual = count1
 IF ((reply->bill_item_qual > 0))
  IF ((request->bill_item_flg=0))
   IF ((request->bill_code_flg=1))
    CALL echo("Getting primary cdm number")
    SELECT INTO "nl:"
     bm.bill_item_mod_id
     FROM bill_item_modifier bm,
      (dummyt d1  WITH seq = value(reply->bill_item_qual)),
      (dummyt d2  WITH seq = value(size(cdm->arr,5)))
     PLAN (d2)
      JOIN (d1)
      JOIN (bm
      WHERE bm.bill_item_type_cd=bill_code
       AND (bm.key1_id=cdm->arr[d2.seq].code_value)
       AND (bm.bill_item_id=reply->bill_item[d1.seq].bill_item_id)
       AND ((bm.key2_id=1) OR (bm.bim1_int=1))
       AND bm.active_ind=1)
     DETAIL
      reply->bill_item[d1.seq].bill_item_mod_id = bm.bill_item_mod_id, reply->bill_item[d1.seq].key6
       = bm.key6,
      CALL echo(concat("key6: ",bm.key6))
     WITH nocounter
    ;end select
   ELSEIF ((request->bill_code_flg=2))
    SELECT INTO "nl:"
     bm.bill_item_mod_id
     FROM bill_item_modifier bm,
      (dummyt d1  WITH seq = value(reply->bill_item_qual)),
      (dummyt d2  WITH seq = value(size(hcpcs->arr,5)))
     PLAN (d2)
      JOIN (d1)
      JOIN (bm
      WHERE bm.bill_item_type_cd=bill_code
       AND (bm.key1_id=hcpcs->arr[d2.seq].code_value)
       AND (bm.bill_item_id=reply->bill_item[d1.seq].bill_item_id)
       AND ((bm.key2_id=1) OR (bm.bim1_int=1))
       AND bm.active_ind=1)
     DETAIL
      reply->bill_item[d1.seq].bill_item_mod_id = bm.bill_item_mod_id, reply->bill_item[d1.seq].key6
       = bm.key6,
      CALL echo(concat("key6: ",bm.key6))
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     bm.bill_item_mod_id
     FROM bill_item_modifier bm,
      (dummyt d1  WITH seq = value(reply->bill_item_qual)),
      (dummyt d2  WITH seq = value(size(cpt->arr,5)))
     PLAN (d2)
      JOIN (d1)
      JOIN (bm
      WHERE bm.bill_item_type_cd=bill_code
       AND (bm.key1_id=cpt->arr[d2.seq].code_value)
       AND (bm.bill_item_id=reply->bill_item[d1.seq].bill_item_id)
       AND ((bm.key2_id=1) OR (bm.bim1_int=1))
       AND bm.active_ind=1)
     DETAIL
      reply->bill_item[d1.seq].bill_item_mod_id = bm.bill_item_mod_id, reply->bill_item[d1.seq].key6
       = bm.key6
     WITH nocounter
    ;end select
   ENDIF
  ELSE
   SELECT INTO "nl:"
    bm.bill_item_mod_id
    FROM bill_item_modifier bm,
     (dummyt d1  WITH seq = value(reply->bill_item_qual))
    PLAN (d1)
     JOIN (bm
     WHERE bm.bill_item_type_cd=bar_code_type_cd
      AND (bm.bill_item_id=reply->bill_item[d1.seq].bill_item_id)
      AND bm.active_ind=1)
    DETAIL
     reply->bill_item[d1.seq].bill_item_mod_id = bm.bill_item_mod_id, reply->bill_item[d1.seq].key6
      = bm.key6
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET stat = alterlist(reply->bill_item,count1)
 SET reply->bill_item_qual = count1
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "s"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->bill_item_qual > 0))
  SET bim_count = 0
  SELECT INTO "nl:"
   FROM bill_item_modifier bim,
    (dummyt d1  WITH seq = value(size(reply->bill_item,5)))
   PLAN (d1)
    JOIN (bim
    WHERE (bim.bill_item_id=reply->bill_item[d1.seq].bill_item_id)
     AND bim.bill_item_type_cd=prompt_cd
     AND bim.active_ind=1)
   ORDER BY bim.bill_item_id
   HEAD bim.bill_item_id
    bim_count = 0
   DETAIL
    bim_count = (bim_count+ 1), stat = alterlist(reply->bill_item[d1.seq].bill_item_mods,bim_count),
    reply->bill_item[d1.seq].bill_item_mods[bim_count].bill_item_mod_id = bim.bill_item_mod_id,
    reply->bill_item[d1.seq].bill_item_mods[bim_count].bill_item_type_cd = bim.bill_item_type_cd,
    reply->bill_item[d1.seq].bill_item_mods[bim_count].key1_id = bim.key1_id, reply->bill_item[d1.seq
    ].bill_item_mods[bim_count].bim_ind = bim.bim_ind,
    reply->bill_item[d1.seq].bill_item_mods[bim_count].bim1_int = bim.bim1_int, reply->bill_item[d1
    .seq].bill_item_mod_qual = bim_count
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  y = seq(batch_charge_entry_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   reply->batch_charge_entry_seq = cnvtreal(y)
  WITH format, counter
 ;end select
 FOR (nbicount = 1 TO reply->bill_item_qual)
   CALL echo(build("checking bill item: ",reply->bill_item[nbicount].bill_item_id))
   CALL echo(build("    with activity type: ",reply->bill_item[nbicount].ext_owner_cd))
   SET inexceptionlist = 0
   SET userhasprivsreturnvalue = 0
   IF (userhasprivs(reply->bill_item[nbicount].ext_owner_cd)=1)
    SET reply->bill_item[nbicount].priv_ind = 1
    CALL echo(build("priv_ind: ",reply->bill_item[nbicount].priv_ind))
   ENDIF
   CALL echo(build("result is: ",reply->bill_item[nbicount].priv_ind))
 ENDFOR
 IF (ibisec=1)
  CALL echo("Checking BILL ITEM Security")
  CALL echo(build("bill item qual: ",reply->bill_item_qual))
  SET nbicount = 0
  FOR (nbicount = 1 TO reply->bill_item_qual)
    CALL echo(build("checking bill item: ",reply->bill_item[nbicount].bill_item_id))
    IF ((reply->bill_item[nbicount].priv_ind=0))
     SET checkbisecreturnvalue = 0
     IF (checkbisecurity(reply->bill_item[nbicount].bill_item_id)=1)
      SET reply->bill_item[nbicount].priv_ind = 1
      CALL echo(build("priv_ind: ",reply->bill_item[nbicount].priv_ind))
     ENDIF
    ENDIF
    CALL echo(build("result is: ",reply->bill_item[nbicount].priv_ind))
  ENDFOR
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE userhasprivs(dactivitytypecd)
   CALL echo(build("executing UserHasPrivs for activity type: ",dactivitytypecd))
   CALL echo(build("and position: ",reqinfo->position_cd))
   SET stat = alterlist(dcp_reply->qual,0)
   SET dcp_request->chk_psn_ind = 1
   SET stat = alterlist(dcp_request->plist,1)
   SET dcp_request->plist[1].privilege_mean = "CHARGEENTRY"
   SET dcp_request->plist[1].privilege_cd = 6016_chargeentry_cd
   EXECUTE dcp_get_privs  WITH replace("REQUEST",dcp_request), replace("REPLY",dcp_reply)
   IF (size(dcp_reply->qual,5)=0)
    CALL echo("Did not find anything for CHARGEENTRY, trying CHARGEVIE&ENT")
    SET dcp_request->plist[1].privilege_meaning = "CHARGEVI&ENT"
    SET dcp_request->plist[1].privilege_cd = 6016_chargevient_cd
    EXECUTE dcp_get_privs  WITH replace("REQUEST",dcp_request), replace("REPLY",dcp_reply)
   ENDIF
   IF (size(dcp_reply->qual,5)=1)
    IF ((dcp_reply->qual[1].priv_value_cd=0))
     CALL echo("PRIV NOT DEFINED.  Trying CHARGEVIE&ENT")
     SET dcp_request->plist[1].privilege_mean = "CHARGEVI&ENT"
     SET dcp_request->plist[1].privilege_cd = 6016_chargevient_cd
     EXECUTE dcp_get_privs  WITH replace("REQUEST",dcp_request), replace("REPLY",dcp_reply)
    ENDIF
   ENDIF
   CALL echo(build("Back from call to dcp size is: ",size(dcp_reply->qual,5)))
   IF (size(dcp_reply->qual,5) > 0)
    FOR (nrepcount = 1 TO size(dcp_reply->qual,5))
     SET meaningforvalue = uar_get_code_meaning(dcp_reply->qual[nrepcount].priv_value_cd)
     IF (meaningforvalue="YES")
      SET userhasprivsreturnvalue = 0
     ELSEIF (meaningforvalue="NO")
      SET userhasprivsreturnvalue = 1
     ELSEIF (meaningforvalue="EXCLUDE")
      CALL echo("In 'Yes, except for'")
      FOR (nexceptionloop = 1 TO dcp_reply->qual[nrepcount].except_cnt)
        IF ((dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_entity_name="ACTIVITY TYPE"
        ))
         IF ((dactivitytypecd=dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_id))
          SET inexceptionlist = 1
          CALL echo(build("User allowed except for: ",dactivitytypecd))
         ENDIF
        ENDIF
      ENDFOR
      IF (inexceptionlist=1)
       SET userhasprivsreturnvalue = 1
      ENDIF
     ELSEIF (meaningforvalue="INCLUDE")
      FOR (nexceptionloop = 1 TO dcp_reply->qual[nrepcount].except_cnt)
        IF ((dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_entity_name="ACTIVITY TYPE"
        ))
         IF ((dactivitytypecd=dcp_reply->qual[nrepcount].excepts[nexceptionloop].exception_id))
          SET inexceptionlist = 1
         ENDIF
        ENDIF
      ENDFOR
      IF (inexceptionlist=0)
       SET userhasprivsreturnvalue = 1
      ENDIF
     ELSE
      CALL echo("Nothing built for this activity type/user")
     ENDIF
    ENDFOR
   ELSE
    CALL echo("Didn't find anything.  Nothing built in PrivTool")
   ENDIF
   RETURN(userhasprivsreturnvalue)
 END ;Subroutine
 SUBROUTINE checkbisecurity(dbillitemid)
   CALL echo(build("CheckBISecurity for bid: ",dbillitemid))
   SET found_one = 0
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por,
     cs_org_reltn cor
    PLAN (por
     WHERE (por.person_id=reqinfo->updt_id)
      AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND por.active_ind=1)
     JOIN (cor
     WHERE cor.organization_id=por.organization_id
      AND cor.cs_org_reltn_type_cd=26078_bill_item
      AND cor.key1_entity_name="BILL_ITEM"
      AND cor.key1_id=dbillitemid
      AND cor.active_ind=1)
    DETAIL
     found_one = 1
    WITH nocounter
   ;end select
   IF (found_one=0)
    CALL echo("The user does not have privs to see the bill item")
    SET checkbisecreturnvalue = 1
   ENDIF
   RETURN(checkbisecreturnvalue)
 END ;Subroutine
 FREE SET cdm
 FREE SET cpt
 FREE SET hcpcs
END GO
