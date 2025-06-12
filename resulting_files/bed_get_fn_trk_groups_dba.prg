CREATE PROGRAM bed_get_fn_trk_groups:dba
 FREE SET reply
 RECORD reply(
   1 tracking_groups[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 prefix = vc
     2 facility
       3 code_value = f8
       3 display = vc
       3 description = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 RECORD temp(
   1 tracking_groups[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 prefix = vc
     2 location_code_value = f8
     2 facility
       3 code_value = f8
       3 display = vc
       3 description = vc
 )
 SET facility_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_ind=1
  DETAIL
   facility_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE cvparse = vc
 SET cvparse = " cv.active_ind = 1"
 DECLARE search_string = vc
 IF (trim(request->search_txt) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = build2(trim(cnvtalphanum(cnvtupper(request->search_txt))),"*")
  ELSE
   SET search_string = build2("*",trim(cnvtalphanum(cnvtupper(request->search_txt))),"*")
  ENDIF
  SET cvparse = build2(cvparse," and cv.display_key = '",search_string,"'")
 ENDIF
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   br_name_value bnv,
   track_group tg
  PLAN (cv
   WHERE cv.code_set=16370
    AND parser(cvparse))
   JOIN (bnv
   WHERE bnv.br_nv_key1=outerjoin("FNTRKGRP_PREFIX")
    AND bnv.br_name=outerjoin(cnvtstring(cv.code_value)))
   JOIN (tg
   WHERE tg.tracking_group_cd=outerjoin(cv.code_value)
    AND tg.child_table=outerjoin("TRACK_ASSOC"))
  ORDER BY cv.display, cv.code_value
  HEAD cv.code_value
   tcnt = (tcnt+ 1), stat = alterlist(temp->tracking_groups,tcnt), temp->tracking_groups[tcnt].
   code_value = cv.code_value,
   temp->tracking_groups[tcnt].display = cv.display, temp->tracking_groups[tcnt].mean = cv
   .cdf_meaning, temp->tracking_groups[tcnt].prefix = bnv.br_value,
   temp->tracking_groups[tcnt].location_code_value = tg.parent_value, temp->tracking_groups[tcnt].
   facility.code_value = 0
  WITH nocounter
 ;end select
 IF (((tcnt=0) OR ((request->max_reply > 0)
  AND (tcnt > request->max_reply))) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   location_group lg1,
   location_group lg2,
   code_value cv
  PLAN (d
   WHERE (temp->tracking_groups[d.seq].location_code_value > 0))
   JOIN (lg1
   WHERE (lg1.child_loc_cd=temp->tracking_groups[d.seq].location_code_value)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.location_group_type_cd=facility_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg2.parent_loc_cd
    AND cv.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp->tracking_groups[d.seq].facility.code_value = lg2.parent_loc_cd, temp->tracking_groups[d.seq]
   .facility.display = cv.display, temp->tracking_groups[d.seq].facility.description = cv.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   location_group lg1,
   location_group lg2,
   location_group lg3,
   code_value cv
  PLAN (d
   WHERE (temp->tracking_groups[d.seq].location_code_value > 0)
    AND (temp->tracking_groups[d.seq].facility.code_value=0))
   JOIN (lg1
   WHERE (lg1.child_loc_cd=temp->tracking_groups[d.seq].location_code_value)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (lg3
   WHERE lg3.child_loc_cd=lg2.parent_loc_cd
    AND lg3.location_group_type_cd=facility_cd
    AND lg3.root_loc_cd=0
    AND lg3.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg3.parent_loc_cd
    AND cv.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp->tracking_groups[d.seq].facility.code_value = lg3.parent_loc_cd, temp->tracking_groups[d.seq]
   .facility.display = cv.display, temp->tracking_groups[d.seq].facility.description = cv.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tcnt),
   location_group lg1,
   location_group lg2,
   location_group lg3,
   location_group lg4,
   code_value cv
  PLAN (d
   WHERE (temp->tracking_groups[d.seq].location_code_value > 0)
    AND (temp->tracking_groups[d.seq].facility.code_value=0))
   JOIN (lg1
   WHERE (lg1.child_loc_cd=temp->tracking_groups[d.seq].location_code_value)
    AND lg1.root_loc_cd=0
    AND lg1.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg1.parent_loc_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (lg3
   WHERE lg3.child_loc_cd=lg2.parent_loc_cd
    AND lg3.root_loc_cd=0
    AND lg3.active_ind=1)
   JOIN (lg4
   WHERE lg4.child_loc_cd=lg3.parent_loc_cd
    AND lg4.location_group_type_cd=facility_cd
    AND lg4.root_loc_cd=0
    AND lg4.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=lg4.parent_loc_cd
    AND cv.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp->tracking_groups[d.seq].facility.code_value = lg4.parent_loc_cd, temp->tracking_groups[d.seq]
   .facility.display = cv.display, temp->tracking_groups[d.seq].facility.description = cv.description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->tracking_groups,tcnt)
 FOR (t = 1 TO tcnt)
   SET reply->tracking_groups[t].code_value = temp->tracking_groups[t].code_value
   SET reply->tracking_groups[t].display = temp->tracking_groups[t].display
   SET reply->tracking_groups[t].mean = temp->tracking_groups[t].mean
   SET reply->tracking_groups[t].prefix = temp->tracking_groups[t].prefix
   SET reply->tracking_groups[t].facility.code_value = temp->tracking_groups[t].facility.code_value
   SET reply->tracking_groups[t].facility.display = temp->tracking_groups[t].facility.display
   SET reply->tracking_groups[t].facility.description = temp->tracking_groups[t].facility.description
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 IF ((request->max_reply > 0)
  AND (tcnt > request->max_reply))
  SET stat = alterlist(reply->tracking_groups,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
