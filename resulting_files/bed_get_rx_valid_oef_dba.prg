CREATE PROGRAM bed_get_rx_valid_oef:dba
 FREE SET reply
 RECORD reply(
   1 formats[*]
     2 id = f8
     2 name = vc
     2 fields[*]
       3 id = f8
       3 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fmtcnt = 0
 SET fldcnt = 0
 DECLARE ord_cd = f8
 SET ord_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET vd_ind = 0
 SET vdu_ind = 0
 SET r_ind = 0
 SET rtu_ind = 0
 SET rt_ind = 0
 SET iou_ind = 0
 SET io_ind = 0
 SET vd_cnt = 0
 SET vdu_cnt = 0
 SET r_cnt = 0
 SET rtu_cnt = 0
 SET rt_cnt = 0
 SET iou_cnt = 0
 SET io_cnt = 0
 SELECT INTO "nl:"
  FROM order_entry_format oef,
   oe_format_fields off,
   order_entry_fields o,
   oe_field_meaning m
  PLAN (oef
   WHERE oef.oe_format_name="Pharmacy IV"
    AND oef.action_type_cd=ord_cd)
   JOIN (off
   WHERE off.oe_format_id=oef.oe_format_id
    AND off.action_type_cd=ord_cd)
   JOIN (o
   WHERE o.oe_field_id=off.oe_field_id)
   JOIN (m
   WHERE m.oe_field_meaning_id=o.oe_field_meaning_id
    AND m.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "RXROUTE", "RATEUNIT", "RATE",
   "INFUSEOVERUNIT", "INFUSEOVER"))
  DETAIL
   IF (m.oe_field_meaning="VOLUMEDOSE")
    vd_cnt = (vd_cnt+ 1), vd_ind = 1
   ENDIF
   IF (m.oe_field_meaning="VOLUMEDOSEUNIT")
    vdu_cnt = (vdu_cnt+ 1), vdu_ind = 1
   ENDIF
   IF (m.oe_field_meaning="RXROUTE")
    r_cnt = (r_cnt+ 1), r_ind = 1
   ENDIF
   IF (m.oe_field_meaning="RATEUNIT")
    rtu_cnt = (rtu_cnt+ 1), rtu_ind = 1
   ENDIF
   IF (m.oe_field_meaning="RATE")
    rt_cnt = (rt_cnt+ 1), rt_ind = 1
   ENDIF
   IF (m.oe_field_meaning="INFUSEOVERUNIT")
    iou_cnt = (iou_cnt+ 1), iou_ind = 1
   ENDIF
   IF (m.oe_field_meaning="INFUSEOVER")
    io_cnt = (io_cnt+ 1), io_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((vd_ind=0) OR (((vdu_ind=0) OR (((r_ind=0) OR (((rtu_ind=0) OR (((rt_ind=0) OR (((iou_ind=0)
  OR (((io_ind=0) OR (((vd_cnt > 1) OR (((vdu_cnt > 1) OR (((r_cnt > 1) OR (((rtu_cnt > 1) OR (((
 rt_cnt > 1) OR (((iou_cnt > 1) OR (io_cnt > 1)) )) )) )) )) )) )) )) )) )) )) )) )) )
  SET fldcnt = 0
  SET fmtcnt = (fmtcnt+ 1)
  SET stat = alterlist(reply->formats,fmtcnt)
  SET reply->formats[fmtcnt].name = "Pharmacy IV"
  IF (((vd_ind=0) OR (vd_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Volume Dose"
  ENDIF
  IF (((vdu_ind=0) OR (vdu_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Volume Dose Unit"
  ENDIF
  IF (((r_ind=0) OR (r_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Route Of Administration"
  ENDIF
  IF (((rtu_ind=0) OR (rtu_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Rate Unit"
  ENDIF
  IF (((rt_ind=0) OR (rt_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Rate"
  ENDIF
  IF (((iou_ind=0) OR (iou_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Infuse Over Unit"
  ENDIF
  IF (((io_ind=0) OR (io_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Infuse Over"
  ENDIF
 ENDIF
 SET sd_ind = 0
 SET sdu_ind = 0
 SET f_ind = 0
 SET r_ind = 0
 SET pr_ind = 0
 SET p_ind = 0
 SET sd_cnt = 0
 SET sdu_cnt = 0
 SET f_cnt = 0
 SET r_cnt = 0
 SET pr_cnt = 0
 SET p_cnt = 0
 SELECT INTO "nl:"
  FROM order_entry_format oef,
   oe_format_fields off,
   order_entry_fields o,
   oe_field_meaning m
  PLAN (oef
   WHERE oef.oe_format_name="Pharmacy Strength Med"
    AND oef.action_type_cd=ord_cd)
   JOIN (off
   WHERE off.oe_format_id=oef.oe_format_id
    AND off.action_type_cd=ord_cd)
   JOIN (o
   WHERE o.oe_field_id=off.oe_field_id)
   JOIN (m
   WHERE m.oe_field_meaning_id=o.oe_field_meaning_id
    AND m.oe_field_meaning IN ("STRENGTHDOSE", "STRENGTHDOSEUNIT", "FREQ", "RXROUTE", "PRNREASON",
   "SCH/PRN"))
  DETAIL
   IF (m.oe_field_meaning="STRENGTHDOSE")
    sd_cnt = (sd_cnt+ 1), sd_ind = 1
   ENDIF
   IF (m.oe_field_meaning="STRENGTHDOSEUNIT")
    sdu_cnt = (sdu_cnt+ 1), sdu_ind = 1
   ENDIF
   IF (m.oe_field_meaning="FREQ")
    f_cnt = (f_cnt+ 1), f_ind = 1
   ENDIF
   IF (m.oe_field_meaning="RXROUTE")
    r_cnt = (r_cnt+ 1), r_ind = 1
   ENDIF
   IF (m.oe_field_meaning="PRNREASON")
    pr_cnt = (pr_cnt+ 1), pr_ind = 1
   ENDIF
   IF (m.oe_field_meaning="SCH/PRN")
    p_cnt = (p_cnt+ 1), p_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((sd_ind=0) OR (((sdu_ind=0) OR (((f_ind=0) OR (((r_ind=0) OR (((pr_ind=0) OR (((p_ind=0) OR (((
 sd_cnt > 1) OR (((sdu_cnt > 1) OR (((f_cnt > 1) OR (((r_cnt > 1) OR (((pr_cnt > 1) OR (p_cnt > 1))
 )) )) )) )) )) )) )) )) )) )) )
  SET fldcnt = 0
  SET fmtcnt = (fmtcnt+ 1)
  SET stat = alterlist(reply->formats,fmtcnt)
  SET reply->formats[fmtcnt].name = "Pharmacy Strength Med"
  IF (((sd_ind=0) OR (sd_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Strength Dose"
  ENDIF
  IF (((sdu_ind=0) OR (sdu_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Strength Dose Unit"
  ENDIF
  IF (((f_ind=0) OR (f_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Frequency"
  ENDIF
  IF (((r_ind=0) OR (r_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Route Of Administration"
  ENDIF
  IF (((pr_ind=0) OR (pr_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "PRN Reason"
  ENDIF
  IF (((p_ind=0) OR (p_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Scheduled / PRN"
  ENDIF
 ENDIF
 SET vd_ind = 0
 SET vdu_ind = 0
 SET f_ind = 0
 SET r_ind = 0
 SET pr_ind = 0
 SET p_ind = 0
 SET vd_cnt = 0
 SET vdu_cnt = 0
 SET f_cnt = 0
 SET r_cnt = 0
 SET pr_cnt = 0
 SET p_cnt = 0
 SELECT INTO "nl:"
  FROM order_entry_format oef,
   oe_format_fields off,
   order_entry_fields o,
   oe_field_meaning m
  PLAN (oef
   WHERE oef.oe_format_name="Pharmacy Volume Med"
    AND oef.action_type_cd=ord_cd)
   JOIN (off
   WHERE off.oe_format_id=oef.oe_format_id
    AND off.action_type_cd=ord_cd)
   JOIN (o
   WHERE o.oe_field_id=off.oe_field_id)
   JOIN (m
   WHERE m.oe_field_meaning_id=o.oe_field_meaning_id
    AND m.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "FREQ", "RXROUTE", "PRNREASON",
   "SCH/PRN"))
  DETAIL
   IF (m.oe_field_meaning="VOLUMEDOSE")
    vd_cnt = (vd_cnt+ 1), vd_ind = 1
   ENDIF
   IF (m.oe_field_meaning="VOLUMEDOSEUNIT")
    vdu_cnt = (vdu_cnt+ 1), vdu_ind = 1
   ENDIF
   IF (m.oe_field_meaning="FREQ")
    f_cnt = (f_cnt+ 1), f_ind = 1
   ENDIF
   IF (m.oe_field_meaning="RXROUTE")
    r_cnt = (r_cnt+ 1), r_ind = 1
   ENDIF
   IF (m.oe_field_meaning="PRNREASON")
    pr_cnt = (pr_cnt+ 1), pr_ind = 1
   ENDIF
   IF (m.oe_field_meaning="SCH/PRN")
    p_cnt = (p_cnt+ 1), p_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((vd_ind=0) OR (((vdu_ind=0) OR (((f_ind=0) OR (((r_ind=0) OR (((pr_ind=0) OR (((p_ind=0) OR (((
 vd_cnt > 1) OR (((vdu_cnt > 1) OR (((f_cnt > 1) OR (((r_cnt > 1) OR (((pr_cnt > 1) OR (p_cnt > 1))
 )) )) )) )) )) )) )) )) )) )) )
  SET fldcnt = 0
  SET fmtcnt = (fmtcnt+ 1)
  SET stat = alterlist(reply->formats,fmtcnt)
  SET reply->formats[fmtcnt].name = "Pharmacy Volume Med"
  IF (((vd_ind=0) OR (vd_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Volume Dose"
  ENDIF
  IF (((vdu_ind=0) OR (vdu_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Volume Dose Unit"
  ENDIF
  IF (((f_ind=0) OR (f_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Frequency"
  ENDIF
  IF (((r_ind=0) OR (r_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Route Of Administration"
  ENDIF
  IF (((pr_ind=0) OR (pr_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "PRN Reason"
  ENDIF
  IF (((p_ind=0) OR (p_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Scheduled / PRN"
  ENDIF
 ENDIF
 SET vd_ind = 0
 SET vdu_ind = 0
 SET sd_ind = 0
 SET sdu_ind = 0
 SET nr_ind = 0
 SET nru_ind = 0
 SET vd_cnt = 0
 SET vdu_cnt = 0
 SET sd_cnt = 0
 SET sdu_cnt = 0
 SET nr_cnt = 0
 SET nru_cnt = 0
 SELECT INTO "nl:"
  FROM order_entry_format oef,
   oe_format_fields off,
   order_entry_fields o,
   oe_field_meaning m
  PLAN (oef
   WHERE oef.oe_format_name="IV Ingredient"
    AND oef.action_type_cd=ord_cd)
   JOIN (off
   WHERE off.oe_format_id=oef.oe_format_id
    AND off.action_type_cd=ord_cd)
   JOIN (o
   WHERE o.oe_field_id=off.oe_field_id)
   JOIN (m
   WHERE m.oe_field_meaning_id=o.oe_field_meaning_id
    AND m.oe_field_meaning IN ("VOLUMEDOSE", "VOLUMEDOSEUNIT", "STRENGTHDOSE", "STRENGTHDOSEUNIT",
   "NORMALIZEDRATE",
   "NORMALIZEDRATEUNIT"))
  DETAIL
   IF (m.oe_field_meaning="VOLUMEDOSE")
    vd_cnt = (vd_cnt+ 1), vd_ind = 1
   ENDIF
   IF (m.oe_field_meaning="VOLUMEDOSEUNIT")
    vdu_cnt = (vdu_cnt+ 1), vdu_ind = 1
   ENDIF
   IF (m.oe_field_meaning="STRENGTHDOSE")
    sd_cnt = (sd_cnt+ 1), sd_ind = 1
   ENDIF
   IF (m.oe_field_meaning="STRENGTHDOSEUNIT")
    sdu_cnt = (sdu_cnt+ 1), sdu_ind = 1
   ENDIF
   IF (m.oe_field_meaning="NORMALIZEDRATE")
    nr_cnt = (nr_cnt+ 1), nr_ind = 1
   ENDIF
   IF (m.oe_field_meaning="NORMALIZEDRATEUNIT")
    nru_cnt = (nru_cnt+ 1), nru_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((vd_ind=0) OR (((vdu_ind=0) OR (((sd_ind=0) OR (((sdu_ind=0) OR (((nr_ind=0) OR (((nru_ind=0)
  OR (((vd_cnt > 1) OR (((vdu_cnt > 1) OR (((sd_cnt > 1) OR (((sdu_cnt > 1) OR (((nr_cnt > 1) OR (
 nru_cnt > 1)) )) )) )) )) )) )) )) )) )) )) )
  SET fldcnt = 0
  SET fmtcnt = (fmtcnt+ 1)
  SET stat = alterlist(reply->formats,fmtcnt)
  SET reply->formats[fmtcnt].name = "IV Ingredient"
  IF (((vd_ind=0) OR (vd_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Volume Dose"
  ENDIF
  IF (((vdu_ind=0) OR (vdu_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Volume Dose Unit"
  ENDIF
  IF (((sd_ind=0) OR (sd_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Strength Dose"
  ENDIF
  IF (((sdu_ind=0) OR (sdu_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Strength Dose Unit"
  ENDIF
  IF (((nr_ind=0) OR (nr_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Normalized Rate"
  ENDIF
  IF (((nru_ind=0) OR (nru_cnt > 1)) )
   SET fldcnt = (fldcnt+ 1)
   SET stat = alterlist(reply->formats[fmtcnt].fields,fldcnt)
   SET reply->formats[fmtcnt].fields[fldcnt].name = "Normalized Rate Unit"
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
