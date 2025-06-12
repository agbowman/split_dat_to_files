CREATE PROGRAM bhs_sys_sudit_smri:dba
 FREE DEFINE rtl
 DEFINE rtl "bhscust:smri_oid.txt"
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 oid = f8
     2 eid = f8
     2 pid = f8
     2 ereg = cv
     2 edisch = vc
     2 econt = vc
     2 estatus = vc
     2 pname = vc
     2 pcont = vc
     2 pstatus = vc
     2 acc = vc
 )
 SELECT INTO "nl:"
  FROM rtlt r
  PLAN (r
   WHERE r.line > " ")
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].oid =
   cnvtreal(r.line)
  WITH nocounter, maxrec = 10
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   order_radiology ord,
   encounter e,
   person p
  PLAN (d)
   JOIN (ord
   WHERE (ord.order_id=temp->qual[d.seq].oid))
   JOIN (e
   WHERE e.encntr_id=ord.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  DETAIL
   temp->qual[d.seq].eid = e.encntr_id, temp->qual[d.seq].pid = p.person_id, temp->qual[d.seq].econt
    = uar_get_code_display(e.contributor_system_cd),
   temp->qual[d.seq].edisch = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;q"), temp->qual[d.seq].ereg =
   format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;q"), temp->qual[d.seq].estatus = uar_get_code_display(e
    .data_status_cd),
   temp->qual[d.seq].pcont = uar_get_code_display(p.contributor_system_cd), temp->qual[d.seq].pname
    = p.name_full_formatted, temp->qual[d.seq].pstatus = uar_get_code_display(p.data_status_cd),
   temp->qual[d.seq].acc = ord.accession
  WITH nocounter
 ;end select
 CALL echorecord(temp)
END GO
