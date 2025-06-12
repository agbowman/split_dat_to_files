CREATE PROGRAM bhs_rpt_charge_by_batch_summ:dba
 PROMPT
  "Name of file: " = "MINE",
  "e-mail address to send report to:" = "",
  "Batch Number:" = 0
  WITH outdev, ms_email, var_batch_num
 DECLARE 13028_cr = f8 WITH public, constant(uar_get_code_by("MEANING",13028,"CR"))
 DECLARE 13028_dr = f8 WITH public, constant(uar_get_code_by("MEANING",13028,"DR"))
 DECLARE intfile_001 = f8 WITH public, noconstant
 DECLARE intfile_002 = f8 WITH public, noconstant
 DECLARE intfile_waste = f8 WITH public, noconstant
 DECLARE intfile_test = f8 WITH public, noconstant
 DECLARE ms_output_dev = vc WITH protect, noconstant("")
 DECLARE node = vc WITH public, noconstant
 DECLARE batch_num = i4 WITH public, noconstant
 DECLARE ml_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_output_dest = vc WITH protect, noconstant("")
 SET intfile_001 = 592027
 SET intfile_002 = 594283
 SET intfile_waste = 596247
 SET intfile_test = 596663
 SET node = trim(curnode,3)
 IF (size(trim( $MS_EMAIL)) > 0)
  SET ms_output_dev = concat( $OUTDEV,"_",format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHH24MMSS;;D"
    ),".pdf")
  SET ml_email_ind = 1
 ELSE
  SET ms_output_dev =  $1
 ENDIF
 IF ((value( $VAR_BATCH_NUM)=- (1)))
  SELECT INTO "NL:"
   ic.batch_num
   FROM interface_charge ic
   WHERE ic.beg_effective_dt_tm > cnvtlookbehind("50, MIN")
   DETAIL
    batch_num = ic.batch_num
   WITH nocounter, maxrec = 1
  ;end select
  SET batch_num_disp = value( $VAR_BATCH_NUM)
  CALL echo(batch_num)
  CALL echo(batch_num_disp)
 ELSE
  SET batch_num = value( $VAR_BATCH_NUM)
 ENDIF
 SET a01 = 001
 SET a02 = ((a01+ 1)+ 049)
 SET a03 = ((a02+ 1)+ 008)
 SET a04 = ((a03+ 1)+ 008)
 SET a05 = ((a04+ 1)+ 008)
 SET a06 = ((a05+ 1)+ 032)
 SET a07 = ((a06+ 1)+ 004)
 SET a08 = ((a07+ 1)+ 012)
 SET a09 = ((a08+ 1)+ 012)
 SET a10 = ((a09+ 1)+ 012)
 SET b01 = 020
 SET b02 = ((b01+ 2)+ 015)
 SET b03 = ((b02+ 2)+ 008)
 SET b04 = ((b03+ 1)+ 008)
 SET b05 = ((b04+ 1)+ 008)
 SET b06 = ((b05+ 1)+ 010)
 SET b07 = ((b06+ 1)+ 012)
 SET b08 = ((b07+ 1)+ 012)
 SET b09 = ((b08+ 1)+ 012)
 SET b10 = ((b09+ 1)+ 012)
 SET 80_equal = fillstring(79,"=")
 SET 132_equal = fillstring(130,"=")
 SET 80_dash = fillstring(79,"-")
 SET 132_dash = fillstring(130,"-")
 SELECT INTO value(ms_output_dev)
  ic.fin_nbr, ic.person_name, ic.prim_cdm,
  ic.prim_cdm_desc, ic.ext_bill_qty, ic.service_dt_tm,
  ic_srvc_dt = floor(ic.service_dt_tm), ic.posted_dt_tm, ic.batch_num,
  c.tier_group_cd, tier_grp_disp = uar_get_code_display(c.tier_group_cd)
  FROM interface_charge ic,
   charge c
  PLAN (ic
   WHERE ic.batch_num=batch_num
    AND ic.active_ind=1
    AND ic.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ic.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (c
   WHERE ic.charge_item_id=c.charge_item_id
    AND c.active_ind=1
    AND c.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ic.batch_num, tier_grp_disp, ic.fin_nbr,
   ic_srvc_dt, ic.prim_cdm
  HEAD REPORT
   col 000, "{F/0}", row + 1,
   col a01, "Daily Charge Batch Report", print_dt_tm_disp = trim(concat("Print Dt/Tm:  ",format(
      sysdate,"MM/DD/YY HH:MM;;Q")),3),
   col a02, print_dt_tm_disp, row + 1,
   node_dev_disp = trim(concat(trim(node,3)," / ",trim(ms_output_dev,3)),3), col_stat = (79 - textlen
   (node_dev_disp)), col col_stat,
   node_dev_disp, row + 1, col 000,
   80_equal, row + 2, tot_cntr = 0,
   tot_dr_cntr = 0, tot_cr_cntr = 0, nc_cntr = 0,
   nc_dr_cntr = 0, nc_cr_cntr = 0, manl_cntr = 0,
   manl_dr_cntr = 0, manl_cr_cntr = 0, reg_001_cntr = 0,
   reg_001_dr_cntr = 0, reg_001_cr_cntr = 0, reg_002_cntr = 0,
   reg_002_dr_cntr = 0, reg_002_cr_cntr = 0, reg_waste_cntr = 0,
   reg_waste_dr_cntr = 0, reg_waste_cr_cntr = 0, reg_test_cntr = 0,
   reg_test_dr_cntr = 0, reg_test_cr_cntr = 0, dft_tot = 0,
   dft_cr_tot = 0, dft_dr_tot = 0
  HEAD ic.batch_num
   batch_num_val = concat("BATCH  ",cnvtstring(ic.batch_num)), col 007, batch_num_val,
   col 045, ic.beg_effective_dt_tm"WWW MMM DD, YYYY  HH:MM;;Q", row + 1,
   col 000, 80_dash, row + 2
  DETAIL
   IF (trim(ic.prim_cdm,3)="NO_CHG")
    nc_cntr = (nc_cntr+ 1)
    IF (ic.charge_type_cd=13028_dr)
     nc_dr_cntr = (nc_dr_cntr+ 1)
    ELSEIF (ic.charge_type_cd=13028_cr)
     nc_cr_cntr = (nc_cr_cntr+ 1)
    ENDIF
   ELSEIF (trim(ic.prim_cdm,3)="MANUAL")
    manl_cntr = (manl_cntr+ 1)
    IF (ic.charge_type_cd=13028_dr)
     manl_dr_cntr = (manl_dr_cntr+ 1)
    ELSEIF (ic.charge_type_cd=13028_cr)
     manl_cr_cntr = (manl_cr_cntr+ 1)
    ENDIF
   ELSE
    CASE (ic.interface_file_id)
     OF intfile_001:
      reg_001_cntr = (reg_001_cntr+ 1),dft_tot = (dft_tot+ 1),
      IF (ic.charge_type_cd=13028_dr)
       reg_001_dr_cntr = (reg_001_dr_cntr+ 1), dft_dr_tot = (dft_dr_tot+ 1)
      ELSEIF (ic.charge_type_cd=13028_cr)
       reg_001_cr_cntr = (reg_001_cr_cntr+ 1), dft_cr_tot = (dft_cr_tot+ 1)
      ENDIF
     OF intfile_002:
      reg_002_cntr = (reg_002_cntr+ 1),dft_tot = (dft_tot+ 1),
      IF (ic.charge_type_cd=13028_dr)
       reg_002_dr_cntr = (reg_002_dr_cntr+ 1), dft_dr_tot = (dft_dr_tot+ 1)
      ELSEIF (ic.charge_type_cd=13028_cr)
       reg_002_cr_cntr = (reg_002_cr_cntr+ 1), dft_cr_tot = (dft_cr_tot+ 1)
      ENDIF
     OF intfile_waste:
      reg_waste_cntr = (reg_waste_cntr+ 1),
      IF (ic.charge_type_cd=13028_dr)
       reg_waste_dr_cntr = (reg_waste_dr_cntr+ 1)
      ELSEIF (ic.charge_type_cd=13028_cr)
       reg_waste_cr_cntr = (reg_waste_cr_cntr+ 1)
      ENDIF
     OF intfile_test:
      reg_test_cntr = (reg_test_cntr+ 1),
      IF (ic.charge_type_cd=13028_dr)
       reg_test_dr_cntr = (reg_test_dr_cntr+ 1)
      ELSEIF (ic.charge_type_cd=13028_cr)
       reg_test_cr_cntr = (reg_test_cr_cntr+ 1)
      ENDIF
    ENDCASE
   ENDIF
   tot_cntr = (tot_cntr+ 1)
   IF (ic.charge_type_cd=13028_dr)
    tot_dr_cntr = (tot_dr_cntr+ 1)
   ELSEIF (ic.charge_type_cd=13028_cr)
    tot_cr_cntr = (tot_cr_cntr+ 1)
   ENDIF
  FOOT  ic.batch_num
   col 000, "{F/1}", row + 1,
   col b02, "De", col b03,
   "Cr", col b04, "Tot",
   row + 1
   IF (manl_cntr > 0)
    col b01, "Man'l:", col b02,
    manl_dr_cntr"#####;;I", col b03, manl_cr_cntr"#####;;I",
    col b04, manl_cntr"#####;;I", row + 1
   ENDIF
   IF (nc_cntr > 0)
    col b01, "No Chg:", col b02,
    nc_dr_cntr"#####;;I", col b03, nc_cr_cntr"#####;;I",
    col b04, nc_cntr"#####;;I", row + 1
   ENDIF
   IF (reg_001_cntr > 0)
    col b01, "001 DFT:", col b02,
    reg_001_dr_cntr"#####;;I", col b03, reg_001_cr_cntr"#####;;I",
    col b04, reg_001_cntr"#####;;I", row + 1
   ENDIF
   IF (reg_002_cntr > 0)
    col b01, "002 DFT:", col b02,
    reg_002_dr_cntr"#####;;I", col b03, reg_002_cr_cntr"#####;;I",
    col b04, reg_002_cntr"#####;;I", row + 1
   ENDIF
   IF (reg_test_cntr > 0)
    col b01, "TEST DFT:", col b02,
    reg_test_dr_cntr"#####;;I", col b03, reg_test_cr_cntr"#####;;I",
    col b04, reg_test_cntr"#####;;I", row + 1
   ENDIF
   IF (reg_waste_cntr > 0)
    col b01, "WASTE DFT:", col b02,
    reg_waste_dr_cntr"#####;;I", col b03, reg_waste_cr_cntr"#####;;I",
    col b04, reg_waste_cntr"#####;;I", row + 1
   ENDIF
   col b01, "-----------------------------------------", row + 1,
   col b01, "Total Chg:", col b02,
   tot_dr_cntr"#####;;I", col b03, tot_cr_cntr"#####;;I",
   col b04, tot_cntr"#####;;I", row + 1,
   col b01, "Total DFT:", col b02,
   dft_dr_tot"#####;;I", col b03, dft_cr_tot"#####;;I",
   col b04, dft_tot"#####;;I", row + 3,
   tot_cntr = 0, tot_dr_cntr = 0, tot_cr_cntr = 0,
   nc_cntr = 0, nc_dr_cntr = 0, nc_cr_cntr = 0,
   manl_cntr = 0, manl_dr_cntr = 0, manl_cr_cntr = 0,
   reg_001_cntr = 0, reg_001_dr_cntr = 0, reg_001_cr_cntr = 0,
   reg_002_cntr = 0, reg_002_dr_cntr = 0, reg_002_cr_cntr = 0,
   reg_waste_cntr = 0, reg_waste_dr_cntr = 0, reg_waste_cr_cntr = 0,
   reg_test_cntr = 0, reg_test_dr_cntr = 0, reg_test_cr_cntr = 0,
   dft_tot = 0, dft_cr_tot = 0, dft_dr_tot = 0
  FOOT REPORT
   col 000, "{F/0}", row + 3,
   col 000, 80_equal, row + 2,
   col 035, "END OF REPORT", row + 2,
   col 000, 80_equal
  WITH maxcol = 80, dio = 38
 ;end select
 IF (ml_email_ind=1
  AND batch_num != 0)
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_output_dev,ms_output_dev, $MS_EMAIL,concat("Charge Batch Summary # ",build(
     batch_num)),1)
 ENDIF
#exit_script
END GO
