CREATE PROGRAM bhs_mp_explr_menu_structr:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person Id" = ""
  WITH outdev, s_person_id
 FREE RECORD m_parents_temp_rec
 RECORD m_parents_temp_rec(
   1 parent[*]
     2 s_descr = vc
     2 f_id = f8
     2 s_name = vc
     2 s_type = vc
     2 l_view_ind = i4
 ) WITH protect
 FREE RECORD m_parents_final_rec
 RECORD m_parents_final_rec(
   1 parent[*]
     2 s_descr = vc
     2 f_id = f8
     2 s_name = vc
     2 s_type = vc
     2 l_view_ind = i4
 ) WITH protect
 FREE RECORD m_app_groups_rec
 RECORD m_app_groups_rec(
   1 l_cntr = i4
   1 app_group[*]
     2 f_app_grp_cd = f8
     2 s_app_group_descr = vc
 )
 FREE RECORD m_security_rec
 RECORD m_security_rec(
   1 l_cntr = i4
   1 menus[*]
     2 f_menu_id = f8
     2 l_view_ind = i4
 )
 FREE RECORD m_security_rec_sorted
 RECORD m_security_rec_sorted(
   1 l_cntr = i4
   1 menus[*]
     2 f_menu_id = f8
     2 l_view_ind = i4
 )
 DECLARE ms_menu = vc WITH protect, noconstant(" ")
 DECLARE ml_fstpass = i4 WITH protect, noconstant(0)
 DECLARE ml_whl_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_fld_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_place = i4 WITH protect, noconstant(0)
 DECLARE ml_item_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_jsonrec = vc WITH protect, noconstant(" ")
 DECLARE ms_jsonrecfinal = vc WITH protect, noconstant(" ")
 DECLARE ms_jsontemp = vc WITH protect, noconstant(" ")
 DECLARE mf_person_id = f8 WITH protect, noconstant(0)
 DECLARE mf_position_cd = f8 WITH protect, noconstant(0)
 DECLARE mf_app_group_cd = f8 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_parentpos = i4 WITH protect, noconstant(0)
 DECLARE ml_view_ind = i4 WITH protect, noconstant(0)
 SET mf_person_id =  $S_PERSON_ID
 SELECT INTO "nl:"
  FROM prsnl p,
   application_group ap
  PLAN (p
   WHERE p.person_id=mf_person_id
    AND p.active_ind=1)
   JOIN (ap
   WHERE p.position_cd=ap.position_cd)
  HEAD ap.position_cd
   m_app_groups_rec->l_cntr = 0,
   CALL echo(uar_get_code_display(ap.position_cd))
  DETAIL
   m_app_groups_rec->l_cntr = (m_app_groups_rec->l_cntr+ 1), stat = alterlist(m_app_groups_rec->
    app_group,m_app_groups_rec->l_cntr), m_app_groups_rec->app_group[m_app_groups_rec->l_cntr].
   f_app_grp_cd = ap.app_group_cd,
   m_app_groups_rec->app_group[m_app_groups_rec->l_cntr].s_app_group_descr = trim(
    uar_get_code_display(ap.app_group_cd),3)
  WITH nocounter
 ;end select
 CALL echorecord(m_app_groups_rec)
 SELECT INTO "nl:"
  FROM explorer_menu_security ems
  ORDER BY ems.menu_id
  HEAD REPORT
   m_security_rec->l_cntr = 0
  DETAIL
   m_security_rec->l_cntr = (m_security_rec->l_cntr+ 1), stat = alterlist(m_security_rec->menus,
    m_security_rec->l_cntr), m_security_rec->menus[m_security_rec->l_cntr].f_menu_id = ems.menu_id,
   ml_pos = locateval(ml_num,0,size(m_app_groups_rec->app_group,5),ems.app_group_cd,m_app_groups_rec
    ->app_group[ml_num].f_app_grp_cd)
   IF (ml_pos > 0)
    m_security_rec->menus[m_security_rec->l_cntr].l_view_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  menu = m_security_rec->menus[d.seq].f_menu_id, view_ind = m_security_rec->menus[d.seq].l_view_ind
  FROM (dummyt d  WITH seq = size(m_security_rec->menus,5))
  PLAN (d)
  ORDER BY view_ind DESC
  DETAIL
   m_security_rec_sorted->l_cntr = (m_security_rec_sorted->l_cntr+ 1), stat = alterlist(
    m_security_rec_sorted->menus,m_security_rec_sorted->l_cntr), m_security_rec_sorted->menus[
   m_security_rec_sorted->l_cntr].l_view_ind = view_ind,
   m_security_rec_sorted->menus[m_security_rec_sorted->l_cntr].f_menu_id = menu
  WITH nocounter
 ;end select
 SET ms_jsonrec = build(ms_jsonrec,"[]")
 SET ms_jsonrecfinal = ms_jsonrec
 SET ml_fld_cnt = (ml_fld_cnt+ 1)
 SET stat = alterlist(m_parents_final_rec->parent,ml_fld_cnt)
 SET m_parents_final_rec->parent[ml_fld_cnt].f_id = 0
 SET m_parents_final_rec->parent[ml_fld_cnt].s_descr = ""
 SET m_parents_final_rec->parent[ml_fld_cnt].s_name = ""
 SET m_parents_final_rec->parent[ml_fld_cnt].s_type = ""
 SET ml_fstpass = 0
 SET ml_whl_cnt = 0
 WHILE (size(m_parents_final_rec->parent,5) > 0
  AND ml_whl_cnt < 10)
   SET ml_whl_cnt = (ml_whl_cnt+ 1)
   SELECT INTO "nl:"
    FROM explorer_menu e,
     explorer_menu e2,
     (dummyt d  WITH seq = size(m_parents_final_rec->parent,5))
    PLAN (d)
     JOIN (e
     WHERE e.menu_parent_id IN (m_parents_final_rec->parent[d.seq].f_id)
      AND e.menu_id != 0.0
      AND e.active_ind=1
      AND  NOT (e.item_type IN ("N", "R")))
     JOIN (e2
     WHERE e2.menu_parent_id=outerjoin(e.menu_id)
      AND e2.menu_id != outerjoin(0.0)
      AND e2.active_ind=outerjoin(1)
      AND e2.item_type != outerjoin("N")
      AND e2.item_type != outerjoin("R"))
    ORDER BY e.menu_parent_id, e.menu_id
    HEAD REPORT
     stat = 0, ml_fld_cnt = 0
    HEAD e.menu_parent_id
     ms_jsonrec = "", ml_item_cnt = 0
     IF (ml_fstpass=0)
      ml_place = findstring("[",ms_jsonrecfinal), ml_fstpass = 1
     ELSE
      ms_menu = trim(cnvtstring(e.menu_parent_id),3), ml_place = findstring(ms_menu,ms_jsonrecfinal)
      IF (ml_place > 0)
       ml_place = findstring("[",ms_jsonrecfinal,ml_place)
      ENDIF
     ENDIF
    HEAD e.menu_id
     ml_pos = 0, ml_view_ind = 0
     IF (e.menu_parent_id=0)
      ml_pos = locateval(ml_num,0,size(m_security_rec_sorted->menus,5),e.menu_id,
       m_security_rec_sorted->menus[ml_num].f_menu_id)
      IF (ml_pos > 0)
       IF ((m_security_rec_sorted->menus[ml_pos].l_view_ind=0))
        ml_view_ind = 0
       ELSE
        ml_view_ind = 1
       ENDIF
      ELSE
       ml_view_ind = 1
      ENDIF
     ELSE
      ml_parentpos = locateval(ml_num,0,size(m_parents_final_rec->parent,5),e.menu_parent_id,
       m_parents_final_rec->parent[ml_num].f_id)
      IF (ml_parentpos > 0)
       IF ((m_parents_final_rec->parent[ml_pos].l_view_ind=1))
        ml_pos = locateval(ml_num,0,size(m_security_rec_sorted->menus,5),e.menu_id,
         m_security_rec_sorted->menus[ml_num].f_menu_id)
        IF (ml_pos > 0)
         IF ((m_security_rec_sorted->menus[ml_pos].l_view_ind=0))
          ml_view_ind = 0
         ELSE
          ml_view_ind = 1
         ENDIF
        ELSE
         ml_view_ind = 1
        ENDIF
       ELSE
        ml_view_ind = 0
       ENDIF
      ENDIF
     ENDIF
     IF (ml_view_ind=1)
      ml_item_cnt = (ml_item_cnt+ 1)
      IF (ml_item_cnt > 1)
       ms_jsonrec = build(ms_jsonrec,",")
      ENDIF
      IF (ml_place > 0)
       IF (e2.menu_parent_id > 0
        AND  NOT (e2.menu_parent_id IN (null)))
        ml_fld_cnt = (ml_fld_cnt+ 1), stat = alterlist(m_parents_temp_rec->parent,ml_fld_cnt),
        m_parents_temp_rec->parent[ml_fld_cnt].f_id = e.menu_id,
        m_parents_temp_rec->parent[ml_fld_cnt].s_descr = replace(e.item_desc,'"',"",0),
        m_parents_temp_rec->parent[ml_fld_cnt].s_name = replace(e.item_name,":DBA","",2),
        m_parents_temp_rec->parent[ml_fld_cnt].s_type = e.item_type,
        m_parents_temp_rec->parent[ml_fld_cnt].l_view_ind = ml_view_ind, ms_jsonrec = build(
         ms_jsonrec,"{"), ms_jsonrec = build(ms_jsonrec,'"id":',cnvtstring(e.menu_id),","),
        ms_jsonrec = build(ms_jsonrec,'"name":"',replace(e.item_name,":DBA","",2),'",'), ms_jsonrec
         = build(ms_jsonrec,'"type":"',e.item_type,'",'), ms_jsonrec = build(ms_jsonrec,'"descr":"',
         replace(e.item_desc,'"',"",0),'",'),
        ms_jsonrec = build(ms_jsonrec,'"children":'), ms_jsonrec = build(ms_jsonrec,"[]"), ms_jsonrec
         = build(ms_jsonrec,"}")
       ELSE
        ms_jsonrec = build(ms_jsonrec,"{"), ms_jsonrec = build(ms_jsonrec,'"id":',cnvtstring(e
          .menu_id),","), ms_jsonrec = build(ms_jsonrec,'"name":"',replace(e.item_name,":DBA","",2),
         '",'),
        ms_jsonrec = build(ms_jsonrec,'"type":"',e.item_type,'",'), ms_jsonrec = build(ms_jsonrec,
         '"descr":"',replace(e.item_desc,'"',"",0),'"'), ms_jsonrec = build(ms_jsonrec,"}")
       ENDIF
      ENDIF
     ENDIF
    FOOT  e.menu_parent_id
     ms_jsonrecfinal = concat(substring(1,ml_place,ms_jsonrecfinal),ms_jsonrec,substring((ml_place+ 1
       ),(size(ms_jsonrecfinal) - ml_place),ms_jsonrecfinal))
    WITH nocounter
   ;end select
   SET stat = moverec(m_parents_temp_rec,m_parents_final_rec)
   SET stat = alterlist(m_parents_temp_rec->parent,0)
 ENDWHILE
 SET _memory_reply_string = ms_jsonrecfinal
#exit_script
 FREE RECORD m_parents_temp_rec
 FREE RECORD m_parents_final_rec
 FREE RECORD m_security_rec
 FREE RECORD m_security_rec_sorted
END GO
