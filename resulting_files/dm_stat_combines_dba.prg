CREATE PROGRAM dm_stat_combines:dba
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 FREE RECORD prsnl_combine
 RECORD prsnl_combine(
   1 qual[*]
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 start_dt_tm = dq8
     2 end_dt_tm = dq8
     2 application_flag = i4
     2 operation_type = vc
     2 reverse_cmb_ind = i2
     2 from_create = dq8
     2 to_create = dq8
     2 description = vc
     2 person_combine_id = f8
 )
 DECLARE qualcnt = i4 WITH noconstant(0)
 DECLARE ds_begin_snapshot = dq8
 DECLARE ds_end_snapshot = dq8
 DECLARE ds_snapshot_type = vc WITH constant("COMBINES_DISCRETE.2")
 DECLARE ds_cnt = i4 WITH protect, noconstant(0)
 DECLARE ds_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE stat_seq = f8
 DECLARE person_row_count = i4 WITH noconstant(0)
 DECLARE person_table_count = i4 WITH noconstant(0)
 DECLARE prsnl_row_count = i4 WITH noconstant(0)
 DECLARE prsnl_table_count = i4 WITH noconstant(0)
 DECLARE prev_entity_name = vc WITH noconstant("")
 DECLARE prsnl_data_ind = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE dsvm_error(msg=vc) = null
 SET ds_begin_snapshot = cnvtdatetime((curdate - 1),0)
 SET ds_end_snapshot = cnvtdatetime((curdate - 1),235959)
 SET stat_seq = 0
 SET ds_cnt = 1
 SET ds_cnt2 = 1
 SUBROUTINE dsvm_error(msg)
  DECLARE dsvm_err_msg = c132
  IF (error(dsvm_err_msg,0) > 0)
   ROLLBACK
   CALL esmerror(concat("Error: ",msg," ",dsvm_err_msg),esmexit)
  ENDIF
 END ;Subroutine
 SET field_exists = checkdic("PERSON_COMBINE.UCB_DT_TM","A",0)
 SET table_exists = checkdic("DM_COMBINE_AUDIT","T",0)
 IF (field_exists=2)
  IF (table_exists=2)
   SELECT INTO "nl:"
    dca.start_dt_tm, dca.end_dt_tm, dca.application_flag,
    dca.operation_type, dca.reverse_cmb_ind, from_create = pf.create_dt_tm,
    to_create = pt.create_dt_tm, dm.description, to_type = pt.person_type_cd,
    from_type = pf.person_type_cd, table_count = count(DISTINCT pcd.entity_name), row_count = count(
     pcd.person_combine_id)
    FROM dm_combine_audit dca,
     person pt,
     person pf,
     dm_flags dm,
     person_combine_det pcd
    WHERE dca.log_level=1
     AND dca.parent_entity_name="PERSON"
     AND dca.end_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     AND dm.flag_value=outerjoin(dca.application_flag)
     AND dm.table_name=outerjoin("DM_COMBINE_AUDIT")
     AND dm.column_name=outerjoin("APPLICATION_FLAG")
     AND pcd.person_combine_id=dca.parent_entity_id
     AND dca.to_entity_id=pt.person_id
     AND dca.from_entity_id=pf.person_id
     AND  NOT ( EXISTS (
    (SELECT
     1
     FROM dm_combine_audit dcap
     WHERE dcap.log_level=1
      AND dcap.parent_entity_name="PRSNL"
      AND dcap.end_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
      AND dcap.combine_group_id=dca.combine_group_id)))
    GROUP BY dca.start_dt_tm, dca.end_dt_tm, dca.application_flag,
     dca.operation_type, dca.reverse_cmb_ind, pf.create_dt_tm,
     pt.create_dt_tm, dm.description, pt.person_type_cd,
     pf.person_type_cd
    HEAD REPORT
     IF (ds_cnt=1)
      qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
       = cnvtdatetime(ds_begin_snapshot),
      dsr->qual[qualcnt].snapshot_type = ds_snapshot_type
     ENDIF
     stat_seq = 0
    DETAIL
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     stat_seq = (stat_seq+ 1)
     IF (dca.operation_type="COMBINE")
      combine_ind = 1, uncombine_ind = 0, combine_time = datetimediff(dca.end_dt_tm,dca.start_dt_tm,5
       ),
      uncombine_time = - (1)
     ELSEIF (dca.operation_type="UNCOMBINE")
      combine_ind = 0, uncombine_ind = 1, combine_time = - (1),
      uncombine_time = datetimediff(dca.end_dt_tm,dca.start_dt_tm,5)
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "PERSON_COMBINES_DISCRETE", dsr->qual[qualcnt].qual[
     ds_cnt].stat_seq = stat_seq, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(dca
      .application_flag,"||",combine_ind,"||",uncombine_ind,
      "||",dca.reverse_cmb_ind,"||",combine_time,"||",
      uncombine_time,"||",datetimediff(dca.end_dt_tm,from_create,5),"||",datetimediff(dca.end_dt_tm,
       to_create,5),
      "||",uar_get_code_display(to_type),"||",uar_get_code_meaning(to_type),"||",
      to_type,"||",uar_get_code_display(from_type),"||",uar_get_code_meaning(from_type),
      "||",from_type,"||",table_count,"||",
      row_count,"||",dm.description),
     ds_cnt = (ds_cnt+ 1)
    FOOT REPORT
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     IF (stat_seq=0)
      stat_seq = (stat_seq+ 1), dsr->qual[qualcnt].qual[ds_cnt].stat_name =
      "PERSON_COMBINES_DISCRETE", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
      dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", ds_cnt = (ds_cnt+ 1)
     ENDIF
    WITH nocounter, nullreport
   ;end select
   CALL dsvm_error("COMBINES_DISCRETE - PERSON_COMBINES_DISCRETE- NEW WAY")
   SELECT INTO "nl:"
    dca.parent_entity_name, dca.parent_entity_id, dca.start_dt_tm,
    dca.end_dt_tm, dca.application_flag, dca.operation_type,
    dca.reverse_cmb_ind, from_create = pf.create_dt_tm, to_create = pt.create_dt_tm,
    dm.description, dca.combine_group_id
    FROM dm_combine_audit dca,
     prsnl pt,
     prsnl pf,
     dm_flags dm,
     dm_combine_audit dca2
    WHERE dca.log_level=1
     AND dca.parent_entity_name="PRSNL"
     AND dca.end_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     AND dm.flag_value=outerjoin(dca.application_flag)
     AND dm.table_name=outerjoin("DM_COMBINE_AUDIT")
     AND dm.column_name=outerjoin("APPLICATION_FLAG")
     AND dca.to_entity_id=pt.person_id
     AND dca.from_entity_id=pf.person_id
     AND dca.combine_group_id=dca2.combine_group_id
     AND dca2.log_level=1
     AND dca2.parent_entity_name="PERSON"
    HEAD REPORT
     ds_cnt2 = 1
    DETAIL
     IF (mod(ds_cnt2,10)=1)
      stat = alterlist(prsnl_combine->qual,(ds_cnt2+ 9))
     ENDIF
     prsnl_combine->qual[ds_cnt2].parent_entity_name = dca.parent_entity_name, prsnl_combine->qual[
     ds_cnt2].start_dt_tm = dca.start_dt_tm, prsnl_combine->qual[ds_cnt2].end_dt_tm = dca.end_dt_tm,
     prsnl_combine->qual[ds_cnt2].application_flag = dca.application_flag, prsnl_combine->qual[
     ds_cnt2].operation_type = dca.operation_type, prsnl_combine->qual[ds_cnt2].reverse_cmb_ind = dca
     .reverse_cmb_ind,
     prsnl_combine->qual[ds_cnt2].from_create = from_create, prsnl_combine->qual[ds_cnt2].to_create
      = to_create, prsnl_combine->qual[ds_cnt2].description = dm.description,
     prsnl_combine->qual[ds_cnt2].person_combine_id = dca2.parent_entity_id, ds_cnt2 = (ds_cnt2+ 1)
    FOOT REPORT
     stat = alterlist(prsnl_combine->qual,(ds_cnt2 - 1))
    WITH nocounter
   ;end select
   IF (size(prsnl_combine->qual,5) > 0)
    SELECT INTO "nl:"
     p.entity_name, c.entity_name
     FROM person_combine_det p,
      combine_detail c,
      (dummyt d  WITH seq = size(prsnl_combine->qual,5))
     PLAN (d)
      JOIN (p
      WHERE (p.person_combine_id=prsnl_combine->qual[d.seq].person_combine_id))
      JOIN (c
      WHERE outerjoin(p.entity_id)=c.combine_id
       AND outerjoin(prsnl_combine->qual[d.seq].parent_entity_id)=c.combine_id)
     ORDER BY p.entity_name, c.entity_name
     HEAD REPORT
      IF (ds_cnt=1)
       qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
       stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot),
       dsr->qual[qualcnt].snapshot_type = ds_snapshot_type
      ENDIF
      stat_seq = 0
     HEAD p.entity_name
      prsnl_table_count = (prsnl_table_count+ 1)
     HEAD c.entity_name
      prsnl_table_count = (prsnl_table_count+ 1)
     DETAIL
      prsnl_row_count = (prsnl_row_count+ 1)
     FOOT REPORT
      IF (mod(ds_cnt,10)=1)
       stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      ENDIF
      stat_seq = (stat_seq+ 1)
      IF ((prsnl_combine->qual[d.seq].operation_type="COMBINE"))
       combine_ind = 1, uncombine_ind = 0, combine_time = datetimediff(prsnl_combine->qual[d.seq].
        end_dt_tm,prsnl_combine->qual[d.seq].start_dt_tm,5),
       uncombine_time = - (1)
      ELSEIF ((prsnl_combine->qual[d.seq].operation_type="UNCOMBINE"))
       combine_ind = 0, uncombine_ind = 1, combine_time = - (1),
       uncombine_time = datetimediff(prsnl_combine->qual[d.seq].end_dt_tm,prsnl_combine->qual[d.seq].
        start_dt_tm,5)
      ENDIF
      dsr->qual[qualcnt].qual[ds_cnt].stat_name = "PRSNL_COMBINES_DISCRETE", dsr->qual[qualcnt].qual[
      ds_cnt].stat_seq = stat_seq, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(
       prsnl_combine->qual[d.seq].application_flag,"||",combine_ind,"||",uncombine_ind,
       "||",prsnl_combine->qual[d.seq].reverse_cmb_ind,"||",combine_time,"||",
       uncombine_time,"||",datetimediff(prsnl_combine->qual[d.seq].end_dt_tm,prsnl_combine->qual[d
        .seq].from_create,5),"||",datetimediff(prsnl_combine->qual[d.seq].end_dt_tm,prsnl_combine->
        qual[d.seq].to_create,5),
       "||",prsnl_combine->qual[d.seq].description,"||",prsnl_table_count,"||",
       prsnl_row_count),
      ds_cnt = (ds_cnt+ 1)
     WITH nocounter
    ;end select
   ELSE
    IF (ds_cnt=1)
     SET qualcnt = (qualcnt+ 1)
     SET stat = alterlist(dsr->qual,qualcnt)
     SET dsr->qual[qualcnt].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot)
     SET dsr->qual[qualcnt].snapshot_type = ds_snapshot_type
    ENDIF
    IF (mod(ds_cnt,10)=1)
     SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    SET stat_seq = (stat_seq+ 1)
    SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = "PRSNL_COMBINES_DISCRETE"
    SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
    SET dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA"
    SET ds_cnt = (ds_cnt+ 1)
   ENDIF
   CALL dsvm_error("COMBINES_DISCRETE - PRSNL_COMBINES_DISCRETE- NEW WAY")
   SELECT INTO "nl:"
    dca.start_dt_tm, dca.end_dt_tm, dca.application_flag,
    dca.operation_type, dca.reverse_cmb_ind, from_create = ef.create_dt_tm,
    to_create = et.create_dt_tm, dm.description, table_count = count(DISTINCT ecd.entity_name),
    row_count = count(ecd.encntr_combine_id)
    FROM dm_combine_audit dca,
     encounter et,
     encounter ef,
     dm_flags dm,
     encntr_combine_det ecd
    WHERE dca.log_level=1
     AND dca.parent_entity_name="ENCOUNTER"
     AND dca.end_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)
     AND dm.flag_value=outerjoin(dca.application_flag)
     AND dm.table_name=outerjoin("DM_COMBINE_AUDIT")
     AND dm.column_name=outerjoin("APPLICATION_FLAG")
     AND ecd.encntr_combine_id=dca.parent_entity_id
     AND dca.to_entity_id=et.encntr_id
     AND dca.from_entity_id=ef.encntr_id
    GROUP BY dca.start_dt_tm, dca.end_dt_tm, dca.application_flag,
     dca.operation_type, dca.reverse_cmb_ind, ef.create_dt_tm,
     et.create_dt_tm, dm.description
    HEAD REPORT
     IF (ds_cnt=1)
      qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
       = cnvtdatetime(ds_begin_snapshot),
      dsr->qual[qualcnt].snapshot_type = ds_snapshot_type
     ENDIF
     stat_seq = 0
    DETAIL
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     stat_seq = (stat_seq+ 1)
     IF (dca.operation_type="COMBINE")
      combine_ind = 1, uncombine_ind = 0, combine_time = datetimediff(dca.end_dt_tm,dca.start_dt_tm,5
       ),
      uncombine_time = - (1)
     ELSEIF (dca.operation_type="UNCOMBINE")
      combine_ind = 0, uncombine_ind = 1, combine_time = - (1),
      uncombine_time = datetimediff(dca.end_dt_tm,dca.start_dt_tm,5)
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "ENCOUNTER_COMBINES_DISCRETE", dsr->qual[qualcnt].
     qual[ds_cnt].stat_seq = stat_seq, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(dca
      .application_flag,"||",combine_ind,"||",uncombine_ind,
      "||",dca.reverse_cmb_ind,"||",combine_time,"||",
      uncombine_time,"||",datetimediff(dca.end_dt_tm,from_create,5),"||",datetimediff(dca.end_dt_tm,
       to_create,5),
      "||",dm.description,"||",table_count,"||",
      row_count),
     ds_cnt = (ds_cnt+ 1)
    FOOT REPORT
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     IF (stat_seq=0)
      stat_seq = (stat_seq+ 1), dsr->qual[qualcnt].qual[ds_cnt].stat_name =
      "ENCOUNTER_COMBINES_DISCRETE", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
      dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", ds_cnt = (ds_cnt+ 1)
     ENDIF
    WITH nocounter, nullreport
   ;end select
   CALL dsvm_error("COMBINES_DISCRETE - ENCOUNTER_COMBINES_DISCRETE - NEW WAY")
  ELSE
   SELECT INTO "nl:"
    pc.application_flag, format(cnvtdatetime(pc.active_status_dt_tm),";;q"), format(cnvtdatetime(pc
      .updt_dt_tm),";;q"),
    cd.entity_name, cd.column_name, from_create = format(cnvtdatetime(pf.create_dt_tm),";;q"),
    to_create = format(cnvtdatetime(pt.create_dt_tm),";;q"), dm.description, to_type = pt
    .person_type_cd,
    from_type = pf.person_type_cd, pc.cmb_dt_tm, pc.ucb_dt_tm,
    pcd.entity_name, pcd.person_combine_id, pcd.entity_id
    FROM combine_det_value cd,
     person_combine pc,
     person pf,
     person pt,
     dm_flags dm,
     person_combine_det pcd
    WHERE cd.combine_id=outerjoin(pc.person_combine_id)
     AND cd.entity_id=outerjoin(pc.to_person_id)
     AND cd.entity_name=outerjoin("PERSON")
     AND cd.column_name=outerjoin("PERSON_ID")
     AND cd.combine_parent=outerjoin("PERSON_COMBINE")
     AND ((pc.cmb_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
     OR (pc.ucb_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)))
     AND pc.updt_dt_tm >= cnvtdatetime(ds_begin_snapshot)
     AND pc.to_person_id=pt.person_id
     AND pc.from_person_id=pf.person_id
     AND dm.flag_value=outerjoin(pc.application_flag)
     AND dm.table_name=outerjoin("PERSON_COMBINE")
     AND dm.column_name=outerjoin("APPLICATION_FLAG")
     AND pcd.person_combine_id=pc.person_combine_id
    ORDER BY pcd.person_combine_id, pcd.entity_name
    HEAD REPORT
     IF (ds_cnt=1)
      qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
       = cnvtdatetime(ds_begin_snapshot),
      dsr->qual[qualcnt].snapshot_type = ds_snapshot_type
     ENDIF
     stat_seq = 0, ds_cnt2 = 1
    HEAD pcd.person_combine_id
     prev_entity_name = "", person_table_count = 0, person_row_count = 0,
     exclude_flag = 0
    DETAIL
     IF (pcd.entity_name != "PRSNL_COMBINE")
      person_row_count = (person_row_count+ 1)
      IF (pcd.entity_name != prev_entity_name)
       person_table_count = (person_table_count+ 1)
      ENDIF
     ELSE
      IF (pcd.entity_name != prev_entity_name)
       stat = alterlist(prsnl_combine->qual,ds_cnt2), prsnl_combine->qual[ds_cnt2].parent_entity_id
        = pcd.entity_id, prsnl_combine->qual[ds_cnt2].person_combine_id = pcd.person_combine_id,
       ds_cnt2 = (ds_cnt2+ 1), exclude_flag = 1
      ENDIF
     ENDIF
     prev_entity_name = pcd.entity_name
    FOOT  pcd.person_combine_id
     IF (exclude_flag=0)
      IF (mod(ds_cnt,10)=1)
       stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      ENDIF
      stat_seq = (stat_seq+ 1)
      IF (pc.cmb_dt_tm >= cnvtdatetime(ds_begin_snapshot)
       AND pc.cmb_dt_tm <= cnvtdatetime(ds_end_snapshot))
       combine_ind = 1, uncombine_ind = 0, combine_time = datetimediff(pc.updt_dt_tm,pc
        .active_status_dt_tm,5),
       uncombine_time = - (1)
      ELSEIF (pc.ucb_dt_tm >= cnvtdatetime(ds_begin_snapshot)
       AND pc.ucb_dt_tm <= cnvtdatetime(ds_end_snapshot))
       combine_ind = 0, uncombine_ind = 1, combine_time = - (1),
       uncombine_time = datetimediff(pc.updt_dt_tm,pc.active_status_dt_tm,5)
      ENDIF
      IF (cd.entity_name="PERSON"
       AND cd.column_name="PERSON_ID")
       reverse_combine_ind = 1
      ELSE
       reverse_combine_ind = 0
      ENDIF
      dsr->qual[qualcnt].qual[ds_cnt].stat_name = "PERSON_COMBINES_DISCRETE", dsr->qual[qualcnt].
      qual[ds_cnt].stat_seq = stat_seq, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(pc
       .application_flag,"||",combine_ind,"||",uncombine_ind,
       "||",reverse_combine_ind,"||",combine_time,"||",
       uncombine_time,"||",datetimediff(pc.active_status_dt_tm,cnvtdatetime(from_create),5),"||",
       datetimediff(pc.active_status_dt_tm,cnvtdatetime(to_create),5),
       "||",dm.description,"||",uar_get_code_display(to_type),"||",
       uar_get_code_meaning(to_type),"||",to_type,"||",uar_get_code_display(from_type),
       "||",uar_get_code_meaning(from_type),"||",from_type,"||",
       person_table_count,"||",person_row_count),
      ds_cnt = (ds_cnt+ 1)
     ENDIF
    FOOT REPORT
     IF (stat_seq=0)
      IF (mod(ds_cnt,10)=1)
       stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
      ENDIF
      stat_seq = (stat_seq+ 1), dsr->qual[qualcnt].qual[ds_cnt].stat_name =
      "PERSON_COMBINES_DISCRETE", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
      dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", ds_cnt = (ds_cnt+ 1)
     ENDIF
    WITH nocounter, nullreport
   ;end select
   CALL dsvm_error("COMBINES_DISCRETE - PERSON_COMBINES_DISCRETE-OLD WAY")
   FOR (itr = 1 TO size(prsnl_combine->qual,5))
     SELECT INTO "nl:"
      c.application_flag, c.active_status_dt_tm, c.updt_dt_tm,
      from_create = pf.create_dt_tm, to_create = pt.create_dt_tm, dm.description,
      c.cmb_dt_tm, c.ucb_dt_tm, cd.combine_id,
      entity_name = cd.entity_name
      FROM combine c,
       prsnl pf,
       prsnl pt,
       dm_flags dm,
       person_combine_det pcd,
       combine_detail cd
      WHERE ((c.cmb_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
       OR (c.ucb_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)))
       AND c.to_id=pt.person_id
       AND c.from_id=pf.person_id
       AND c.parent_entity="PRSNL"
       AND dm.flag_value=outerjoin(c.application_flag)
       AND dm.table_name=outerjoin("COMBINE")
       AND dm.column_name=outerjoin("APPLICATION_FLAG")
       AND c.combine_id=pcd.entity_id
       AND pcd.entity_id=cd.combine_id
       AND (pcd.entity_id=prsnl_combine->qual[itr].parent_entity_id)
       AND ((pcd.entity_name="PRSNL_COMBINE") UNION ALL (
      (SELECT
       - (1), cnvtdatetime("01-JAN-1800"), sysdate,
       sysdate, sysdate, " ",
       sysdate, sysdate, prsnl_combine->qual[itr].parent_entity_id,
       endity_name = pcd.entity_name
       FROM person_combine_det pcd
       WHERE (pcd.person_combine_id=prsnl_combine->qual[itr].person_combine_id)
        AND pcd.entity_name != "PRSNL_COMBINE")))
      ORDER BY 10
      HEAD REPORT
       IF (ds_cnt=1)
        qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].
        stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot),
        dsr->qual[qualcnt].snapshot_type = ds_snapshot_type
       ENDIF
       prsnl_row_count = 0, prsnl_table_count = 0, dsr_populated_ind = 0,
       prsnl_data_ind = 1
      HEAD entity_name
       prsnl_table_count = (prsnl_table_count+ 1)
      DETAIL
       prsnl_row_count = (prsnl_row_count+ 1)
       IF (dsr_populated_ind=0
        AND cnvtdatetime(c.active_status_dt_tm) != cnvtdatetime("01-JAN-1800"))
        IF (mod(ds_cnt,10)=1)
         stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
        ENDIF
        stat_seq = (stat_seq+ 1)
        IF (c.cmb_dt_tm >= cnvtdatetime(ds_begin_snapshot)
         AND c.cmb_dt_tm <= cnvtdatetime(ds_end_snapshot))
         combine_ind = 1, uncombine_ind = 0, combine_time = datetimediff(c.updt_dt_tm,c
          .active_status_dt_tm,5),
         uncombine_time = - (1)
        ELSEIF (c.ucb_dt_tm >= cnvtdatetime(ds_begin_snapshot)
         AND c.ucb_dt_tm <= cnvtdatetime(ds_end_snapshot))
         combine_ind = 0, uncombine_ind = 1, combine_time = - (1),
         uncombine_time = datetimediff(c.updt_dt_tm,c.active_status_dt_tm,5)
        ENDIF
        dsr->qual[qualcnt].qual[ds_cnt].stat_name = "PRSNL_COMBINES_DISCRETE", dsr->qual[qualcnt].
        qual[ds_cnt].stat_seq = stat_seq, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(c
         .application_flag,"||",combine_ind,"||",uncombine_ind,
         "||",0,"||",combine_time,"||",
         uncombine_time,"||",datetimediff(c.active_status_dt_tm,cnvtdatetime(from_create),5),"||",
         datetimediff(c.active_status_dt_tm,cnvtdatetime(to_create),5),
         "||",dm.description),
        ds_cnt = (ds_cnt+ 1), dsr_populated_ind = 1
       ENDIF
      FOOT REPORT
       IF (dsr_populated_ind=1)
        dsr->qual[qualcnt].qual[(ds_cnt - 1)].stat_clob_val = build(dsr->qual[qualcnt].qual[(ds_cnt
          - 1)].stat_clob_val,"||",prsnl_table_count,"||",prsnl_row_count)
       ENDIF
      WITH nocounter, rdbunion
     ;end select
   ENDFOR
   IF (prsnl_data_ind=0)
    IF (mod(ds_cnt,10)=1)
     SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
    ENDIF
    SET stat_seq = (stat_seq+ 1)
    SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = "PRSNL_COMBINES_DISCRETE"
    SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
    SET dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA"
    SET ds_cnt = (ds_cnt+ 1)
   ENDIF
   CALL dsvm_error("COMBINES_DISCRETE - PRSNL_COMBINES_DISCRETE- OLD WAY")
   SELECT INTO "nl:"
    ec.application_flag, ec.active_status_dt_tm, ec.updt_dt_tm,
    from_create = ef.create_dt_tm, to_create = et.create_dt_tm, dm.description,
    ec.cmb_dt_tm, ec.ucb_dt_tm, table_count = count(DISTINCT ecd.entity_name),
    row_count = count(ecd.encntr_combine_id)
    FROM encntr_combine ec,
     encounter ef,
     encounter et,
     dm_flags dm,
     encntr_combine_det ecd
    WHERE ((ec.cmb_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot))
     OR (ec.ucb_dt_tm BETWEEN cnvtdatetime(ds_begin_snapshot) AND cnvtdatetime(ds_end_snapshot)))
     AND ec.updt_dt_tm >= cnvtdatetime(ds_begin_snapshot)
     AND ec.to_encntr_id=et.encntr_id
     AND ec.from_encntr_id=ef.encntr_id
     AND dm.flag_value=outerjoin(ec.application_flag)
     AND dm.table_name=outerjoin("ENCNTR_COMBINE")
     AND dm.column_name=outerjoin("APPLICATION_FLAG")
     AND ec.encntr_combine_id=ecd.encntr_combine_id
    GROUP BY ec.application_flag, ec.active_status_dt_tm, ec.updt_dt_tm,
     ef.create_dt_tm, et.create_dt_tm, dm.description,
     ec.cmb_dt_tm, ec.ucb_dt_tm
    HEAD REPORT
     IF (ds_cnt=1)
      qualcnt = (qualcnt+ 1), stat = alterlist(dsr->qual,qualcnt), dsr->qual[qualcnt].stat_snap_dt_tm
       = cnvtdatetime(ds_begin_snapshot),
      dsr->qual[qualcnt].snapshot_type = ds_snapshot_type
     ENDIF
     stat_seq = 0
    DETAIL
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     stat_seq = (stat_seq+ 1)
     IF (ec.cmb_dt_tm >= cnvtdatetime(ds_begin_snapshot)
      AND ec.cmb_dt_tm <= cnvtdatetime(ds_end_snapshot))
      combine_ind = 1, uncombine_ind = 0, combine_time = datetimediff(ec.updt_dt_tm,ec
       .active_status_dt_tm,5),
      uncombine_time = - (1)
     ELSEIF (ec.ucb_dt_tm >= cnvtdatetime(ds_begin_snapshot)
      AND ec.ucb_dt_tm <= cnvtdatetime(ds_end_snapshot))
      combine_ind = 0, uncombine_ind = 1, combine_time = - (1),
      uncombine_time = datetimediff(ec.updt_dt_tm,ec.active_status_dt_tm,5)
     ENDIF
     dsr->qual[qualcnt].qual[ds_cnt].stat_name = "ENCOUNTER_COMBINES_DISCRETE", dsr->qual[qualcnt].
     qual[ds_cnt].stat_seq = stat_seq, dsr->qual[qualcnt].qual[ds_cnt].stat_clob_val = build(ec
      .application_flag,"||",combine_ind,"||",uncombine_ind,
      "||",0,"||",combine_time,"||",
      uncombine_time,"||",datetimediff(ec.active_status_dt_tm,cnvtdatetime(from_create),5),"||",
      datetimediff(ec.active_status_dt_tm,cnvtdatetime(to_create),5),
      "||",dm.description,"||",table_count,"||",
      row_count),
     ds_cnt = (ds_cnt+ 1)
    FOOT REPORT
     IF (mod(ds_cnt,10)=1)
      stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 9))
     ENDIF
     IF (stat_seq=0)
      stat_seq = (stat_seq+ 1), dsr->qual[qualcnt].qual[ds_cnt].stat_name =
      "ENCOUNTER_COMBINES_DISCRETE", dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq,
      dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NO_NEW_DATA", ds_cnt = (ds_cnt+ 1)
     ENDIF
    WITH nocounter, nullreport
   ;end select
   CALL dsvm_error("COMBINES_DISCRETE - ENCOUNTER_COMBINES_DISCRETE - OLD WAY")
  ENDIF
  IF (mod(ds_cnt,10)=1)
   SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt+ 1))
  ENDIF
  SET dsr->qual[qualcnt].qual[ds_cnt].stat_name = "COLLECTION_METHOD"
  SET dsr->qual[qualcnt].qual[ds_cnt].stat_seq = stat_seq
  IF (table_exists=2)
   SET dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "NEW WAY"
  ELSE
   SET dsr->qual[qualcnt].qual[ds_cnt].stat_str_val = "OLD WAY"
  ENDIF
  SET ds_cnt = (ds_cnt+ 1)
  IF (qualcnt > 0)
   SET stat = alterlist(dsr->qual[qualcnt].qual,(ds_cnt - 1))
  ENDIF
 ELSE
  SET stat = alterlist(dsr->qual,1)
  SET dsr->qual[1].snapshot_type = ms_snapshot_type
  SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime(ds_begin_snapshot)
  SET stat = alterlist(dsr->qual[1].qual,1)
  SET dsr->qual[1].qual[1].stat_name = "CODEBASE_TOO_OLD"
 ENDIF
 EXECUTE dm_stat_snaps_load
 SET qualcnt = 0
 COMMIT
#exit_program
END GO
