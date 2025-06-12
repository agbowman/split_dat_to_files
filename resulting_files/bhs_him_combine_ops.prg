CREATE PROGRAM bhs_him_combine_ops
 PROMPT
  "OUTPUT TO FILE/PRINTER/MINE " = "MINE",
  "ENTER AN EMAIL ADDRESS OR REPORT" = "REPORT_VIEW "
  WITH outdev, email
 DECLARE var_output = vc
 DECLARE email_ind = i4
 SET email_ind = 0
 IF (findstring("@", $EMAIL) > 0)
  SET email_ind = 1
  SET var_output = "COMBINETESTING"
 ELSE
  SET email_ind = 0
  SET var_output =  $OUTDEV
 ENDIF
 RECORD cmb(
   1 c_cnt = i4
   1 combines[*]
     2 username = vc
     2 full_name = vc
     2 combine_type = vc
     2 combine_id = f8
     2 combine_dt_tm = vc
     2 from_person_id = f8
     2 from_person_name = vc
     2 from_cmrn = vc
     2 from_encntr_id = f8
     2 rad_order_ind = i2
     2 fa_cnt = i4
     2 from_aliases[*]
       3 alias_id = f8
       3 alias = vc
     2 to_person_id = f8
     2 to_person_name = vc
     2 to_cmrn = vc
     2 to_encntr_id = f8
     2 ta_cnt = i4
     2 to_aliases[*]
       3 alias_id = f8
       3 alias = vc
     2 move_encntr_id = f8
     2 move_encntr_fin = vc
 )
 SELECT INTO "NL:"
  pc.person_combine_id, username = substring(1,20,pr.username), full_name = substring(1,30,pr
   .name_full_formatted),
  combine_dt_tm = format(pc.updt_dt_tm,"DD-MMM-YYYY HH:MM:SS;;D"), pc.from_person_id,
  from_person_name = substring(1,30,p1.name_full_formatted),
  encntr_fin =
  IF (pc.encntr_id <= 0.00) "PERSON COMBINE      "
  ELSE substring(1,20,ea.alias)
  ENDIF
  , pc.to_person_id, to_person_name = substring(1,30,p2.name_full_formatted)
  FROM person_combine pc,
   prsnl pr,
   encntr_alias ea,
   person p1,
   person p2
  PLAN (pc
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),curtime3) AND cnvtdatetime(sysdate))
   JOIN (pr
   WHERE pc.updt_id=pr.person_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(pc.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(1077.00)) )
   JOIN (p1
   WHERE pc.from_person_id=p1.person_id)
   JOIN (p2
   WHERE pc.to_person_id=p2.person_id)
  ORDER BY pr.name_full_formatted, pc.updt_dt_tm
  HEAD REPORT
   c_cnt = 0
  HEAD pc.person_combine_id
   c_cnt = (cmb->c_cnt+ 1), stat = alterlist(cmb->combines,c_cnt), cmb->c_cnt = c_cnt,
   cmb->combines[c_cnt].username = pr.username, cmb->combines[c_cnt].full_name = pr
   .name_full_formatted
   IF (pc.encntr_id > 0.00)
    cmb->combines[c_cnt].combine_type = "ENCNTR_MOVE"
   ELSEIF (pc.active_ind=1)
    cmb->combines[c_cnt].combine_type = "PERSON_COMBINE"
   ELSE
    cmb->combines[c_cnt].combine_type = "PERSON_UNCOMBINE"
   ENDIF
   cmb->combines[c_cnt].combine_id = pc.person_combine_id, cmb->combines[c_cnt].combine_dt_tm =
   format(pc.updt_dt_tm,";;Q"), cmb->combines[c_cnt].from_person_id = pc.from_person_id,
   cmb->combines[c_cnt].from_person_name = p1.name_full_formatted, cmb->combines[c_cnt].to_person_id
    = pc.to_person_id, cmb->combines[c_cnt].to_person_name = p2.name_full_formatted,
   cmb->combines[c_cnt].move_encntr_id = pc.encntr_id, cmb->combines[c_cnt].move_encntr_fin = trim(
    encntr_fin,3)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM encntr_combine ec,
   prsnl pr,
   encounter e,
   person p,
   person_alias pa,
   encntr_combine_det ecd,
   encntr_alias ea1,
   encntr_alias ea2
  PLAN (ec
   WHERE ec.updt_dt_tm BETWEEN cnvtdatetime((curdate - 7),curtime3) AND cnvtdatetime(sysdate))
   JOIN (pr
   WHERE ec.updt_id=pr.person_id)
   JOIN (e
   WHERE ec.to_encntr_id=e.encntr_id)
   JOIN (p
   WHERE e.person_id=p.person_id)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.person_alias_type_cd=2.00)
   JOIN (ecd
   WHERE ec.encntr_combine_id=ecd.encntr_combine_id
    AND ecd.entity_name="ENCNTR_ALIAS")
   JOIN (ea1
   WHERE (ea1.encntr_alias_id= Outerjoin(ecd.entity_id))
    AND (ea1.encntr_alias_type_cd= Outerjoin(1077.00)) )
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(ec.to_encntr_id))
    AND (ea2.encntr_alias_type_cd= Outerjoin(1077.00)) )
  ORDER BY pr.name_full_formatted, ec.updt_dt_tm
  HEAD REPORT
   c_cnt = 0
  HEAD ec.encntr_combine_id
   c_cnt = (cmb->c_cnt+ 1), stat = alterlist(cmb->combines,c_cnt), cmb->c_cnt = c_cnt,
   cmb->combines[c_cnt].username = pr.username, cmb->combines[c_cnt].full_name = pr
   .name_full_formatted
   IF (ec.active_ind=1)
    cmb->combines[c_cnt].combine_type = "ENCNTR_COMBINE"
   ELSE
    cmb->combines[c_cnt].combine_type = "ENCNTR_UNCOMBINE"
   ENDIF
   cmb->combines[c_cnt].combine_id = ec.encntr_combine_id, cmb->combines[c_cnt].combine_dt_tm =
   build2(format(ec.updt_dt_tm,"MM/DD/YYYY;;D")," ",cnvtupper(format(ec.updt_dt_tm,"HH:MM;;S"))), cmb
   ->combines[c_cnt].from_person_id = p.person_id,
   cmb->combines[c_cnt].from_person_name = p.name_full_formatted, cmb->combines[c_cnt].from_encntr_id
    = ec.from_encntr_id, cmb->combines[c_cnt].from_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd),
   cmb->combines[c_cnt].fa_cnt = 1, stat = alterlist(cmb->combines[c_cnt].from_aliases,1), cmb->
   combines[c_cnt].from_aliases[1].alias_id = ea1.encntr_alias_id,
   cmb->combines[c_cnt].from_aliases[1].alias = ea1.alias, cmb->combines[c_cnt].to_person_id = p
   .person_id, cmb->combines[c_cnt].to_person_name = p.name_full_formatted,
   cmb->combines[c_cnt].to_encntr_id = ec.to_encntr_id, cmb->combines[c_cnt].to_cmrn = cnvtalias(pa
    .alias,pa.alias_pool_cd), cmb->combines[c_cnt].ta_cnt = 1,
   stat = alterlist(cmb->combines[c_cnt].to_aliases,1), cmb->combines[c_cnt].to_aliases[1].alias_id
    = ea2.encntr_alias_id, cmb->combines[c_cnt].to_aliases[1].alias = ea2.alias
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(cmb->c_cnt)),
   person_alias pa
  PLAN (d1
   WHERE (cmb->combines[d1.seq].combine_type="PERSON*")
    AND (cmb->combines[d1.seq].move_encntr_id=0.00))
   JOIN (pa
   WHERE (cmb->combines[d1.seq].to_person_id=pa.person_id)
    AND pa.person_alias_type_cd != 18
    AND ((pa.active_ind=1) OR (pa.end_effective_dt_tm >= cnvtdatetime(sysdate))) )
  HEAD REPORT
   ta_cnt = 0
  DETAIL
   IF (pa.person_alias_type_cd=2
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
    cmb->combines[d1.seq].to_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ELSE
    ta_cnt = (cmb->combines[d1.seq].ta_cnt+ 1), stat = alterlist(cmb->combines[d1.seq].to_aliases,
     ta_cnt), cmb->combines[d1.seq].ta_cnt = ta_cnt,
    cmb->combines[d1.seq].to_aliases[ta_cnt].alias_id = pa.person_alias_id, cmb->combines[d1.seq].
    to_aliases[ta_cnt].alias = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(cmb->c_cnt)),
   person_alias pa
  PLAN (d1
   WHERE (cmb->combines[d1.seq].combine_type="ENCNTR_MOVE")
    AND (cmb->combines[d1.seq].move_encntr_id > 0.00))
   JOIN (pa
   WHERE (cmb->combines[d1.seq].from_person_id=pa.person_id)
    AND pa.person_alias_type_cd != 18
    AND ((pa.active_ind=1) OR (pa.end_effective_dt_tm >= cnvtdatetime(sysdate))) )
  ORDER BY pa.updt_dt_tm DESC
  HEAD REPORT
   fa_cnt = 0
  DETAIL
   IF (pa.person_alias_type_cd=2
    AND (cmb->combines[d1.seq].from_cmrn <= " "))
    cmb->combines[d1.seq].from_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ELSE
    fa_cnt = (cmb->combines[d1.seq].fa_cnt+ 1), stat = alterlist(cmb->combines[d1.seq].from_aliases,
     fa_cnt), cmb->combines[d1.seq].fa_cnt = fa_cnt,
    cmb->combines[d1.seq].from_aliases[fa_cnt].alias_id = pa.person_alias_id, cmb->combines[d1.seq].
    from_aliases[fa_cnt].alias = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(cmb->c_cnt)),
   person_combine_det pcd,
   person_alias pa
  PLAN (d1
   WHERE (cmb->combines[d1.seq].combine_type="PERSON*")
    AND (cmb->combines[d1.seq].move_encntr_id=0.00))
   JOIN (pcd
   WHERE (cmb->combines[d1.seq].combine_id=pcd.person_combine_id)
    AND pcd.entity_name="PERSON_ALIAS")
   JOIN (pa
   WHERE pcd.entity_id=pa.person_alias_id
    AND pa.person_alias_type_cd != 18)
  ORDER BY pa.updt_dt_tm DESC
  HEAD REPORT
   fa_cnt = 0
  DETAIL
   IF (pa.person_alias_type_cd=2
    AND (cmb->combines[d1.seq].from_cmrn <= " "))
    cmb->combines[d1.seq].from_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ELSE
    fa_cnt = (cmb->combines[d1.seq].fa_cnt+ 1), stat = alterlist(cmb->combines[d1.seq].from_aliases,
     fa_cnt), cmb->combines[d1.seq].fa_cnt = fa_cnt,
    cmb->combines[d1.seq].from_aliases[fa_cnt].alias_id = pa.person_alias_id, cmb->combines[d1.seq].
    from_aliases[fa_cnt].alias = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(cmb->c_cnt)),
   person_combine_det pcd
  PLAN (d1
   WHERE (cmb->combines[d1.seq].combine_type="PERSON*"))
   JOIN (pcd
   WHERE (cmb->combines[d1.seq].combine_id=pcd.person_combine_id)
    AND pcd.entity_name="ORDER_RADIOLOGY")
  HEAD d1.seq
   cmb->combines[d1.seq].rad_order_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d1  WITH seq = value(cmb->c_cnt)),
   encntr_combine_det ecd
  PLAN (d1
   WHERE (cmb->combines[d1.seq].combine_type="ENCNTR_MOVE"))
   JOIN (ecd
   WHERE (cmb->combines[d1.seq].combine_id=ecd.encntr_combine_id)
    AND ecd.entity_name="ORDER_RADIOLOGY")
  HEAD d1.seq
   cmb->combines[d1.seq].rad_order_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO value(var_output)
  FROM dummyt d
  PLAN (d)
  HEAD REPORT
   col + 0,
   CALL print(build("ACTIVITY_TYPE",char(9))), col + 0,
   CALL print(build("ACTIVITY_DT_TM",char(9))), col + 0,
   CALL print(build("USERNAME",char(9))),
   col + 0,
   CALL print(build("PRSNL_NAME",char(9))), col + 0,
   CALL print(build("FROM_PERON_NAME",char(9))), col + 0,
   CALL print(build("FROM_PERSON_CMRN",char(9))),
   col + 0,
   CALL print(build("TO_PERSON_NAME",char(9))), col + 0,
   CALL print(build("TO_PERSON_CMRN",char(9))), col + 0,
   CALL print(build("FROM_PERSON_ALIASES",char(9))),
   col + 0,
   CALL print(build("TO_PERSON_ALIASES",char(9))), col + 0,
   CALL print(build("RAD_ORDER_IND",char(9)))
  DETAIL
   FOR (c = 1 TO cmb->c_cnt)
     row + 1, col + 0,
     CALL print(build(trim(cmb->combines[c].combine_type,3),char(9),trim(cmb->combines[c].
       combine_dt_tm,3),char(9),trim(cmb->combines[c].username,3),
      char(9),trim(cmb->combines[c].full_name,3),char(9),trim(cmb->combines[c].from_person_name,3),
      char(9),
      trim(cmb->combines[c].from_cmrn,3),char(9),trim(cmb->combines[c].to_person_name,3),char(9),trim
      (cmb->combines[c].to_cmrn,3),
      char(9)))
     IF ((cmb->combines[c].fa_cnt > 0))
      FOR (f = 1 TO cmb->combines[c].fa_cnt)
        IF (f=1)
         col + 0,
         CALL print(build2(trim(cmb->combines[c].from_aliases[f].alias,3)))
        ELSE
         col + 0,
         CALL print(build2(", ",trim(cmb->combines[c].from_aliases[f].alias,3)))
        ENDIF
      ENDFOR
      col + 0,
      CALL print(char(9))
     ENDIF
     IF ((cmb->combines[c].ta_cnt > 0))
      FOR (t = 1 TO cmb->combines[c].ta_cnt)
        IF (t=1)
         col + 0,
         CALL print(build2(trim(cmb->combines[c].to_aliases[t].alias,3)))
        ELSE
         col + 0,
         CALL print(build2(", ",trim(cmb->combines[c].to_aliases[t].alias,3)))
        ENDIF
      ENDFOR
      col + 0,
      CALL print(char(9))
     ENDIF
     IF ((cmb->combines[c].ta_cnt=0))
      col + 0,
      CALL print(char(9))
     ENDIF
     IF ((cmb->combines[c].fa_cnt=0))
      col + 0,
      CALL print(char(9))
     ENDIF
     col + 0,
     CALL print(build(cmb->combines[c].rad_order_ind,char(9)))
   ENDFOR
  WITH nocounter, maxcol = 32000, maxrow = 1,
   formfeed = none, format = variable, landscape
 ;end select
 IF (email_ind=1)
  SET filename_in = concat(trim(var_output),".DAT")
  SET email_address = trim( $EMAIL)
  SET filename_out = "COMBINETESTING.XLS"
  EXECUTE bhs_ma_email_file
  CALL emailfile(cnvtlower(filename_in),cnvtlower(filename_out),email_address,curprog,0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = concat(trim("combinetestinge"),format(curdate,"MMDDYYYY;;D"),".csv will be sent to -"),
    msg2 = concat("   ", $EMAIL), col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 1, row + 1,
    "{F/1}{CPI/9}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
 ELSE
  SET var_output =  $OUTDEV
 ENDIF
END GO
