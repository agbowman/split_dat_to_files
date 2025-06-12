CREATE PROGRAM edw_appt_book_res_reltn:dba
 DECLARE getchildres(p_appt_book_id=f8,p_child_appt_book_id=f8,p_level=i4) = null WITH public
 DECLARE appt_book_child_cnt = i4 WITH noconstant(0)
 DECLARE appt_book_parent_cnt = i4 WITH noconstant(0)
 DECLARE record_cnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH noconstant(1)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 RECORD appt_book_child(
   1 qual[*]
     2 appt_book_id = f8
     2 resource_cd = f8
     2 hierarchy_level = i4
     2 src_active_ind = c1
 )
 RECORD appt_book_parent(
   1 qual[*]
     2 appt_book_id = f8
     2 group_id = f8
     2 level_cnt = i4
 )
 SELECT INTO "nl:"
  n_active_ind = nullind(sbl.active_ind)
  FROM sch_book_list sbl
  WHERE sbl.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   IF (sbl.resource_cd > 0)
    appt_book_child_cnt = (appt_book_child_cnt+ 1)
    IF (mod(appt_book_child_cnt,10)=1)
     stat = alterlist(appt_book_child->qual,(appt_book_child_cnt+ 9))
    ENDIF
    appt_book_child->qual[appt_book_child_cnt].appt_book_id = sbl.appt_book_id, appt_book_child->
    qual[appt_book_child_cnt].resource_cd = sbl.resource_cd, appt_book_child->qual[
    appt_book_child_cnt].hierarchy_level = 1,
    appt_book_child->qual[appt_book_child_cnt].src_active_ind = nullcheck(trim(cnvtstring(sbl
       .active_ind),3),blank_field,n_active_ind)
   ELSE
    appt_book_parent_cnt = (appt_book_parent_cnt+ 1)
    IF (mod(appt_book_parent_cnt,10)=1)
     stat = alterlist(appt_book_parent->qual,(appt_book_parent_cnt+ 9))
    ENDIF
    appt_book_parent->qual[appt_book_parent_cnt].appt_book_id = sbl.appt_book_id, appt_book_parent->
    qual[appt_book_parent_cnt].group_id = sbl.child_appt_book_id, appt_book_parent->qual[
    appt_book_parent_cnt].level_cnt = 1
   ENDIF
  WITH nocounter
 ;end select
 WHILE (i <= appt_book_parent_cnt)
  CALL getchildres(appt_book_parent->qual[i].appt_book_id,appt_book_parent->qual[i].group_id,
   appt_book_parent->qual[i].level_cnt)
  SET i = (i+ 1)
 ENDWHILE
 SELECT DISTINCT INTO value(aptb_rlt_extractfile)
  appt_book_id = appt_book_child->qual[d.seq].appt_book_id, resource_cd = appt_book_child->qual[d.seq
  ].resource_cd, hierarchy_level = appt_book_child->qual[d.seq].hierarchy_level
  FROM (dummyt d  WITH seq = value(appt_book_child_cnt))
  WHERE appt_book_child_cnt > 0
  ORDER BY appt_book_id, resource_cd, hierarchy_level DESC
  HEAD appt_book_id
   row + 0
  HEAD resource_cd
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_source_id)),
   v_bar,
   CALL print(build(cnvtstring(appt_book_id,16),"~",cnvtstring(resource_cd,16))), v_bar,
   CALL print(trim(cnvtstring(appt_book_id,16))), v_bar,
   CALL print(trim(cnvtstring(resource_cd,16))),
   v_bar,
   CALL print(trim(cnvtstring(hierarchy_level,16))), v_bar,
   "3", v_bar, extract_dt_tm_fmt,
   v_bar,
   CALL print(trim(appt_book_child->qual[d.seq].src_active_ind,3)), v_bar,
   row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 FREE RECORD appt_book_parent
 FREE RECORD appt_book_child
 CALL echo(build("APTB_RLT Count = ",record_cnt))
 CALL edwupdatescriptstatus("APTB_RLT",record_cnt,"3","3")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "003 06/01/07 YC3429"
 SUBROUTINE getchildres(p_appt_book_id,p_child_appt_book_id,p_level)
   IF (p_appt_book_id != p_child_appt_book_id)
    SELECT INTO "nl:"
     n_active_ind = nullind(sbl.active_ind)
     FROM sch_book_list sbl
     WHERE sbl.appt_book_id=p_child_appt_book_id
      AND p_level <= 25
     DETAIL
      IF (sbl.resource_cd > 0)
       appt_book_child_cnt = (appt_book_child_cnt+ 1)
       IF (mod(appt_book_child_cnt,10)=1)
        stat = alterlist(appt_book_child->qual,(appt_book_child_cnt+ 9))
       ENDIF
       appt_book_child->qual[appt_book_child_cnt].appt_book_id = p_appt_book_id, appt_book_child->
       qual[appt_book_child_cnt].resource_cd = sbl.resource_cd, appt_book_child->qual[
       appt_book_child_cnt].hierarchy_level = (p_level+ 1),
       appt_book_child->qual[appt_book_child_cnt].src_active_ind = nullcheck(trim(cnvtstring(sbl
          .active_ind),3),blank_field,n_active_ind)
      ELSE
       appt_book_parent_cnt = (appt_book_parent_cnt+ 1)
       IF (mod(appt_book_parent_cnt,10)=1)
        stat = alterlist(appt_book_parent->qual,(appt_book_parent_cnt+ 9))
       ENDIF
       appt_book_parent->qual[appt_book_parent_cnt].appt_book_id = p_appt_book_id, appt_book_parent->
       qual[appt_book_parent_cnt].group_id = sbl.child_appt_book_id, appt_book_parent->qual[
       appt_book_parent_cnt].level_cnt = (p_level+ 1)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
END GO
