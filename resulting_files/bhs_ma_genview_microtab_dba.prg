CREATE PROGRAM bhs_ma_genview_microtab:dba
 SET rh2r = "\f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "{\f0 \fs18 \b \ul \cb2 \pard\sl0"
 SET rh2u = "{\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \f0 \fs18 \cb2 "
 SET wb = "{\f0 \fs18 \b \cb2 "
 SET uf = " }"
 SET wu = "{ \f0 \fs18 \ul \cb2 "
 SET wi = "{ \f0 \fs18 \i \cb2 "
 SET wbi = "{ \f0 \fs18 \b \i \cb2 "
 SET wiu = " {\f0 \fs18 \i \ul \cb2 "
 SET wbiu = "{ \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 DECLARE black = vc
 DECLARE red = vc
 SET header = "{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern\fprq1\fcharset0 r_ansi;}}"
 SET colortable =
 "{{\colortbl;\red0\green0\blue0;\red255\green255\blue255;\red0\green128\blue0;\red255\green0\blue0;}"
 SET red = "\viewkind4\uc1\pard\cf4\f0\fs20 "
 SET black = "\viewkind4\uc1\pard\cf1\f0\fs20 "
 DECLARE rcd_flag = i4 WITH noconstant(0), public
 DECLARE temp_disp1 = c32000 WITH noconstant(fillstring(32000," ")), public
 DECLARE temp_disp2 = c150 WITH noconstant(fillstring(150," ")), public
 DECLARE lidx = i4 WITH noconstant(0), public
 DECLARE criticalhead = vc WITH noconstant(" "), public
 DECLARE micro_var = f8 WITH constant(uar_get_code_by("MEANING",106,"MICROBIOLOGY")), protect
 DECLARE doc_type_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"DOC")), protect
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_micro_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"MICROBIOLOGY"))
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD blob
 RECORD blob(
   1 person_id = f8
   1 cntblob = i4
   1 list[*]
     2 s_accession = vc
     2 encntr_id = f8
     2 order_id = f8
     2 event_cd = f8
     2 result_status_cd = f8
     2 result_dt = c18
     2 f_result_dt = f8
     2 collect_dt = c18
     2 parent_event_id = f8
     2 event_id = f8
     2 blob_contents = vc
     2 compression_cd = f8
     2 f_clinsig_dt = f8
     2 l_ecnt = i4
     2 equal[*]
       3 f_event_id = f8
 )
 SELECT DISTINCT INTO "nl:"
  e.person_id, e.encntr_id
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id)
    AND e.person_id > 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   blob->person_id = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted, c.encntr_id, c.order_id,
  o.activity_type_cd, activity_type = uar_get_code_display(o.activity_type_cd), c_event_disp =
  uar_get_code_display(c.event_cd),
  c.event_cd, c.parent_event_id, c.result_status_cd,
  uar_get_code_display(c.record_status_cd), result_status = uar_get_code_display(c.result_status_cd),
  c.event_tag,
  p.name_full_formatted, c.valid_from_dt_tm, c.valid_until_dt_tm,
  result_collect_dt = format(ces.collect_dt_tm,"@SHORTDATETIMENOSEC"), clinical_sig_result_dt =
  format(c.clinsig_updt_dt_tm,"@SHORTDATETIMENOSEC"), ceb_compression_disp = uar_get_code_display(ceb
   .compression_cd),
  ceb.compression_cd, ceb.blob_seq_num, ceb.event_id,
  ceb.blob_length, textlen_ceb_blob_contents = textlen(ceb.blob_contents)
  FROM clinical_event c,
   orders o,
   ce_blob ceb,
   person p,
   ce_specimen_coll ces,
   bhs_event_cd_list becl,
   v500_event_set_explode v,
   encntr_alias ea
  PLAN (c
   WHERE (c.person_id=blob->person_id)
    AND c.event_class_cd=doc_type_cd
    AND c.event_tag != "In Error"
    AND c.valid_until_dt_tm=cnvtdatetime("31-Dec-2100"))
   JOIN (o
   WHERE (o.order_id= Outerjoin(c.order_id))
    AND (o.activity_type_cd= Outerjoin(micro_var)) )
   JOIN (ceb
   WHERE ceb.event_id=c.event_id
    AND ceb.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (p
   WHERE p.person_id=c.person_id)
   JOIN (ces
   WHERE ces.event_id=c.parent_event_id
    AND ces.valid_until_dt_tm > sysdate)
   JOIN (becl
   WHERE (becl.event_cd= Outerjoin(c.event_cd))
    AND (becl.listkey= Outerjoin("WINGMICROBIOLOGY")) )
   JOIN (v
   WHERE (v.event_cd= Outerjoin(c.event_cd))
    AND (v.event_set_cd= Outerjoin(mf_micro_cd)) )
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(c.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(mf_fin_cd))
    AND (ea.alias= Outerjoin("V*")) )
  ORDER BY c.clinsig_updt_dt_tm DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(blob->list,1000)
  DETAIL
   IF (((o.activity_type_cd=micro_var) OR (((becl.listkey="WINGMICROBIOLOGY"
    AND ea.alias="V*") OR (v.event_set_cd=mf_micro_cd)) )) )
    cnt += 1, blob->cntblob = cnt
    IF (mod(cnt,100)=1
     AND cnt > 100)
     stat = alterlist(blob->list,(cnt+ 99))
    ENDIF
    blob->list[cnt].encntr_id = c.encntr_id, blob->list[cnt].order_id = o.order_id, blob->list[cnt].
    event_cd = c.event_cd,
    blob->list[cnt].result_status_cd = c.result_status_cd, blob->list[cnt].result_dt =
    clinical_sig_result_dt, blob->list[cnt].collect_dt = result_collect_dt,
    blob->list[cnt].parent_event_id = c.parent_event_id, blob->list[cnt].event_id = c.event_id, blob
    ->list[cnt].f_clinsig_dt = c.clinsig_updt_dt_tm
    IF (ceb.compression_cd=uar_get_code_by("MEANING",120,"OCFCOMP"))
     blob->list[cnt].compression_cd = ceb.compression_cd, blobout = fillstring(32000," "),
     blob_return_len = 0,
     CALL uar_ocf_uncompress(ceb.blob_contents,textlen_ceb_blob_contents,blobout,size(blobout),
     blob_return_len), blobout = replace(blobout,char(10),reol,0), blob->list[cnt].blob_contents =
     blobout
    ELSE
     len = findstring("ocf_blob",trim(ceb.blob_contents),1,0)
     IF (len > 0)
      blobout = trim(substring(1,(len - 1),trim(ceb.blob_contents)))
     ELSE
      blobout = trim(ceb.blob_contents)
     ENDIF
     blobout = trim(substring(1,32000,blobout)), blobout = replace(blobout,char(10),reol,0), blob->
     list[cnt].blob_contents = blobout
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(blob->list,cnt)
  WITH nocounter, maxrec = 250
 ;end select
 DECLARE mf_cs53_txt_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2698"))
 DECLARE mf_cs200_bloodculture2rapididnaa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"BLOODCULTURE2RAPIDIDNAA"))
 DECLARE mf_cs200_bloodculturerapididnaa_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   200,"BLOODCULTURERAPIDIDNAA"))
 SELECT INTO "nl:"
  textlen_lb_long_blob = textlen(lb.long_blob)
  FROM clinical_event ce,
   orders o,
   ce_event_note cen,
   long_blob lb
  PLAN (ce
   WHERE (ce.person_id=blob->person_id)
    AND ce.event_tag != "In Error"
    AND ce.valid_until_dt_tm=cnvtdatetime("31-Dec-2100")
    AND ce.event_class_cd=mf_cs53_txt_cd
    AND textlen(trim(ce.accession_nbr,3)) > 0)
   JOIN (o
   WHERE o.order_id=ce.order_id
    AND o.activity_type_cd=micro_var)
   JOIN (cen
   WHERE cen.event_id=ce.event_id
    AND cen.valid_until_dt_tm > cnvtdatetime(sysdate))
   JOIN (lb
   WHERE lb.parent_entity_id=cen.ce_event_note_id
    AND lb.parent_entity_name="CE_EVENT_NOTE"
    AND lb.active_ind=1)
  ORDER BY ce.accession_nbr DESC, cen.ce_event_note_id
  HEAD ce.accession_nbr
   blob->cntblob += 1, stat = alterlist(blob->list,blob->cntblob), blob->list[blob->cntblob].
   encntr_id = ce.encntr_id,
   blob->list[blob->cntblob].order_id = o.order_id, blob->list[blob->cntblob].s_accession = trim(ce
    .accession_nbr,3), blob->list[blob->cntblob].event_cd = o.catalog_cd,
   blob->list[blob->cntblob].result_status_cd = ce.result_status_cd, blob->list[blob->cntblob].
   result_dt = format(ce.clinsig_updt_dt_tm,"@SHORTDATETIMENOSEC"), blob->list[blob->cntblob].
   f_result_dt = ce.clinsig_updt_dt_tm,
   blob->list[blob->cntblob].collect_dt = format(ce.event_start_dt_tm,"@SHORTDATETIMENOSEC"), blob->
   list[blob->cntblob].parent_event_id = ce.parent_event_id, blob->list[blob->cntblob].event_id = ce
   .event_id,
   blob->list[blob->cntblob].f_clinsig_dt = ce.clinsig_updt_dt_tm
  DETAIL
   IF (ce.clinsig_updt_dt_tm > cnvtdatetime(blob->list[blob->cntblob].f_result_dt))
    blob->list[blob->cntblob].f_result_dt = ce.clinsig_updt_dt_tm, blob->list[blob->cntblob].
    result_dt = format(ce.clinsig_updt_dt_tm,"@SHORTDATETIMENOSEC")
   ENDIF
   IF (trim(ce.result_val,3) IN ("Not Detected", "Not applicable")
    AND o.catalog_cd IN (mf_cs200_bloodculture2rapididnaa_cd, mf_cs200_bloodculturerapididnaa_cd))
    CALL echo("SKIP THIS TO NOT SHOW RESULTS")
   ELSE
    IF (cen.compression_cd=uar_get_code_by("MEANING",120,"OCFCOMP"))
     blob->list[blob->cntblob].compression_cd = cen.compression_cd, blobout = fillstring(32000," "),
     blob_return_len = 0,
     CALL uar_ocf_uncompress(lb.long_blob,textlen_lb_long_blob,blobout,size(blobout),blob_return_len),
     blobout = replace(blobout,char(10),reol,0)
     IF (((trim(cnvtupper(ce.result_val),3) IN ("COMMENT")) OR (size(trim(ce.result_val,3))=0)) )
      blob->list[blob->cntblob].blob_contents = concat(blob->list[blob->cntblob].blob_contents,reol,
       "\b> \b0 ",trim(uar_get_code_display(ce.event_cd),3),": ",
       reol,trim(replace(replace(trim(blobout,3),"(NOTE)\par","")," EQ "," =",4),3),reol)
     ELSE
      blob->list[blob->cntblob].blob_contents = concat(blob->list[blob->cntblob].blob_contents,reol,
       "\b> \b0 ",trim(uar_get_code_display(ce.event_cd),3),": \b ",
       trim(ce.result_val,3)," \b0",reol,trim(replace(replace(trim(blobout,3),"(NOTE)\par","")," EQ ",
         " =",4),3),reol)
     ENDIF
    ELSE
     len = findstring("ocf_blob",trim(lb.long_blob),1,0)
     IF (len > 0)
      blobout = trim(substring(1,(len - 1),trim(lb.long_blob)))
     ELSE
      blobout = trim(lb.long_blob)
     ENDIF
     blobout = trim(substring(1,32000,blobout)), blobout = replace(blobout,char(10),reol,0)
     IF (((trim(cnvtupper(ce.result_val),3) IN ("COMMENT")) OR (size(trim(ce.result_val,3))=0)) )
      blob->list[blob->cntblob].blob_contents = concat(blob->list[blob->cntblob].blob_contents,reol,
       "\b> \b0 ",trim(uar_get_code_display(ce.event_cd),3),": ",
       reol,trim(replace(replace(trim(blobout,3),"(NOTE)\par","")," EQ "," =",4),3),reol)
     ELSE
      blob->list[blob->cntblob].blob_contents = concat(blob->list[blob->cntblob].blob_contents,reol,
       "\b> \b0 ",trim(uar_get_code_display(ce.event_cd),3),": \b ",
       trim(ce.result_val,3)," \b0",reol,trim(replace(replace(trim(blobout,3),"(NOTE)\par","")," EQ ",
         " =",4),3),reol)
     ENDIF
    ENDIF
    blob->list[blob->cntblob].l_ecnt += 1, stat = alterlist(blob->list[blob->cntblob].equal,blob->
     list[blob->cntblob].l_ecnt), blob->list[blob->cntblob].equal[blob->list[blob->cntblob].l_ecnt].
    f_event_id = ce.event_id
   ENDIF
  WITH nocounter
 ;end select
 DECLARE ml_accession_ind = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  textlen_lb_long_blob = textlen(lb.long_blob)
  FROM clinical_event ce,
   orders o,
   ce_event_note cen,
   long_blob lb
  PLAN (ce
   WHERE (ce.person_id=blob->person_id)
    AND ce.event_tag != "In Error"
    AND ce.valid_until_dt_tm=cnvtdatetime("31-Dec-2100")
    AND ce.event_class_cd=mf_cs53_txt_cd)
   JOIN (o
   WHERE o.order_id=ce.order_id
    AND o.activity_type_cd=micro_var)
   JOIN (cen
   WHERE cen.event_id=ce.event_id
    AND cen.valid_until_dt_tm > cnvtdatetime(sysdate))
   JOIN (lb
   WHERE lb.parent_entity_id=cen.ce_event_note_id
    AND lb.parent_entity_name="CE_EVENT_NOTE"
    AND lb.active_ind=1)
  ORDER BY ce.order_id DESC, cen.ce_event_note_id
  HEAD ce.order_id
   IF (size(trim(ce.accession_nbr,3))=0)
    ml_accession_ind = 0
   ELSE
    ml_accession_ind = 1
   ENDIF
   IF (ml_accession_ind=0)
    blob->cntblob += 1, stat = alterlist(blob->list,blob->cntblob), blob->list[blob->cntblob].
    encntr_id = ce.encntr_id,
    blob->list[blob->cntblob].order_id = o.order_id, blob->list[blob->cntblob].s_accession = trim(ce
     .accession_nbr,3), blob->list[blob->cntblob].event_cd = o.catalog_cd,
    blob->list[blob->cntblob].result_status_cd = ce.result_status_cd, blob->list[blob->cntblob].
    result_dt = format(ce.clinsig_updt_dt_tm,"@SHORTDATETIMENOSEC"), blob->list[blob->cntblob].
    f_result_dt = ce.clinsig_updt_dt_tm,
    blob->list[blob->cntblob].collect_dt = format(ce.event_start_dt_tm,"@SHORTDATETIMENOSEC"), blob->
    list[blob->cntblob].parent_event_id = ce.parent_event_id, blob->list[blob->cntblob].event_id = ce
    .event_id,
    blob->list[blob->cntblob].f_clinsig_dt = ce.clinsig_updt_dt_tm
   ENDIF
  DETAIL
   IF (ml_accession_ind=0)
    IF (ce.clinsig_updt_dt_tm > cnvtdatetime(blob->list[blob->cntblob].f_result_dt))
     blob->list[blob->cntblob].f_result_dt = ce.clinsig_updt_dt_tm, blob->list[blob->cntblob].
     result_dt = format(ce.clinsig_updt_dt_tm,"@SHORTDATETIMENOSEC")
    ENDIF
    IF (trim(ce.result_val,3) IN ("Not Detected", "Not applicable")
     AND o.catalog_cd IN (mf_cs200_bloodculture2rapididnaa_cd, mf_cs200_bloodculturerapididnaa_cd))
     CALL echo("SKIP THIS TO NOT SHOW RESULTS")
    ELSE
     IF (cen.compression_cd=uar_get_code_by("MEANING",120,"OCFCOMP"))
      blob->list[blob->cntblob].compression_cd = cen.compression_cd, blobout = fillstring(32000," "),
      blob_return_len = 0,
      CALL uar_ocf_uncompress(lb.long_blob,textlen_lb_long_blob,blobout,size(blobout),blob_return_len
      ), blobout = replace(blobout,char(10),reol,0)
      IF (((trim(cnvtupper(ce.result_val),3) IN ("COMMENT")) OR (size(trim(ce.result_val,3))=0)) )
       blob->list[blob->cntblob].blob_contents = concat(blob->list[blob->cntblob].blob_contents,reol,
        "\b> \b0 ",trim(uar_get_code_display(ce.event_cd),3),": ",
        reol,trim(replace(replace(trim(blobout,3),"(NOTE)\par","")," EQ "," =",4),3),reol)
      ELSE
       blob->list[blob->cntblob].blob_contents = concat(blob->list[blob->cntblob].blob_contents,reol,
        "\b> \b0 ",trim(uar_get_code_display(ce.event_cd),3),": \b ",
        trim(ce.result_val,3)," \b0",reol,trim(replace(replace(trim(blobout,3),"(NOTE)\par",""),
          " EQ "," =",4),3),reol)
      ENDIF
     ELSE
      len = findstring("ocf_blob",trim(lb.long_blob),1,0)
      IF (len > 0)
       blobout = trim(substring(1,(len - 1),trim(lb.long_blob)))
      ELSE
       blobout = trim(lb.long_blob)
      ENDIF
      blobout = trim(substring(1,32000,blobout)), blobout = replace(blobout,char(10),reol,0)
      IF (((trim(cnvtupper(ce.result_val),3) IN ("COMMENT")) OR (size(trim(ce.result_val,3))=0)) )
       blob->list[blob->cntblob].blob_contents = concat(blob->list[blob->cntblob].blob_contents,reol,
        "\b> \b0 ",trim(uar_get_code_display(ce.event_cd),3),": ",
        reol,trim(replace(replace(trim(blobout,3),"(NOTE)\par","")," EQ "," =",4),3),reol)
      ELSE
       blob->list[blob->cntblob].blob_contents = concat(blob->list[blob->cntblob].blob_contents,reol,
        "\b> \b0 ",trim(uar_get_code_display(ce.event_cd),3),": \b ",
        trim(ce.result_val,3)," \b0",reol,trim(replace(replace(trim(blobout,3),"(NOTE)\par",""),
          " EQ "," =",4),3),reol)
      ENDIF
     ENDIF
     blob->list[blob->cntblob].l_ecnt += 1, stat = alterlist(blob->list[blob->cntblob].equal,blob->
      list[blob->cntblob].l_ecnt), blob->list[blob->cntblob].equal[blob->list[blob->cntblob].l_ecnt].
     f_event_id = ce.event_id
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_cs8_active_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2627"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 FOR (ml_idx1 = 1 TO blob->cntblob)
   IF (textlen(trim(blob->list[ml_idx1].s_accession,3)) != 0)
    SELECT INTO "nl:"
     FROM clinical_event ce,
      code_value cv,
      orders o
     PLAN (ce
      WHERE (ce.accession_nbr=blob->list[ml_idx1].s_accession)
       AND (ce.person_id=blob->person_id)
       AND ce.event_tag != "In Error"
       AND ce.valid_until_dt_tm=cnvtdatetime("31-Dec-2100")
       AND  NOT (expand(ml_idx2,1,blob->list[ml_idx1].l_ecnt,ce.event_id,blob->list[ml_idx1].equal[
       ml_idx2].f_event_id))
       AND ce.view_level=1
       AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
      mf_cs8_modified_cd))
      JOIN (cv
      WHERE cv.code_value=ce.event_cd
       AND cv.display_key != "*SPECIMENSOURCE")
      JOIN (o
      WHERE (o.order_id= Outerjoin(ce.order_id)) )
     ORDER BY ce.event_cd, ce.clinsig_updt_dt_tm DESC
     HEAD ce.event_cd
      IF (trim(ce.result_val,3) IN ("Not Detected", "Not applicable")
       AND o.catalog_cd IN (mf_cs200_bloodculture2rapididnaa_cd, mf_cs200_bloodculturerapididnaa_cd))
       CALL echo("SKIP THIS TO NOT SHOW RESULTS")
      ELSE
       IF (size(trim(ce.result_val,3)) > 0
        AND  NOT (trim(cnvtupper(ce.result_val),3) IN ("COMMENT")))
        blob->list[ml_idx1].blob_contents = concat("\b> \b0 ",trim(uar_get_code_display(ce.event_cd),
          3),": \b ",trim(ce.result_val)," \b0",
         reol,blob->list[ml_idx1].blob_contents)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM clinical_event ce,
      code_value cv,
      orders o
     PLAN (ce
      WHERE (ce.accession_nbr=blob->list[ml_idx1].s_accession)
       AND (ce.person_id=blob->person_id)
       AND ce.event_tag != "In Error"
       AND ce.valid_until_dt_tm=cnvtdatetime("31-Dec-2100")
       AND ce.result_status_cd IN (mf_cs8_active_cd, mf_cs8_altered_cd, mf_cs8_auth_cd,
      mf_cs8_modified_cd))
      JOIN (cv
      WHERE cv.code_value=ce.event_cd
       AND cv.display_key="*SPECIMENSOURCE")
      JOIN (o
      WHERE (o.order_id= Outerjoin(ce.order_id)) )
     ORDER BY ce.accession_nbr, ce.clinsig_updt_dt_tm DESC
     HEAD ce.accession_nbr
      IF (trim(ce.result_val,3) IN ("Not Detected", "Not applicable")
       AND o.catalog_cd IN (mf_cs200_bloodculture2rapididnaa_cd, mf_cs200_bloodculturerapididnaa_cd))
       CALL echo("SKIP THIS TO NOT SHOW RESULTS")
      ELSE
       IF (size(trim(ce.result_val,3)) > 0)
        blob->list[ml_idx1].blob_contents = concat("Specimen: ",trim(ce.result_val),reol,reol,blob->
         list[ml_idx1].blob_contents)
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (size(blob->list,5) > 0)
  SET rcd_flag = 1
 ENDIF
 FREE RECORD blob_out
 RECORD blob_out(
   1 person_id = f8
   1 cntblob = i4
   1 list[*]
     2 encntr_id = f8
     2 order_id = f8
     2 event_cd = f8
     2 result_status_cd = f8
     2 result_dt = c18
     2 collect_dt = c18
     2 parent_event_id = f8
     2 event_id = f8
     2 blob_contents = vc
     2 compression_cd = f8
     2 f_clinsig_dt = f8
 )
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = blob->cntblob)
  PLAN (d1)
  ORDER BY cnvtdatetime(blob->list[d1.seq].f_clinsig_dt) DESC
  DETAIL
   blob_out->cntblob += 1, stat = alterlist(blob_out->list,blob_out->cntblob), blob_out->list[
   blob_out->cntblob].encntr_id = blob->list[d1.seq].encntr_id,
   blob_out->list[blob_out->cntblob].order_id = blob->list[d1.seq].order_id, blob_out->list[blob_out
   ->cntblob].event_cd = blob->list[d1.seq].event_cd, blob_out->list[blob_out->cntblob].
   result_status_cd = blob->list[d1.seq].result_status_cd,
   blob_out->list[blob_out->cntblob].result_dt = blob->list[d1.seq].result_dt, blob_out->list[
   blob_out->cntblob].collect_dt = blob->list[d1.seq].collect_dt, blob_out->list[blob_out->cntblob].
   parent_event_id = blob->list[d1.seq].parent_event_id,
   blob_out->list[blob_out->cntblob].event_id = blob->list[d1.seq].event_id, blob_out->list[blob_out
   ->cntblob].blob_contents = blob->list[d1.seq].blob_contents, blob_out->list[blob_out->cntblob].
   compression_cd = blob->list[d1.seq].compression_cd,
   blob_out->list[blob_out->cntblob].f_clinsig_dt = blob->list[d1.seq].f_clinsig_dt
  WITH nocounter, maxrec = 250
 ;end select
 CALL echorecord(blob_out)
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   stat = alterlist(drec->line_qual,1000)
  DETAIL
   lidx += 1, temp_disp1 = concat("Micro Cultures: (",trim(cnvtstring(blob_out->cntblob),3),
    " cultures)"), drec->line_qual[lidx].disp_line = concat(header,rh2bu,wb,trim(temp_disp1,3),uf,
    uf,reol,reol),
   drec->line_qual[lidx].disp_line = concat(drec->line_qual[lidx].disp_line,
    " \b 'Not detected' and 'Not applicable' results for ",
    "the Rapid Blood Culture ID have been filtered from this view. ",reol,
    "Please go to the Flowsheet for full details. \b0",
    reol,reol)
   IF (rcd_flag=1)
    FOR (bb = 1 TO size(blob_out->list,5))
      lidx += 1
      IF (mod(lidx,100)=1
       AND lidx > 1000)
       stat = alterlist(drec->line_qual,(lidx+ 99))
      ENDIF
      IF (((findstring("CVRB2",cnvtupper(trim(blob_out->list[bb].blob_contents,3))) > 0) OR (
      findstring("CRITICAL VALUE CALLED AND VERIFIED BY READBACK FOR:",cnvtupper(trim(blob_out->list[
         bb].blob_contents,3))) > 0)) )
       criticalhead = red
      ELSE
       criticalhead = black
      ENDIF
      temp_disp1 = concat(wb,"***********************************************************",uf,reol,
       colortable,
       criticalhead,rh2r,wb,"Culture/Event_id: ",uf,
       rtab,trim(uar_get_code_display(blob_out->list[bb].event_cd),3),"/",cnvtstring(blob_out->list[
        bb].event_id),reol,
       wb,"Collect date: ",uf,rtab,blob_out->list[bb].collect_dt,
       reol,wb,"Result Status: ",uf,rtab,
       trim(uar_get_code_display(blob_out->list[bb].result_status_cd),3),reol,wb,"Result Date: ",uf,
       rtab,blob_out->list[bb].result_dt,reol,reol,trim(blob_out->list[bb].blob_contents,3),
       uf,reol,reol), drec->line_qual[lidx].disp_line = trim(temp_disp1,3)
    ENDFOR
   ELSE
    lidx += 1, temp_disp2 = concat("No Micro Cultures Found"," "), drec->line_qual[lidx].disp_line =
    concat(wr,trim(temp_disp2),reol,wr)
   ENDIF
  FOOT REPORT
   stat = alterlist(drec->line_qual,lidx)
   FOR (x = 1 TO lidx)
     reply->text = concat(reply->text,drec->line_qual[x].disp_line)
   ENDFOR
  WITH nocounter, maxcol = 1000, maxrow = 800,
   dio = postscript
 ;end select
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echorecord(reply)
#exit_script
END GO
