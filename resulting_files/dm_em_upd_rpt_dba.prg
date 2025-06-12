CREATE PROGRAM dm_em_upd_rpt:dba
 SET c_mod = "DM_EM_UPD_RPT 002"
 EXECUTE FROM 1000_init TO 1099_init_exit
 IF (validate(i_update_ind,0)=0
  AND validate(i_update_ind,1)=1)
  SET i_update_ind = true
 ENDIF
 IF (validate(i_commit_ind,0)=0
  AND validate(i_commit_ind,1)=1)
  SET deur_rec->commit_flag = deur_rec->commit_int
 ELSE
  SET deur_rec->commit_flag = i_commit_ind
 ENDIF
 IF ((deur_rec->commit_flag=0))
  SET deur_rec->commit_flag = deur_rec->commit_int
 ENDIF
 IF (validate(i_report_ind,0)=0
  AND validate(i_report_ind,1)=1)
  SET i_report_ind = true
 ENDIF
 IF (validate(g_audit_only,0)=0
  AND validate(g_audit_only,1)=1)
  DECLARE g_audit_only = i4
  SET g_audit_only = false
 ELSEIF (g_audit_only=true)
  SET i_report_ind = true
 ENDIF
 DECLARE debug_ind = i4
 IF (validate(i_debug_ind,1)=1
  AND validate(i_debug_ind,0)=0)
  SET debug_ind = false
  SET i_debug_ind = debug_ind
 ELSE
  SET debug_ind = i_debug_ind
 ENDIF
 IF (i_report_ind=false
  AND i_update_ind=false)
  CALL echo(fillstring(80,"*"))
  CALL echo("Neither report or update mode indicated.  Exiting program.")
  CALL echo(fillstring(80,"*"))
  GO TO exit_program
 ENDIF
 CALL deur_sub_load_pt(1)
 CALL deur_sub_load_pc(1)
 CALL deur_sub_build_sel(deur_recst->qual_cnt)
 EXECUTE FROM 2000_get_new_values TO 2000_end_get_new_values
 IF (i_debug_ind)
  CALL deur_sub_echo_record("deur_recrpt","deur_deur_recrpt.dat")
 ENDIF
 CALL deur_sub_write_rpt(i_report_ind)
 IF (g_audit_only=true)
  GO TO exit_program
 ENDIF
 CALL deur_sub_update(i_update_ind)
 GO TO exit_program
#1000_init
 FREE SET deur_recst
 FREE RECORD deur_recst
 RECORD deur_recst(
   1 tbl_max_cnt = i4
   1 pcd_max_cnt = i4
   1 qual_cnt = i4
   1 qual[*]
     2 person_combine_id = f8
     2 from_person_id = f8
     2 to_person_id = f8
     2 encntr_id = f8
     2 entity_name = vc
     2 attribute_name = vc
     2 entity_id = f8
     2 updt_dt_tm = f8
     2 new_person_id = f8
     2 new_encntr_id = f8
     2 problem_ind = i4
     2 encntr_id_update_flag = i4
     2 ndx = i4
     2 pcd_cnt = i4
     2 pcd_qual[*]
       3 person_combine_det_id = f8
       3 entity_name = vc
       3 entity_id = f8
       3 attribute_name = vc
       3 parent_person_id = f8
       3 updt_dt_tm = f8
       3 qual_ndx = i4
       3 tbl_cnt = i4
       3 tbl_qual[*]
         4 update_flag = i4
         4 entity_name = vc
         4 attribute_name = vc
         4 entity_id = f8
         4 attribute_value = f8
         4 child_person_id = f8
         4 qual_ndx = i4
         4 status = i4
         4 errnum = i4
         4 errmsg = c132
 )
 FREE SET deur_recsel
 FREE RECORD deur_recsel
 RECORD deur_recsel(
   1 complete_str = vc
   1 select_str = vc
   1 from_str = vc
   1 where_str = vc
   1 order_str = vc
   1 with_str = vc
   1 head_rpt_str = vc
   1 head_str_pc = vc
   1 head_str = vc
   1 detail_str = vc
   1 foot_str = vc
   1 foot_str_pc = vc
   1 foot_rpt_str = vc
   1 subroutine_str = vc
   1 parent_column = vc
   1 parent_pk_column = vc
   1 parent_person_column = vc
   1 order_column = vc
   1 person_column = vc
   1 entity_column = vc
   1 str = vc
 )
 FREE SET deur_rectbls
 FREE RECORD deur_rectbls
 RECORD deur_rectbls(
   1 qual_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 used_flag = i4
     2 pk_column = vc
     2 person_column = vc
     2 parent_column = vc
     2 table_exists_ind = i4
     2 p_cnt = i4
     2 parent[*]
       3 table_name = vc
       3 pk_column = vc
       3 parent_column = vc
       3 person_column = vc
       3 child_column = vc
 )
 FREE SET deur_recrpt
 FREE RECORD deur_recrpt
 RECORD deur_recrpt(
   1 report_start_ind = i4
   1 pc_qual_max_cnt = i4
   1 rpt_encntr_str = vc
   1 rpt_new_encntr_str = vc
   1 rpt_new_person_str = vc
   1 rpt_person_str = vc
   1 rpt_table_str2 = vc
   1 pc_cnt = i4
   1 pc_qual[*]
     2 encntr_id_update_flag = i4
     2 encntr_id = f8
     2 recst_ndx = i4
     2 sort_id = i4
     2 type_name = vc
     2 table_str = vc
     2 qual_cnt = i4
     2 qual[*]
       3 q_sort_id = i4
       3 recst_pcd_ndx = i4
       3 rectbls_ndx = i4
 )
 FREE SET deur_rectrg
 FREE RECORD deur_rectrg
 RECORD deur_rectrg(
   1 table_cnt = i4
   1 last_action_flag = i4
   1 table_qual[*]
     2 table_name = vc
     2 select_dt_tm = f8
     2 trg_cnt = i4
     2 trg_qual[*]
       3 trigger_name = vc
       3 status = c10
 )
 FREE SET deur_rec
 FREE RECORD deur_rec
 RECORD deur_rec(
   1 ccl_version_ind = i4
   1 str = vc
   1 head_val = f8
   1 entity_name = vc
   1 pk_column = vc
   1 attribute_name = vc
   1 child_entity_name = vc
   1 child_attribute_name = vc
   1 cs327_update_cd = f8
   1 commit_flag = i4
   1 pc_head_rstr = vc
   1 pc_head_rstr2 = vc
   1 p_table_rstr = vc
   1 c_table_rstr = vc
   1 table_rstr = vc
   1 not_set = i4
   1 table_found = i4
   1 table_not_found = i4
   1 columns_not_found = i4
   1 commit_int = i4
   1 rollback_int = i4
   1 rptfile = vc
   1 fprefix = vc
   1 fext = c4
   1 unique_tempstr = vc
   1 fname = vc
   1 fini = i4
   1 rptfile_fix = c60
   1 stat = i4
   1 return_status = i4
   1 enabled = i4
   1 disabled = i4
 )
 DECLARE deur_sub_load_pc(1) = null
 DECLARE deur_sub_write_rpt(1) = null
 DECLARE deur_sub_update(1) = null
 DECLARE deur_sub_load_pt(1) = null
 DECLARE deur_sub_load_tbl("1","2","3","4","5",
  "6","7","8") = null
 DECLARE deur_sub_build_sel(1) = null
 DECLARE deur_sub_echo("string to echo") = null
 DECLARE deur_sub_trigger_action("table_name","trigger_action") = i4
 DECLARE pc_ndx = i4
 DECLARE pcd_ndx = i4
 DECLARE t_ndx = i4
 DECLARE pc_cnt = i4
 DECLARE pcd_cnt = i4
 DECLARE qual_cnt = i4
 DECLARE encntr_id_update_flag = i4
 DECLARE i_ndx = i4
 DECLARE j_ndx = i4
 SET pc_head_def =
 "Encounter XXX_ENCNTR_ID was moved from person XXX_FROM_PERSON_ID to XXX_TO_PERSON_ID."
 SET pc_head_def1 =
 "This encounter XXX_ENCNTR_ID has been combined into encounter XXX_NEW_ENCNTR_ID."
 SET pc_head_def2 = "Person XXX_TO_PERSON_ID has been combined into XXX_NEW_PERSON_ID."
 SET pc_head_def3 = "  The following entries should be associated with person XXX_NEW_PERSON_ID."
 SET p_table_def1 = "   The following entries are associated with this encounter:"
 SET p_table_def2 = concat("  XXX_P_COL_NAME XXX_P_COL_VALUE on table XXX_PARENT_TABLE ",
  "is related to this encounter and person XXX_PARENT_PERSON_ID.")
 SET c_table_def = concat(
  "     XXX_CHILD_TABLE for XXX_C_COL_NAME XXX_C_COL_VALUE : this row is incorrectly ",
  "associated with person XXX_CHILD_PERSON_ID.")
 SET rpt_encntr_def = pc_head_def
 SET rpt_new_encntr_def = pc_head_def1
 SET rpt_new_person_def = pc_head_def2
 SET rpt_person_def = pc_head_def3
 SET p_table_def = p_table_def1
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i4
  SET true = 1
 ENDIF
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i4
  SET false = 0
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=327
   AND c.active_ind=1
   AND c.cdf_meaning="UPT"
  DETAIL
   deur_rec->cs327_update_cd = c.code_value
  WITH nocounter
 ;end select
 IF ((deur_rec->cs327_update_cd=0))
  CALL echo(fillstring(80,"*"))
  CALL echo("Code value for 'Update' from code_set 327 not set.  Exiting program.")
  CALL echo(fillstring(80,"*"))
  GO TO exit_program
 ENDIF
 SET deur_rec->ccl_version_ind = 0
 IF (validate(curutc,0)=0
  AND validate(curutc,1)=1)
  SET deur_rec->ccl_version_ind = 1
 ENDIF
 SET deur_rec->not_set = 0
 SET deur_rec->table_found = 1
 SET deur_rec->table_not_found = 2
 SET deur_rec->columns_not_found = 3
 SET deur_rec->commit_int = 1
 SET deur_rec->rollback_int = 2
 SET deur_rec->enabled = 1
 SET deur_rec->disabled = 2
