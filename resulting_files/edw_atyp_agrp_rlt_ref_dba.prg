CREATE PROGRAM edw_atyp_agrp_rlt_ref:dba
 DECLARE getchildres(p_parent_id=f8,p_child_id=f8,p_level=i4,p_association_id=f8) = null WITH public
 DECLARE app_group_child_cnt = i4 WITH noconstant(0)
 DECLARE app_group_parent_cnt = i4 WITH noconstant(0)
 DECLARE record_cnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH noconstant(1)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 RECORD appgrp_child(
   1 qual[*]
     2 parent_id = f8
     2 display_id = f8
     2 hierarchy_level = i4
     2 association_id = f8
     2 child_id = f8
     2 src_active_ind = c1
 )
 RECORD appgrp_parent(
   1 qual[*]
     2 parent_id = f8
     2 child_id = f8
     2 level_cnt = i4
     2 association_id = f8
 )
 SELECT INTO "nl:"
  n_active_ind = nullind(sa.active_ind)
  FROM sch_assoc sa
  WHERE sa.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   IF (sa.data_source_meaning="APPTTYPE")
    app_group_child_cnt = (app_group_child_cnt+ 1)
    IF (mod(app_group_child_cnt,10)=1)
     stat = alterlist(appgrp_child->qual,(app_group_child_cnt+ 9))
    ENDIF
    appgrp_child->qual[app_group_child_cnt].parent_id = sa.parent_id, appgrp_child->qual[
    app_group_child_cnt].display_id = sa.display_id, appgrp_child->qual[app_group_child_cnt].
    hierarchy_level = 1,
    appgrp_child->qual[app_group_child_cnt].association_id = sa.association_id, appgrp_child->qual[
    app_group_child_cnt].child_id = sa.child_id, appgrp_child->qual[app_group_child_cnt].
    src_active_ind = nullcheck(trim(cnvtstring(sa.active_ind),3),blank_field,n_active_ind)
   ELSEIF (sa.data_source_meaning="ATGROUP")
    app_group_parent_cnt = (app_group_parent_cnt+ 1)
    IF (mod(app_group_parent_cnt,10)=1)
     stat = alterlist(appgrp_parent->qual,(app_group_parent_cnt+ 9))
    ENDIF
    appgrp_parent->qual[app_group_parent_cnt].parent_id = sa.parent_id, appgrp_parent->qual[
    app_group_parent_cnt].child_id = sa.child_id, appgrp_parent->qual[app_group_parent_cnt].level_cnt
     = 1,
    appgrp_parent->qual[app_group_parent_cnt].association_id = sa.association_id
   ENDIF
  WITH nocounter
 ;end select
 WHILE (i <= app_group_parent_cnt)
  CALL getchildres(appgrp_parent->qual[i].parent_id,appgrp_parent->qual[i].child_id,appgrp_parent->
   qual[i].level_cnt,appgrp_parent->qual[i].association_id)
  SET i = (i+ 1)
 ENDWHILE
 SELECT DISTINCT INTO value(agrp_rlt_extractfile)
  association_id = appgrp_child->qual[d.seq].association_id, child_id = appgrp_child->qual[d.seq].
  child_id, parent_id = appgrp_child->qual[d.seq].parent_id,
  display_id = appgrp_child->qual[d.seq].display_id, hierarchy_level = appgrp_child->qual[d.seq].
  hierarchy_level
  FROM (dummyt d  WITH seq = value(app_group_child_cnt))
  WHERE app_group_child_cnt > 0
  ORDER BY parent_id, display_id, hierarchy_level DESC
  HEAD parent_id
   row + 0
  HEAD display_id
   record_cnt = (record_cnt+ 1), col 0,
   CALL print(trim(health_system_source_id)),
   v_bar,
   CALL print(build(cnvtstring(association_id,16),"~",cnvtstring(display_id,16))), v_bar,
   CALL print(trim(cnvtstring(parent_id,16))), v_bar,
   CALL print(trim(cnvtstring(child_id,16))),
   v_bar,
   CALL print(trim(cnvtstring(display_id,16))), v_bar,
   CALL print(trim(cnvtstring(hierarchy_level,16))), v_bar, "3",
   v_bar, extract_dt_tm_fmt, v_bar,
   CALL print(trim(appgrp_child->qual[d.seq].src_active_ind,3)), v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 FREE RECORD appgrp_parent
 FREE RECORD appgrp_child
 CALL echo(build("AGRP_RLT Count = ",record_cnt))
 CALL edwupdatescriptstatus("AGRP_RLT",record_cnt,"3","3")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "003 06/01/07 YC3429"
 SUBROUTINE getchildres(p_parent_id,p_child_id,p_level,p_association_id)
   IF (p_parent_id != p_child_id)
    SELECT INTO "nl:"
     n_active_ind = nullind(sa.active_ind)
     FROM sch_assoc sa
     WHERE sa.parent_id=p_child_id
      AND p_level <= 25
     DETAIL
      IF (sa.data_source_meaning="APPTTYPE")
       app_group_child_cnt = (app_group_child_cnt+ 1)
       IF (mod(app_group_child_cnt,10)=1)
        stat = alterlist(appgrp_child->qual,(app_group_child_cnt+ 9))
       ENDIF
       appgrp_child->qual[app_group_child_cnt].parent_id = p_parent_id, appgrp_child->qual[
       app_group_child_cnt].display_id = sa.display_id, appgrp_child->qual[app_group_child_cnt].
       hierarchy_level = (p_level+ 1),
       appgrp_child->qual[app_group_child_cnt].association_id = p_association_id, appgrp_child->qual[
       app_group_child_cnt].child_id = sa.child_id, appgrp_child->qual[app_group_child_cnt].
       src_active_ind = nullcheck(trim(cnvtstring(sa.active_ind),3),blank_field,n_active_ind)
      ELSEIF (sa.data_source_meaning="ATGROUP")
       app_group_parent_cnt = (app_group_parent_cnt+ 1)
       IF (mod(app_group_parent_cnt,10)=1)
        stat = alterlist(appgrp_parent->qual,(app_group_parent_cnt+ 9))
       ENDIF
       appgrp_parent->qual[app_group_parent_cnt].parent_id = p_parent_id, appgrp_parent->qual[
       app_group_parent_cnt].child_id = sa.child_id, appgrp_parent->qual[app_group_parent_cnt].
       level_cnt = (p_level+ 1),
       appgrp_parent->qual[app_group_parent_cnt].association_id = p_association_id
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
END GO
