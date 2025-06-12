CREATE PROGRAM bhs_med_recon_detail4
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select From List:" = 0,
  "Enter Start Date:" = curdate,
  "Enter End Date" = curdate
  WITH outdev, physician_id, st_dt,
  en_dt
 EXECUTE bhs_sys_stand_subroutine
 IF (findstring("@", $OUTDEV) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(curdate,curtime3),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET email_ind = 0
  SET output_dest =  $OUTDEV
 ENDIF
 SET beg_date_disp = format(cnvtdate( $ST_DT),"MM/DD/YYYY;;d")
 SET end_date_disp = format(cnvtdate( $EN_DT),"MM/DD/YYYY;;d")
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 150
 ENDIF
 DECLARE any_status_ind = c1 WITH constant(substring(1,1,reflect(parameter(2,0)))), public
 SET fnbr = uar_get_code_by("DISPLAY_KEY",319,"FINNBR")
 SET status_1 = uar_get_code_by("DISPLAY_KEY",6004,"ORDERED")
 SET status_2 = uar_get_code_by("DISPLAY_KEY",6004,"COMPLETED")
 SET activity_type_1 = uar_get_code_by("DISPLAY_KEY",106,"COMMUNICATIONORDERS")
 SET catalog_type_1 = uar_get_code_by("DISPLAY_KEY",6000,"PATIENTCARE")
 SET catalog_cd_3 = uar_get_code_by("DISPLAY_KEY",200,"HOMEMEDSUPDATEDINMEDICATIONPROFILE")
 SET catalog_cd_2 = uar_get_code_by("DISPLAY_KEY",200,"COMPLETEMEDRECONCILIATIONDISCHARGE")
 SET catalog_cd_1 = uar_get_code_by("DISPLAY_KEY",200,"COMPLETEMEDRECONCILIATIONADMIT")
 DECLARE strtend = vc
 SELECT
  IF (any_status_ind="C")
   PLAN (d1)
    JOIN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(cnvtdate( $ST_DT),0000) AND cnvtdatetime(cnvtdate(
       $EN_DT),235959)
     AND ((e.encntr_type_cd+ 0)=679656.00))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (ep
    WHERE ep.encntr_id=e.encntr_id
     AND ep.encntr_prsnl_r_cd=1119
     AND ep.prsnl_person_id > 0
     AND ((ep.active_ind=1
     AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000))) OR (ep.active_ind=0
     AND ((ep.expire_dt_tm+ 0) != null)
     AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000)))) )
    JOIN (p2
    WHERE p2.person_id=ep.prsnl_person_id)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=fnbr)
    JOIN (o
    WHERE o.encntr_id=outerjoin(e.encntr_id)
     AND o.catalog_cd=outerjoin(792016))
    JOIN (oa
    WHERE oa.order_id=outerjoin(o.order_id)
     AND oa.action_sequence=outerjoin(1)
     AND oa.action_personnel_id > outerjoin(0))
    JOIN (p1
    WHERE p1.person_id=outerjoin(oa.action_personnel_id))
    JOIN (o1
    WHERE o1.encntr_id=outerjoin(e.encntr_id)
     AND o1.catalog_cd=outerjoin(catalog_cd_1)
     AND o1.order_status_cd=outerjoin(status_2))
    JOIN (o2
    WHERE o2.encntr_id=outerjoin(e.encntr_id)
     AND o2.catalog_cd=outerjoin(61245331.00))
    JOIN (o3
    WHERE o3.encntr_id=outerjoin(e.encntr_id)
     AND o3.need_rx_verify_ind=outerjoin(0)
     AND o3.activity_type_cd=outerjoin(705)
     AND o3.catalog_type_cd=outerjoin(2516)
     AND o3.orig_ord_as_flag IN (outerjoin(1), outerjoin(2)))
    JOIN (oa3
    WHERE oa3.order_id=outerjoin(o3.order_id)
     AND oa3.action_sequence=outerjoin(1)
     AND oa3.action_personnel_id > outerjoin(0))
  ELSE
   PLAN (d1)
    JOIN (e
    WHERE e.disch_dt_tm BETWEEN cnvtdatetime(cnvtdate( $ST_DT),0000) AND cnvtdatetime(cnvtdate(
       $EN_DT),235959)
     AND ((e.encntr_type_cd+ 0)=679656.00))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (ep
    WHERE ep.encntr_id=e.encntr_id
     AND ep.encntr_prsnl_r_cd=1119
     AND (ep.prsnl_person_id= $PHYSICIAN_ID)
     AND ((ep.active_ind=1
     AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000))) OR (ep.active_ind=0
     AND ((ep.expire_dt_tm+ 0) != null)
     AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000)))) )
    JOIN (p2
    WHERE p2.person_id=ep.prsnl_person_id)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=fnbr)
    JOIN (o
    WHERE o.encntr_id=outerjoin(e.encntr_id)
     AND o.catalog_cd=outerjoin(792016))
    JOIN (oa
    WHERE oa.order_id=outerjoin(o.order_id)
     AND oa.action_sequence=outerjoin(1)
     AND oa.action_personnel_id > outerjoin(0))
    JOIN (p1
    WHERE p1.person_id=outerjoin(oa.action_personnel_id))
    JOIN (o1
    WHERE o1.encntr_id=outerjoin(e.encntr_id)
     AND o1.catalog_cd=outerjoin(catalog_cd_1)
     AND o1.order_status_cd=outerjoin(status_2))
    JOIN (o2
    WHERE o2.encntr_id=outerjoin(e.encntr_id)
     AND o2.catalog_cd=outerjoin(61245331.00))
    JOIN (o3
    WHERE o3.encntr_id=outerjoin(e.encntr_id)
     AND o3.need_rx_verify_ind=outerjoin(0)
     AND o3.activity_type_cd=outerjoin(705)
     AND o3.catalog_type_cd=outerjoin(2516)
     AND o3.orig_ord_as_flag IN (outerjoin(1), outerjoin(2)))
    JOIN (oa3
    WHERE oa3.order_id=outerjoin(o3.order_id)
     AND oa3.action_sequence=outerjoin(1)
     AND oa3.action_personnel_id > outerjoin(0))
  ENDIF
  DISTINCT INTO value(output_dest)
  pat_name = substring(1,30,trim(p.name_full_formatted)), acct_nbr = cnvtalias(ea.alias,ea
   .alias_pool_cd), phys =
  IF (p1.person_id=0.0) trim(p2.name_full_formatted)
  ELSE trim(p1.name_full_formatted)
  ENDIF
  ,
  adm_med_rec_dt =
  IF (o1.orig_order_dt_tm=null) " "
  ELSE format(o1.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;d")
  ENDIF
  , med_rec_ord =
  IF (o2.orig_order_dt_tm != null) "Yes"
  ELSE "No"
  ENDIF
  , med_prof_updt = o3.updt_dt_tm"@SHORTDATETIME",
  disch_ord_dt =
  IF (o.orig_order_dt_tm=null) "No Ord by Clin Staff"
  ELSE format(o.orig_order_dt_tm,"mm/dd/yyyy HH:MM;;d")
  ENDIF
  , e.disch_dt_tm"@SHORTDATETIME", diff_disch_ord =
  IF (datetimediff(o.orig_order_dt_tm,o3.updt_dt_tm,3) <= 2.00
   AND o.orig_order_dt_tm != null
   AND oa3.action_personnel_id=p2.person_id) "Yes"
  ELSE "No"
  ENDIF
  ,
  diff_disch_ord2 =
  IF (datetimediff(o.orig_order_dt_tm,o3.updt_dt_tm,3) <= 2.00
   AND o.orig_order_dt_tm != null
   AND oa3.action_personnel_id != p2.person_id) "Yes"
  ELSE "No"
  ENDIF
  , diff_disch_dt =
  IF (datetimediff(e.disch_dt_tm,o3.updt_dt_tm,3) <= 2.00) "Yes"
  ELSE "No"
  ENDIF
  , attend_phy = trim(p2.name_full_formatted)
  FROM dummyt d1,
   encounter e,
   person p,
   encntr_alias ea,
   encntr_prsnl_reltn ep,
   prsnl p2,
   orders o,
   order_action oa,
   prsnl p1,
   orders o1,
   orders o2,
   orders o3,
   order_action oa3
  ORDER BY phys, acct_nbr
  HEAD REPORT
   col 1, "Medication Reconciliation Detail Report", row + 1,
   date = format(curdate,"mm/dd/yyyy;;q"), col 1, "Report Date: ",
   date, row + 1, strtend = build("Range: ",format(cnvtdatetime(cnvtdate( $ST_DT),0000),
     "mm/dd/yyyy hh:mm;;d")," - ",format(cnvtdatetime(cnvtdate( $EN_DT),2359),"mm/dd/yyyy hh:mm;;d")),
   col 1, strtend, row + 1,
   time = format(curtime3,"hh:mm"), strtend = build("Phys Name",",","Patient Name",",","Account Num",
    ",","Admit Med Recon Date",",","Discharge Order Date",",",
    "Phys. Recon Order Placed",",","Home Meds Updt by Attd",",","Home Meds Updt by Other"), col 1,
   strtend, row + 1
  DETAIL
   pat_name = replace(pat_name,","," ",0), phys = replace(phys,","," ",0), strtend = build(phys,",",
    pat_name,",",acct_nbr,
    ",",adm_med_rec_dt,",",disch_ord_dt,",",
    med_rec_ord,",",diff_disch_ord,",",diff_disch_ord2),
   col 1, strtend, row + 1
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 IF (email_ind=1)
  SET filename_in = concat(trim(output_dest),".dat")
  SET filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog," - Med Recon Detail ",beg_date_disp," to ",end_date_disp)
  SET dclcom = concat('sed "s/$/`echo \\\r`/" ',filename_in)
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
END GO