#1099_init_exit
 SUBROUTINE deur_sub_build_sel(p_ind_xxx)
   CALL echo("Starting DEUR_SUB_BUILD_SEL.")
   IF (debug_ind)
    CALL deur_sub_echo_record("deur_recst","deur1_deur_recst.dat")
   ENDIF
   DECLARE t_alias = c4
   DECLARE t0_alias = c4
   DECLARE t1_alias = c4
   DECLARE t2_alias = c4
   SET deur_recsel->select_str = concat(" select into 'nl:'",
    "  cmb_from_person = deur_recst->qual[d1.seq].from_person_id",
    "  ,cmb_to_person = deur_recst->qual[d1.seq].to_person_id",
    "  ,cmb_encntr_id = deur_recst->qual[d1.seq].encntr_id",
    "  ,person_combine_id = deur_recst->qual[d1.seq].person_combine_id",
    "  ,person_combine_det_id = deur_recst->qual[d1.seq].pcd_qual[d2.seq].person_combine_det_id",
    "  ,encntr_id_update_flag = deur_recst->qual[d1.seq].encntr_id_update_flag")
   SET deur_recsel->from_str = " "
   FOR (i_ndx = 1 TO deur_rectbls->qual_cnt)
     IF ((deur_rectbls->qual[i_ndx].table_exists_ind IN (deur_rec->not_set, deur_rec->table_found)))
      SET deur_recsel->from_str = concat("  from (dummyt d1 with seq = ",build(deur_recst->qual_cnt),
       "), ","  (dummyt d2 with seq = ",build(deur_recst->pcd_max_cnt),
       ")")
      SET deur_recsel->where_str = concat("  plan d1 where d1.seq > 0",
       "  join d2 where d2.seq <= deur_recst->qual[d1.seq].pcd_cnt",
       "    and deur_recst->qual[d1.seq].pcd_qual[d2.seq].entity_name = ","'",cnvtupper(trim(
         deur_rectbls->qual[i_ndx].parent[1].table_name)),
       "'")
      SET j_ndx = 1
      SET first_one = true
      SET order_column_set = false
      SET deur_rec->entity_name = deur_rectbls->qual[i_ndx].parent[deur_rectbls->qual[i_ndx].p_cnt].
      table_name
      SET deur_rec->child_entity_name = deur_rectbls->qual[i_ndx].table_name
      SET deur_rec->child_attribute_name = deur_rectbls->qual[i_ndx].person_column
      FOR (j_ndx = 1 TO deur_rectbls->qual[i_ndx].p_cnt)
        SET deur_recsel->order_str = " order person_combine_id, person_combine_det_id "
        SET t0_alias = build("t",(j_ndx - 1))
        SET t1_alias = build("t",j_ndx)
        SET t2_alias = build("t",(j_ndx+ 1))
        IF (j_ndx=1)
         SET t_alias = t1_alias
        ENDIF
        SET deur_recsel->parent_pk_column = "BOGUS"
        IF ((deur_rectbls->qual[i_ndx].p_cnt=1))
         SET deur_recsel->from_str = concat(deur_recsel->from_str,", ",deur_rectbls->qual[i_ndx].
          parent[1].table_name," ",trim(t1_alias))
         SET deur_recsel->where_str = concat(deur_recsel->where_str,"  join ",trim(t1_alias),
          " where ",trim(t1_alias),
          ".",deur_rectbls->qual[i_ndx].parent[1].pk_column,
          " = deur_recst->qual[d1.seq].pcd_qual[d2.seq].entity_id","  join ",trim(t2_alias),
          " where ",trim(t2_alias),".",deur_rectbls->qual[i_ndx].parent_column," = ",
          trim(t1_alias),".",deur_rectbls->qual[i_ndx].parent[j_ndx].child_column)
         SET deur_recsel->from_str = concat(deur_recsel->from_str,", ",deur_rectbls->qual[i_ndx].
          table_name," ",trim(t2_alias))
         SET deur_recsel->where_str = concat(trim(deur_recsel->where_str),"  and ",trim(t2_alias),".",
          deur_rectbls->qual[i_ndx].person_column,
          " != ",trim(t1_alias),".",deur_rectbls->qual[i_ndx].parent[1].person_column)
         SET deur_recsel->parent_pk_column = concat(trim(t1_alias),".",deur_rectbls->qual[i_ndx].
          parent[1].pk_column)
         SET deur_recsel->parent_column = concat(trim(t1_alias),".",deur_rectbls->qual[i_ndx].parent[
          1].parent_column)
         SET deur_recsel->parent_person_column = concat(trim(t1_alias),".",deur_rectbls->qual[i_ndx].
          parent[1].person_column)
         SET deur_recsel->order_column = concat(trim(t2_alias),".",deur_rectbls->qual[i_ndx].
          parent_column)
         SET deur_recsel->person_column = concat(trim(t2_alias),".",deur_rectbls->qual[i_ndx].
          person_column)
         SET deur_recsel->entity_column = concat(trim(t2_alias),".",deur_rectbls->qual[i_ndx].
          pk_column)
        ELSE
         IF (first_one)
          SET deur_recsel->from_str = concat(deur_recsel->from_str,", ",deur_rectbls->qual[i_ndx].
           parent[1].table_name," ",trim(t1_alias))
          SET deur_recsel->where_str = concat(deur_recsel->where_str,"  join ",trim(t1_alias),
           "  where"," ",
           trim(t1_alias),".",deur_rectbls->qual[i_ndx].parent[1].pk_column,
           " = deur_recst->qual[d1.seq].pcd_qual[d2.seq].entity_id")
          SET deur_recsel->parent_column = concat(trim(t1_alias),".",deur_rectbls->qual[i_ndx].
           parent[1].parent_column)
         ELSE
          SET deur_recsel->from_str = concat(deur_recsel->from_str,", ",deur_rectbls->qual[i_ndx].
           parent[j_ndx].table_name," ",trim(t1_alias))
          SET deur_recsel->where_str = concat(deur_recsel->where_str,"  join ",trim(t1_alias),
           " where"," ",
           trim(t1_alias),".",deur_rectbls->qual[i_ndx].parent[j_ndx].parent_column," = "," ",
           trim(t0_alias),".",deur_rectbls->qual[i_ndx].parent[(j_ndx - 1)].child_column)
         ENDIF
         IF ((j_ndx=deur_rectbls->qual[i_ndx].p_cnt))
          SET deur_recsel->from_str = concat(deur_recsel->from_str,", ",deur_rectbls->qual[i_ndx].
           table_name," ",trim(t2_alias))
          SET deur_recsel->where_str = concat(deur_recsel->where_str,"  join ",trim(t2_alias),
           " where"," ",
           trim(t2_alias),".",deur_rectbls->qual[i_ndx].parent[j_ndx].child_column," = ",trim(
            t1_alias),
           ".",deur_rectbls->qual[i_ndx].parent_column,"  and ",trim(t2_alias),".",
           deur_rectbls->qual[i_ndx].person_column," != ",trim(t_alias),".",deur_rectbls->qual[i_ndx]
           .parent[1].person_column)
          SET deur_recsel->parent_pk_column = concat(trim(t1_alias),".",deur_rectbls->qual[i_ndx].
           parent_column)
          SET deur_recsel->parent_person_column = concat(trim(t_alias),".",deur_rectbls->qual[i_ndx].
           parent[1].person_column)
          SET deur_recsel->order_column = concat(trim(t2_alias),".",deur_rectbls->qual[i_ndx].
           parent_column)
          SET deur_recsel->person_column = concat(trim(t2_alias),".",deur_rectbls->qual[i_ndx].
           person_column)
          SET deur_recsel->entity_column = concat(trim(t2_alias),".",deur_rectbls->qual[i_ndx].
           pk_column)
         ENDIF
        ENDIF
        SET first_one = 0
      ENDFOR
      IF (order_column_set=false)
       SET deur_recsel->head_str_pc = "  HEAD person_combine_id"
       IF (i_report_ind)
        SET deur_recsel->head_str_pc = concat(deur_recsel->head_str_pc,
         "    if (deur_recst->qual[d1.seq].pcd_qual[d2.seq].tbl_cnt != 0)",
         "       t_ndx = maxval(deur_recst->qual[d1.seq].pcd_qual[d2.seq].tbl_cnt,0)",
         "       deur_rec->stat = alterlist(deur_recst->qual[d1.seq].pcd_qual[d2.seq].tbl_qual,t_ndx + 10)",
         "     endif",
         "  d1seq = d1.seq","  d2seq = d2.seq")
       ELSE
        SET deur_recsel->head_str_pc = concat(deur_recsel->head_str_pc,"  deur_rec->stat = 1")
       ENDIF
       SET deur_recsel->order_str = concat(trim(deur_recsel->order_str),",",deur_recsel->order_column
        )
       SET deur_recsel->head_rpt_str = "  HEAD REPORT"
       IF (i_report_ind)
        SET deur_recsel->head_rpt_str = concat(deur_recsel->head_rpt_str,"  pc_cnt = 0",
         "  qual_cnt = 0")
        SET deur_recsel->head_str = concat("  HEAD ",deur_recsel->order_column,"  t_ndx = 0")
        SET deur_recsel->head_str = concat(deur_recsel->head_str,
         "    deur_recrpt->pc_cnt = size(deur_recrpt->pc_qual,5)",
         "    pc_cnt = deur_recrpt->pc_cnt + 1",
         "    deur_rec->stat = alterlist(deur_recrpt->pc_qual,pc_cnt)",
         "    deur_recrpt->pc_qual[pc_cnt].sort_id = pc_cnt",
         "    deur_recrpt->pc_qual[pc_cnt].recst_ndx = deur_recst->qual[d1seq].ndx",
         "    deur_recrpt->pc_qual[pc_cnt].encntr_id = deur_recst->qual[d1seq].encntr_id",
         "    deur_recst->qual[d1seq].pcd_qual[d2.seq].parent_person_id = ",deur_recsel->
         parent_person_column,"    deur_recst->qual[d1.seq].problem_ind = 1",
         "    qual_cnt = 0")
       ENDIF
       SET order_column_set = true
      ENDIF
      IF (debug_ind)
       CALL echo(build("I_ndx: ",i_ndx,"; j_ndx: ",j_ndx))
       CALL echo(concat("Child_entity_name: ",deur_rec->child_entity_name))
       CALL echo(concat("Child_attribute_name: ",deur_rec->child_attribute_name))
       CALL echo(concat("Deur_rec->entity_name: ",deur_rec->entity_name))
      ENDIF
      SET deur_recsel->detail_str = "  DETAIL"
      IF (i_update_ind=false
       AND i_report_ind=false)
       SET deur_recsel->detail_str = "  DETAIL  deur_rec->stat = 1"
      ENDIF
      IF (i_update_ind)
       SET deur_recsel->detail_str = concat(deur_recsel->detail_str,"  /","* update information *",
        "/","   t_ndx = deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_cnt + 1",
        "   deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_cnt = t_ndx","   if (mod(t_ndx,10) = 1) ",
        "     deur_rec->stat = alterlist(deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_qual,t_ndx + 9) ",
        "   endif ","   deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_qual[t_ndx].update_flag = 1",
        "   deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_qual[t_ndx].entity_name = deur_rec->child_entity_name",
        "   deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_qual[t_ndx].attribute_name = deur_rec->child_attribute_name",
        "   deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_qual[t_ndx].entity_id = ",deur_recsel->
        entity_column,"   deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_qual[t_ndx].child_person_id = ",
        deur_recsel->person_column,
        "   deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_qual[t_ndx].qual_ndx = ",build(i_ndx))
      ENDIF
      IF (i_report_ind)
       SET deur_recsel->detail_str = concat(deur_recsel->detail_str,"  /",
        "* audit report information *","/",
        "  if (deur_recst->qual[d1.seq].encntr_id_update_flag = TRUE)",
        "    deur_recrpt->pc_qual[pc_cnt].encntr_id_update_flag = TRUE","    qual_cnt = qual_cnt + 1",
        "    if (mod(qual_cnt,10) = 1)",
        "      deur_rec->stat = alterlist(deur_recrpt->pc_qual[pc_cnt].qual,qual_cnt + 9)",
        "    endif",
        "    deur_recrpt->pc_qual[pc_cnt].qual[qual_cnt].q_sort_id = qual_cnt","  endif")
      ENDIF
      SET deur_recsel->foot_str = concat(" FOOT ",deur_recsel->order_column)
      IF (i_update_ind=false
       AND i_report_ind=false)
       SET deur_recsel->foot_str = concat(deur_recsel->foot_str,"  deur_rec->stat = 1")
      ENDIF
      IF (i_report_ind)
       SET deur_recsel->foot_str = concat(deur_recsel->foot_str,"  if (qual_cnt > 0)",
        "    deur_rec->stat = alterlist(deur_recrpt->pc_qual[pc_cnt].qual,qual_cnt)",
        "    deur_recrpt->pc_qual[pc_cnt].qual_cnt = qual_cnt","  endif",
        "  if (qual_cnt > deur_recrpt->pc_qual_max_cnt)",
        "    deur_recrpt->pc_qual_max_cnt = qual_cnt","  endif")
      ELSE
       SET deur_recsel->foot_str = concat(deur_recsel->foot_str,"  deur_rec->stat = 1")
      ENDIF
      SET deur_recsel->foot_str_pc = "  FOOT person_combine_id"
      IF (i_update_ind=false
       AND i_report_ind=false)
       SET deur_recsel->foot_str_pc = concat(deur_recsel->foot_str_pc,"  deur_rec->stat = 1")
      ENDIF
      IF (i_update_ind)
       SET deur_recsel->foot_str_pc = concat(deur_recsel->foot_str_pc,
        "   deur_rec->stat = alterlist(deur_recst->qual[d1seq].pcd_qual[d2seq].tbl_qual,t_ndx)",
        "   if (t_ndx > deur_recst->tbl_max_cnt)","     deur_recst->tbl_max_cnt = t_ndx","   endif")
      ELSE
       SET deur_recsel->foot_str_pc = concat(deur_recsel->foot_str_pc,"  deur_rec->stat = 1")
      ENDIF
      IF (i_report_ind)
       SET deur_recsel->foot_rpt_str = concat("  foot report","  deur_recrpt->pc_cnt = pc_cnt",
        "  deur_rec->stat = alterlist(deur_recrpt->pc_qual,pc_cnt)")
      ENDIF
      SET deur_recsel->with_str = "with nocounter"
      IF (debug_ind)
       CALL echo("")
       CALL deur_sub_echo(deur_recsel->select_str)
       CALL deur_sub_echo(deur_recsel->from_str)
       CALL deur_sub_echo(deur_recsel->where_str)
       CALL deur_sub_echo(deur_recsel->order_str)
       CALL deur_sub_echo(deur_recsel->head_rpt_str)
       CALL deur_sub_echo(deur_recsel->head_str_pc)
       CALL deur_sub_echo(deur_recsel->head_str)
       CALL deur_sub_echo(deur_recsel->detail_str)
       CALL deur_sub_echo(deur_recsel->foot_str_pc)
       CALL deur_sub_echo(deur_recsel->foot_str)
       CALL deur_sub_echo(deur_recsel->foot_rpt_str)
       CALL deur_sub_echo(deur_recsel->with_str)
      ENDIF
      CALL parser(deur_recsel->select_str)
      CALL parser(deur_recsel->from_str)
      CALL parser(deur_recsel->where_str)
      CALL parser(deur_recsel->order_str)
      CALL parser(deur_recsel->head_rpt_str)
      CALL parser(deur_recsel->head_str_pc)
      CALL parser(deur_recsel->head_str)
      CALL parser(deur_recsel->detail_str)
      CALL parser(deur_recsel->foot_str_pc)
      CALL parser(deur_recsel->foot_str)
      CALL parser(deur_recsel->foot_rpt_str)
      CALL parser(deur_recsel->with_str)
      CALL parser(" go")
     ENDIF
   ENDFOR
   IF (debug_ind)
    CALL deur_sub_echo_record("deur_recst","deur2_deur_recst.dat")
   ENDIF
 END ;Subroutine
 SUBROUTINE deur_sub_echo(p_var)
   FREE SET mys
   FREE SET p
   FREE SET ok
   FREE SET col_sz
   SET mys = size(p_var)
   SET p = 1
   SET ok = 1
   SET col_sz = 80
   WHILE (ok)
     SET deur_rec->str = substring(p,col_sz,p_var)
     IF (deur_rec->ccl_version_ind)
      SET e = 1
      WHILE (e)
       SET l_e = e
       SET e = findstring("  ",substring(p,col_sz,p_var),(e+ 1))
      ENDWHILE
      SET e = l_e
      IF ( NOT (e))
       SET e = 1
       WHILE (e)
        SET l_e = e
        SET e = findstring(" ",substring(p,col_sz,p_var),(e+ 1))
       ENDWHILE
       SET e = l_e
      ENDIF
      IF (e <= 1)
       SET e = col_sz
      ENDIF
     ELSE
      SET e = findstring("  ",substring(p,col_sz,p_var))
      IF ( NOT (e))
       SET e = findstring(" ",substring(p,col_sz,p_var),p,1)
       IF ( NOT (e))
        SET e = col_sz
       ENDIF
      ENDIF
     ENDIF
     SET deur_rec->str = trim(substring(p,e,p_var))
     CALL echo(deur_rec->str)
     SET p = (p+ e)
     IF (p > mys)
      SET ok = 0
     ENDIF
   ENDWHILE
 END ;Subroutine
