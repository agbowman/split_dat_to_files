CREATE PROGRAM bed_rec_par_child_ord_allign:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 pelist[*]
     2 oe_format = f8
     2 oe_field = f8
     2 catalog = f8
     2 synonym = f8
 )
 SET reply->run_status_flag = 1
 SET cont_pass_value = 0
 SET acc_pass_value = 0
 SET cont_fail_value = 0
 DECLARE order_action = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE z_var = f8 WITH constant(uar_get_code_by("MEANING",6011,"TRADEPROD")), protect
 DECLARE y_var = f8 WITH constant(uar_get_code_by("MEANING",6011,"GENERICPROD")), protect
 SET tcnt = 0
 SELECT DISTINCT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   order_entry_format oef,
   oe_format_fields off,
   order_entry_fields oefs,
   oe_field_meaning ofm,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.cont_order_method_flag=0)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND  NOT (ocs.mnemonic_type_cd IN (z_var, y_var))
    AND ocs.active_ind=1)
   JOIN (oef
   WHERE oef.oe_format_id=ocs.oe_format_id
    AND oef.action_type_cd=order_action)
   JOIN (off
   WHERE off.oe_format_id=oef.oe_format_id
    AND off.action_type_cd=oef.action_type_cd)
   JOIN (oefs
   WHERE oefs.oe_field_id=off.oe_field_id)
   JOIN (ofm
   WHERE ofm.oe_field_meaning_id=oefs.oe_field_meaning_id
    AND trim(ofm.oe_field_meaning) IN ("FREQ", "FREQSCHEDID"))
   JOIN (cv1
   WHERE outerjoin(oc.catalog_type_cd)=cv1.code_value
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE outerjoin(oc.activity_type_cd)=cv2.code_value
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE outerjoin(oc.activity_subtype_cd)=cv3.code_value
    AND cv3.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE outerjoin(ocs.mnemonic_type_cd)=cv4.code_value
    AND cv4.active_ind=outerjoin(1))
  ORDER BY ocs.synonym_id
  HEAD ocs.synonym_id
   IF (((off.accept_flag=0) OR (((off.accept_flag=1) OR (((off.accept_flag=2) OR (off.accept_flag=3
   ))
    AND ((off.default_value > " ") OR (off.default_parent_entity_id > 0)) )) )) )
    cont_fail_value = 1
   ELSE
    tcnt = (tcnt+ 1), stat = alterlist(temp->pelist,tcnt), temp->pelist[tcnt].oe_format = oef
    .oe_format_id,
    temp->pelist[tcnt].oe_field = off.oe_field_id, temp->pelist[tcnt].catalog = oc.catalog_cd, temp->
    pelist[tcnt].synonym = ocs.synonym_id,
    acc_pass_value = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (cont_fail_value=1)
  SET reply->run_status_flag = 3
  CALL echo(build("flag",reply->run_status_flag))
  GO TO exit_script
 ENDIF
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    order_catalog oc,
    order_catalog_synonym ocs,
    accept_format_flexing aff,
    code_value cv1,
    code_value cv2,
    code_value cv3,
    code_value cv4
   PLAN (d
    WHERE (temp->pelist[d.seq].oe_format > 0))
    JOIN (oc
    WHERE (oc.catalog_cd=temp->pelist[d.seq].catalog)
     AND oc.cont_order_method_flag=0
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE (ocs.synonym_id=temp->pelist[d.seq].synonym)
     AND ocs.catalog_cd=oc.catalog_cd
     AND  NOT (ocs.mnemonic_type_cd IN (z_var, y_var))
     AND ocs.active_ind=1)
    JOIN (aff
    WHERE (aff.oe_format_id=temp->pelist[d.seq].oe_format)
     AND (aff.oe_field_id=temp->pelist[d.seq].oe_field)
     AND aff.action_type_cd=order_action)
    JOIN (cv1
    WHERE outerjoin(oc.catalog_type_cd)=cv1.code_value
     AND cv1.active_ind=outerjoin(1))
    JOIN (cv2
    WHERE outerjoin(oc.activity_type_cd)=cv2.code_value
     AND cv2.active_ind=outerjoin(1))
    JOIN (cv3
    WHERE outerjoin(oc.activity_subtype_cd)=cv3.code_value
     AND cv3.active_ind=outerjoin(1))
    JOIN (cv4
    WHERE outerjoin(ocs.mnemonic_type_cd)=cv4.code_value
     AND cv4.active_ind=outerjoin(1))
   ORDER BY ocs.synonym_id
   HEAD ocs.synonym_id
    IF (((aff.accept_flag=0) OR (((aff.accept_flag=1) OR (((aff.accept_flag=2) OR (aff.accept_flag=3
    ))
     AND ((aff.default_value > " ") OR (aff.default_parent_entity_id > 0)) )) )) )
     cont_fail_value = 1
    ELSE
     acc_pass_value = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (cont_fail_value=1)
   SET reply->run_status_flag = 3
   CALL echo(build("flag",reply->run_status_flag))
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
END GO
