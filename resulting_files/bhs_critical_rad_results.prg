CREATE PROGRAM bhs_critical_rad_results
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Recipient email(s)" = ""
  WITH outdev, recipient_emails
 DECLARE ocfcomp_var = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE nocomp_var = f8 WITH constant(uar_get_code_by("MEANING",120,"NOCOMP")), protect
 DECLARE blobout = vc
 DECLARE output_ceblob = vc
 DECLARE bsize = i4
 DECLARE blobcatstr = vc
 DECLARE longblob_ocfcomp_var = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE longblob_nocomp_var = f8 WITH constant(uar_get_code_by("MEANING",120,"NOCOMP")), protect
 DECLARE longblob_out = vc
 DECLARE output_longblob = vc
 DECLARE longblob_size = i4
 DECLARE longblob_catstr = vc
 DECLARE ms_outfile = vc WITH protect, constant(concat("rad_result",format(curdate,"YYYYMMDD;;D"),
   ".csv"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_recipient_emails = vc WITH protect, constant( $RECIPIENT_EMAILS)
 IF (findstring("@",ms_recipient_emails)=0)
  CALL echo("###########################################")
  CALL echo(build("Invalid email recipients list"))
  CALL echo("###########################################")
  GO TO exit_script
 ENDIF
 SET start_date = cnvtlookbehind("1M",cnvtdatetime(((curdate - day(curdate))+ 1),0))
 SET end_date = cnvtlookbehind("1D",cnvtlookahead("1M",start_date))
 SELECT INTO value(ms_outfile)
  o.accession, patient_name = per.name_full_formatted, mrn = ea.alias,
  exam = uar_get_code_display(o.catalog_cd), re.complete_dt_tm, pp.name_full_formatted,
  c.blob_contents, l.long_blob
  FROM encntr_alias ea,
   order_radiology o,
   person per,
   rad_exam re,
   rad_report_prsnl rrp,
   rad_report_detail rrd,
   rad_report rre,
   prsnl pp,
   ce_blob c,
   long_blob l,
   ce_event_note cen
  WHERE cen.ce_event_note_id=l.parent_entity_id
   AND cen.event_id=c.event_id
   AND cen.event_id=rrd.detail_event_id
   AND c.event_id=rrd.detail_event_id
   AND pp.person_id=rrp.report_prsnl_id
   AND rre.rad_report_id=rrp.rad_report_id
   AND rrp.rad_report_id=rrd.rad_report_id
   AND rrp.prsnl_relation_flag=2
   AND o.order_id=rre.order_id
   AND re.order_id=o.order_id
   AND per.person_id=o.person_id
   AND ea.encntr_id=o.encntr_id
   AND ea.active_ind=1
   AND ea.end_effective_dt_tm > sysdate
   AND ea.encntr_alias_type_cd=1079
   AND re.sched_req_dt_tm BETWEEN cnvtlookbehind("1M",cnvtdatetime(((curdate - day(curdate))+ 1),0))
   AND cnvtlookahead("1M",cnvtlookbehind("1M",cnvtdatetime(((curdate - day(curdate))+ 1),0)))
   AND sysdate BETWEEN c.valid_from_dt_tm AND c.valid_until_dt_tm
   AND (cen.ce_event_note_id=
  (SELECT
   max(cen.ce_event_note_id)
   FROM ce_event_note cen
   WHERE event_id=c.event_id))
  ORDER BY c.event_id DESC
  HEAD REPORT
   ms_line = concat("RADIOLOGY REPORT for CRITICAL RESULTS ",format(cnvtdatetime(start_date),
     "MM/DD/YY HH:MM;;D")," to ",format(cnvtdatetime(end_date),"MM/DD/YY HH:MM;;D")), col 0, ms_line,
   row + 1, row + 1, ms_line = concat('"Accession","Patient Name","MRN","Exam Name"',
    ',"Exam Complete Date","Exam Complete Time","Radiologist Name"',
    ',"Radiology Report","Dictation_Details"'),
   col 0, ms_line
  HEAD o.accession
   blobcatstr = " ", longblob_catstr = " "
  DETAIL
   blobout = notrim(fillstring(32768," ")), output_ceblob = notrim(fillstring(32768," "))
   IF (c.compression_cd=ocfcomp_var)
    uncompsize = 0, blob_un = uar_ocf_uncompress(c.blob_contents,size(c.blob_contents),blobout,size(
      blobout),uncompsize), stat = uar_rtf2(blobout,uncompsize,output_ceblob,size(output_ceblob),
     bsize,
     0),
    output_ceblob = substring(1,bsize,output_ceblob)
   ELSE
    output_ceblob = c.blob_contents
   ENDIF
   blob_final2 = replace(output_ceblob,char(20),""), blob_final3 = replace(blob_final2,"ocf_blob",""),
   blob_final4 = replace(blob_final3,"          ","  "),
   blobcatstr = concat(blobcatstr,blob_final4),
   CALL echo("blobcatstr"),
   CALL echo(blobcatstr),
   longblob_out = notrim(fillstring(32768," ")), output_longblob = notrim(fillstring(32768," "))
   IF (cen.compression_cd=longblob_ocfcomp_var)
    uncompsize_longblob = 0, long_blob_un = uar_ocf_uncompress(l.long_blob,size(l.long_blob),
     longblob_out,size(longblob_out),uncompsize_longblob), stat = uar_rtf2(longblob_out,
     uncompsize_longblob,output_longblob,size(output_longblob),longblob_size,
     0),
    output_longblob = substring(1,longblob_size,output_longblob)
   ELSE
    output_longblob = l.long_blob
   ENDIF
   longblob_catstr = concat(longblob_catstr,output_longblob)
   IF (findstring("CRITICAL RESULT",cnvtupper(blobcatstr)) > 0)
    row + 1, ms_line = build('"',o.accession,'"',",",'"',
     patient_name,'"',",",mrn,",",
     '"',exam,'"',",",format(re.complete_dt_tm,"DD-MMM-YYYY;;D"),
     ",",format(re.complete_dt_tm,"HH:MM:SS;;M"),",",'"',pp.name_full_formatted,
     '"',",",'"',blobcatstr,'"',
     ",",'"',longblob_catstr,'"'), col 0,
    ms_line
   ENDIF
  FOOT REPORT
   row + 1
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 30000, maxrow = 1
 ;end select
 EXECUTE bhs_sys_stand_subroutine
 CALL emailfile(ms_outfile,ms_outfile,ms_recipient_emails,concat(
   "RADIOLOGY REPORT for CRITICAL RESULTS ",format(cnvtdatetime(start_date),"MM/DD/YY HH:MM;;D"),
   " to ",format(cnvtdatetime(end_date),"MM/DD/YY HH:MM;;D")),0)
END GO
