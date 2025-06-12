CREATE PROGRAM bed_get_mdro_parameters:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 mdro_code_value = f8
    1 mdro_display = vc
    1 mdro_description = vc
    1 mdro_type_ind = i2
    1 category_id = f8
    1 category_name = vc
    1 category_type_ind = i2
    1 drug_groups[*]
      2 drg_grp_id = f8
      2 name = vc
      2 drug_resistant_nbr = i4
      2 drugs[*]
        3 drug_code_value = f8
        3 display = vc
        3 description = vc
        3 interp_results[*]
          4 interp_code_value = f8
          4 display = vc
          4 description = vc
    1 group_resistant_nbr = i4
    1 normalcy_codes[*]
      2 normalcy_code_value = f8
      2 display = vc
      2 description = vc
      2 cdf_meaning = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 mdro_id = f8
    1 mdro_name_display = vc
    1 antibiotics_text = vc
    1 drug_relation_id = f8
    1 lookback_setting_nbr = i4
    1 lookback_setting_unit
      2 display = vc
      2 lookback_setting_unit_cd = f8
  )
 ENDIF
 DECLARE e_parse = vc WITH protect, noconstant("")
 DECLARE o_parse = vc WITH protect, noconstant("")
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
 SET e_parse = build2("cat_e.br_mdro_cat_event_id = ",request->mdro_code_value)
 SET o_parse = build2("cat_o.br_mdro_cat_organism_id = ",request->mdro_code_value)
 IF (validate(request->facility_code_value))
  SET e_parse = build2(e_parse," and cat_e.location_cd = ")
  SET e_parse = build2(e_parse,request->facility_code_value)
  SET o_parse = build2(o_parse," and cat_o.location_cd = ")
  SET o_parse = build2(o_parse,request->facility_code_value)
 ENDIF
 IF ((request->mdro_type_ind=1))
  SET tcnt = 0
  SELECT INTO "NL:"
   FROM br_mdro_cat_event cat_e,
    br_mdro_cat cat,
    br_cat_event_normalcy cen,
    code_value cve,
    code_value cvn,
    br_mdro mn,
    code_value unit_cv
   PLAN (cat_e
    WHERE parser(e_parse))
    JOIN (cat
    WHERE cat.br_mdro_cat_id=cat_e.br_mdro_cat_id
     AND (cat.cat_type_flag=request->category_type_ind))
    JOIN (cen
    WHERE cen.br_mdro_cat_event_id=cat_e.br_mdro_cat_event_id)
    JOIN (cve
    WHERE cve.code_value=cat_e.event_cd
     AND cve.active_ind=1)
    JOIN (cvn
    WHERE cvn.code_value=cen.normalcy_cd
     AND cvn.active_ind=1)
    JOIN (mn
    WHERE mn.br_mdro_id=cat_e.br_mdro_id)
    JOIN (unit_cv
    WHERE unit_cv.code_value=outerjoin(cat_e.lookback_time_span_unit_cd))
   ORDER BY cat_e.event_cd, cen.normalcy_cd, unit_cv.code_value
   HEAD cat_e.event_cd
    acnt = 0, reply->category_name = cat.mdro_cat_name, reply->category_id = cat.br_mdro_cat_id,
    reply->mdro_code_value = cat_e.event_cd, reply->mdro_type_ind = 1, reply->mdro_display = cve
    .display,
    reply->mdro_description = cve.description, reply->category_type_ind = cat.cat_type_flag, reply->
    mdro_id = mn.br_mdro_id,
    reply->mdro_name_display = mn.mdro_name, reply->drug_relation_id = cat_e.br_mdro_cat_event_id,
    reply->lookback_setting_nbr = cat_e.lookback_time_span_nbr,
    reply->lookback_setting_unit.lookback_setting_unit_cd = cat_e.lookback_time_span_unit_cd
   HEAD cen.normalcy_cd
    acnt = (acnt+ 1), stat = alterlist(reply->normalcy_codes,acnt), reply->normalcy_codes[acnt].
    normalcy_code_value = cen.normalcy_cd,
    reply->normalcy_codes[acnt].display = cvn.display, reply->normalcy_codes[acnt].description = cvn
    .description, reply->normalcy_codes[acnt].cdf_meaning = cvn.cdf_meaning
   HEAD unit_cv.code_value
    reply->lookback_setting_unit.display = unit_cv.display
   WITH nocounter
  ;end select
 ELSEIF ((request->mdro_type_ind=2))
  SET cat_org_id = 0.0
  SET tcnt = 0
  SELECT INTO "nl:"
   FROM br_mdro_cat_organism cat_o,
    br_mdro_cat cat,
    code_value cv,
    br_mdro mn,
    code_value unit_cv
   PLAN (cat_o
    WHERE parser(o_parse))
    JOIN (cat
    WHERE cat.br_mdro_cat_id=cat_o.br_mdro_cat_id
     AND (cat.cat_type_flag=request->category_type_ind))
    JOIN (cv
    WHERE cv.code_value=cat_o.organism_cd
     AND cv.active_ind=1)
    JOIN (mn
    WHERE mn.br_mdro_id=cat_o.br_mdro_id)
    JOIN (unit_cv
    WHERE unit_cv.code_value=outerjoin(cat_o.lookback_time_span_unit_cd))
   ORDER BY cat_o.organism_cd, unit_cv.code_value
   HEAD cat_o.organism_cd
    acnt = 0, cat_org_id = cat_o.br_mdro_cat_organism_id, reply->category_name = cat.mdro_cat_name,
    reply->category_id = cat.br_mdro_cat_id, reply->category_type_ind = cat.cat_type_flag, reply->
    group_resistant_nbr = cat_o.group_resistant_cnt,
    reply->mdro_code_value = cat_o.organism_cd, reply->mdro_type_ind = 2, reply->mdro_display = cv
    .display,
    reply->mdro_description = cv.description, reply->mdro_id = mn.br_mdro_id, reply->
    mdro_name_display = mn.mdro_name,
    reply->antibiotics_text = cat_o.antibiotics_txt, reply->drug_relation_id = cat_o
    .br_mdro_cat_organism_id, reply->lookback_setting_nbr = cat_o.lookback_time_span_nbr,
    reply->lookback_setting_unit.lookback_setting_unit_cd = cat_o.lookback_time_span_unit_cd
   HEAD unit_cv.code_value
    reply->lookback_setting_unit.display = unit_cv.display
   WITH nocounter
  ;end select
  IF ((reply->group_resistant_nbr > 0))
   SELECT INTO "nl:"
    FROM br_mdro_cat_organism cat_o,
     br_drug_group_organism dgo,
     br_drug_group dg,
     br_drug_group_antibiotic dga,
     code_value cvdrug
    PLAN (cat_o
     WHERE (cat_o.br_mdro_cat_id=reply->category_id)
      AND parser(o_parse))
     JOIN (dgo
     WHERE dgo.br_mdro_cat_organism_id=cat_o.br_mdro_cat_organism_id)
     JOIN (dga
     WHERE dga.br_drug_group_id=dgo.br_drug_group_id)
     JOIN (dg
     WHERE dg.br_drug_group_id=dga.br_drug_group_id)
     JOIN (cvdrug
     WHERE cvdrug.code_value=dga.antibiotic_cd
      AND cvdrug.active_ind=1)
    ORDER BY dgo.br_drug_group_id, dga.antibiotic_cd
    HEAD REPORT
     dgcnt = 0
    HEAD dgo.br_drug_group_id
     dgcnt = (dgcnt+ 1), dcnt = 0, stat = alterlist(reply->drug_groups,dgcnt),
     reply->drug_groups[dgcnt].drg_grp_id = dgo.br_drug_group_id, reply->drug_groups[dgcnt].
     drug_resistant_nbr = dgo.drug_resistant_cnt, reply->drug_groups[dgcnt].name = dg.drug_group_name
    HEAD dga.antibiotic_cd
     dcnt = (dcnt+ 1), stat = alterlist(reply->drug_groups[dgcnt].drugs,dcnt), reply->drug_groups[
     dgcnt].drugs[dcnt].drug_code_value = dga.antibiotic_cd,
     reply->drug_groups[dgcnt].drugs[dcnt].display = cvdrug.display, reply->drug_groups[dgcnt].drugs[
     dcnt].description = cvdrug.description
    WITH nocounter
   ;end select
   SET dgcnt = size(reply->drug_groups,5)
   FOR (i = 1 TO dgcnt)
    SET dcnt = size(reply->drug_groups[i].drugs,5)
    IF (dcnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(dcnt)),
       br_drug_group_organism dgo,
       br_drug_group_antibiotic dga,
       br_organism_drug_result odr
      PLAN (d)
       JOIN (dgo
       WHERE dgo.br_mdro_cat_organism_id=cat_org_id)
       JOIN (dga
       WHERE dga.br_drug_group_id=dgo.br_drug_group_id
        AND (dga.antibiotic_cd=reply->drug_groups[i].drugs[d.seq].drug_code_value))
       JOIN (odr
       WHERE odr.br_drug_group_organism_id=dgo.br_drug_group_organism_id
        AND odr.br_drug_group_antibiotic_id=dga.br_drug_group_antibiotic_id)
      ORDER BY dga.antibiotic_cd
      HEAD dga.antibiotic_cd
       icnt = 0
      DETAIL
       icnt = (icnt+ 1), stat = alterlist(reply->drug_groups[i].drugs[d.seq].interp_results,icnt),
       reply->drug_groups[i].drugs[d.seq].interp_results[icnt].interp_code_value = odr.result_cd,
       reply->drug_groups[i].drugs[d.seq].interp_results[icnt].display = uar_get_code_display(odr
        .result_cd), reply->drug_groups[i].drugs[d.seq].interp_results[icnt].description =
       uar_get_code_description(odr.result_cd)
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (validate(bed_commit_ind,1))
  CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
  IF (error_flag="N")
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "F"
  ENDIF
  CALL echorecord(reply)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
