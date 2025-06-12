CREATE PROGRAM bhs_med_recon_summ
 PROMPT
  "Output to File/Printer/MINE " = "MINE",
  "Enter Start Date:" = curdate,
  "Enter End Date" = curdate
  WITH outdev, st_dt, en_dt
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD encntrs
 RECORD encntrs(
   1 qual[*]
     2 phy_id = f8
     2 phy_name = vc
     2 pos_cd = f8
     2 dept_name = vc
     2 pat_cnt = f8
     2 ord_cnt = i4
     2 med_cnt = i4
     2 score = i4
     2 percent_c = f8
     2 percent_disp = vc
     2 encntr[*]
       3 eid = f8
       3 disch = dq8
       3 phy_updt_flg = i2
       3 pat_med_flg = i2
       3 score_flg = i2
 )
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $OUTDEV
 ENDIF
 IF (( $ST_DT=999))
  SET start_date = datetimefind(cnvtdatetime((curdate - 10),0),"M","B","B")
  SET end_date = datetimefind(cnvtdatetime((curdate - 10),0),"M","E","E")
  SET beg_date_disp = format(start_date,"MM/DD/YYYY;;d")
  SET end_date_disp = format(end_date,"MM/DD/YYYY;;d")
 ELSE
  SET start_date = cnvtdatetime(cnvtdate( $ST_DT),0)
  SET end_date = cnvtdatetime(cnvtdate( $EN_DT),235959)
  SET beg_date_disp = format(cnvtdate( $ST_DT),"MM/DD/YYYY;;d")
  SET end_date_disp = format(cnvtdate( $EN_DT),"MM/DD/YYYY;;d")
 ENDIF
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(2,0)))), public
 DECLARE strtend = vc
 DECLARE pname = vc
 DECLARE patcnt_d = vc
 DECLARE ordcnt_d = vc
 DECLARE medcnt_d = vc
 DECLARE score_d = vc
 DECLARE percent_d = vc
 DECLARE phys_type = vc
 DECLARE idx = i4
 DECLARE index = i4
 SET fnbr = uar_get_code_by("DISPLAY_KEY",319,"FINNBR")
 SET status_1 = uar_get_code_by("DISPLAY_KEY",6004,"ORDERED")
 SET status_2 = uar_get_code_by("DISPLAY_KEY",6004,"COMPLETED")
 SET activity_type_1 = uar_get_code_by("DISPLAY_KEY",106,"COMMUNICATIONORDERS")
 SET catalog_type_1 = uar_get_code_by("DISPLAY_KEY",6000,"PATIENTCARE")
 SET catalog_cd_3 = uar_get_code_by("DISPLAY_KEY",200,"HOMEMEDSUPDATEDINMEDICATIONPROFILE")
 SET catalog_cd_2 = uar_get_code_by("DISPLAY_KEY",200,"COMPLETEMEDRECONCILIATIONDISCHARGE")
 SET catalog_cd_1 = uar_get_code_by("DISPLAY_KEY",200,"COMPLETEMEDRECONCILIATIONADMIT")
 DECLARE patient_count = i4
 SET disch_inp = 679656.00
 SET disch_obs = 679659.00
 SET disch_daystay = 679662.00
 SELECT DISTINCT INTO "nl:"
  pid = ep.prsnl_person_id, eid = e.encntr_id, d = e.disch_dt_tm
  FROM encounter e,
   encntr_prsnl_reltn ep
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND e.encntr_type_cd IN (disch_inp, disch_obs))
   JOIN (ep
   WHERE ep.encntr_id=e.encntr_id
    AND ep.encntr_prsnl_r_cd=1119
    AND ep.end_effective_dt_tm > sysdate
    AND ep.prsnl_person_id > 0)
  ORDER BY pid, eid, 0
  HEAD REPORT
   cnt1 = 0, cnt2 = 0, stat = alterlist(encntrs->qual,10),
   stat = alterlist(encntrs->qual,10)
  HEAD pid
   cnt1 = (cnt1+ 1)
   IF (mod(cnt1,10)=1)
    stat = alterlist(encntrs->qual,(cnt1+ 9))
   ENDIF
   encntrs->qual[cnt1].phy_id = pid
  DETAIL
   cnt2 = (cnt2+ 1)
   IF (mod(cnt2,10)=1)
    stat = alterlist(encntrs->qual[cnt1].encntr,(cnt2+ 9))
   ENDIF
   encntrs->qual[cnt1].encntr[cnt2].eid = eid, encntrs->qual[cnt1].encntr[cnt2].disch = d
  FOOT  pid
   stat = alterlist(encntrs->qual[cnt1].encntr,cnt2), encntrs->qual[cnt1].pat_cnt = cnt2, cnt2 = 0
  FOOT REPORT
   stat = alterlist(encntrs->qual,cnt1)
  WITH nocounter
 ;end select
 SET phy_cnt = size(encntrs->qual,5)
 FOR (x = 1 TO phy_cnt)
  SET pat_cnt = size(encntrs->qual[x].encntr,5)
  IF (pat_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(pat_cnt)),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.encntr_id=encntrs->qual[x].encntr[d.seq].eid)
      AND ((o.catalog_cd=catalog_cd_3) OR (((o.orig_ord_as_flag+ 0) IN (1, 2))
      AND ((o.need_rx_verify_ind+ 0)=0)
      AND ((o.activity_type_cd+ 0)=705)
      AND ((o.catalog_type_cd+ 0)=2516)
      AND o.current_start_dt_tm BETWEEN cnvtlookbehind("24,H",encntrs->qual[x].encntr[d.seq].disch)
      AND cnvtlookahead("24,H",encntrs->qual[x].encntr[d.seq].disch)
      AND  EXISTS (
     (SELECT
      oa.order_id
      FROM order_action oa
      WHERE o.order_id=oa.order_id
       AND  EXISTS (
      (SELECT
       pr.person_id
       FROM prsnl pr
       WHERE pr.person_id=oa.action_personnel_id
        AND ((pr.physician_ind+ 0)=1))))))) )
    DETAIL
     IF (o.catalog_cd=catalog_cd_3)
      encntrs->qual[x].encntr[d.seq].phy_updt_flg = 1, encntrs->qual[x].encntr[d.seq].score_flg = 1
     ELSEIF (o.orig_ord_as_flag IN (1, 2)
      AND o.updt_id > 1)
      encntrs->qual[x].encntr[d.seq].pat_med_flg = 1, encntrs->qual[x].encntr[d.seq].score_flg = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 FOR (x = 1 TO phy_cnt)
   SET ordcnt = 0
   SET medcnt = 0
   SET tscore = 0.0
   FOR (y = 1 TO size(encntrs->qual[x].encntr,5))
     IF ((encntrs->qual[x].encntr[y].pat_med_flg=1))
      SET medcnt = (medcnt+ 1)
     ENDIF
     IF ((encntrs->qual[x].encntr[y].phy_updt_flg=1))
      SET ordcnt = (ordcnt+ 1)
     ENDIF
     IF ((encntrs->qual[x].encntr[y].score_flg=1))
      SET tscore = (tscore+ 1)
     ENDIF
   ENDFOR
   SET encntrs->qual[x].med_cnt = medcnt
   SET encntrs->qual[x].ord_cnt = ordcnt
   SET encntrs->qual[x].score = tscore
   IF (tscore > 0)
    SET encntrs->qual[x].percent_c = ((tscore/ encntrs->qual[x].pat_cnt) * 100)
    SET encntrs->qual[x].percent_disp = build(encntrs->qual[x].percent_c," %")
   ELSE
    SET encntrs->qual[x].percent_disp = "0.0 %"
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(phy_cnt)),
   prsnl pr
  PLAN (d)
   JOIN (pr
   WHERE (pr.person_id=encntrs->qual[d.seq].phy_id))
  DETAIL
   encntrs->qual[d.seq].phy_name = pr.name_full_formatted, encntrs->qual[d.seq].pos_cd = pr
   .position_cd
  WITH nocounter
 ;end select
 SELECT INTO value(output_dest)
  FROM (dummyt d  WITH seq = 1)
  PLAN (d
   WHERE d.seq > 0)
  HEAD REPORT
   col 1, "Medication Reconciliation Summary Report", row + 1,
   date = format(curdate,"mm/dd/yyyy;;q"), col 1, "Report Date: ",
   date, row + 1, strtend = build("Range: ",format(start_date,"mm/dd/yyyy hh:mm;;d")," - ",format(
     end_date,"mm/dd/yyyy hh:mm;;d")),
   col 1, strtend, row + 1,
   time = format(curtime3,"hh:mm"), strtend = build("Attending Phys",",","Dept.",",","Pat Disch",
    ",","Order Placed",",","Profile updated",",",
    "Med Rec Comp",",","Med Rec Score",","), col 1,
   strtend, row + 1
  DETAIL
   FOR (x = 1 TO phy_cnt)
     CASE (uar_get_code_display(encntrs->qual[x].pos_cd))
      OF "BHS Anesthesiology MD":
       phys_type = "Anesthesiology"
      OF "BHS Cardiology MD":
       phys_type = "Internal Medicine"
      OF "BHS Cardiac Surgery MD":
       phys_type = "Surgery"
      OF "BHS Critical Care MD":
       phys_type = "Internal Medicine"
      OF "BHS ER Medicine MD":
       phys_type = "Emergency Medicine"
      OF "BHS Infectious Disease MD":
       phys_type = "Internal Medicine"
      OF "BHS GI MD":
       phys_type = "Internal Medicine"
      OF "BHS Urology MD":
       phys_type = "Surgery"
      OF "BHS Thoracic MD":
       phys_type = "Surgery"
      OF "BHS Trauma MD":
       phys_type = "Surgery"
      OF "BHS Resident":
       phys_type = "Resident"
      OF "BHS Oncology MD":
       phys_type = "Internal Medicine"
      OF "BHS Neonatal MD":
       phys_type = "Pediatrics"
      OF "BHS Neurology MD":
       phys_type = "Internal Medicine"
      OF "BHS OB/GYN MD":
       phys_type = "Ob/Gyn"
      OF "BHS Orthopedics MD":
       phys_type = "Surgery"
      OF "BHS General Pediatrics MD":
       phys_type = "Pediatrics"
      OF "BHS Psychiatry MD":
       phys_type = "Psychiatry"
      OF "BHS Physiatry MD":
       phys_type = "Internal Medicine"
      OF "BHS Pulmonary MD":
       phys_type = "Internal Medicine"
      OF "BHS Radiology MD":
       phys_type = "Radiology"
      OF "BHS Renal MD":
       phys_type = "Internal Medicine"
      OF "BHS General Surgery MD":
       phys_type = "Surgery"
      OF "BHS Midwife":
       phys_type = "Ob/Gyn"
      OF "BHS Associate Professional":
       phys_type = "Associate Provider"
      OF "BHS Physician (General Medicine)":
       phys_type = "Internal Medicine"
      OF "BHS Medical Student":
       phys_type = "Medical Student"
      ELSE
       phys_type = "Other"
     ENDCASE
     pname = replace(encntrs->qual[x].phy_name,","," ",0), patcnt_d = cnvtstring(encntrs->qual[x].
      pat_cnt), ordcnt_d = cnvtstring(encntrs->qual[x].ord_cnt),
     medcnt_d = cnvtstring(encntrs->qual[x].med_cnt), score_d = cnvtstring(encntrs->qual[x].score),
     percent_d = encntrs->qual[x].percent_disp,
     strtend = build(pname,",",phys_type,",",patcnt_d,
      ",",ordcnt_d,",",medcnt_d,",",
      score_d,",",percent_d), col 1, strtend,
     row + 1
   ENDFOR
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 IF (email_ind=1)
  SET filename_in = concat(trim(output_dest),".dat")
  SET filename_out = build(format(start_date,"MMDDYYYY;;d"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Med Recon Summ ",beg_date_disp," to ",end_date_disp)
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
