CREATE PROGRAM ap_case_search_all
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start(MMDDYY):" = "CURDATE",
  "Stop (MMDDYY):" = "CURDATE",
  "Specimen:" = "*"
  WITH outdev, sdate, edate,
  sp
 SET ocfcd = 0.0
 SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,ocfcd)
 SET blobout = fillstring(32768," ")
 SET blobnortf = fillstring(32768," ")
 SET bsize = 0
 SELECT INTO  $OUTDEV
  c.accession_nbr, c.encntr_id, c.person_id,
  c.reference_nbr, c.event_id, c.clinsig_updt_dt_tm,
  c.event_cd, c_event_disp = uar_get_code_display(c.event_cd), c.task_assay_cd,
  c_task_assay_disp = uar_get_code_display(c.task_assay_cd), c.parent_event_id, cb.blob_contents,
  cb.event_id, cb.compression_cd, cb_compression_disp = uar_get_code_display(cb.compression_cd),
  blobin = trim(cb.blob_contents), e.encntr_id, e.encntr_type_cd,
  e_encntr_type_disp = uar_get_code_display(e.encntr_type_cd), textlen = textlen(cb.blob_contents), c
  .authentic_flag,
  p.name_full_formatted, p.person_id, name = substring(1,25,p.name_full_formatted),
  expr7 = curdate, expr8 = curpage, expr9 = curprog,
  cb.valid_until_dt_tm
  FROM clinical_event c,
   ce_blob cb,
   encounter e,
   dummyt d1,
   person p
  PLAN (c
   WHERE c.clinsig_updt_dt_tm BETWEEN cnvtdatetime(cnvtdate( $SDATE),0) AND cnvtdatetime(cnvtdate(
      $EDATE),235959)
    AND ((c.task_assay_cd+ 0)=22167)
    AND c.authentic_flag=1)
   JOIN (p
   WHERE c.person_id=p.person_id)
   JOIN (e
   WHERE ((c.encntr_id+ 0)=e.encntr_id))
   JOIN (cb
   WHERE cb.event_id=c.event_id
    AND cb.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cb.compression_cd=ocfcd)
   JOIN (d1
   WHERE uar_ocf_uncompress(cb.blob_contents,textlen(cb.blob_contents),blobout,size(blobout),32768)
    >= 0
    AND (blobout= $SP))
  HEAD REPORT
   SUBROUTINE ccl_text_wrap(x,y,z)
     eol = size(trim(z),1), bseg = 1, eseg = 1,
     line = substring(bseg,eol,z)
     WHILE (eseg <= eol)
       bseg = eseg, eseg = (eseg+ y)
       IF (findstring("",substring(bseg,(eseg - bseg),line)) > 0)
        WHILE (substring((eseg - 1),1,line) != " "
         AND eseg != bseg)
          eseg = (eseg - 1)
        ENDWHILE
        segment = substring(bseg,((eseg - bseg) - 1),z)
       ELSE
        segment = substring(bseg,(eseg - bseg),z)
       ENDIF
       col x,
       CALL print(substring(1,y,segment)), row + 1
     ENDWHILE
   END ;Subroutine report
   , cntr = 0
  HEAD PAGE
   col 5, curprog, col 77,
   "Search for", col 93,  $PROMPT4,
   row + 1, col 117, curpage,
   row + 1, col 5, curdate,
   col 50, b = concat(format(cnvtdatetime( $PROMPT2),"mm/dd/yy;;d")," - ",format(cnvtdatetime(
       $PROMPT3),"mm/dd/yy;;d")), col 49,
   col 50, b, row + 2
  DETAIL
   blobout = fillstring(32000," "), blobout, blob_un = uar_ocf_uncompress(cb.blob_contents,textlen,
    blobout,size(blobout),32768),
   stat = uar_rtf2(blobout,size(blobout),blobnortf,size(blobnortf),bsize,
    0), col 21, col 1,
   "Case#:", c.accession_nbr, col 30,
   name, col 55, e_encntr_type_disp,
   row + 1, col 1, "Diagnosis:",
   row + 1, col + 1,
   CALL ccl_text_wrap(col,100,blobnortf),
   row + 1, row + 1, line1 = fillstring(32,"-"),
   col 29, line1, row + 1
  FOOT REPORT
   col 61, "***   End of Report   ***"
  WITH format = variable
 ;end select
END GO