#2000_get_new_values
 CALL echo("Label 2000_GET_NEW_VALUES.")
 FREE SET request
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 encntr_id = f8
 )
 FREE SET reply
 FREE RECORD reply
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 new_person_id = f8
   1 new_encntr_id = f8
   1 valid_person_ind = i2
   1 valid_encntr_ind = i2
   1 person_encntr_match_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FOR (i_ndx = 1 TO deur_recst->qual_cnt)
   IF ((deur_recst->qual[i_ndx].problem_ind=true)
    AND (((deur_recst->qual[i_ndx].new_person_id=0)) OR ((deur_recst->qual[i_ndx].new_encntr_id=0)))
   )
    SET request->person_id = deur_recst->qual[i_ndx].to_person_id
    SET request->encntr_id = deur_recst->qual[i_ndx].encntr_id
    EXECUTE dm_combine_in_process
    IF (i_debug_ind)
     CALL echo(build("I_ndx: ",i_ndx,"; Person_id:",request->person_id,"; Encntr_id:",
       request->encntr_id))
    ENDIF
    IF ((reply->person_encntr_match_ind=1))
     SELECT INTO "nl:"
      to_person_id = deur_recst->qual[d.seq].to_person_id, new_person_id = deur_recst->qual[d.seq].
      new_person_id
      FROM (dummyt d  WITH seq = value(deur_recst->qual_cnt))
      WHERE d.seq > 0
       AND (deur_recst->qual[d.seq].new_person_id=0)
       AND (deur_recst->qual[d.seq].to_person_id=deur_recst->qual[i_ndx].to_person_id)
      DETAIL
       deur_recst->qual[d.seq].new_person_id = deur_recst->qual[d.seq].to_person_id, deur_recst->
       qual[d.seq].new_encntr_id = deur_recst->qual[d.seq].encntr_id
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      to_person_id = deur_recst->qual[d.seq].to_person_id, new_person_id = deur_recst->qual[d.seq].
      new_person_id
      FROM (dummyt d  WITH seq = value(deur_recst->qual_cnt))
      WHERE d.seq > 0
       AND (deur_recst->qual[d.seq].new_person_id=0)
       AND (deur_recst->qual[d.seq].to_person_id=deur_recst->qual[i_ndx].to_person_id)
      DETAIL
       IF ((reply->valid_person_ind=1))
        deur_recst->qual[d.seq].new_person_id = deur_recst->qual[i_ndx].to_person_id
       ELSE
        deur_recst->qual[d.seq].new_person_id = reply->new_person_id
        IF (i_debug_ind)
         CALL echo(build("I_ndx:",i_ndx,"; Old person_id:",to_person_id,"; new: ",
          reply->new_person_id))
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      encntr_id = deur_recst->qual[d.seq].encntr_id, new_encntr_id = deur_recst->qual[d.seq].
      new_encntr_id
      FROM (dummyt d  WITH seq = value(deur_recst->qual_cnt))
      WHERE d.seq > 0
       AND (deur_recst->qual[d.seq].new_encntr_id=0)
       AND (deur_recst->qual[d.seq].encntr_id=deur_recst->qual[i_ndx].encntr_id)
      DETAIL
       IF ((reply->valid_encntr_ind=1))
        deur_recst->qual[d.seq].new_encntr_id = deur_recst->qual[i_ndx].encntr_id
       ELSE
        deur_recst->qual[d.seq].new_encntr_id = reply->new_encntr_id
        IF (i_debug_ind)
         CALL echo(build("I_ndx:",i_ndx,"; Old encntr_id:",encntr_id,"; new: ",
          reply->new_encntr_id))
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 FREE RECORD request
 FREE RECORD reply
 IF (debug_ind)
  CALL deur_sub_echo_record("deur_recst","deur3_deur_recst.dat")
 ENDIF
 CALL echo("Label 2000_END_GET_NEW_VALUES.")
