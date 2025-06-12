CREATE PROGRAM bhs_rpt_restricted
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "begdate" = "SYSDATE",
  "enddate" = "SYSDATE",
  "runType" = 0
  WITH outdev, begdate, enddate,
  runtype
 FREE RECORD res
 RECORD res(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 rpt_title = vc
   1 list[*]
     2 login_id = vc
     2 user_nm = vc
     2 pt_nm = vc
     2 mrn = vc
     2 event_dt = vc
     2 event_tm = vc
 )
 DECLARE mf_position_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSPCOOFFICESTAFF")),
 protect
 DECLARE mf_position_cd1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSPCOWOENOEZSCRIPT")),
 protect
 DECLARE mf_position_cd2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSOBGYNMD")), protect
 DECLARE mf_position_cd3 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSLABMEDTECHBMC")),
 protect
 DECLARE mf_position_cd4 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSONCOLOGYMD")),
 protect
 DECLARE mf_position_cd5 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSPHYSICIANNEUROLOGY")),
 protect
 DECLARE mf_restricted_reltn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "BEHAVIORALHEALTHSCANNER"))
 DECLARE mf_restricted_reltn_cd1 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "ZLABTECHGENETICSSCANNER")), protect
 DECLARE mf_restricted_reltn_cd2 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,
   "ZGENETICCOUNSELOR")), protect
 DECLARE mf_restricted_reltn_cd3 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"ZGENETICIST")),
 protect
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE ms_posval = vc WITH noconstant(" ")
 DECLARE ms_relval = vc WITH noconstant(" ")
 DECLARE mn_email_ind = i4
 DECLARE mn_cnt = i4
 DECLARE mf_filename_in = vc
 DECLARE mf_filename_out = vc
 DECLARE mf_subject_line = vc
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET mn_email_ind = 0
  SET output_dest =  $OUTDEV
 ENDIF
 IF (cnvtupper( $BEGDATE) IN ("BEGOFWEEKLY", "BOW"))
  SET beg_date_qual = datetimefind(cnvtdatetime((curdate - 6),0000),"W","B","B")
 ELSE
  SET beg_date_qual = cnvtdatetime(cnvtdate( $BEGDATE),0000)
 ENDIF
 IF (cnvtupper( $ENDDATE) IN ("ENDOFWEEKLY", "EOW"))
  SET end_date_qual = datetimefind(cnvtdatetime((curdate - 6),235959),"W","E","E")
 ELSE
  SET end_date_qual = cnvtdatetime(cnvtdate( $ENDDATE),235959)
 ENDIF
 SET beg_date_disp = format(beg_date_qual,"MM/DD/YYYY;;d")
 SET end_date_disp = format(end_date_qual,"MM/DD/YYYY;;d")
 CALL echo(beg_date_disp)
 CALL echo(end_date_disp)
 SET s_date = beg_date_qual
 SET e_date = datetimeadd(s_date,7)
 IF (e_date >= end_date_qual)
  SET e_date = end_date_qual
 ENDIF
 IF (( $RUNTYPE=0))
  SET res->beg_dt_tm = cnvtdatetime( $BEGDATE)
  SET res->end_dt_tm = cnvtdatetime( $ENDDATE)
  SET res->rpt_title = "Behavioral Health Restricted Folder Access Report"
 ELSEIF (( $RUNTYPE=1))
  SET res->beg_dt_tm = cnvtdatetime( $BEGDATE)
  SET res->end_dt_tm = cnvtdatetime( $ENDDATE)
  SET res->rpt_title = "Genetics Consoler Report"
 ELSE
  SET res->beg_dt_tm = s_date
  SET res->end_dt_tm = e_date
  SET res->rpt_title = "Genetics Consoler Weekly Report"
 ENDIF
 SET mn_cnt = 0
 SELECT INTO "nl:"
  login_id = substring(1,50,pr.username), user_name = substring(1,50,pr.name_full_formatted), pt_name
   = substring(1,50,p.name_full_formatted),
  mrn = cnvtalias(ea2.alias,ea2.encntr_alias_type_cd), event_occured_date = format(epr
   .transaction_dt_tm,"@SHORTDATE"), event_occured_time = format(epr.transaction_dt_tm,
   "@TIMENOSECONDS")
  FROM encntr_prsnl_reltn epr,
   prsnl pr,
   encounter e,
   person p,
   encntr_alias ea2
  PLAN (epr
   WHERE epr.expiration_ind IN (0, 1)
    AND ((( $RUNTYPE=0)
    AND epr.encntr_prsnl_r_cd=mf_restricted_reltn_cd) OR (( $RUNTYPE > 0)
    AND epr.encntr_prsnl_r_cd IN (mf_restricted_reltn_cd1, mf_restricted_reltn_cd2,
   mf_restricted_reltn_cd3)))
    AND epr.transaction_dt_tm BETWEEN cnvtdatetime(res->beg_dt_tm) AND cnvtdatetime(res->end_dt_tm))
   JOIN (pr
   WHERE epr.prsnl_person_id=pr.person_id
    AND ((( $RUNTYPE=0)
    AND pr.position_cd=mf_position_cd) OR (( $RUNTYPE > 0)
    AND pr.position_cd IN (mf_position_cd, mf_position_cd1, mf_position_cd2, mf_position_cd3,
   mf_position_cd4,
   mf_position_cd5))) )
   JOIN (e
   WHERE e.encntr_id=epr.encntr_id
    AND e.end_effective_dt_tm >= sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.end_effective_dt_tm >= sysdate)
   JOIN (ea2
   WHERE (ea2.encntr_id= Outerjoin(e.encntr_id))
    AND (ea2.active_ind= Outerjoin(1))
    AND (ea2.encntr_alias_type_cd= Outerjoin(mf_mrn_cd)) )
  ORDER BY epr.transaction_dt_tm DESC
  HEAD epr.encntr_prsnl_reltn_id
   mn_cnt += 1, stat = alterlist(res->list,mn_cnt), res->list[mn_cnt].login_id = login_id,
   res->list[mn_cnt].user_nm = user_name, res->list[mn_cnt].pt_nm = pt_name, res->list[mn_cnt].mrn =
   mrn,
   res->list[mn_cnt].event_dt = event_occured_date, res->list[mn_cnt].event_tm = event_occured_time
  WITH nocounter
 ;end select
 CALL echorecord(res)
 IF (curqual > 0)
  SELECT INTO value(output_dest)
   FROM (dummyt d  WITH seq = value(size(res->list,5)))
   PLAN (d)
   HEAD REPORT
    output_line1 = concat("Baystate Health ",trim(substring(1,50,res->rpt_title))," Beginning Date: ",
     format(cnvtdatetime(res->beg_dt_tm),"MM/DD/YYYY;;q")," Ending Date: ",
     format(cnvtdatetime(res->end_dt_tm),"MM/DD/YYYY;;q")), output_line = build(',"',"Login Id",'","',
     "User Name",'","',
     "Patient Name",'","',"MRN",'","',"Event Occured Date",
     '","',"Event Occured Time              ",'",'), col 1,
    output_line1, row + 1, col 1,
    output_line, row + 1
   DETAIL
    output_line = build(',"',substring(1,50,res->list[d.seq].login_id),'","',substring(1,50,res->
      list[d.seq].user_nm),'","',
     substring(1,50,res->list[d.seq].pt_nm),'","',substring(1,30,res->list[d.seq].mrn),'","',
     substring(1,30,res->list[d.seq].event_dt),
     '","',substring(1,30,res->list[d.seq].event_tm),'",'), col 1, output_line,
    row + 1
   WITH maxcol = 10000, formfeed = none, maxrow = 1,
    format = variable
  ;end select
  IF (( $RUNTYPE=2))
   SET mf_filename_in = concat(trim(output_dest),".dat")
   SET mf_filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
   SET mf_subject_line = concat(curprog," - Genetics Counselor Relationship Rpt ",beg_date_disp,
    " to ",end_date_disp)
   EXECUTE bhs_ma_email_file
   CALL emailfile(mf_filename_in,mf_filename_out, $1,mf_subject_line,1)
  ENDIF
 ELSE
  IF (( $RUNTYPE=2))
   SET mf_filename_in = concat(trim(output_dest),".dat")
   SET mf_filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
   SET mf_subject_line = concat(curprog," - Genetics Counselor Relationship Rpt ",beg_date_disp,
    " to ",end_date_disp)
   EXECUTE bhs_ma_email_file
   CALL emailfile(mf_filename_in,mf_filename_out, $1,mf_subject_line,1)
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt
    HEAD REPORT
     msg1 = "No qualified data for the time range", col 0, "{PS/792 0 translate 90 rotate/}",
     y_pos = 18, row + 1, "{F/1}{CPI/7}",
     CALL print(calcpos(36,(y_pos+ 0))), msg1, row + 2
    WITH dio = 08
   ;end select
   GO TO exit_prog
  ENDIF
 ENDIF
#exit_prog
END GO
