CREATE PROGRAM bhs_hie_excl_doc:dba
 FREE RECORD bhed_notes
 RECORD bhed_notes(
   1 ml_cnt = i4
   1 list[*]
     2 mf_event_cd = f8
     2 ms_name = vc
 ) WITH protect
 DECLARE ml_bhed_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_bhed_loop = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM v500_event_set_explode vese,
   code_value cv
  PLAN (vese
   WHERE vese.event_set_cd IN (
   (SELECT
    d.event_cd
    FROM bhs_event_cd_list d
    WHERE d.listkey="HIEED"
     AND d.grouper="FOLDER"
     AND d.active_ind=1)))
   JOIN (cv
   WHERE cv.code_value=vese.event_cd
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
  HEAD REPORT
   bhed_notes->ml_cnt = 0
  DETAIL
   bhed_notes->ml_cnt = (bhed_notes->ml_cnt+ 1), stat = alterlist(bhed_notes->list,bhed_notes->ml_cnt
    ), bhed_notes->list[bhed_notes->ml_cnt].mf_event_cd = vese.event_cd,
   bhed_notes->list[bhed_notes->ml_cnt].ms_name = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_value IN (
  (SELECT
   d.event_cd
   FROM bhs_event_cd_list d
   WHERE d.listkey="HIEED"
    AND d.grouper="NOTE"
    AND d.active_ind=1))
  HEAD REPORT
   ml_bhed_pos = 0
  DETAIL
   ml_bhed_pos = locateval(ml_bhed_loop,1,bhed_notes->ml_cnt,cv.code_value,bhed_notes->list[
    ml_bhed_loop].mf_event_cd)
   IF (ml_bhed_pos=0)
    bhed_notes->ml_cnt = (bhed_notes->ml_cnt+ 1), stat = alterlist(bhed_notes->list,bhed_notes->
     ml_cnt), bhed_notes->list[bhed_notes->ml_cnt].mf_event_cd = cv.code_value,
    bhed_notes->list[bhed_notes->ml_cnt].ms_name = cv.display
   ENDIF
  WITH nocounter
 ;end select
 SET ml_bhed_pos = 0
 SET ml_bhed_loop = 0
 SET ml_bhed_pos = locateval(ml_bhed_loop,1,bhed_notes->ml_cnt,trim(oen_reply->res_oru_group[1].
   obx_group[1].obx.observation_id.text,3),trim(bhed_notes->list[ml_bhed_loop].ms_name,3))
 IF (ml_bhed_pos != 0)
  SET oenstatus->ignore = 1
 ENDIF
#exit_script
END GO
