CREATE PROGRAM bed_get_pharm_ord_evnt_cd_rels:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orders[*]
      2 catalog_code_value = f8
      2 description = vc
      2 primary_mnemonic = vc
      2 event_code_value = f8
      2 event_code_display = vc
      2 event_code_description = vc
      2 immunization_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE cat_parse_txt = vc
 SET pharmacy_ct_code_value = 0.0
 SET primary_code_value = 0.0
 SET pharmacy_ct_code_value = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET dil_exists = 0
 SET diluent_code_value = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name_key="DILUENTS"
   AND trim(cnvtupper(v.event_set_name))="DILUENTS"
  DETAIL
   diluent_code_value = v.event_set_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM v500_event_set_canon vec
  WHERE vec.event_set_cd=diluent_code_value
  DETAIL
   dil_exists = 1
  WITH nocounter
 ;end select
 SET med_code_value = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name_key="MEDICATIONS"
   AND trim(cnvtupper(v.event_set_name))="MEDICATIONS"
  DETAIL
   med_code_value = v.event_set_cd
  WITH nocounter
 ;end select
 SET med_exists = 0
 SELECT INTO "nl:"
  FROM v500_event_set_canon vec
  WHERE vec.event_set_cd=med_code_value
  DETAIL
   med_exists = 1
  WITH nocounter
 ;end select
 SET req_cnt = size(request->catalog_code_values,5)
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   order_catalog oc,
   code_value_event_r cr,
   v500_event_code vec,
   v500_event_set_explode vex,
   v500_event_set_code ves,
   code_value c,
   order_catalog_synonym ocs
  PLAN (d)
   JOIN (oc
   WHERE oc.catalog_type_cd=pharmacy_ct_code_value
    AND (oc.catalog_cd=request->catalog_code_values[d.seq].catalog_code_value)
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (cr
   WHERE cr.parent_cd=oc.catalog_cd)
   JOIN (vec
   WHERE vec.event_cd=cr.event_cd)
   JOIN (vex
   WHERE vex.event_cd=vec.event_cd
    AND vex.event_set_level=0)
   JOIN (ves
   WHERE ves.event_set_cd=vex.event_set_cd)
   JOIN (c
   WHERE c.code_value=oc.catalog_cd
    AND c.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=c.code_value
    AND ocs.mnemonic_type_cd=primary_code_value
    AND ocs.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   tcnt = 0
  DETAIL
   IF (((oc.cki="MUL.ORD!*"
    AND med_exists=1) OR (oc.cki="MUL.MMDC!*"
    AND dil_exists=1)) )
    tcnt = (tcnt+ 1), stat = alterlist(reply->orders,tcnt), reply->orders[tcnt].catalog_code_value =
    oc.catalog_cd,
    reply->orders[tcnt].description = oc.description, reply->orders[tcnt].primary_mnemonic = ocs
    .mnemonic, reply->orders[tcnt].event_code_value = vec.event_cd,
    reply->orders[tcnt].event_code_display = vec.event_cd_disp, reply->orders[tcnt].
    event_code_description = vec.event_cd_descr
   ENDIF
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   code_value_extension c
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=reply->orders[d.seq].catalog_code_value)
    AND c.code_set=200
    AND c.field_name="IMMUNIZATIONIND"
    AND c.field_type=1
    AND c.field_value="1")
  ORDER BY d.seq
  DETAIL
   reply->orders[d.seq].immunization_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
