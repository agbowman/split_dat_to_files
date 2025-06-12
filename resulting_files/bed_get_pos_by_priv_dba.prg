CREATE PROGRAM bed_get_pos_by_priv:dba
 FREE SET reply
 RECORD reply(
   1 plist[*]
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 privilege_code_value = f8
     2 privilege_display = vc
     2 privilege_mean = vc
     2 priv_value_code_value = f8
     2 priv_value_display = vc
     2 priv_value_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET tot_count = 0
 SET count = 0
 SET stat = alterlist(reply->plist,50)
 SET pcount = size(request->plist,5)
 SET yes_code_value = 0.0
 SET yes_display = fillstring(40," ")
 SET yes_cdf_meaning = fillstring(12," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=6017
   AND cv.cdf_meaning="YES"
  DETAIL
   yes_code_value = cv.code_value, yes_display = cv.display, yes_cdf_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 FOR (x = 1 TO pcount)
  SELECT INTO "NL:"
   FROM priv_loc_reltn plr,
    privilege priv,
    code_value cv6016,
    code_value cv6017,
    code_value cv88
   PLAN (priv
    WHERE priv.active_ind=1
     AND (priv.privilege_cd=request->plist[x].privilege_code_value)
     AND (priv.priv_value_cd=request->plist[x].priv_value_code_value))
    JOIN (plr
    WHERE plr.active_ind=1
     AND priv.priv_loc_reltn_id=plr.priv_loc_reltn_id
     AND (plr.position_cd != request->position_code_value))
    JOIN (cv88
    WHERE cv88.code_set=88
     AND cv88.active_ind=1
     AND cv88.code_value=plr.position_cd)
    JOIN (cv6016
    WHERE cv6016.code_set=outerjoin(6016)
     AND cv6016.active_ind=outerjoin(1)
     AND cv6016.code_value=outerjoin(priv.privilege_cd))
    JOIN (cv6017
    WHERE cv6017.code_set=outerjoin(6017)
     AND cv6017.active_ind=outerjoin(1)
     AND cv6017.code_value=outerjoin(priv.priv_value_cd))
   DETAIL
    tot_count = (tot_count+ 1), count = (count+ 1)
    IF (count > 50)
     stat = alterlist(reply->plist,(tot_count+ 50)), count = 0
    ENDIF
    reply->plist[tot_count].position_code_value = plr.position_cd, reply->plist[tot_count].
    position_display = cv88.display, reply->plist[tot_count].position_mean = cv88.cdf_meaning,
    reply->plist[tot_count].privilege_code_value = priv.privilege_cd, reply->plist[tot_count].
    privilege_display = cv6016.display, reply->plist[tot_count].privilege_mean = cv6016.cdf_meaning,
    reply->plist[tot_count].priv_value_code_value = priv.priv_value_cd, reply->plist[tot_count].
    priv_value_display = cv6017.display, reply->plist[tot_count].priv_value_mean = cv6017.cdf_meaning
   WITH nocounter
  ;end select
  IF ((yes_code_value=request->plist[x].priv_value_code_value))
   SELECT INTO "NL:"
    FROM br_position_category bpc,
     br_position_cat_comp bpcc,
     code_value cv88,
     code_value cv6016,
     priv_loc_reltn plr,
     privilege priv
    PLAN (bpc
     WHERE bpc.active_ind=1
      AND bpc.step_cat_mean="PCO")
     JOIN (bpcc
     WHERE bpcc.category_id=bpc.category_id
      AND (bpcc.position_cd != request->position_code_value))
     JOIN (cv88
     WHERE cv88.code_set=88
      AND cv88.active_ind=1
      AND cv88.code_value=bpcc.position_cd)
     JOIN (cv6016
     WHERE cv6016.code_set=6016
      AND cv6016.active_ind=1
      AND (cv6016.code_value=request->plist[x].privilege_code_value))
     JOIN (plr
     WHERE plr.active_ind=outerjoin(1)
      AND plr.position_cd=outerjoin(bpcc.position_cd))
     JOIN (priv
     WHERE priv.active_ind=outerjoin(1)
      AND priv.priv_loc_reltn_id=outerjoin(plr.priv_loc_reltn_id)
      AND priv.privilege_cd=outerjoin(request->plist[x].privilege_code_value))
    DETAIL
     IF (priv.privilege_cd=0)
      tot_count = (tot_count+ 1), count = (count+ 1)
      IF (count > 50)
       stat = alterlist(reply->plist,(tot_count+ 50)), count = 0
      ENDIF
      reply->plist[tot_count].position_code_value = bpcc.position_cd, reply->plist[tot_count].
      position_display = cv88.display, reply->plist[tot_count].position_mean = cv88.cdf_meaning,
      reply->plist[tot_count].privilege_code_value = request->plist[x].privilege_code_value, reply->
      plist[tot_count].privilege_display = cv6016.display, reply->plist[tot_count].privilege_mean =
      cv6016.cdf_meaning,
      reply->plist[tot_count].priv_value_code_value = yes_code_value, reply->plist[tot_count].
      priv_value_display = yes_display, reply->plist[tot_count].priv_value_mean = yes_cdf_meaning
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SET stat = alterlist(reply->plist,tot_count)
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
