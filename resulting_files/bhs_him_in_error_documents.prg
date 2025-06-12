CREATE PROGRAM bhs_him_in_error_documents
 PROMPT
  "Output to File/Printer/MINE " = "MINE",
  "Beginning Date: " = "WEEKAGO",
  "Ending Date: " = "YESTERDAY"
  WITH prompt1, prompt2, prompt3
 IF (( $2="WEEKAGO"))
  SET beg_date_qual = (curdate - 7)
 ELSE
  SET beg_date_qual = cnvtdate( $2)
 ENDIF
 IF (( $3="YESTERDAY"))
  SET end_date_qual = (curdate - 1)
 ELSE
  SET end_date_qual = cnvtdate( $3)
 ENDIF
 FREE RECORD inerr
 RECORD inerr(
   1 list[*]
     2 encntr_id = f8
     2 event_id = f8
     2 prsnl_id = f8
     2 person_id = f8
     2 pat_name = vc
     2 prsnl_name = vc
     2 clinsig_updt_dt_tm = dq8
     2 fin = vc
     2 mrn = vc
     2 reg_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 event_cd = f8
     2 comment = vc
 )
 DECLARE fin_alias_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mrn_alias_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE doc_event_class_cd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE softmed_contrib_sys_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",89,"SOFTMED")
  )
 DECLARE cnt = i4
 SET cnt = 0
 SELECT INTO "nl:"
  FROM clinical_event ce,
   clinical_event ce2
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(beg_date_qual,0) AND cnvtdatetime(end_date_qual,
    235959)
    AND ce.result_status_cd=31
    AND ce.event_class_cd=doc_event_class_cd
    AND ce.contributor_system_cd=softmed_contrib_sys_cd
    AND ce.view_level=1)
   JOIN (ce2
   WHERE ce2.event_id=ce.event_id
    AND ce2.clinical_event_id != ce.clinical_event_id)
  ORDER BY ce.encntr_id, ce.event_id
  HEAD ce.encntr_id
   row + 0
  HEAD ce.event_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(inerr->list,(cnt+ 9))
   ENDIF
   inerr->list[cnt].encntr_id = ce.encntr_id, inerr->list[cnt].person_id = ce.person_id, inerr->list[
   cnt].prsnl_id = ce.updt_id,
   inerr->list[cnt].event_id = ce.event_id, inerr->list[cnt].event_cd = ce2.event_cd, inerr->list[cnt
   ].clinsig_updt_dt_tm = ce.clinsig_updt_dt_tm
  FOOT REPORT
   stat = alterlist(inerr->list,cnt)
  WITH counter
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   encntr_alias fin,
   encntr_alias mrn,
   prsnl pr,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=inerr->list[d.seq].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pr
   WHERE (pr.person_id=inerr->list[d.seq].prsnl_id))
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm
    AND fin.encntr_alias_type_cd=fin_alias_type_cd)
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN mrn.beg_effective_dt_tm AND mrn.end_effective_dt_tm
    AND mrn.encntr_alias_type_cd=mrn_alias_type_cd)
  DETAIL
   inerr->list[d.seq].pat_name = p.name_full_formatted, inerr->list[d.seq].prsnl_name = substring(1,
    30,pr.name_full_formatted), inerr->list[d.seq].reg_dt_tm = e.reg_dt_tm,
   inerr->list[d.seq].disch_dt_tm = e.disch_dt_tm, inerr->list[d.seq].mrn = substring(1,12,cnvtalias(
     mrn.alias,mrn.alias_pool_cd)), inerr->list[d.seq].fin = substring(1,15,cnvtalias(fin.alias,fin
     .alias_pool_cd))
  WITH counter
 ;end select
 SELECT INTO "nl:"
  FROM long_blob lb,
   ce_event_note cen,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (cen
   WHERE (cen.event_id=inerr->list[d.seq].event_id))
   JOIN (lb
   WHERE lb.parent_entity_id=cen.ce_event_note_id)
  DETAIL
   IF (uar_get_code_display(cen.compression_cd)="OCF Compression")
    sze = textlen(lb.long_blob), blob_out = fillstring(32000," "), blob_ret_len = 0,
    CALL uar_ocf_uncompress(lb.long_blob,sze,blob_out,32000,blob_ret_len), inerr->list[d.seq].comment
     = blob_out
   ELSE
    inerr->list[d.seq].comment = replace(lb.long_blob,"ocf_blob","")
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(inerr)
 SELECT INTO  $1
  inerr_dt_tm = cnvtdatetime(inerr->list[d.seq].clinsig_updt_dt_tm)
  FROM (dummyt d  WITH seq = value(size(inerr->list,5)))
  ORDER BY inerr_dt_tm
  HEAD REPORT
   MACRO (line_wrap)
    limit = 0, cr = char(13), lf = char(10)
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", ","))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      printstring = substring(1,pos,tempstring)
      IF (limit > 1)
       printstring = concat("   ",printstring)
      ENDIF
      lfloc = findstring(lf,printstring), crloc = findstring(cr,printstring)
      IF (lfloc=0
       AND crloc=0)
       col xcol, printstring, row + 1,
       tempstring = substring((pos+ 1),9999,tempstring)
      ELSE
       IF (((crloc < lfloc
        AND crloc > 0) OR (lfloc=0)) )
        printstring = substring(1,(crloc - 1),printstring), col xcol, printstring,
        row + 1, tempstring = substring((crloc+ 2),9999,tempstring)
       ELSEIF (((lfloc < crloc
        AND lfloc > 0) OR (crloc=0)) )
        printstring = substring(1,(lfloc - 1),printstring), col xcol, printstring,
        row + 1, tempstring = substring((lfloc+ 2),9999,tempstring)
       ENDIF
       WHILE (substring(1,1,tempstring) IN (" ", cr, lf))
         tempstring = substring(2,9999,tempstring)
       ENDWHILE
      ENDIF
    ENDWHILE
   ENDMACRO
  HEAD PAGE
   CALL center("Baystate Medical Center",1,132), row + 1,
   CALL center("Documents that were marked as in error",1,132),
   row + 1, beg_date_disp = format(beg_date_qual,"MM/DD/YYYY;;D"), end_date_disp = format(
    end_date_qual,"MM/DD/YYYY;;D"),
   CALL center(concat("From: ",beg_date_disp," to ",end_date_disp),1,132), row + 1
  DETAIL
   inerr_dt_disp = format(inerr_dt_tm,"MM/DD/YYYY HH:MM;;D"), col 1, inerr_dt_disp,
   col 18, inerr->list[d.seq].fin, col 30,
   inerr->list[d.seq].mrn, col 40, inerr->list[d.seq].pat_name,
   document_name = substring(1,40,uar_get_code_display(inerr->list[d.seq].event_cd)), col 70,
   document_name,
   reg_dt_disp = format(inerr->list[d.seq].reg_dt_tm,"MM/DD/YYYY;;D"), col 120, reg_dt_disp,
   col 104, inerr->list[d.seq].prsnl_name, row + 1
   IF (size(inerr->list[d.seq].comment) > 0
    AND size(inerr->list[d.seq].comment) < 125)
    col 5, inerr->list[d.seq].comment, row + 1
   ELSE
    tempstring = inerr->list[d.seq].comment, xcol = 5, maxlen = 125,
    line_wrap
   ENDIF
 ;end select
END GO
