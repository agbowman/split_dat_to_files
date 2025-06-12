CREATE PROGRAM cco_rpt_von_patientlist:dba
 PROMPT
  "Output Summary to File/Printer/MINE" = "MINE",
  "Select Organization to Report:" = 0,
  "Patient Types to Report:" = 0,
  "Record Status (VON Patients Only)" = 0,
  "Starting Birth Date:" = "CURDATE",
  "Ending Birth Date" = "CURDATE"
  WITH outdev, org_id, pat_type,
  rec_type, beg_dob_dt, end_dob_dt
 DECLARE initialize(p1) = null WITH protect
 DECLARE load_von(p1) = null WITH protect
 DECLARE load_eligible(p1) = null WITH protect
 DECLARE load_all(p1) = null WITH protect
 DECLARE print_report(p1) = null WITH protect
 DECLARE meaning_code(mc_codeset,mc_meaning) = f8 WITH protect
 DECLARE von_app_cd = f8 WITH noconstant(0.0), protect
 DECLARE c_curdatetime_disp = vc WITH constant(format(cnvtdatetime(curdate,curtime3),"@LONGDATETIME")
  ), protect
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD pat(
   1 cnt = i2
   1 list[*]
     2 name = vc
     2 von_pat = vc
     2 dob = dq8
 )
 CALL initialize("")
 IF (( $PAT_TYPE=1))
  CALL load_von("")
 ELSEIF (( $PAT_TYPE=2))
  CALL load_eligible("")
 ELSE
  CALL load_all("")
 ENDIF
 CALL print_report("org_id = 0")
 SUBROUTINE initialize(p1)
   SET von_app_cd = meaning_code(400700,"VON")
 END ;Subroutine
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
 SUBROUTINE load_von(p1)
   DECLARE parser_line = vc WITH noconstant(fillstring(50," ")), protect
   IF (( $REC_TYPE IN (0, 1, 2, 3)))
    SET parser_line = build("coe.record_status_flag =",value( $REC_TYPE))
   ELSE
    SET parser_line = "1 = 1"
   ENDIF
   SELECT INTO "nl:"
    FROM cco_encounter coe,
     person p
    PLAN (coe
     WHERE coe.cco_source_app_cd=von_app_cd
      AND parser(parser_line)
      AND coe.active_ind=1)
     JOIN (p
     WHERE p.person_id=coe.person_id
      AND p.birth_dt_tm >= cnvtdatetime( $BEG_DOB_DT)
      AND p.birth_dt_tm <= cnvtdatetime( $END_DOB_DT)
      AND p.active_ind=1)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(pat->list,(cnt+ 9))
     ENDIF
     pat->list[cnt].name = p.name_full_formatted, pat->list[cnt].dob = p.birth_dt_tm
    FOOT REPORT
     pat->cnt = cnt, stat = alterlist(pat->list,cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE load_eligible(p1)
   SELECT INTO "nl:"
    FROM person p
    PLAN (p
     WHERE  NOT ( EXISTS (
     (SELECT
      coe.person_id
      FROM cco_encounter coe
      WHERE p.person_id=coe.person_id
       AND coe.cco_source_app_cd=von_app_cd
       AND coe.active_ind=1)))
      AND p.birth_dt_tm >= cnvtdatetime( $BEG_DOB_DT)
      AND p.birth_dt_tm <= cnvtdatetime( $END_DOB_DT)
      AND p.active_ind=1)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(pat->list,(cnt+ 9))
     ENDIF
     pat->list[cnt].name = p.name_full_formatted, pat->list[cnt].dob = p.birth_dt_tm
    FOOT REPORT
     pat->cnt = cnt, stat = alterlist(pat->list,cnt)
    WITH maxrec = 10, nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE load_all(p1)
   SELECT INTO "nl:"
    FROM person p,
     cco_encounter coe
    PLAN (p
     WHERE p.birth_dt_tm >= cnvtdatetime( $BEG_DOB_DT)
      AND p.birth_dt_tm <= cnvtdatetime( $END_DOB_DT)
      AND p.active_ind=1)
     JOIN (coe
     WHERE outerjoin(von_app_cd)=coe.cco_source_app_cd
      AND outerjoin(p.person_id)=coe.person_id
      AND outerjoin(1)=coe.active_ind)
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,10)=1)
      stat = alterlist(pat->list,(cnt+ 9))
     ENDIF
     pat->list[cnt].name = p.name_full_formatted, pat->list[cnt].dob = p.birth_dt_tm
     IF (coe.cco_encounter_id > 0)
      pat->list[cnt].von_pat = "VON"
     ELSE
      pat->list[cnt].von_pat = "---"
     ENDIF
    FOOT REPORT
     pat->cnt = cnt, stat = alterlist(pat->list,cnt)
    WITH maxrec = 20, nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE print_report(p1)
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = pat->cnt)
    HEAD PAGE
     row + 1, col 1, c_curdatetime_disp,
     col 50, "By Module: CCO_RPT_VON_PATIENTLIST", row + 1,
     CALL center("*** Vermont Oxford Network ***",0,80), row + 1,
     CALL center("Patient List Report",0,80),
     row + 1, row + 1,
     CALL center("ORGANIZATION NAME HERE",0,80),
     row + 1
     IF (( $PAT_TYPE=1))
      listtype = "Patients with VON Records"
      IF (( $REC_TYPE=0))
       rectype = "Incompleted Records"
      ELSEIF (( $REC_TYPE=1))
       rectype = "Complete Records"
      ELSEIF (( $REC_TYPE=2))
       rectype = "Modified and Complete Records"
      ELSEIF (( $REC_TYPE=3))
       rectype = "Modified and Incomplete Records"
      ENDIF
     ELSEIF (( $PAT_TYPE=2))
      listtype = "Eligible Patients", rectype = "All Records"
     ELSE
      listtype = "All Patients (with or without VON record)", rectype = "All Records"
     ENDIF
     CALL center(listtype,0,80), row + 1,
     CALL center(rectype,0,80),
     row + 1, line = fillstring(80,"-"), col 1,
     line, row + 1
    DETAIL
     IF ((pat->cnt > 0))
      num = format(d.seq,"#####"), col 2, "rec # ",
      num, col 20, pat->list[d.seq].von_pat,
      col 30, pat->list[d.seq].name, dob_line = format(cnvtdatetime(pat->list[d.seq].dob),
       "mm/dd/yyyy;;d"),
      col 60, dob_line, row + 1
     ELSE
      col 2, "NO ELIGIBLE PATIENTS", row + 1
     ENDIF
    WITH nocounter, format, separator = " "
   ;end select
 END ;Subroutine
#9999_exit_program
END GO