#2000_end_get_new_values
 SUBROUTINE deur_sub_load_pc(p)
   CALL echo("Starting DEUR_SUB_LOAD_PC.")
   SELECT INTO "nl:"
    cmb_from_person = pc.from_person_id, cmb_to_person = pc.to_person_id, cmb_encntr = pc.encntr_id,
    cmb_id = pc.person_combine_id
    FROM person_combine pc,
     person_combine_det pcd
    PLAN (pc
     WHERE pc.active_ind=1
      AND pc.encntr_id > 0)
     JOIN (pcd
     WHERE pcd.person_combine_id=pc.person_combine_id
      AND pcd.entity_name IN ("ORDERS", "ORDER_RADIOLOGY", "RESULT", "PATHOLOGY_CASE",
     "PRODUCT_EVENT",
     "PERSON_HLA_AB_SCREEN", "ENCOUNTER", "PERSON_HLA_XM", "CLINICAL_EVENT"))
    ORDER BY pc.encntr_id, pc.updt_dt_tm DESC, pcd.person_combine_id,
     pcd.person_combine_det_id
    HEAD REPORT
     qual_cnt = 0, pcd_cnt = 0, hld_pcd_id = 0.0
    HEAD pc.encntr_id
     encntr_id_update_flag = true, qual_cnt = (qual_cnt+ 1)
     IF (mod(qual_cnt,50)=1)
      deur_rec->stat = alterlist(deur_recst->qual,(qual_cnt+ 49))
     ENDIF
     deur_recst->qual[qual_cnt].to_person_id = cmb_to_person, deur_recst->qual[qual_cnt].
     from_person_id = cmb_from_person, deur_recst->qual[qual_cnt].encntr_id = cmb_encntr,
     deur_recst->qual[qual_cnt].person_combine_id = cmb_id, deur_recst->qual[qual_cnt].updt_dt_tm =
     cnvtreal(pc.updt_dt_tm), deur_recst->qual[qual_cnt].ndx = qual_cnt,
     deur_recst->qual[qual_cnt].encntr_id_update_flag = encntr_id_update_flag, pcd_cnt = 0,
     hld_pcd_id = pcd.person_combine_id
    DETAIL
     IF (hld_pcd_id=pcd.person_combine_id)
      pcd_cnt = (pcd_cnt+ 1)
      IF (mod(pcd_cnt,10)=1)
       deur_rec->stat = alterlist(deur_recst->qual[qual_cnt].pcd_qual,(pcd_cnt+ 9))
      ENDIF
      deur_recst->qual[qual_cnt].pcd_qual[pcd_cnt].person_combine_det_id = pcd.person_combine_det_id,
      deur_recst->qual[qual_cnt].pcd_qual[pcd_cnt].entity_name = pcd.entity_name, deur_recst->qual[
      qual_cnt].pcd_qual[pcd_cnt].entity_id = pcd.entity_id,
      deur_recst->qual[qual_cnt].pcd_qual[pcd_cnt].attribute_name = pcd.attribute_name, deur_recst->
      qual[qual_cnt].pcd_qual[pcd_cnt].updt_dt_tm = cnvtreal(pcd.updt_dt_tm)
     ENDIF
    FOOT  pc.encntr_id
     IF (pcd_cnt > 0)
      deur_rec->stat = alterlist(deur_recst->qual[qual_cnt].pcd_qual,pcd_cnt), deur_recst->qual[
      qual_cnt].pcd_cnt = pcd_cnt
     ENDIF
     IF ((pcd_cnt > deur_recst->pcd_max_cnt))
      deur_recst->pcd_max_cnt = pcd_cnt
     ENDIF
    FOOT REPORT
     deur_rec->stat = alterlist(deur_recst->qual,qual_cnt), deur_recst->qual_cnt = qual_cnt
    WITH nocounter
   ;end select
   CALL echo(fillstring(80,"*"))
   CALL echo(concat("Number of active person_combine rows found to start: ",build(deur_recst->
      qual_cnt)))
   CALL echo(fillstring(80,"*"))
   CALL echo("Ending DEUR_SUB_LOAD_PC.")
 END ;Subroutine
 SUBROUTINE deur_sub_load_pt(p_yyy)
   CALL deur_sub_load_tbl("PULL_ORD_SCHED","ORDER_ID","","","ORDER_RADIOLOGY",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("RESULT","RESULT_ID","ORDER_ID","","ORDERS",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("AP_FT_EVENT","FOLLOWUP_EVENT_ID","CASE_ID","","PATHOLOGY_CASE",
    "CASE_ID","ENCNTR_ID","","")
   CALL deur_sub_load_tbl("AP_QA_INFO","QA_FLAG_ID","CASE_ID","","PATHOLOGY_CASE",
    "CASE_ID","ENCNTR_ID","","")
   CALL deur_sub_load_tbl("ASSIGN","PRODUCT_EVENT_ID","","","PRODUCT_EVENT",
    "PRODUCT_EVENT_ID","ENCNTR_ID","","")
   CALL deur_sub_load_tbl("PATIENT_DISPENSE","PRODUCT_EVENT_ID","","","PRODUCT_EVENT",
    "PRODUCT_EVENT_ID","ENCNTR_ID","","")
   CALL deur_sub_load_tbl("TRANSFUSION","PRODUCT_EVENT_ID","","","PRODUCT_EVENT",
    "PRODUCT_EVENT_ID","ENCNTR_ID","","")
   CALL deur_sub_load_tbl("CROSSMATCH","PRODUCT_EVENT_ID","","","PRODUCT_EVENT",
    "PRODUCT_EVENT_ID","ENCNTR_ID","","")
   CALL deur_sub_load_tbl("HLA_SERA_QUERY_SERUM","SERA_QUERY_SERUM_ID","ORDER_ID","","ORDERS",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("HLA_XM_RES_TRAY","HLA_XM_RES_TRAY_ID","ORDER_ID","DONOR_ID","ORDERS",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("PERSON_HLA_AB_SCREEN","HLA_AB_SCREEN_ID","ORDER_ID","","ORDERS",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("PERSON_HLA_AB_SCN_AUDIT","HLA_AB_SCN_AUDIT_ID","HLA_AB_SCREEN_ID","",
    "ORDERS",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("LAST","","","","PERSON_HLA_AB_SCREEN",
    "HLA_AB_SCREEN_ID","ORDER_ID","","")
   CALL deur_sub_load_tbl("PERSON_HLA_AB_SPEC","HLA_AB_SPEC_ID","ORDER_ID","","ORDERS",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("PERSON_HLA_TYPE","HLA_TYPE_ID","ORDER_ID","","ORDERS",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("PERSON_HLA_XM","HLA_XM_ID","ORDER_ID","","ORDERS",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("BB_EXCEPTION","EXCEPTION_ID","ORDER_ID","","ORDERS",
    "ORDER_ID","","","")
   CALL deur_sub_load_tbl("CE_EVENT_PRSNL","CE_EVENT_PRSNL_ID","EVENT_ID","","CLINICAL_EVENT",
    "CLINICAL_EVENT_ID","","","EVENT_ID")
   SELECT INTO "nl:"
    t.table_name
    FROM dtable t,
     (dummyt d  WITH seq = value(deur_rectbls->qual_cnt))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (t
     WHERE trim(deur_rectbls->qual[d.seq].table_name)=t.table_name)
    DETAIL
     deur_rectbls->qual[d.seq].table_exists_ind = deur_rec->table_not_found
     IF (size(trim(check(t.table_name))) > 0)
      deur_rectbls->qual[d.seq].table_exists_ind = deur_rec->table_found
     ENDIF
    WITH nocounter, outerjoin = d
   ;end select
   SELECT INTO "nl:"
    FROM dtable t,
     dtableattr a,
     dtableattrl l,
     (dummyt d  WITH seq = value(deur_rectbls->qual_cnt))
    PLAN (d
     WHERE (deur_rectbls->qual[d.seq].table_exists_ind=deur_rec->table_found))
     JOIN (t
     WHERE (deur_rectbls->qual[d.seq].table_name=t.table_name))
     JOIN (a
     WHERE t.table_name=a.table_name)
     JOIN (l
     WHERE l.structtype != "K"
      AND btest(l.stat,11)=0
      AND btest(l.stat,9)=0
      AND btest(l.stat,10)=0
      AND l.attr_name IN (deur_rectbls->qual[d.seq].pk_column, deur_rectbls->qual[d.seq].
     person_column, deur_rectbls->qual[d.seq].parent_column))
    ORDER BY t.table_name
    HEAD t.table_name
     pk_col_flag = 0, par_col_flag = 0, per_col_flag = 0
    DETAIL
     IF ((l.attr_name=deur_rectbls->qual[d.seq].pk_column))
      pk_col_flag = 1
     ENDIF
     IF ((l.attr_name=deur_rectbls->qual[d.seq].person_column))
      per_col_flag = 1
     ENDIF
     IF ((l.attr_name=deur_rectbls->qual[d.seq].parent_column))
      par_col_flag = 1
     ENDIF
    FOOT  t.table_name
     IF (false IN (pk_col_flag, per_col_flag, par_col_flag))
      deur_rectbls->qual[d.seq].table_exists_ind = deur_rec->columns_not_found
     ENDIF
    WITH nocounter, outerjoin = d
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(deur_rectbls->qual_cnt))
    PLAN (d1
     WHERE d1.seq > 0
      AND (deur_rectbls->qual[d1.seq].table_exists_ind=deur_rec->columns_not_found))
    ORDER BY deur_rectbls->qual[d1.seq].table_name
    HEAD REPORT
     deur_cnt = deur_recrpt->pc_cnt, deur_rec->stat = alterlist(deur_recrpt->pc_qual,(deur_cnt+ 10)),
     deur_recrpt->report_start_ind = 1
    DETAIL
     deur_cnt = (deur_cnt+ 1)
     IF (mod(deur_cnt,10)=1)
      deur_rec->stat = alterlist(deur_recrpt->pc_qual,(deur_cnt+ 10))
     ENDIF
     deur_recrpt->pc_qual[deur_cnt].encntr_id_update_flag = true, deur_recrpt->pc_qual[deur_cnt].
     qual_cnt = 1, deur_recrpt->pc_cnt = 1,
     deur_recrpt->pc_qual_max_cnt = 1, deur_recrpt->pc_qual[deur_cnt].table_str = concat(
      "The required columns were not found on the table ",deur_rectbls->qual[d1.seq].table_name,
      " - looking for: ",deur_rectbls->qual[d1.seq].pk_column,"; ",
      deur_rectbls->qual[d1.seq].parent_column,"; ",deur_rectbls->qual[d1.seq].person_column),
     deur_recrpt->pc_qual[deur_cnt].sort_id = deur_cnt
    FOOT REPORT
     deur_rec->stat = alterlist(deur_recrpt->pc_qual,deur_cnt), deur_recrpt->pc_cnt = deur_cnt
    WITH nocounter
   ;end select
   IF (debug_ind)
    CALL deur_sub_echo_record("deur_rectbls","deur_deur_rectbls.dat")
   ENDIF
 END ;Subroutine
 SUBROUTINE deur_sub_load_tbl(child_table,c_pk_column,c_par_column,c_person_id,parent_table,
  p_pk_column,p_par_column,p_person_id,p_child_column)
  IF (child_table="LAST")
   IF (p_person_id="")
    SET my_p_person_id = "PERSON_ID"
   ELSEIF (p_person_id="NO_PERSON_ID")
    SET my_p_person_id = ""
   ELSE
    SET my_p_person_id = p_person_id
   ENDIF
   IF (p_par_column="")
    SET my_p_par_column = p_pk_column
   ELSE
    SET my_p_par_column = p_par_column
   ENDIF
   IF (p_child_column="")
    SET my_p_child_column = p_pk_column
   ELSE
    SET my_p_child_column = p_child_column
   ENDIF
   SET cnt = deur_rectbls->qual_cnt
   SET cnt2 = (size(deur_rectbls->qual[cnt].parent,5)+ 1)
   SET deur_rec->stat = alterlist(deur_rectbls->qual[cnt].parent,cnt2)
   SET deur_rectbls->qual[cnt].parent[cnt2].table_name = parent_table
   SET deur_rectbls->qual[cnt].parent[cnt2].pk_column = p_pk_column
   SET deur_rectbls->qual[cnt].parent[cnt2].parent_column = my_p_par_column
   SET deur_rectbls->qual[cnt].parent[cnt2].person_column = my_p_person_id
   SET deur_rectbls->qual[cnt].parent[cnt2].child_column = my_p_child_column
   SET deur_rectbls->qual[cnt].p_cnt = cnt2
  ELSE
   IF (p_person_id="")
    SET my_p_person_id = "PERSON_ID"
   ELSEIF (p_person_id="NO_PERSON_ID")
    SET my_p_person_id = ""
   ELSE
    SET my_p_person_id = p_person_id
   ENDIF
   IF (c_person_id="")
    SET my_c_person_id = "PERSON_ID"
   ELSEIF (c_person_id="NO_PERSON_ID")
    SET my_c_person_id = ""
   ELSE
    SET my_c_person_id = c_person_id
   ENDIF
   IF (c_par_column="")
    SET my_c_par_column = c_pk_column
   ELSE
    SET my_c_par_column = c_par_column
   ENDIF
   IF (p_par_column="")
    SET my_p_par_column = p_pk_column
   ELSE
    SET my_p_par_column = p_par_column
   ENDIF
   IF (p_child_column="")
    SET my_p_child_column = p_pk_column
   ELSE
    SET my_p_child_column = p_child_column
   ENDIF
   SET cnt = (deur_rectbls->qual_cnt+ 1)
   SET deur_rectbls->qual_cnt = cnt
   SET deur_rec->stat = alterlist(deur_rectbls->qual,cnt)
   SET deur_rectbls->qual[cnt].table_name = child_table
   SET deur_rectbls->qual[cnt].pk_column = c_pk_column
   SET deur_rectbls->qual[cnt].parent_column = my_c_par_column
   SET deur_rectbls->qual[cnt].person_column = my_c_person_id
   SET deur_rectbls->qual[cnt].table_exists_ind = 0
   SET deur_rec->stat = alterlist(deur_rectbls->qual[cnt].parent,1)
   SET deur_rectbls->qual[cnt].parent[1].table_name = parent_table
   SET deur_rectbls->qual[cnt].parent[1].pk_column = p_pk_column
   SET deur_rectbls->qual[cnt].parent[1].parent_column = my_p_par_column
   SET deur_rectbls->qual[cnt].parent[1].person_column = my_p_person_id
   SET deur_rectbls->qual[cnt].parent[1].child_column = my_p_child_column
   SET deur_rectbls->qual[cnt].p_cnt = 1
  ENDIF
  IF ((cnt > deur_rectbls->qual_cnt))
   SET deur_rectbls->qual_cnt = cnt
  ENDIF
 END ;Subroutine
 SUBROUTINE deur_sub_update(p_xxx)
   IF (p_xxx)
    FOR (i_ndx = 1 TO deur_rectbls->qual_cnt)
      IF ((deur_rectbls->qual[i_ndx].table_exists_ind IN (deur_rec->not_set, deur_rec->table_found)))
       SET deur_rec->entity_name = deur_rectbls->qual[i_ndx].table_name
       SET deur_rec->pk_column = deur_rectbls->qual[i_ndx].pk_column
       SET cnt = 0
       FOR (pc_ndx = 1 TO deur_recst->qual_cnt)
         FOR (pcd_ndx = 1 TO deur_recst->qual[pc_ndx].pcd_cnt)
           FOR (t_ndx = 1 TO deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_cnt)
             IF ((deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].entity_name=deur_rec->
             entity_name)
              AND (deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].update_flag=true))
              IF ((deur_recst->qual[pc_ndx].encntr_id_update_flag=true))
               IF ((deur_recst->qual[pc_ndx].new_person_id != deur_recst->qual[pc_ndx].pcd_qual[
               pcd_ndx].parent_person_id))
                SET deur_rec->stat = deur_sub_trigger_action(deur_rec->entity_name,"DISABLE")
               ENDIF
               SET deur_recsel->complete_str = concat("update into ",deur_rec->entity_name," u",
                "  set u.",deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].attribute_name,
                " = ",build(deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].parent_person_id),"  where u.",
                deur_rec->pk_column," = ",
                build(deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].entity_id),
                "  with status(deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].status",
                " ,deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].errnum",
                " ,deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].errmsg)",
                " , nocounter ")
               IF (debug_ind)
                CALL echo(build("pc_ndx: ",pc_ndx,"; pcd_ndx: ",pcd_ndx,"; t_ndx: ",
                  t_ndx))
                CALL echo(build("deur_recst->qual[pc_ndx].to_person_id: ",deur_recst->qual[pc_ndx].
                  to_person_id))
                CALL echo(build("deur_recst->qual[pc_ndx].from_person_id: ",deur_recst->qual[pc_ndx].
                  from_person_id))
                CALL echo(build("deur_recst->qual[pc_ndx].new_person_id: ",deur_recst->qual[pc_ndx].
                  new_person_id))
                CALL echo(build("deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].parent_person_id: ",
                  deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].parent_person_id))
                CALL deur_sub_echo(deur_recsel->complete_str)
               ENDIF
               CALL parser(concat(deur_recsel->complete_str," go"))
               IF ((deur_rec->commit_flag=deur_rec->commit_int))
                COMMIT
               ELSEIF ((deur_rec->commit_flag=deur_rec->rollback_int))
                ROLLBACK
               ENDIF
               IF ((deur_recst->qual[pc_ndx].new_person_id != deur_recst->qual[pc_ndx].pcd_qual[
               pcd_ndx].parent_person_id))
                SET deur_rec->stat = deur_sub_trigger_action(deur_rec->entity_name,"ENABLE")
               ENDIF
              ENDIF
              IF ((((deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].status=true)) OR ((
              deur_recst->qual[pc_ndx].encntr_id_update_flag=false))) )
               IF (debug_ind)
                CALL echo("")
                CALL echo("Values used for current insert/select are: ")
                CALL echo(build("pc_ndx: ",pc_ndx,"; pcd_ndx: ",pcd_ndx,"; t_ndx: ",
                  t_ndx))
                CALL echo(concat("Child entity_name    : ",deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx]
                  .tbl_qual[t_ndx].entity_name))
                CALL echo(concat("Child entity_id      : ",build(deur_recst->qual[pc_ndx].pcd_qual[
                   pcd_ndx].tbl_qual[t_ndx].entity_id)))
                CALL echo(concat("cs327_update_cd      : ",build(deur_rec->cs327_update_cd)))
                CALL echo(concat("Child attribute_name : ",deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx]
                  .tbl_qual[t_ndx].attribute_name))
                CALL echo(concat("Parent entity_id     : ",build(deur_recst->qual[pc_ndx].pcd_qual[
                   pcd_ndx].entity_id)))
                CALL echo(concat("Parent entity_name   : ",build(deur_recst->qual[pc_ndx].pcd_qual[
                   pcd_ndx].entity_name)))
                CALL echo(concat("Updt_dt_tm           : ",format(deur_recst->qual[pc_ndx].updt_dt_tm,
                   ";;q")))
               ENDIF
               CALL echo(fillstring(80,"*"))
               CALL echo(
                "Performing insert/select to add the current encounter move in the person_combine_detail table."
                )
               CALL echo(fillstring(80,"*"))
               INSERT  FROM person_combine_det d
                (d.person_combine_det_id, d.person_combine_id, d.updt_cnt,
                d.updt_dt_tm, d.updt_id, d.updt_task,
                d.updt_applctx, d.active_ind, d.active_status_cd,
                d.active_status_dt_tm, d.active_status_prsnl_id, d.entity_name,
                d.entity_id, d.combine_action_cd, d.attribute_name,
                d.prev_active_ind, d.prev_active_status_cd, d.prev_end_eff_dt_tm,
                d.combine_desc_cd, d.to_record_ind)(SELECT
                 seq(person_combine_seq,nextval), pc.person_combine_id, 0,
                 cnvtdatetime(curdate,curtime3), 0.0, 0,
                 0, pc.active_ind, pc.active_status_cd,
                 cnvtdatetime(curdate,curtime3), 0.0, deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].
                 tbl_qual[t_ndx].entity_name,
                 deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].entity_id, deur_rec->
                 cs327_update_cd, deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].
                 attribute_name,
                 0, 0.0, null,
                 0, 0
                 FROM person_combine pc,
                  person_combine_det pcd2
                 WHERE (pcd2.entity_id=deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].entity_id)
                  AND (pcd2.entity_name=deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].entity_name)
                  AND pc.person_combine_id=pcd2.person_combine_id
                  AND pc.updt_dt_tm=cnvtdatetime(deur_recst->qual[pc_ndx].updt_dt_tm)
                  AND  NOT ( EXISTS (
                 (SELECT
                  pcd3.person_combine_det_id
                  FROM person_combine_det pcd3
                  WHERE pcd3.person_combine_id=pcd2.person_combine_id
                   AND (pcd3.entity_name=deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].
                  entity_name)
                   AND (pcd3.entity_id=deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].
                  entity_id)
                   AND (pcd3.attribute_name=deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx
                  ].attribute_name)
                   AND pcd3.updt_dt_tm >= cnvtdatetime(deur_recst->qual[pc_ndx].updt_dt_tm)))))
               ;end insert
               CALL echo(fillstring(80,"*"))
               CALL echo(
                "Performing insert/select to add information for person combines done after the encounter move."
                )
               CALL echo(fillstring(80,"*"))
               INSERT  FROM person_combine_det d
                (d.person_combine_det_id, d.person_combine_id, d.updt_cnt,
                d.updt_dt_tm, d.updt_id, d.updt_task,
                d.updt_applctx, d.active_ind, d.active_status_cd,
                d.active_status_dt_tm, d.active_status_prsnl_id, d.entity_name,
                d.entity_id, d.combine_action_cd, d.attribute_name,
                d.prev_active_ind, d.prev_active_status_cd, d.prev_end_eff_dt_tm,
                d.combine_desc_cd, d.to_record_ind)(SELECT
                 seq(person_combine_seq,nextval), pc.person_combine_id, 0,
                 cnvtdatetime(curdate,curtime3), 0.0, 0,
                 0, pc.active_ind, pc.active_status_cd,
                 cnvtdatetime(curdate,curtime3), 0.0, deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].
                 tbl_qual[t_ndx].entity_name,
                 deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].entity_id, deur_rec->
                 cs327_update_cd, deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].
                 attribute_name,
                 0, 0.0, null,
                 0, 0
                 FROM person_combine pc,
                  person_combine_det pcd2
                 WHERE pc.updt_dt_tm >= cnvtdatetime(deur_recst->qual[pc_ndx].updt_dt_tm)
                  AND pc.encntr_id=0
                  AND pc.active_ind=1
                  AND pcd2.person_combine_id=pc.person_combine_id
                  AND (pcd2.entity_id=deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].entity_id)
                  AND (pcd2.entity_name=deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].entity_name)
                  AND  NOT ( EXISTS (
                 (SELECT
                  pcd3.person_combine_det_id
                  FROM person_combine_det pcd3
                  WHERE pcd3.person_combine_id=pcd2.person_combine_id
                   AND pcd3.entity_id=pcd2.entity_id
                   AND (pcd3.entity_name=deur_recst->qual[pc_ndx].pcd_qual[pcd_ndx].tbl_qual[t_ndx].
                  entity_name)))))
               ;end insert
               IF (curqual)
                SET cnt = (cnt+ 1)
               ENDIF
               IF ((deur_rec->commit_flag=deur_rec->commit_int))
                COMMIT
               ELSEIF ((deur_rec->commit_flag=deur_rec->rollback_int))
                ROLLBACK
               ENDIF
              ENDIF
             ENDIF
           ENDFOR
         ENDFOR
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE deur_sub_write_rpt(p_int1)
  IF (p_int1)
   SET deur_recsel->str = " "
   IF ((deur_recrpt->pc_cnt=0))
    SET deur_rec->stat = alterlist(deur_recrpt->pc_qual,1)
    SET deur_rec->stat = alterlist(deur_recrpt->pc_qual[1].qual,1)
    SET deur_recrpt->pc_qual_max_cnt = 1
    SET deur_recrpt->pc_cnt = 1
    SET deur_recrpt->pc_qual[1].qual_cnt = 1
    SET deur_recsel->str = "NULLREPORT"
   ENDIF
   IF ((deur_recrpt->pc_qual_max_cnt=0))
    SET deur_recrpt->pc_qual_max_cnt = 1
    SET deur_rec->stat = alterlist(deur_recrpt->pc_qual[1].qual,1)
    SET deur_recsel->str = "NULLREPORT"
   ENDIF
   SET deur_rec->rptfile = "ccluserdir:dm_em_rpt.dat"
   SET deur_rec->fname = deur_rec->rptfile
   IF (findfile(deur_rec->rptfile)=1)
    SET deur_rec->fprefix = "ccluserdir:dm_em_rpt_"
    SET deur_rec->fext = ".dat"
    WHILE ((deur_rec->fini=0))
      SET deur_rec->unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,
          curtime3),cnvtdatetime(curdate,000000)) * 864000)))
      SET deur_rec->fname = cnvtlower(build(deur_rec->fprefix,deur_rec->unique_tempstr,deur_rec->fext
        ))
      IF (findfile(deur_rec->fname)=0)
       SET deur_rec->fini = 1
      ENDIF
    ENDWHILE
    IF ((deur_rec->rptfile != deur_rec->fname))
     SET deur_rec->rptfile = deur_rec->fname
    ENDIF
   ENDIF
   IF ((deur_recrpt->pc_cnt > 0))
    CALL echo(fillstring(80,"*"))
    CALL echo(concat("Generating report file to ",deur_rec->rptfile,"."))
    CALL echo(fillstring(80,"*"))
    SET logical f1 value(deur_rec->rptfile)
    SELECT INTO "f1"
     order_col1 = deur_recrpt->pc_qual[d1.seq].sort_id, encntr_id = deur_recrpt->pc_qual[d1.seq].
     encntr_id
     FROM (dummyt d1  WITH seq = value(deur_recrpt->pc_cnt)),
      (dummyt d2  WITH seq = value(deur_recrpt->pc_qual_max_cnt))
     PLAN (d1
      WHERE d1.seq > 0
       AND (deur_recrpt->pc_qual[d1.seq].encntr_id_update_flag=true))
      JOIN (d2
      WHERE (d2.seq <= deur_recrpt->pc_qual[d1.seq].qual_cnt))
     ORDER BY deur_recrpt->pc_qual[d1.seq].encntr_id, order_col1
     HEAD REPORT
      IF (cursys="AIX")
       deur_rec->rptfile = replace(deur_rec->rptfile,":","/",0)
      ENDIF
      row 1, col 1, "File is: ",
      deur_rec->rptfile, row + 2
      IF ((deur_recsel->str="NULLREPORT"))
       row + 1, col 1, "No existing problems found."
      ENDIF
      recst_ndx = 0, rpt_start = 0
     HEAD encntr_id
      IF (size(trim(deur_recrpt->pc_qual[d1.seq].table_str)) > 0)
       row + 1, col 1, deur_recrpt->pc_qual[d1.seq].table_str,
       row + 1
      ELSE
       deur_recsel->str = " ", deur_recrpt->rpt_encntr_str = " ", deur_recrpt->rpt_new_encntr_str =
       " ",
       deur_recrpt->rpt_new_person_str = " ", recst_ndx = deur_recrpt->pc_qual[d1.seq].recst_ndx,
       deur_recsel->str = rpt_encntr_def,
       deur_recsel->str = replace(deur_recsel->str,"XXX_ENCNTR_ID",build(floor(deur_recst->qual[
          recst_ndx].encntr_id)),0), deur_recsel->str = replace(deur_recsel->str,"XXX_FROM_PERSON_ID",
        build(floor(deur_recst->qual[recst_ndx].from_person_id)),0), deur_recsel->str = replace(
        deur_recsel->str,"XXX_TO_PERSON_ID",build(floor(deur_recst->qual[recst_ndx].to_person_id)),0),
       deur_recrpt->rpt_encntr_str = deur_recsel->str
       IF ((deur_recst->qual[recst_ndx].new_encntr_id != deur_recst->qual[recst_ndx].encntr_id))
        deur_recsel->str = rpt_new_encntr_def, deur_recsel->str = replace(deur_recsel->str,
         "XXX_ENCNTR_ID",build(floor(deur_recst->qual[recst_ndx].encntr_id)),0), deur_recsel->str =
        replace(deur_recsel->str,"XXX_NEW_ENCNTR_ID",build(floor(deur_recst->qual[recst_ndx].
           new_encntr_id)),0),
        deur_recrpt->rpt_new_encntr_str = deur_recsel->str
       ENDIF
       IF ((deur_recst->qual[recst_ndx].new_person_id != deur_recst->qual[recst_ndx].to_person_id))
        deur_recsel->str = rpt_new_person_def, deur_recsel->str = replace(deur_recsel->str,
         "XXX_TO_PERSON_ID",build(floor(deur_recst->qual[recst_ndx].to_person_id)),0), deur_recsel->
        str = replace(deur_recsel->str,"XXX_NEW_PERSON_ID",build(floor(deur_recst->qual[recst_ndx].
           new_person_id)),0),
        deur_recrpt->rpt_new_person_str = deur_recsel->str
       ENDIF
       deur_recsel->str = rpt_person_def, deur_recsel->str = replace(deur_recsel->str,
        "XXX_NEW_PERSON_ID",build(floor(deur_recst->qual[recst_ndx].new_person_id)),0), deur_recrpt->
       rpt_person_str = deur_recsel->str,
       col 1, deur_recrpt->rpt_encntr_str
       IF (size(trim(deur_recrpt->rpt_new_encntr_str,5)) > 0)
        row + 1, col 1, deur_recrpt->rpt_new_encntr_str
       ENDIF
       IF (size(trim(deur_recrpt->rpt_new_person_str,5)) > 0)
        row + 1, col 1, deur_recrpt->rpt_new_person_str
       ENDIF
       pcd_cnt = deur_recst->qual[recst_ndx].pcd_cnt
       FOR (pcd_ndx = 1 TO pcd_cnt)
        tbl_cnt = deur_recst->qual[recst_ndx].pcd_qual[pcd_ndx].tbl_cnt,
        FOR (tbl_ndx = 1 TO tbl_cnt)
          qual_ndx = deur_recst->qual[recst_ndx].pcd_qual[pcd_ndx].tbl_qual[tbl_ndx].qual_ndx
          IF (tbl_ndx=1)
           deur_recsel->str = p_table_def2, deur_recsel->str = replace(deur_recsel->str,
            "XXX_PARENT_TABLE",trim(deur_recst->qual[recst_ndx].pcd_qual[pcd_ndx].entity_name),0),
           deur_recsel->str = replace(deur_recsel->str,"XXX_P_COL_NAME",trim(deur_rectbls->qual[
             qual_ndx].parent_column),0),
           deur_recsel->str = replace(deur_recsel->str,"XXX_P_COL_VALUE",build(floor(deur_recst->
              qual[recst_ndx].pcd_qual[pcd_ndx].entity_id)),0)
           IF ((deur_recst->qual[recst_ndx].pcd_qual[pcd_ndx].parent_person_id > 0))
            deur_recsel->str = replace(deur_recsel->str,"XXX_PARENT_PERSON_ID",build(floor(deur_recst
               ->qual[recst_ndx].pcd_qual[pcd_ndx].parent_person_id)),0)
           ELSE
            deur_recsel->str = replace(deur_recsel->str,"XXX_PARENT_PERSON_ID",
             "<no person_id available>",0)
           ENDIF
           deur_recrpt->rpt_table_str2 = deur_recsel->str, row + 1, col 1,
           deur_recrpt->rpt_table_str2
          ENDIF
          deur_recsel->str = c_table_def, deur_recsel->str = replace(deur_recsel->str,
           "XXX_CHILD_TABLE",trim(deur_recst->qual[recst_ndx].pcd_qual[pcd_ndx].tbl_qual[tbl_ndx].
            entity_name),0), deur_recsel->str = replace(deur_recsel->str,"XXX_C_COL_VALUE",build(
            floor(deur_recst->qual[recst_ndx].pcd_qual[pcd_ndx].tbl_qual[tbl_ndx].entity_id)),0),
          deur_recsel->str = replace(deur_recsel->str,"XXX_C_COL_NAME",trim(deur_rectbls->qual[
            qual_ndx].pk_column),0), deur_recsel->str = replace(deur_recsel->str,"XXX_PARENT_TABLE",
           trim(deur_recst->qual[recst_ndx].pcd_qual[pcd_ndx].entity_name),0), deur_recsel->str =
          replace(deur_recsel->str,"XXX_CHILD_PERSON_ID",build(floor(deur_recst->qual[recst_ndx].
             pcd_qual[pcd_ndx].tbl_qual[tbl_ndx].child_person_id)),0),
          row + 1, col 1, deur_recsel->str
        ENDFOR
       ENDFOR
      ENDIF
     DETAIL
      row + 0
     FOOT  encntr_id
      row + 2
     WITH nocounter, maxcol = 200, nullreport,
      formfeed = none
    ;end select
   ENDIF
  ENDIF
  IF (curenv=0)
   FREE DEFINE rtl2
   DEFINE rtl2 "f1"
   SELECT
    rtl2t.line
    FROM rtl2t
    DETAIL
     deur_recsel->str = trim(rtl2t.line), row + 1, col 1,
     deur_recsel->str
    WITH nocounter, maxcol = 210
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE deur_sub_trigger_action(p_table_name,p_trigger_action)
   DECLARE table_ndx = i4
   DECLARE select_dt_tm = f8
   SET deur_rec->return_status = 1
   SET p_table_name = cnvtupper(p_table_name)
   SET p_trigger_action = cnvtupper(p_trigger_action)
   IF ((deur_rectrg->table_cnt > 0))
    SELECT INTO "nl:"
     d.table_name
     FROM (dummyt d  WITH seq = value(deur_rectrg->table_cnt))
     PLAN (d
      WHERE (deur_rectrg->table_qual[d.seq].table_name=p_table_name))
     DETAIL
      table_ndx = d.seq, select_dt_tm = deur_rectrg->table_qual[d.seq].select_dt_tm
     WITH nocounter
    ;end select
   ENDIF
   IF (((table_ndx=0) OR (datetimeadd(cnvtdatetime(select_dt_tm),- ((10/ 1440.))) >= cnvtdatetime(
    curdate,curtime3)
    AND (deur_rectrg->last_action_flag IN (deur_rec->enabled, 0)))) )
    SELECT INTO "nl:"
     ut.trigger_name
     FROM user_triggers ut
     WHERE ut.table_name=p_table_name
      AND ut.trigger_name="TRG_?CMB*"
     HEAD REPORT
      IF (table_ndx=0)
       table_ndx = (size(deur_rectrg->table_qual,5)+ 1), deur_rec->stat = alterlist(deur_rectrg->
        table_qual,table_ndx)
      ELSE
       deur_stat = alterlist(deur_rectrg->table_qual[table_ndx].trg_qual,0)
      ENDIF
      deur_rectrg->table_qual[table_ndx].table_name = cnvtupper(p_table_name), deur_rectrg->
      table_qual[table_ndx].select_dt_tm = cnvtdatetime(curdate,curtime3), trg_cnt = 0
     DETAIL
      trg_cnt = (trg_cnt+ 1)
      IF (mod(trg_cnt,10)=1)
       deur_stat = alterlist(deur_rectrg->table_qual[table_ndx].trg_qual,(trg_cnt+ 10))
      ENDIF
      deur_rectrg->table_qual[table_ndx].trg_qual[trg_cnt].trigger_name = ut.trigger_name,
      deur_rectrg->table_qual[table_ndx].trg_qual[trg_cnt].status = trim(ut.status)
     FOOT REPORT
      deur_rec->stat = alterlist(deur_rectrg->table_qual[table_ndx].trg_qual,trg_cnt), deur_rectrg->
      table_qual[table_ndx].trg_cnt = trg_cnt, deur_rectrg->table_cnt = table_ndx
    ;end select
   ENDIF
   SET deur_recsel->str = " "
   IF (table_ndx > 0)
    FOR (trg_cnt = 1 TO deur_rectrg->table_qual[table_ndx].trg_cnt)
      IF (trim(deur_rectrg->table_qual[table_ndx].trg_qual[trg_cnt].status)="ENABLED")
       SET deur_recsel->str = concat("RDB alter trigger ",deur_rectrg->table_qual[table_ndx].
        trg_qual[trg_cnt].trigger_name," ",p_trigger_action," GO")
       IF (i_debug_ind)
        CALL echo(concat("Executing parser statement: ",deur_recsel->str))
       ENDIF
       CALL parser(deur_recsel->str)
      ELSE
       IF (i_debug_ind)
        CALL echo(concat("Trigger ",deur_rectrg->table_qual[table_ndx].trg_qual[trg_cnt].trigger_name,
          " not already enabled.  Skipping."))
       ENDIF
      ENDIF
    ENDFOR
    IF (p_trigger_action="ENABLE")
     SET deur_rectrg->last_action_flag = deur_rec->enabled
    ELSE
     SET deur_rectrg->last_action_flag = deur_rec->disabled
    ENDIF
   ELSE
    CALL echo(concat("No combine triggers found for table: ",p_table_name))
   ENDIF
   RETURN(deur_rec->return_status)
 END ;Subroutine
 SUBROUTINE deur_sub_echo_record(p_recstr,p_filename)
   SET deur_rec->stat = 0
   SET deur_rec->stat = findfile(p_filename)
   IF ((deur_rec->stat=true))
    SET deur_rec->stat = remove(p_filename)
    IF ((deur_rec->stat=false))
     CALL echo(fillstring(80,"*"))
     CALL echo(concat("Unable to delete existing file ",p_filename))
     CALL echo(fillstring(80,"*"))
    ENDIF
   ENDIF
   CASE (cnvtupper(p_recstr))
    OF "DEUR_RECST":
     CALL echorecord(deur_recst,p_filename)
    OF "DEUR_RECTBLS":
     CALL echorecord(deur_rectbls,p_filename)
    OF "DEUR_RECRPT":
     CALL echorecord(deur_recrpt,p_filename)
   ENDCASE
 END ;Subroutine
#exit_program
END GO
