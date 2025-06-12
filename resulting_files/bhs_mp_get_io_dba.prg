CREATE PROGRAM bhs_mp_get_io:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_rec
 RECORD m_rec(
   1 event_set[1]
     2 s_event_set_name = vc
     2 f_event_set_cd = f8
     2 level_1[*]
       3 s_event_set_name = vc
       3 f_event_set_cd = f8
       3 f_vol_total = f8
       3 level_2[*]
         4 s_event_set_name = vc
         4 f_event_set_cd = f8
         4 f_vol_total = f8
         4 event_cds[*]
           5 s_event_disp = vc
           5 f_event_cd = f8
           5 f_event_id = f8
           5 results[*]
             6 f_vol = f8
 ) WITH protect
 FREE RECORD m_reply
 RECORD m_reply(
   1 f_in_infusions_vol = f8
   1 f_in_blood_vol = f8
   1 f_in_gi_vol = f8
   1 f_in_irrigation_vol = f8
   1 f_in_dialysis_vol = f8
   1 f_in_misc_vol = f8
   1 f_out_urine_vol = f8
   1 f_out_gi_vol = f8
   1 f_out_drains_vol = f8
   1 f_out_irrigation_vol = f8
   1 f_out_dialysis_vol = f8
   1 f_out_misc_vol = f8
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 DECLARE mf_io_cd = f8 WITH protect, constant(uar_get_code_by("DESCRIPTION",93,"FLUID BALANCE"))
 DECLARE mf_intake_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"HISTORICALINTAKE")
  )
 DECLARE mf_output_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"HISTORICALOUTPUT")
  )
 DECLARE mf_admin_info_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "ADMINISTRATIONINFORMATION"))
 DECLARE mf_io_event_set_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ml_cnt1 = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE mf_tmp_vol = f8 WITH protect, noconstant(0.0)
 DECLARE ml_intake_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_admin_idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM v500_event_set_code vesc
  PLAN (vesc
   WHERE vesc.event_set_name="IO")
  ORDER BY vesc.event_set_name
  HEAD vesc.event_set_cd
   mf_io_event_set_cd = vesc.event_set_cd
  WITH nocounter
 ;end select
 SET m_rec->event_set[1].s_event_set_name = "Intake and Output"
 SET m_rec->event_set[1].f_event_set_cd = mf_io_event_set_cd
 SELECT
  parent_set_disp = uar_get_code_display(vesc.parent_event_set_cd), vesc.parent_event_set_cd,
  event_set_disp = uar_get_code_display(vesc.event_set_cd),
  vesc.event_set_cd, event_set_disp1 = uar_get_code_display(vesc1.event_set_cd), vesc1.event_set_cd,
  event_disp = uar_get_code_display(vese.event_cd), vese.event_cd
  FROM v500_event_set_canon vesc,
   v500_event_set_canon vesc1,
   v500_event_set_explode vese
  PLAN (vesc
   WHERE vesc.parent_event_set_cd=mf_io_event_set_cd)
   JOIN (vesc1
   WHERE vesc1.parent_event_set_cd=vesc.event_set_cd)
   JOIN (vese
   WHERE vese.event_set_cd=vesc1.event_set_cd)
  ORDER BY event_set_disp, event_set_disp1, event_disp
  HEAD REPORT
   pl_lev1_cnt = 0, pl_lev2_cnt = 0, pl_evnt_cnt = 0,
   pl_idx = 0, pl_num = 0
  HEAD vesc.event_set_cd
   pl_lev2_cnt = 0, pl_evnt_cnt = 0, pl_lev1_cnt = (pl_lev1_cnt+ 1),
   stat = alterlist(m_rec->event_set[1].level_1,pl_lev1_cnt), m_rec->event_set[1].level_1[pl_lev1_cnt
   ].f_event_set_cd = vesc.event_set_cd, m_rec->event_set[1].level_1[pl_lev1_cnt].s_event_set_name =
   trim(uar_get_code_display(vesc.event_set_cd))
  HEAD vesc1.event_set_cd
   pl_evnt_cnt = 0, pl_lev2_cnt = (pl_lev2_cnt+ 1), stat = alterlist(m_rec->event_set[1].level_1[
    pl_lev1_cnt].level_2,pl_lev2_cnt),
   m_rec->event_set[1].level_1[pl_lev1_cnt].level_2[pl_lev2_cnt].f_event_set_cd = vesc1.event_set_cd,
   m_rec->event_set[1].level_1[pl_lev1_cnt].level_2[pl_lev2_cnt].s_event_set_name = trim(
    uar_get_code_display(vesc1.event_set_cd))
  DETAIL
   pl_evnt_cnt = (pl_evnt_cnt+ 1), stat = alterlist(m_rec->event_set[1].level_1[pl_lev1_cnt].level_2[
    pl_lev2_cnt].event_cds,pl_evnt_cnt), m_rec->event_set[1].level_1[pl_lev1_cnt].level_2[pl_lev2_cnt
   ].event_cds[pl_evnt_cnt].f_event_cd = vese.event_cd,
   m_rec->event_set[1].level_1[pl_lev1_cnt].level_2[pl_lev2_cnt].event_cds[pl_evnt_cnt].s_event_disp
    = trim(uar_get_code_display(vese.event_cd))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ce_intake_output_result c
  PLAN (c
   WHERE c.reference_event_cd=mf_admin_info_cd
    AND c.encntr_id=mf_encntr_id
    AND c.io_end_dt_tm >= cnvtlookbehind("12, H",sysdate))
  HEAD REPORT
   pf_vol_tot = 0.0
  DETAIL
   pf_vol_tot = (pf_vol_tot+ c.io_volume)
  FOOT REPORT
   m_reply->f_in_infusions_vol = pf_vol_tot,
   CALL echo(build2("tot admin: ",pf_vol_tot))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(m_rec->event_set[1].level_1,5))),
   dummyt d2,
   dummyt d3,
   ce_intake_output_result c,
   clinical_event ce
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->event_set[1].level_1[d1.seq].level_2,5)))
   JOIN (d2
   WHERE maxrec(d3,size(m_rec->event_set[1].level_1[d1.seq].level_2[d2.seq].event_cds,5)))
   JOIN (d3)
   JOIN (c
   WHERE (c.reference_event_cd=m_rec->event_set[1].level_1[d1.seq].level_2[d2.seq].event_cds[d3.seq].
   f_event_cd)
    AND c.encntr_id=mf_encntr_id
    AND c.io_end_dt_tm >= cnvtlookbehind("12, H",sysdate))
   JOIN (ce
   WHERE ce.event_id=c.event_id
    AND ce.valid_until_dt_tm >= sysdate
    AND ce.result_status_cd IN (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=8
     AND  NOT (cv.display_key IN ("NOTDONE", "INERROR", "CANCELED", "INLAB", "INPROGRESS",
    "REJECTED", "PRELIMINARY", "UNKNOWN")))))
  ORDER BY d1.seq, d2.seq, d3.seq
  HEAD REPORT
   pl_cnt = 0, pf_vol_tot = 0.0, pf_intake_tot = 0.0,
   pf_output_tot = 0.0
  HEAD d1.seq
   pf_intake_tot = 0.0, pf_output_tot = 0.0
  HEAD d2.seq
   pl_cnt = 0, pf_vol_tot = 0.0
  DETAIL
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->event_set[1].level_1[d1.seq].level_2[d2.seq].
    event_cds[d3.seq].results,pl_cnt), m_rec->event_set[1].level_1[d1.seq].level_2[d2.seq].event_cds[
   d3.seq].results[pl_cnt].f_vol = c.io_volume,
   pf_vol_tot = (pf_vol_tot+ c.io_volume)
  FOOT  d2.seq
   m_rec->event_set[1].level_1[d1.seq].level_2[d2.seq].f_vol_total = pf_vol_tot
   IF ((m_rec->event_set[1].level_1[d1.seq].s_event_set_name="Intake"))
    pf_intake_tot = (pf_intake_tot+ pf_vol_tot)
   ELSEIF ((m_rec->event_set[1].level_1[d1.seq].s_event_set_name="Output"))
    pf_output_tot = (pf_output_tot+ pf_vol_tot)
   ENDIF
  FOOT  d1.seq
   IF ((m_rec->event_set[1].level_1[d1.seq].s_event_set_name="Intake"))
    m_rec->event_set[1].level_1[d1.seq].f_vol_total = pf_intake_tot,
    CALL echo(build2("Total intake: ",pf_intake_tot))
   ELSEIF ((m_rec->event_set[1].level_1[d1.seq].s_event_set_name="Output"))
    m_rec->event_set[1].level_1[d1.seq].f_vol_total = pf_output_tot,
    CALL echo(build2("Total output: ",pf_output_tot))
   ENDIF
  WITH nocounter
 ;end select
 FOR (ml_cnt1 = 1 TO size(m_rec->event_set[1].level_1,5))
   FOR (ml_cnt2 = 1 TO size(m_rec->event_set[1].level_1[ml_cnt1].level_2,5))
    SET mf_tmp_vol = m_rec->event_set[1].level_1[ml_cnt1].level_2[ml_cnt2].f_vol_total
    IF (cnvtupper(m_rec->event_set[1].level_1[ml_cnt1].s_event_set_name)="INTAKE")
     CASE (cnvtupper(m_rec->event_set[1].level_1[ml_cnt1].level_2[ml_cnt2].s_event_set_name))
      OF "DILUENTS":
       SET m_reply->f_in_infusions_vol = (m_reply->f_in_infusions_vol+ mf_tmp_vol)
      OF "BLOOD PRODUCTS SECTION":
       SET m_reply->f_in_blood_vol = (m_reply->f_in_blood_vol+ mf_tmp_vol)
      OF "FEEDINGS SECTION":
       SET m_reply->f_in_gi_vol = (m_reply->f_in_gi_vol+ mf_tmp_vol)
      OF "PARENTERAL NUTRITION SECTION":
       SET m_reply->f_in_gi_vol = (m_reply->f_in_gi_vol+ mf_tmp_vol)
      OF "ORAL INTAKE SECTION":
       SET m_reply->f_in_gi_vol = (m_reply->f_in_gi_vol+ mf_tmp_vol)
      OF "CBI INPUT SECTION":
       SET m_reply->f_in_irrigation_vol = (m_reply->f_in_irrigation_vol+ mf_tmp_vol)
      OF "IRRIGANT INTAKE SECTION":
       SET m_reply->f_in_irrigation_vol = (m_reply->f_in_irrigation_vol+ mf_tmp_vol)
      OF "DIALYSIS INTAKE SECTION":
       SET m_reply->f_in_dialysis_vol = (m_reply->f_in_dialysis_vol+ mf_tmp_vol)
      OF "MISC INTAKE SECTION":
       SET m_reply->f_in_misc_vol = (m_reply->f_in_misc_vol+ mf_tmp_vol)
     ENDCASE
    ELSEIF (cnvtupper(m_rec->event_set[1].level_1[ml_cnt1].s_event_set_name)="OUTPUT")
     CASE (cnvtupper(m_rec->event_set[1].level_1[ml_cnt1].level_2[ml_cnt2].s_event_set_name))
      OF "URINE OUTPUT SECTION":
       SET m_reply->f_out_urine_vol = (m_reply->f_out_urine_vol+ mf_tmp_vol)
      OF "GI OUTPUT SECTION":
       SET m_reply->f_out_gi_vol = (m_reply->f_out_gi_vol+ mf_tmp_vol)
      OF "STOOL OUTPUT SECTION":
       SET m_reply->f_out_gi_vol = (m_reply->f_out_gi_vol+ mf_tmp_vol)
      OF "BLAKE DRAINS":
       SET m_reply->f_out_drains_vol = (m_reply->f_out_drains_vol+ mf_tmp_vol)
      OF "CHEST TUBES":
       SET m_reply->f_out_drains_vol = (m_reply->f_out_drains_vol+ mf_tmp_vol)
      OF "DAVOL":
       SET m_reply->f_out_drains_vol = (m_reply->f_out_drains_vol+ mf_tmp_vol)
      OF "DRAINS":
       SET m_reply->f_out_drains_vol = (m_reply->f_out_drains_vol+ mf_tmp_vol)
      OF "HEMOVAC":
       SET m_reply->f_out_drains_vol = (m_reply->f_out_drains_vol+ mf_tmp_vol)
      OF "JP DRAIN":
       SET m_reply->f_out_drains_vol = (m_reply->f_out_drains_vol+ mf_tmp_vol)
      OF "WOUND VACS":
       SET m_reply->f_out_drains_vol = (m_reply->f_out_drains_vol+ mf_tmp_vol)
      OF "CBI OUTPUT SECTION":
       SET m_reply->f_out_irrigation_vol = (m_reply->f_out_irrigation_vol+ mf_tmp_vol)
      OF "IRRIGANT OUTPUT SECTION":
       SET m_reply->f_out_irrigation_vol = (m_reply->f_out_irrigation_vol+ mf_tmp_vol)
      OF "DIALYSIS OUTPUT SECTION":
       SET m_reply->f_out_dialysis_vol = (m_reply->f_out_dialysis_vol+ mf_tmp_vol)
      OF "INSENSIBLE LOSS VOL":
       SET m_reply->f_out_misc_vol = (m_reply->f_out_misc_vol+ mf_tmp_vol)
      OF "MISC OUTPUT SECTION":
       SET m_reply->f_out_misc_vol = (m_reply->f_out_misc_vol+ mf_tmp_vol)
     ENDCASE
    ENDIF
   ENDFOR
 ENDFOR
#exit_script
 CALL echo("rectojson")
 CALL echo(cnvtrectojson(m_reply))
 CALL echo("echojson")
 CALL echojson(m_reply, $OUTDEV)
 CALL echorecord(m_rec)
 FREE RECORD m_rec
 CALL echorecord(m_reply)
 FREE RECORD m_reply
END GO
