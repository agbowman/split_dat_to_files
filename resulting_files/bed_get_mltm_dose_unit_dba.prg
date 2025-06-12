CREATE PROGRAM bed_get_mltm_dose_unit:dba
 FREE SET reply
 RECORD reply(
   1 dose_units[*]
     2 display = vc
     2 cki = vc
     2 ignore_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SELECT DISTINCT INTO "nl:"
  m.dose_unit_cki
  FROM mltm_drc_premise m
  WHERE m.dose_range_type_id != 5
   AND m.dose_unit_cki > " "
  ORDER BY m.dose_unit_cki
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->dose_units,100)
  HEAD m.dose_unit_cki
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 100)
    stat = alterlist(reply->dose_units,(cnt+ 100)), list_count = 1
   ENDIF
   reply->dose_units[cnt].display = m.dose_unit_disp, reply->dose_units[cnt].cki = m.dose_unit_cki,
   reply->dose_units[cnt].ignore_ind = 0
  FOOT REPORT
   stat = alterlist(reply->dose_units,cnt)
  WITH nocounter
 ;end select
 SET cnt = size(reply->dose_units,5)
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    br_name_value b
   PLAN (d)
    JOIN (b
    WHERE (b.br_value=reply->dose_units[d.seq].cki)
     AND b.br_nv_key1="MLTM_IGN_UNITS"
     AND b.br_name="MLTM_DRC_PREMISE")
   DETAIL
    reply->dose_units[d.seq].ignore_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 EXECUTE mltm_upd_mltm_drc_premise  WITH replace("REPLY",reply_mltm)
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
