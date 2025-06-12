CREATE PROGRAM bed_get_sn_inventory:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 ilist[*]
       3 available_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD inv_locs(
   1 vlist[*]
     2 parent_loc_cd = f8
     2 child_loc_cd = f8
 )
 RECORD fill_locs(
   1 flist[*]
     2 location_cd = f8
 )
 SET reply->status_data.status = "F"
 SET fill_loc_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=202
   AND cv.cdf_meaning="SURGPICK"
   AND cv.active_ind=1
  DETAIL
   fill_loc_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SET surg_area_cnt = 0
 SET surg_area_cnt = size(request->sa_list,5)
 IF (surg_area_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->slist,surg_area_cnt)
 FOR (s = 1 TO surg_area_cnt)
   SET surg_area_loc_cd = 0.0
   SELECT INTO "NL"
    FROM service_resource sr
    WHERE (sr.service_resource_cd=request->sa_list[s].surg_area_code_value)
    DETAIL
     surg_area_loc_cd = sr.location_cd
    WITH nocounter
   ;end select
   SET fill_locs_loaded_ind = 0
   SET item_cnt = 0
   SET item_cnt = size(request->sa_list[s].i_list,5)
   SET stat = alterlist(reply->slist[s].ilist,item_cnt)
   FOR (i = 1 TO item_cnt)
     SET inv_loc_cnt = 0
     SET alterlist_inv_loc_cnt = 0
     SET stat = alterlist(inv_locs->vlist,10)
     SELECT INTO "NL:"
      FROM item_control_info ici,
       location_group lg,
       code_value cv
      PLAN (ici
       WHERE (ici.item_id=request->sa_list[s].i_list[i].item_id))
       JOIN (lg
       WHERE lg.child_loc_cd=ici.location_cd
        AND lg.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=lg.root_loc_cd
        AND cv.code_set=220
        AND cv.cdf_meaning="INVVIEW"
        AND cv.active_ind=1)
      DETAIL
       inv_loc_cnt = (inv_loc_cnt+ 1), alterlist_inv_loc_cnt = (alterlist_inv_loc_cnt+ 1)
       IF (alterlist_inv_loc_cnt > 10)
        stat = alterlist(inv_locs->vlist,(inv_loc_cnt+ 10)), alterlist_inv_loc_cnt = 1
       ENDIF
       inv_locs->vlist[inv_loc_cnt].parent_loc_cd = lg.parent_loc_cd, inv_locs->vlist[inv_loc_cnt].
       child_loc_cd = lg.child_loc_cd
      WITH nocounter
     ;end select
     SET stat = alterlist(inv_locs->vlist,inv_loc_cnt)
     SET found_ind = 0
     FOR (l = 1 TO inv_loc_cnt)
       IF ((inv_locs->vlist[l].parent_loc_cd=surg_area_loc_cd))
        SET found_ind = 1
        SET l = (inv_loc_cnt+ 1)
       ENDIF
     ENDFOR
     IF (found_ind=1)
      SET reply->slist[s].ilist[i].available_ind = 1
     ELSE
      IF (fill_locs_loaded_ind=0)
       SET fill_loc_cnt = 0
       SET alterlist_fill_loc_cnt = 0
       SET stat = alterlist(fill_locs->flist,10)
       SELECT INTO "NL:"
        FROM loc_resource_r lrr
        WHERE (lrr.service_resource_cd=request->sa_list[s].surg_area_code_value)
         AND lrr.loc_resource_type_cd=fill_loc_type_cd
        DETAIL
         fill_loc_cnt = (fill_loc_cnt+ 1), alterlist_fill_loc_cnt = (alterlist_fill_loc_cnt+ 1)
         IF (alterlist_fill_loc_cnt > 10)
          stat = alterlist(fill_locs->flist,(fill_loc_cnt+ 10)), alterlist_fill_loc_cnt = 1
         ENDIF
         fill_locs->flist[fill_loc_cnt].location_cd = lrr.location_cd
        WITH nocounter
       ;end select
       SET stat = alterlist(fill_locs->flist,fill_loc_cnt)
      ENDIF
      FOR (f = 1 TO fill_loc_cnt)
       FOR (v = 1 TO inv_loc_cnt)
         IF ((fill_locs->flist[f].location_cd=inv_locs->vlist[v].child_loc_cd))
          SET found_ind = 1
          SET v = (inv_loc_cnt+ 1)
         ENDIF
       ENDFOR
       IF (found_ind=1)
        SET f = (fill_loc_cnt+ 1)
       ENDIF
      ENDFOR
      IF (found_ind=1)
       SET reply->slist[s].ilist[i].available_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
