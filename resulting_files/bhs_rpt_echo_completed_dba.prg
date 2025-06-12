CREATE PROGRAM bhs_rpt_echo_completed:dba
 DECLARE cs6003_order = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER")), protect
 DECLARE cs6003_complete = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE")), protect
 DECLARE cs6004_completed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")), protect
 DECLARE cs200_echocomp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,"ECHOCOMPLETE")), protect
 DECLARE disp_line = vc
 SET facility_fmc = 673937.00
 FREE RECORD echoord
 RECORD echoord(
   1 qaul[*]
     2 orddttm = c20
     2 compdttm = c20
     2 resultdttm = c20
     2 admitdttm = c20
     2 admitdx = vc
     2 encntrtype = vc
     2 blobcont = vc
     2 ordphys = c40
     2 ordid = vc
     2 encntrid = f8
     2 clineventid = f8
     2 eventid = f8
     2 confdttm = vc
     2 name = vc
     2 fin = vc
     2 mrn = vc
     2 loc = vc
 )
 SELECT INTO "nl:"
  FROM orders o,
   encounter e,
   order_action oa,
   dummyt d,
   prsnl p
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime("01-AUG-2007 00:00:00") AND cnvtdatetime(
    "01-AUG-2008 23:59:59")
    AND ((o.catalog_cd+ 0)=cs200_echocomp)
    AND ((o.order_status_cd+ 0)=cs6004_completed))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_facility_cd=facility_fmc)
   JOIN (d)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=cs6003_complete)
   JOIN (p
   WHERE p.person_id=oa.order_provider_id)
  HEAD REPORT
   cnt = 0, stat = alterlist(echoord->qaul,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(echoord->qaul,(cnt+ 10))
   ENDIF
   echoord->qaul[cnt].orddttm = format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d"), echoord->qaul[cnt].
   ordid = build(cnvtstring(o.order_id),"*"), echoord->qaul[cnt].encntrid = o.encntr_id,
   echoord->qaul[cnt].ordphys = substring(1,40,p.name_full_formatted), echoord->qaul[cnt].compdttm =
   format(oa.action_dt_tm,"mm/dd/yy hh:mm;;d"), echoord->qaul[cnt].admitdttm = format(e.reg_dt_tm,
    "mm/dd/yy hh:mm;;d"),
   echoord->qaul[cnt].admitdx = trim(e.reason_for_visit), echoord->qaul[cnt].loc = build(
    uar_get_code_display(e.loc_nurse_unit_cd),"/",uar_get_code_display(e.loc_room_cd),"-",
    uar_get_code_display(e.loc_bed_cd))
  FOOT REPORT
   stat = alterlist(echoord->qaul,cnt)
  WITH nocounter
 ;end select
 CALL echorecord(echoord)
 SELECT INTO "nl:"
  FROM clinical_event ce,
   (dummyt d  WITH seq = value(size(echoord->qaul,5)))
  PLAN (d)
   JOIN (ce
   WHERE operator(ce.reference_nbr,"LIKE",patstring(echoord->qaul[d.seq].ordid,1))
    AND ce.valid_until_dt_tm > sysdate
    AND ce.contributor_system_cd=689445.00
    AND ce.view_level=1)
  DETAIL
   echoord->qaul[d.seq].resultdttm = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;d"), echoord->qaul[d
   .seq].clineventid = ce.clinical_event_id, echoord->qaul[d.seq].eventid = ce.event_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM ce_blob ceb,
   (dummyt d  WITH seq = value(size(echoord->qaul,5)))
  PLAN (d)
   JOIN (ceb
   WHERE (ceb.event_id=echoord->qaul[d.seq].eventid)
    AND ceb.valid_until_dt_tm > sysdate)
  DETAIL
   echoord->qaul[d.seq].blobcont = trim(ceb.blob_contents)
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(echoord->qaul,5))
   DECLARE blob_in = vc
   DECLARE blob_out = vc
   DECLARE blob_out2 = vc
   SET blob_out = fillstring(32000,"")
   SET blob_out2 = fillstring(32000,"")
   SET blob_return_len = 0
   SET bsize = 0
   SET bflag = 0
   SET locstr = 0
   SET blob_in = echoord->qaul[x].blobcont
   SET stat = uar_ocf_uncompress(blob_in,size(blob_in),blob_out,32000,blob_return_len)
   SET stat = uar_rtf2(blob_out,size(blob_out),blob_out2,size(blob_out2),bsize,
    bflag)
   SET locstr = 0
   SET locstr = findstring("Confirmed ",blob_out2,1,2)
   IF (locstr > 0)
    SET echoord->qaul[x].confdttm = trim(substring(locstr,100,blob_out2))
   ELSE
    SET locstr = findstring("Amended ",blob_out2,1,2)
    IF (locstr > 0)
     SET echoord->qaul[x].confdttm = trim(substring(locstr,100,blob_out2))
    ELSE
     SET echoord->qaul[x].confdttm = " "
    ENDIF
   ENDIF
 ENDFOR
 CALL echorecord(echoord)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(echoord->qaul,5))),
   encounter e,
   encntr_alias ea,
   encntr_alias ea2,
   person p
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=echoord->qaul[d.seq].encntrid))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077
    AND ea.end_effective_dt_tm > sysdate
    AND ea.active_ind=1)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.end_effective_dt_tm > sysdate
    AND ea2.active_ind=1
    AND ea2.encntr_alias_type_cd=1079)
   JOIN (p
   WHERE p.person_id=e.person_id)
  DETAIL
   echoord->qaul[d.seq].name = trim(p.name_full_formatted), echoord->qaul[d.seq].fin = ea.alias,
   echoord->qaul[d.seq].mrn = ea2.alias,
   echoord->qaul[d.seq].encntrtype = uar_get_code_display(e.encntr_type_cd)
  WITH nocounter
 ;end select
 CALL echorecord(echoord)
 IF (size(echoord->qaul,5) > 0)
  SELECT INTO "echo_complete.csv"
   name = echoord->qaul[d.seq].name, fin = echoord->qaul[d.seq].fin, mrn = echoord->qaul[d.seq].mrn,
   loc = echoord->qaul[d.seq].loc, admit = echoord->qaul[d.seq].admitdttm, admitdx = echoord->qaul[d
   .seq].admitdx,
   order_dt_tm = echoord->qaul[d.seq].orddttm, order_complete = echoord->qaul[d.seq].compdttm,
   confirmed_date = echoord->qaul[d.seq].confdttm,
   encounter_type = echoord->qaul[d.seq].encntrtype, result = echoord->qaul[d.seq].resultdttm,
   ordering_phys = echoord->qaul[d.seq].ordphys,
   oid = echoord->qaul[d.seq].ordid
   FROM (dummyt d  WITH seq = value(size(echoord->qaul,5)))
   PLAN (d
    WHERE d.seq > 0)
   WITH format = pcformat
  ;end select
  IF (findfile("echo_complete.csv")=1)
   SET filename_in = "echo_complete.csv"
   SET filename_out = format(curdate,"MMDDYYYY;;D")
   DECLARE subject_line = vc
   SET subject_line = concat(curprog," - Echo Completed Rpt ")
   EXECUTE bhs_ma_email_file
   CALL emailfile(filename_in,filename_in,"naser.sanjar2@bhs.org",subject_line,1)
  ENDIF
 ENDIF
END GO
