CREATE PROGRAM edw_details_ref:dba
 DECLARE det_ref_cnt = i4 WITH noconstant(0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 RECORD details_ref_keys(
   1 qual[*]
     2 oe_field_id = f8
 )
 SELECT INTO "nl:"
  FROM order_entry_fields oef
  WHERE oef.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   det_ref_cnt = (det_ref_cnt+ 1)
   IF (mod(det_ref_cnt,100)=1)
    stat = alterlist(details_ref_keys->qual,(det_ref_cnt+ 99))
   ENDIF
   details_ref_keys->qual[det_ref_cnt].oe_field_id = oef.oe_field_id
  WITH nocounter
 ;end select
 IF (sch_det_ref="Y")
  SELECT INTO "nl:"
   FROM oe_field_meaning oem,
    order_entry_fields oef
   PLAN (oem
    WHERE oem.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm))
    JOIN (oef
    WHERE oef.oe_field_meaning_id=oem.oe_field_meaning_id)
   DETAIL
    det_ref_cnt = (det_ref_cnt+ 1)
    IF (mod(det_ref_cnt,100)=1)
     stat = alterlist(details_ref_keys->qual,(det_ref_cnt+ 99))
    ENDIF
    details_ref_keys->qual[det_ref_cnt].oe_field_id = oef.oe_field_id
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO "NL:"
   oe_field_id = details_ref_keys->qual[d.seq].oe_field_id
   FROM (dummyt d  WITH seq = value(det_ref_cnt))
   PLAN (d
    WHERE det_ref_cnt > 0)
   ORDER BY oe_field_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), details_ref_keys->qual[cnt].oe_field_id = oe_field_id
   FOOT REPORT
    det_ref_cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO value(detail_r_extractfile)
  FROM (dummyt d  WITH seq = value(det_ref_cnt)),
   order_entry_fields oef,
   oe_field_meaning oem
  PLAN (d
   WHERE det_ref_cnt > 0)
   JOIN (oef
   WHERE (oef.oe_field_id=details_ref_keys->qual[d.seq].oe_field_id))
   JOIN (oem
   WHERE oem.oe_field_meaning_id=oef.oe_field_meaning_id)
  DETAIL
   col 0, health_system_source_id, v_bar,
   CALL print(trim(cnvtstring(oef.oe_field_id,16),3)), v_bar,
   CALL print(trim(cnvtstring(oef.catalog_type_cd,16),3)),
   v_bar,
   CALL print(trim(replace(oem.oe_field_meaning,str_find,str_replace,3),3)), v_bar,
   CALL print(trim(replace(oef.description,str_find,str_replace,3),3)), v_bar,
   CALL print(build(oef.field_type_flag)),
   v_bar,
   CALL print(build(oef.codeset)), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar, "1", v_bar,
   row + 1
  WITH check, noheading, nocounter,
   format = lfstream, maxcol = 1999, maxrow = 1,
   append
 ;end select
 FREE RECORD details_ref_keys
 CALL echo(build("DETAIL_R Count = ",curqual))
 CALL edwupdatescriptstatus("DETAIL_R",curqual,"3","3")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "003 05/30/07 JW014069"
END GO
