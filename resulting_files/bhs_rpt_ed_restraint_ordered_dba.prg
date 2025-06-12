CREATE PROGRAM bhs_rpt_ed_restraint_ordered:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 0,
  "Unit" = value(0.0),
  "Enter Emails" = ""
  WITH outdev, f_fname, f_unit,
  s_emails
 DECLARE mf_cs69_emergency = f8 WITH constant(uar_get_code_by("DISPLAYKEY",69,"EMERGENCY")), protect
 DECLARE mf_cs6004_ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mf_cs106_restraints = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"RESTRAINTS")),
 protect
 DECLARE mf_cs6004_deleted = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs220_eshld = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESHLD")), protect
 DECLARE mf_cs220_edhld = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"EDHLD")), protect
 DECLARE mf_cs220_erhd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ERHD")), protect
 DECLARE mf_cs220_edhold = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"EDHOLD")), protect
 DECLARE ms_filename = vc WITH noconstant(concat("active_restraint_orders_")), protect
 DECLARE ms_output_file = vc WITH noconstant(build(trim(ms_filename,3),format(sysdate,"MMDDYYYY;;q"),
   ".csv")), protect
 DECLARE ml_attloc = i4 WITH protect
 DECLARE ml_num = i4 WITH protect
 DECLARE ml_loc = i4 WITH protect
 DECLARE ml_numres = i4 WITH protect
 DECLARE ml_time = i4 WITH noconstant(0), protect
 DECLARE ml_ops_ind = i4 WITH noconstant(0), protect
 DECLARE order_name = vc WITH noconstant("                                                    "),
 protect
 DECLARE ms_opr_var1 = vc WITH protect
 DECLARE ms_lcheck = vc WITH protect
 DECLARE ml_gcnt = i4 WITH noconstant(0), protect
 DECLARE ms_sender = vc WITH protect
 DECLARE ms_msgcls = vc WITH protect
 DECLARE ms_sendto = vc WITH protect
 DECLARE ms_subject = vc WITH protect
 DECLARE ml_msgpriority = i4 WITH protect
 RECORD restraints(
   1 l_cnt_ord = i4
   1 pats[*]
     2 s_patname = vc
     2 s_facility = vc
     2 s_unit = vc
     2 s_mrn = vc
     2 s_fin = vc
     2 s_order_name = vc
     2 s_type = vc
     2 s_reason = vc
     2 s_mode = vc
     2 s_status = vc
     2 f_order_id = f8
     2 s_order_dt = vc
 )
 FREE RECORD grec2
 RECORD grec2(
   1 list[*]
     2 f_cv = f8
     2 s_disp = c15
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
 SET ml_gcnt = 0
 IF (ms_lcheck="L")
  SET ms_opr_var1 = "IN"
  WHILE (ms_lcheck > " ")
    SET ml_gcnt += 1
    SET ms_lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),ml_gcnt)))
    CALL echo(ms_lcheck)
    IF (ms_lcheck > " ")
     IF (mod(ml_gcnt,5)=1)
      SET stat = alterlist(grec2->list,(ml_gcnt+ 4))
     ENDIF
     SET grec2->list[ml_gcnt].f_cv = cnvtint(parameter(parameter2( $F_UNIT),ml_gcnt))
     SET grec2->list[ml_gcnt].s_disp = uar_get_code_display(parameter(parameter2( $F_UNIT),ml_gcnt))
    ENDIF
  ENDWHILE
  SET ml_gcnt -= 1
  SET stat = alterlist(grec2->list,ml_gcnt)
 ELSE
  SET stat = alterlist(grec2->list,1)
  SET ml_gcnt = 1
  SET grec2->list[1].f_cv =  $F_UNIT
  IF ((grec2->list[1].f_cv=0.0))
   SET grec2->list[1].s_disp = "All Units"
   SET ms_opr_var1 = "!="
  ELSE
   SET grec2->list[1].s_disp = uar_get_code_display(grec2->list[1].f_cv)
   SET ms_opr_var1 = "="
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  facility = uar_get_code_display(e.loc_facility_cd), unit = uar_get_code_display(e.loc_nurse_unit_cd
   )
  FROM orders o,
   encntr_alias mrn,
   encntr_alias fin,
   encounter e,
   person p,
   encntr_domain ed
  PLAN (ed
   WHERE ed.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND (ed.loc_facility_cd= $F_FNAME)
    AND operator(ed.loc_nurse_unit_cd,ms_opr_var1, $F_UNIT))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_status_cd=mf_cs48_active
    AND e.disch_dt_tm=null
    AND ((e.encntr_type_class_cd=mf_cs69_emergency) OR (e.loc_nurse_unit_cd IN (mf_cs220_edhld,
   mf_cs220_erhd, mf_cs220_eshld, mf_cs220_edhold))) )
   JOIN (o
   WHERE o.order_status_cd=mf_cs6004_ordered
    AND o.activity_type_cd=mf_cs106_restraints
    AND o.encntr_id=e.encntr_id
    AND o.person_id=e.person_id)
   JOIN (fin
   WHERE fin.encntr_id=ed.encntr_id
    AND fin.active_ind=1
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND sysdate BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm)
   JOIN (mrn
   WHERE mrn.encntr_id=ed.encntr_id
    AND mrn.active_ind=1
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND sysdate BETWEEN mrn.beg_effective_dt_tm AND mrn.end_effective_dt_tm)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_status_cd=mf_cs48_active
    AND p.active_ind=1)
  ORDER BY facility, unit, p.name_full_formatted,
   e.encntr_id, o.order_id DESC
  HEAD REPORT
   stat = alterlist(restraints->pats,10)
  HEAD o.order_id
   restraints->l_cnt_ord += 1,
   CALL echo(build("count = ",restraints->l_cnt_ord," >",mod(restraints->l_cnt_ord,10)))
   IF (mod(restraints->l_cnt_ord,10)=1
    AND (restraints->l_cnt_ord > 1))
    stat = alterlist(restraints->pats,(restraints->l_cnt_ord+ 9))
   ENDIF
   restraints->pats[restraints->l_cnt_ord].s_facility = trim(uar_get_code_display(e.loc_facility_cd),
    3), restraints->pats[restraints->l_cnt_ord].s_unit = trim(uar_get_code_display(ed
     .loc_nurse_unit_cd),3), restraints->pats[restraints->l_cnt_ord].s_patname = trim(p
    .name_full_formatted,3),
   restraints->pats[restraints->l_cnt_ord].s_fin = trim(fin.alias,3), restraints->pats[restraints->
   l_cnt_ord].s_mrn = trim(mrn.alias,3), restraints->pats[restraints->l_cnt_ord].s_order_name = trim(
    o.ordered_as_mnemonic,3),
   restraints->pats[restraints->l_cnt_ord].f_order_id = o.order_id, restraints->pats[restraints->
   l_cnt_ord].s_status = trim(uar_get_code_display(o.order_status_cd),3), restraints->pats[restraints
   ->l_cnt_ord].s_order_dt = trim(format(o.orig_order_dt_tm,";;Q"),3)
  FOOT REPORT
   null, stat = alterlist(restraints->pats,restraints->l_cnt_ord)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   oe_format_fields off,
   orders o
  PLAN (o
   WHERE expand(ml_num,1,size(restraints->pats,5),o.order_id,restraints->pats[ml_num].f_order_id))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.action_sequence IN (
   (SELECT
    max(odi2.action_sequence)
    FROM order_detail odi2
    WHERE odi2.order_id=od.order_id
     AND odi2.oe_field_meaning_id=od.oe_field_meaning_id
    GROUP BY odi2.order_id)))
   JOIN (off
   WHERE off.oe_format_id=o.oe_format_id
    AND off.oe_field_id=od.oe_field_id
    AND off.label_text IN ("Reason"))
  ORDER BY o.order_id
  HEAD o.order_id
   ml_attloc = 0, ml_attloc = locateval(ml_numres,1,size(restraints->pats,5),o.order_id,restraints->
    pats[ml_numres].f_order_id)
   IF (ml_attloc != 0)
    restraints->pats[ml_attloc].s_reason = trim(od.oe_field_display_value,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   oe_format_fields off,
   orders o
  PLAN (o
   WHERE expand(ml_num,1,size(restraints->pats,5),o.order_id,restraints->pats[ml_num].f_order_id))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.action_sequence IN (
   (SELECT
    max(odi2.action_sequence)
    FROM order_detail odi2
    WHERE odi2.order_id=od.order_id
     AND odi2.oe_field_meaning_id=od.oe_field_meaning_id
    GROUP BY odi2.order_id)))
   JOIN (off
   WHERE off.oe_format_id=o.oe_format_id
    AND off.oe_field_id=od.oe_field_id
    AND off.label_text IN ("Mode"))
  ORDER BY o.order_id
  HEAD o.order_id
   ml_attloc = 0, ml_attloc = locateval(ml_numres,1,size(restraints->pats,5),o.order_id,restraints->
    pats[ml_numres].f_order_id)
   IF (ml_attloc != 0)
    restraints->pats[ml_attloc].s_mode = trim(od.oe_field_display_value,3)
   ENDIF
  WITH nocounter, format
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   oe_format_fields off,
   orders o
  PLAN (o
   WHERE expand(ml_num,1,size(restraints->pats,5),o.order_id,restraints->pats[ml_num].f_order_id))
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.action_sequence IN (
   (SELECT
    max(odi2.action_sequence)
    FROM order_detail odi2
    WHERE odi2.order_id=od.order_id
     AND odi2.oe_field_meaning_id=od.oe_field_meaning_id
    GROUP BY odi2.order_id)))
   JOIN (off
   WHERE off.oe_format_id=o.oe_format_id
    AND off.oe_field_id=od.oe_field_id
    AND off.label_text IN ("Type"))
  ORDER BY o.order_id
  HEAD o.order_id
   ml_attloc = 0, ml_attloc = locateval(ml_numres,1,size(restraints->pats,5),o.order_id,restraints->
    pats[ml_numres].f_order_id)
   IF (ml_attloc != 0)
    restraints->pats[ml_attloc].s_type = trim(od.oe_field_display_value,3)
   ENDIF
  WITH nocounter
 ;end select
 SET ml_ops_ind = findstring("@", $S_EMAILS,1,0)
 IF (ml_ops_ind=0)
  SELECT INTO  $OUTDEV
   patient_name = substring(1,100,restraints->pats[d1.seq].s_patname), facility = substring(1,30,
    restraints->pats[d1.seq].s_facility), unit = substring(1,30,restraints->pats[d1.seq].s_unit),
   mrn = substring(1,30,restraints->pats[d1.seq].s_mrn), fin = substring(1,30,restraints->pats[d1.seq
    ].s_fin), order_name = substring(1,100,restraints->pats[d1.seq].s_order_name),
   type = substring(1,100,restraints->pats[d1.seq].s_type), reason = substring(1,100,restraints->
    pats[d1.seq].s_reason), mode = substring(1,100,restraints->pats[d1.seq].s_mode),
   order_status = substring(1,30,restraints->pats[d1.seq].s_status), order_date = substring(1,30,
    restraints->pats[d1.seq].s_order_dt)
   FROM (dummyt d1  WITH seq = size(restraints->pats,5))
   PLAN (d1)
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (ml_ops_ind > 0)
  SET frec->file_name = ms_output_file
  IF (size(restraints->pats,5) > 0)
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = build('"Patient Name",','"Facility",','"Unit",','"MRN",','"Acct Number",',
    '"Order",','"Type",','"Restraint Reason",','"Mode",','"Order Status",',
    char(13))
   SET stat = cclio("WRITE",frec)
   FOR (ml_cnt = 1 TO size(restraints->pats,5))
    SET frec->file_buf = build('"',trim(restraints->pats[ml_cnt].s_patname,3),'","',trim(restraints->
      pats[ml_cnt].s_facility,3),'","',
     trim(restraints->pats[ml_cnt].s_unit,3),'","',trim(restraints->pats[ml_cnt].s_mrn,3),'","',trim(
      restraints->pats[ml_cnt].s_fin,3),
     '","',trim(restraints->pats[ml_cnt].s_order_name,3),'","',trim(restraints->pats[ml_cnt].s_type,3
      ),'","',
     trim(restraints->pats[ml_cnt].s_reason,3),'","',trim(restraints->pats[ml_cnt].s_mode,3),'","',
     trim(restraints->pats[ml_cnt].s_status,3),
     '"',char(13))
    SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
   SET ms_subject = build2("Active Restraint Orders Run Date: ",format(cnvtdatetime(curdate,curtime),
     "mmm-dd-yyyy hh:mm ;;d"))
   EXECUTE bhs_ma_email_file
   CALL emailfile(frec->file_name,frec->file_name, $S_EMAILS,ms_subject,1)
  ELSE
   SET ms_subject = build2("No Active Restraint Orders Run Date: ",format(cnvtdatetime(curdate,
      curtime),"mmm-dd-yyyy hh:mm ;;d"))
   SET ms_email_body = " Active Restraint Orders all locations"
   SET ms_sendto = replace( $S_EMAILS,","," ",0)
   SET dclcom1 = concat("echo '",ms_email_body,"'"," | mailx -s '",ms_subject,
    "' ",ms_sendto)
   CALL echo(build("DCLCOM1>>>",dclcom1))
   SET dcllen1 = size(trim(dclcom1))
   SET dclstatus = 0
   CALL dcl(dclcom1,dcllen1,dclstatus)
   CALL echo(build("DCLSTATUS>>>",dclstatus))
   IF (dclstatus=1)
    CALL echo("emailed success")
   ELSE
    CALL echo("emailed failed")
   ENDIF
  ENDIF
 ENDIF
END GO
