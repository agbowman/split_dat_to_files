CREATE PROGRAM cv_install_audit:dba
 RECORD internal_cv(
   1 case_cnt = i4
   1 sched_case_cnt = i4
   1 case_cart_cnt = i4
   1 pref_card_cnt = i4
   1 periop_doc_cnt = i4
   1 charged_case_cnt = i4
   1 max_room_cnt = i4
   1 max_doc_cnt = i4
   1 max_seg_cnt = i4
   1 max_stage_cnt = i4
   1 total_area_cnt = i4
   1 total_stage_cnt = i4
   1 total_room_cnt = i4
   1 total_doc_cnt = i4
   1 total_seg_cnt = i4
   1 areas[*]
     2 area_cd = f8
     2 area_disp = vc
     2 case_tracking_ind = i2
     2 stages[*]
       3 stage_cd = f8
       3 stage_disp = vc
       3 rooms[*]
         4 room_cd = f8
         4 room_disp = vc
       3 documents[*]
         4 doc_type_cd = f8
         4 doc_type_disp = vc
         4 doc_type_mean = c12
         4 segments[*]
           5 seg_cd = f8
           5 seg_disp = vc
 )
 EXECUTE cclseclogin
 SET mnemonic = fillstring(7," ")
 SET environment = fillstring(15," ")
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,2,8,70)
 CALL video(n)
 CALL text(2,15,"C V N E T   A U D I T   R E P O R T")
 CALL text(4,10,"Client mnemonic: ")
 CALL text(5,10,"Environment:     ")
 CALL accept(4,30,"C(7);CU"," ")
 SET mnemonic = curaccept
 IF (trim(mnemonic)="")
  GO TO exit_script
 ENDIF
 CALL accept(5,30,"C(15);CU"," ")
 SET environment = curaccept
 IF (trim(environment)="")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=221
   AND cv.cdf_meaning="SURGAREA"
   AND cv.active_ind=1
  ORDER BY cv.display
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal_cv->areas,cnt), internal_cv->areas[cnt].area_cd = cv
   .code_value,
   internal_cv->areas[cnt].area_disp = trim(cv.display)
  FOOT REPORT
   internal_cv->total_area_cnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM resource_group rg1,
   resource_group rg2,
   (dummyt d1  WITH seq = value(size(internal_cv->areas,5)))
  PLAN (d1)
   JOIN (rg1
   WHERE (rg1.parent_service_resource_cd=internal_cv->areas[d1.seq].area_cd)
    AND rg1.active_ind=1)
   JOIN (rg2
   WHERE rg2.parent_service_resource_cd=rg1.child_service_resource_cd
    AND rg2.active_ind=1)
  ORDER BY rg1.parent_service_resource_cd, rg1.child_service_resource_cd
  HEAD REPORT
   op_cnt = 0
  HEAD rg1.parent_service_resource_cd
   op_cnt = 0, stage_cnt = 0
  HEAD rg1.child_service_resource_cd
   stage_cnt = (stage_cnt+ 1), internal_cv->total_stage_cnt = (internal_cv->total_stage_cnt+ 1),
   op_cnt = 0,
   stat = alterlist(internal_cv->areas[d1.seq].stages,stage_cnt), internal_cv->areas[d1.seq].stages[
   stage_cnt].stage_cd = rg1.child_service_resource_cd, internal_cv->areas[d1.seq].stages[stage_cnt].
   stage_disp = trim(uar_get_code_display(rg1.child_service_resource_cd))
  DETAIL
   op_cnt = (op_cnt+ 1), internal_cv->total_room_cnt = (internal_cv->total_room_cnt+ 1), stat =
   alterlist(internal_cv->areas[d1.seq].stages[stage_cnt].rooms,op_cnt),
   internal_cv->areas[d1.seq].stages[stage_cnt].rooms[op_cnt].room_cd = rg2.child_service_resource_cd,
   internal_cv->areas[d1.seq].stages[stage_cnt].rooms[op_cnt].room_disp = trim(uar_get_code_display(
     rg2.child_service_resource_cd))
  FOOT  rg1.child_service_resource_cd
   IF ((op_cnt > internal_cv->max_room_cnt))
    internal_cv->max_room_cnt = op_cnt
   ENDIF
  FOOT  rg1.parent_service_resource_cd
   IF ((stage_cnt > internal_cv->max_stage_cnt))
    internal_cv->max_stage_cnt = stage_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM sn_doc_ref sdr,
   code_value cv,
   (dummyt d1  WITH seq = value(size(internal_cv->areas,5))),
   (dummyt d2  WITH seq = value(internal_cv->max_stage_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(internal_cv->areas[d1.seq].stages,5))
   JOIN (sdr
   WHERE (sdr.area_cd=internal_cv->areas[d1.seq].area_cd)
    AND (sdr.stage_cd=internal_cv->areas[d1.seq].stages[d2.seq].stage_cd))
   JOIN (cv
   WHERE cv.code_value=sdr.doc_type_cd)
  ORDER BY sdr.area_cd, sdr.stage_cd, cv.display
  HEAD REPORT
   doc_cnt = 0
  HEAD sdr.area_cd
   doc_cnt = 0
  HEAD sdr.stage_cd
   doc_cnt = 0
  DETAIL
   doc_cnt = (doc_cnt+ 1), internal_cv->total_doc_cnt = (internal_cv->total_doc_cnt+ 1), stat =
   alterlist(internal_cv->areas[d1.seq].stages[d2.seq].documents,doc_cnt),
   internal_cv->areas[d1.seq].stages[d2.seq].documents[doc_cnt].doc_type_cd = cv.code_value,
   internal_cv->areas[d1.seq].stages[d2.seq].documents[doc_cnt].doc_type_disp = trim(cv.display),
   internal_cv->areas[d1.seq].stages[d2.seq].documents[doc_cnt].doc_type_mean = cv.cdf_meaning
  FOOT  sdr.stage_cd
   IF ((doc_cnt > internal_cv->max_doc_cnt))
    internal_cv->max_doc_cnt = doc_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  area = d1.seq, stage = d2.seq, document = d3.seq
  FROM segment_reference sr,
   code_value cv,
   (dummyt d1  WITH seq = value(size(internal_cv->areas,5))),
   (dummyt d2  WITH seq = value(internal_cv->max_stage_cnt)),
   (dummyt d3  WITH seq = value(internal_cv->max_doc_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(internal_cv->areas[d1.seq].stages,5))
   JOIN (d3
   WHERE d3.seq <= size(internal_cv->areas[d1.seq].stages[d2.seq].documents,5))
   JOIN (sr
   WHERE (sr.doc_type_cd=internal_cv->areas[d1.seq].stages[d2.seq].documents[d3.seq].doc_type_cd)
    AND (sr.surg_area_cd=internal_cv->areas[d1.seq].area_cd)
    AND sr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=sr.seg_cd)
  ORDER BY area, stage, document,
   cv.display
  HEAD REPORT
   seg_cnt = 0
  HEAD area
   seg_cnt = 0
  HEAD stage
   seg_cnt = 0
  HEAD document
   seg_cnt = 0
  DETAIL
   seg_cnt = (seg_cnt+ 1), internal_cv->total_seg_cnt = (internal_cv->total_seg_cnt+ 1), stat =
   alterlist(internal_cv->areas[d1.seq].stages[d2.seq].documents[d3.seq].segments,seg_cnt),
   internal_cv->areas[d1.seq].stages[d2.seq].documents[d3.seq].segments[seg_cnt].seg_cd = cv
   .code_value, internal_cv->areas[d1.seq].stages[d2.seq].documents[d3.seq].segments[seg_cnt].
   seg_disp = trim(cv.display)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM sn_name_value_prefs snvp,
   (dummyt d1  WITH seq = value(size(internal_cv->areas,5)))
  PLAN (d1)
   JOIN (snvp
   WHERE (snvp.parent_entity_id=internal_cv->areas[d1.seq].area_cd)
    AND snvp.parent_entity_name="SERVICE_RESOURCE"
    AND snvp.pref_name="SNCASETRK")
  DETAIL
   IF (trim(snvp.pref_value)="1")
    internal_cv->areas[d1.seq].case_tracking_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc
  WHERE sc.surg_case_id > 0
  DETAIL
   internal_cv->case_cnt = (internal_cv->case_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc
  WHERE sc.sch_event_id > 0
  DETAIL
   internal_cv->sched_case_cnt = (internal_cv->sched_case_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM sn_charge_item sci
  WHERE sci.surg_case_id > 0
  ORDER BY sci.surg_case_id
  HEAD sci.surg_case_id
   internal_cv->charged_case_cnt = (internal_cv->charged_case_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM case_cart cc
  WHERE cc.case_cart_id > 0
  DETAIL
   internal_cv->case_cart_cnt = (internal_cv->case_cart_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM preference_card pc
  WHERE pc.pref_card_id > 0
  DETAIL
   internal_cv->pref_card_cnt = (internal_cv->pref_card_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM perioperative_document pd
  WHERE pd.periop_doc_id > 0
  DETAIL
   internal_cv->periop_doc_cnt = (internal_cv->periop_doc_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT
  FROM (dummyt d1  WITH seq = 1)
  HEAD REPORT
   line = fillstring(130,"-"), title = fillstring(130," "), first_page = "T",
   room_cnt = 0, doc_cnt = 0, title = concat(mnemonic,"(",environment,") - SURGINET AUDIT REPORT  ",
    format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY HH:MM;;D")),
   row 0,
   CALL center(trim(title),0,130), row + 1,
   line, row + 2,
   CALL center("ACTIVITY COUNTS",0,130),
   row + 1,
   CALL center("---------------",0,130), row + 1,
   col 10, "Surgery Case Count:", col 40,
   internal_cv->case_cnt, col 70, "Surgery Case Cart Count:",
   col 100, internal_cv->case_cart_cnt, row + 1,
   col 10, "Charged Surgery Case Count:", col 40,
   internal_cv->charged_case_cnt, col 70, "Scheduled Surgery Case Count:",
   col 100, internal_cv->sched_case_cnt, row + 1,
   col 10, "Preference Card Count:", col 40,
   internal_cv->pref_card_cnt, col 70, "Perioperative Document Count:",
   col 100, internal_cv->periop_doc_cnt, row + 1,
   line, row + 3,
   CALL center("REFERENCE COUNTS",0,130),
   row + 1,
   CALL center("----------------",0,130), row + 1,
   col 10, "Total Area Count:", col 40,
   internal_cv->total_area_cnt, col 70, "Total Stage Count:",
   col 100, internal_cv->total_stage_cnt, row + 1,
   col 10, "Total Room Count:", col 40,
   internal_cv->total_room_cnt, col 70, "Total Document Count:",
   col 100, internal_cv->total_doc_cnt, row + 1,
   col 10, "Total Segment Count:", col 40,
   internal_cv->total_seg_cnt, row + 1, line,
   row + 3,
   CALL center("DETAIL REFERENCE INFORMATION",0,130), row + 1,
   CALL center("----------------------------",0,130), row + 1
  HEAD PAGE
   IF (first_page="F")
    title = fillstring(130," "), title = concat(mnemonic,"(",environment,
     ") - SURGINET AUDIT REPORT  ",format(cnvtdatetime(curdate,curtime),"DD-MMM-YYYY HH:MM;;D"),
     "  cont."),
    CALL center(trim(title),0,130),
    row + 1, line, row + 2
   ELSE
    first_page = "F"
   ENDIF
  DETAIL
   FOR (x = 1 TO size(internal_cv->areas,5))
     row + 1, col 5, "AREA => ",
     internal_cv->areas[x].area_disp
     IF ((internal_cv->areas[x].case_tracking_ind=1))
      col + 2, "*** Case Tracking Installed ***"
     ENDIF
     stage_cnt = 0, room_cnt = 0, doc_cnt = 0,
     seg_cnt = 0, stage_cnt = size(internal_cv->areas[x].stages,5)
     FOR (y = 1 TO size(internal_cv->areas[x].stages,5))
       room_cnt = (room_cnt+ size(internal_cv->areas[x].stages[y].rooms,5)), doc_cnt = (doc_cnt+ size
       (internal_cv->areas[x].stages[y].documents,5))
       FOR (z = 1 TO size(internal_cv->areas[x].stages[y].documents,5))
         seg_cnt = (seg_cnt+ size(internal_cv->areas[x].stages[y].documents[z].segments,5))
       ENDFOR
     ENDFOR
     row + 1, col 10, "Total Stage Count:    ",
     stage_cnt"###", col 70, "Total Room Count:     ",
     room_cnt"###", row + 1, col 10,
     "Total Document Count: ", doc_cnt"###", col 70,
     "Total Segment Count:  ", seg_cnt"###"
     FOR (y = 1 TO size(internal_cv->areas[x].stages,5))
       row + 1, col 10, "STAGE => ",
       internal_cv->areas[x].stages[y].stage_disp
       FOR (z = 1 TO size(internal_cv->areas[x].stages[y].rooms,5))
         row + 1, col 15, "ROOM => ",
         internal_cv->areas[x].stages[y].rooms[z].room_disp
       ENDFOR
       FOR (z = 1 TO size(internal_cv->areas[x].stages[y].documents,5))
         row + 1, col 15, "DOCUMENT TYPE => ",
         internal_cv->areas[x].stages[y].documents[z].doc_type_disp, col + 2, "(",
         internal_cv->areas[x].stages[y].documents[z].doc_type_mean, ")"
         FOR (i = 1 TO size(internal_cv->areas[x].stages[y].documents[z].segments,5))
           row + 1, col 20, "SEGMENT => ",
           internal_cv->areas[x].stages[y].documents[z].segments[i].seg_disp
         ENDFOR
       ENDFOR
     ENDFOR
     row + 1
   ENDFOR
  FOOT REPORT
   row + 1, line, row + 1,
   CALL center("*** END OF AUDIT ***",0,130)
  WITH nocounter, maxcol = 135
 ;end select
#exit_script
END GO
