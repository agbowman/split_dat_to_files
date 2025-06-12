CREATE PROGRAM bhs_rw_pco_metrics:dba
 CALL echo(build2("Beginning Program:"," ",format(cnvtdatetime(curdate,curtime3),";;Q")))
 CALL echo("")
 IF (( $2="999"))
  SET beg_dt_tm = format(datetimefind(cnvtdatetime((cnvtdate(datetimefind(cnvtdatetime(curdate,0),"M",
       "B","B")) - 1),0),"M","B","B"),"DD-MMM-YYYY;;D")
  SET end_dt_tm = format(datetimefind(cnvtdatetime((cnvtdate(datetimefind(cnvtdatetime(curdate,0),"M",
       "B","B")) - 1),0),"M","E","E"),"DD-MMM-YYYY;;D")
 ELSE
  SET beg_dt_tm = cnvtdatetime(cnvtdate( $2),0)
  SET end_dt_tm = cnvtdatetime(cnvtdate( $3),235959)
 ENDIF
 CALL echo(build2("BEG_DT_TM ",format(beg_dt_tm,";;Q")))
 CALL echo(build2("END_DT_TM ",format(end_dt_tm,";;Q")))
 IF (findstring("@", $1) > 0)
  SET email_ind = 1
  SET output_dest = trim(concat(cnvtlower(curprog),format(beg_dt_tm,"MMDDYYYY;;D")),4)
 ELSE
  SET email_ind = 0
  SET output_dest = trim( $1,3)
 ENDIF
 FREE RECORD work
 RECORD work(
   1 pr_cnt = i4
   1 prsnl[*]
     2 person_id = f8
     2 full_name = vc
     2 first_name = vc
     2 last_name = vc
     2 allergy_cnt = i4
   1 idx_prsnl[*]
     2 person_id = f8
     2 prsnl_slot = i4
   1 tp_cnt = i4
   1 test_persons[*]
     2 person_id = f8
   1 te_cnt = i4
   1 test_encntrs[*]
     2 encntr_id = f8
 )
 DECLARE tbl_slot = i4 WITH noconstant(0)
 DECLARE rpt_slot = i4 WITH noconstant(0)
 DECLARE tmp_tp = i4 WITH noconstant(0)
 DECLARE tmp_te = i4 WITH noconstant(0)
 SELECT DISTINCT INTO "NL:"
  p.person_id
  FROM organization o,
   encounter e,
   person p
  PLAN (o
   WHERE o.org_name_key="MOCKBAYSTATEHEALTHSYSTEM")
   JOIN (e
   WHERE o.organization_id=e.organization_id)
   JOIN (p
   WHERE e.person_id=p.person_id)
  ORDER BY p.person_id
  HEAD REPORT
   tp_cnt = 0
  DETAIL
   tp_cnt = (work->tp_cnt+ 1), work->tp_cnt = tp_cnt, stat = alterlist(work->test_persons,tp_cnt),
   work->test_persons[tp_cnt].person_id = p.person_id
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "NL:"
  e.encntr_id
  FROM person p,
   encounter e
  PLAN (p
   WHERE expand(tmp_tp,1,work->tp_cnt,p.person_id,work->test_persons[tmp_tp].person_id))
   JOIN (e
   WHERE p.person_id=e.person_id)
  ORDER BY e.encntr_id
  HEAD REPORT
   te_cnt = 0
  DETAIL
   te_cnt = (work->te_cnt+ 1), work->te_cnt = te_cnt, stat = alterlist(work->test_encntrs,te_cnt),
   work->test_encntrs[te_cnt].encntr_id = e.encntr_id
  WITH nocounter
 ;end select
 CALL echo("")
 CALL echo(build2("Gather Physicians Begin:"," ",format(cnvtdatetime(curdate,curtime3),";;Q")))
 CALL echo("")
 DECLARE cs88_bhs_dba_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSDBA"))
 DECLARE cs88_dba_bhs_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"DBABHS"))
 DECLARE cs88_dba_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"DBA"))
 SELECT INTO "NL:"
  FROM prsnl pr,
   omf_app_ctx_month_st omf
  PLAN (omf
   WHERE omf.start_month BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)
    AND omf.application_number=961000)
   JOIN (pr
   WHERE omf.person_id=pr.person_id
    AND pr.physician_ind=1
    AND trim(pr.username,3) > " "
    AND  NOT ( EXISTS (
   (SELECT
    pr2.person_id
    FROM prsnl pr2
    WHERE pr.name_last_key=pr2.name_last_key
     AND pr.name_first_key=pr2.name_first_key
     AND pr2.position_cd IN (cs88_bhs_dba_cd, cs88_dba_bhs_cd, cs88_dba_cd)))))
  ORDER BY pr.name_full_formatted
  HEAD REPORT
   pr_cnt = 0, x_slot = 0
  DETAIL
   pr_cnt = (pr_cnt+ 1), stat = alterlist(work->prsnl,pr_cnt), stat = alterlist(work->idx_prsnl,
    pr_cnt),
   work->pr_cnt = pr_cnt, work->prsnl[pr_cnt].person_id = pr.person_id, work->prsnl[pr_cnt].
   first_name = pr.name_first,
   work->prsnl[pr_cnt].last_name = pr.name_last, work->prsnl[pr_cnt].full_name = pr
   .name_full_formatted, x_slot = pr_cnt,
   work->idx_prsnl[x_slot].person_id = pr.person_id, work->idx_prsnl[x_slot].prsnl_slot = pr_cnt
   WHILE ((work->idx_prsnl[(x_slot - 1)].person_id > work->idx_prsnl[x_slot].person_id)
    AND x_slot > 1)
     work->idx_prsnl[x_slot].person_id = work->idx_prsnl[(x_slot - 1)].person_id, work->idx_prsnl[
     x_slot].prsnl_slot = work->idx_prsnl[(x_slot - 1)].prsnl_slot, work->idx_prsnl[(x_slot - 1)].
     person_id = pr.person_id,
     work->idx_prsnl[(x_slot - 1)].prsnl_slot = pr_cnt, x_slot = (x_slot - 1)
   ENDWHILE
  WITH nocounter
 ;end select
 FREE SET cs88_bhs_dba_cd
 FREE SET cs88_dba_bhs_cd
 FREE SET cs88_dba_cd
 CALL echo("")
 CALL echo(build2("Gather Physicians End:"," ",format(cnvtdatetime(curdate,curtime3),";;Q")))
 CALL echo(cost(3))
 IF ((work->pr_cnt <= 0))
  CALL echo("No Providers found. Exiting Script")
  GO TO exit_script
 ENDIF
 CALL echo("")
 CALL echo(build2("Gather Allergies Begin:"," ",format(cnvtdatetime(curdate,curtime3),";;Q")))
 CALL echo("")
 SET tbl_slot = 0
 SET rpt_slot = 0
 SET tmp_te = 0
 SET tmp_tp = 0
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(work->pr_cnt)),
   allergy a
  PLAN (d)
   JOIN (a
   WHERE (((work->idx_prsnl[d.seq].person_id=a.updt_id)
    AND a.updt_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm)) OR ((work->
   idx_prsnl[d.seq].person_id=a.reviewed_prsnl_id)
    AND a.reviewed_dt_tm BETWEEN cnvtdatetime(beg_dt_tm) AND cnvtdatetime(end_dt_tm))) )
  DETAIL
   work->prsnl[d.seq].allergy_cnt = (work->prsnl[d.seq].allergy_cnt+ 1)
  WITH nocounter
 ;end select
 CALL echo("")
 CALL echo(build2("Gather Allergies End:"," ",format(cnvtdatetime(curdate,curtime3),";;Q")))
 CALL echo(cost(3))
 CALL echo(" ")
 CALL echorecord(work)
#exit_script
END GO
