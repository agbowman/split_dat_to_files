CREATE PROGRAM bed_get_hco_loc_reltn:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 hco[*]
      2 id = f8
      2 locations[*]
        3 reltn_id = f8
        3 code_value = f8
        3 display = vc
        3 mean = vc
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
 SET hcnt = size(request->hco,5)
 SET stat = alterlist(reply->hco,hcnt)
 FOR (x = 1 TO hcnt)
   SET reply->hco[x].id = request->hco[x].id
 ENDFOR
 IF (hcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(hcnt)),
    br_hco_loc_reltn b1,
    code_value cv1
   PLAN (d)
    JOIN (b1
    WHERE (b1.br_hco_id=request->hco[d.seq].id))
    JOIN (cv1
    WHERE cv1.code_value=b1.location_cd)
   ORDER BY d.seq, b1.br_hco_loc_reltn_id
   HEAD d.seq
    lcnt = 0
   HEAD b1.br_hco_loc_reltn_id
    lcnt = (lcnt+ 1), stat = alterlist(reply->hco[d.seq].locations,lcnt), reply->hco[d.seq].
    locations[lcnt].reltn_id = b1.br_hco_loc_reltn_id,
    reply->hco[d.seq].locations[lcnt].code_value = b1.location_cd, reply->hco[d.seq].locations[lcnt].
    display = cv1.display, reply->hco[d.seq].locations[lcnt].mean = cv1.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
