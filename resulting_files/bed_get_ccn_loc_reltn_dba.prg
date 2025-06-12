CREATE PROGRAM bed_get_ccn_loc_reltn:dba
 FREE SET reply
 RECORD reply(
   1 ccn[*]
     2 id = f8
     2 locations[*]
       3 reltn_id = f8
       3 code_value = f8
       3 display = vc
       3 mean = vc
       3 point_of_service[*]
         4 reltn_id = f8
         4 point_of_service_code = i4
         4 encounter_type_code_value = f8
         4 encounter_type_display = vc
         4 encounter_type_mean = vc
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = size(request->ccn,5)
 SET stat = alterlist(reply->ccn,ccnt)
 FOR (x = 1 TO ccnt)
   SET reply->ccn[x].id = request->ccn[x].id
 ENDFOR
 IF (ccnt > 0)
  SET load_inactive_locs_ind = 0
  IF (validate(request->load_inactive_locs_ind))
   SET load_inactive_locs_ind = request->load_inactive_locs_ind
  ENDIF
  DECLARE cv1_parse = vc
  SET cv1_parse = " cv1.code_value = b1.location_cd"
  IF (load_inactive_locs_ind=0)
   SET cv1_parse = build(cv1_parse," and cv1.active_ind = 1")
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ccnt)),
    br_ccn_loc_reltn b1,
    br_ccn_loc_ptsvc_reltn b2,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (b1
    WHERE (b1.br_ccn_id=request->ccn[d.seq].id)
     AND b1.active_ind=1
     AND b1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cv1
    WHERE parser(cv1_parse))
    JOIN (b2
    WHERE b2.br_ccn_loc_reltn_id=outerjoin(b1.br_ccn_loc_reltn_id)
     AND b2.active_ind=outerjoin(1)
     AND b2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(b2.encntr_type_cd)
     AND cv2.active_ind=outerjoin(1))
   ORDER BY d.seq, b1.br_ccn_loc_reltn_id, b2.br_ccn_loc_ptsvc_reltn_id
   HEAD d.seq
    lcnt = 0
   HEAD b1.br_ccn_loc_reltn_id
    lcnt = (lcnt+ 1), stat = alterlist(reply->ccn[d.seq].locations,lcnt), reply->ccn[d.seq].
    locations[lcnt].reltn_id = b1.br_ccn_loc_reltn_id,
    reply->ccn[d.seq].locations[lcnt].code_value = b1.location_cd, reply->ccn[d.seq].locations[lcnt].
    display = cv1.display, reply->ccn[d.seq].locations[lcnt].mean = cv1.cdf_meaning,
    reply->ccn[d.seq].locations[lcnt].active_ind = cv1.active_ind, pcnt = 0
   DETAIL
    IF (b2.br_ccn_loc_ptsvc_reltn_id > 0)
     pcnt = (pcnt+ 1), stat = alterlist(reply->ccn[d.seq].locations[lcnt].point_of_service,pcnt),
     reply->ccn[d.seq].locations[lcnt].point_of_service[pcnt].reltn_id = b2.br_ccn_loc_ptsvc_reltn_id,
     reply->ccn[d.seq].locations[lcnt].point_of_service[pcnt].point_of_service_code = b2
     .ptsvc_code_nbr, reply->ccn[d.seq].locations[lcnt].point_of_service[pcnt].
     encounter_type_code_value = b2.encntr_type_cd, reply->ccn[d.seq].locations[lcnt].
     point_of_service[pcnt].encounter_type_display = cv2.display,
     reply->ccn[d.seq].locations[lcnt].point_of_service[pcnt].encounter_type_mean = cv2.cdf_meaning
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
