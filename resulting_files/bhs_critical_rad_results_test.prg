CREATE PROGRAM bhs_critical_rad_results_test
 PROMPT
  "Begin dt/tm:" = "CURDATE",
  "End dt/tm" = "CURDATE"
  WITH bdate, edate
 SET blobout = fillstring(32000," ")
 SET blobnortf = fillstring(32000," ")
 SET bsize = 0
 SET len1 = 0
 SET blob_ret_len = 0
 SET blobout2 = fillstring(32000," ")
 SET blobnortf2 = fillstring(32000," ")
 SET bsize2 = 0
 SET len2 = 0
 SET blob_ret_len2 = 0
 DECLARE ocfcomp_var = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE nocomp_var = f8 WITH constant(uar_get_code_by("MEANING",120,"NOCOMP")), protect
 DECLARE ms_full_blob = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat( $BDATE," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat( $EDATE," 23:59:59"))
 DECLARE blobout = vc
 DECLARE output_ceblob = vc
 DECLARE bsize = i4
 DECLARE blobcatstr = vc
 DECLARE blob_rtf = vc
 FREE RECORD rad
 RECORD rad(
   1 cnt = i4
   1 list[*]
     2 detail_id = f8
 )
 SET long_blobout = fillstring(32000," ")
 SET long_blobnortf = fillstring(32000," ")
 SET long_bsize = 0
 SET long_len1 = 0
 SET long_blob_ret_len = 0
 SET long_blob_out_value = fillstring(32000," ")
 SET long_blobnortf2 = fillstring(32000," ")
 SET long_bsize2 = 0
 SET long_len2 = 0
 SET long_blob_ret_len2 = 0
 SET filename = concat("rad_extract",format(curdate,"YYYYMMDD;;D"),".rad")
 DECLARE ms_outfile = vc WITH protect, constant(concat("rad_result",format(curdate,"YYYYMMDD;;D"),
   ".txt"))
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE idx1 = i4 WITH protect
 DECLARE idx2 = i4 WITH protect
 SELECT INTO value(filename)
  accession = trim(rad.accession), proc_desc = trim(uar_get_code_display(rad.catalog_cd)),
  patient_name = trim(per.name_full_formatted),
  last_name = trim(per.name_last_key), first_name = trim(per.name_first_key), mrn = substring(1,10,
   trim(pa.alias)),
  facility = substring(1,20,uar_get_code_display(e.loc_facility_cd)), fin = trim(fin.alias), sex =
  substring(1,1,uar_get_code_display(per.sex_cd)),
  per.birth_dt_tm, orderable = substring(1,10,trim(cva.alias)), order_alias = substring(1,16,trim(pla
    .alias)),
  order_provider_last_name = pn.name_last_key, order_provider_first_name = pn.name_first_key, rad
  .order_id,
  rre.rad_report_id, rrd.detail_event_id, c.event_id,
  l.parent_entity_id
  FROM order_radiology rad,
   orders o,
   encounter e,
   encntr_alias fin,
   person per,
   person_alias pa,
   order_action oa,
   prsnl_alias pla,
   person_name pn,
   code_value_alias cva,
   rad_report rre,
   rad_report_detail rrd,
   ce_blob c,
   ce_event_note cen,
   long_blob l
  PLAN (rad
   WHERE rad.start_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (o
   WHERE o.order_id=rad.order_id
    AND o.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=outerjoin(rad.encntr_id)
    AND e.active_ind=outerjoin(1)
    AND e.end_effective_dt_tm > outerjoin(sysdate))
   JOIN (fin
   WHERE fin.encntr_id=outerjoin(rad.encntr_id)
    AND fin.encntr_alias_type_cd=outerjoin(1077)
    AND fin.end_effective_dt_tm > outerjoin(sysdate))
   JOIN (per
   WHERE per.person_id=rad.person_id
    AND per.active_ind=1
    AND per.end_effective_dt_tm > sysdate)
   JOIN (pa
   WHERE pa.person_id=outerjoin(per.person_id)
    AND pa.active_ind=outerjoin(1)
    AND pa.end_effective_dt_tm > outerjoin(sysdate)
    AND pa.person_alias_type_cd=outerjoin(2)
    AND pa.alias_pool_cd=outerjoin(674546))
   JOIN (oa
   WHERE oa.order_id=rad.order_id
    AND oa.action_sequence=o.last_action_sequence)
   JOIN (pla
   WHERE pla.person_id=outerjoin(oa.order_provider_id)
    AND pla.active_ind=outerjoin(1)
    AND pla.alias_pool_cd=outerjoin(719676))
   JOIN (pn
   WHERE pn.person_id=outerjoin(oa.order_provider_id)
    AND pn.name_type_cd=outerjoin(766)
    AND pn.active_ind=outerjoin(1))
   JOIN (cva
   WHERE cva.code_value=outerjoin(rad.catalog_cd)
    AND cva.contributor_source_cd=outerjoin(115141412))
   JOIN (rre
   WHERE rre.order_id=outerjoin(rad.order_id))
   JOIN (rrd
   WHERE rrd.rad_report_id=rre.rad_report_id)
   JOIN (c
   WHERE c.event_id=rrd.detail_event_id
    AND c.valid_until_dt_tm > sysdate)
   JOIN (cen
   WHERE cen.event_id=c.event_id
    AND cen.valid_until_dt_tm > sysdate)
   JOIN (l
   WHERE l.parent_entity_id=cen.ce_event_note_id
    AND l.active_ind=1
    AND (cen.ce_event_note_id=
   (SELECT
    max(cen.ce_event_note_id)
    FROM ce_event_note cen
    WHERE event_id=c.event_id)))
  ORDER BY rad.accession, c.event_id
  HEAD REPORT
   pn_blob_cnt = 0, pl_row_cnt = 0, rad->cnt = 0
  HEAD rad.accession
   blobnortf = " ", output_ceblob = " ", long_blobnortf = " "
  DETAIL
   IF (size(trim(cva.alias))=0)
    CALL echo(rad.order_id)
   ENDIF
   IF ((rad->cnt > 0))
    idx1 = locateval(idx2,1,rad->cnt,rrd.detail_event_id,rad->list[idx2].detail_id)
    IF (idx1=0)
     pn_blob_cnt = (pn_blob_cnt+ 1), rad->cnt = (rad->cnt+ 1), stat = alterlist(rad->list,rad->cnt),
     rad->list[rad->cnt].detail_id = rrd.detail_event_id, blobout = notrim(fillstring(32768," ")),
     output_ceblob = notrim(fillstring(32768," "))
     IF (c.compression_cd=ocfcomp_var)
      uncompsize = 0, blob_un = uar_ocf_uncompress(c.blob_contents,size(c.blob_contents),blobout,size
       (blobout),uncompsize), blobout = replace(blobout,"\par ","~",0),
      blobout = replace(blobout,char(13),"~",0), blobout = replace(blobout,char(10),"~",0), stat =
      uar_rtf(blobout,uncompsize,output_ceblob,size(output_ceblob),bsize,
       0),
      output_ceblob = substring(1,bsize,output_ceblob)
     ELSE
      output_ceblob = c.blob_contents
     ENDIF
     output_ceblob = replace(output_ceblob,char(13),"~",0), output_ceblob = replace(output_ceblob,
      char(10),"~",0), output_ceblob = replace(output_ceblob,"ocf_blob",""),
     output_ceblob = replace(output_ceblob,"~~~~~","",0), output_ceblob = replace(output_ceblob,
      "~~~~","",0), output_ceblob = replace(output_ceblob,"~~~","",0),
     long_blobnortf = fillstring(32000," "), long_blobout = fillstring(32000," "),
     CALL uar_ocf_uncompress(l.long_blob,size(l.long_blob),long_blobout,size(long_blobout),
     long_blob_ret_len),
     long_blobnortf = trim(long_blobout,3), long_blobnortf = replace(long_blobnortf,char(10),"~",0),
     long_blobnortf = replace(long_blobnortf,char(13),"",0)
     IF (pn_blob_cnt=1)
      ms_full_blob = concat("RESULT:"," ",trim(proc_desc)," ","~~",
       " ",trim(output_ceblob)," ","~~",trim(long_blobnortf)), blobnortf = "", long_blobnortf = "",
      output_ceblob = " "
     ELSEIF (pn_blob_cnt > 1)
      ms_full_blob = concat(ms_full_blob,"~~","ADDENDUM:"," ",trim(proc_desc),
       " ","~~"," ",trim(output_ceblob)," ",
       "~~",trim(long_blobnortf),"~~")
     ENDIF
    ENDIF
   ELSE
    pn_blob_cnt = (pn_blob_cnt+ 1), rad->cnt = (rad->cnt+ 1), stat = alterlist(rad->list,rad->cnt),
    rad->list[rad->cnt].detail_id = rrd.detail_event_id, blobout = notrim(fillstring(32768," ")),
    output_ceblob = notrim(fillstring(32768," "))
    IF (c.compression_cd=ocfcomp_var)
     uncompsize = 0, blob_un = uar_ocf_uncompress(c.blob_contents,size(c.blob_contents),blobout,size(
       blobout),uncompsize), blobout = replace(blobout,"\par ","~",0),
     blobout = replace(blobout,char(13),"~",0), blobout = replace(blobout,char(10),"~",0), stat =
     uar_rtf(blobout,uncompsize,output_ceblob,size(output_ceblob),bsize,
      0),
     output_ceblob = substring(1,bsize,output_ceblob)
    ELSE
     output_ceblob = c.blob_contents
    ENDIF
    output_ceblob = replace(output_ceblob,char(13),"~",0), output_ceblob = replace(output_ceblob,char
     (10),"~",0), output_ceblob = replace(output_ceblob,"ocf_blob",""),
    output_ceblob = replace(output_ceblob,"~~~~~","",0), output_ceblob = replace(output_ceblob,"~~~~",
     "",0), output_ceblob = replace(output_ceblob,"~~~","",0),
    long_blobnortf = fillstring(32000," "), long_blobout = fillstring(32000," "),
    CALL uar_ocf_uncompress(l.long_blob,size(l.long_blob),long_blobout,size(long_blobout),
    long_blob_ret_len),
    long_blobnortf = trim(long_blobout,3), long_blobnortf = replace(long_blobnortf,char(10),"~",0),
    long_blobnortf = replace(long_blobnortf,char(13),"",0)
    IF (pn_blob_cnt=1)
     ms_full_blob = concat("RESULT:"," ",trim(proc_desc)," ","~~",
      " ",trim(output_ceblob)," ","~~",trim(long_blobnortf)), blobnortf = "", long_blobnortf = "",
     output_ceblob = " "
    ELSEIF (pn_blob_cnt > 1)
     ms_full_blob = concat(ms_full_blob,"~~","ADDENDUM:"," ",trim(proc_desc),
      " ","~~"," ",trim(output_ceblob)," ",
      "~~",trim(long_blobnortf),"~~")
    ENDIF
   ENDIF
  FOOT  rad.accession
   pn_blob_cnt = 0, pl_row_cnt = (pl_row_cnt+ 1), ms_line = concat(trim(mrn),"|",trim(last_name),"|",
    trim(first_name),
    "|",trim(format(per.birth_dt_tm,"YYYYMMDDHHMMSS;;D")),"|",trim(sex),"|",
    trim(fin),"|",trim(facility),"|",trim(accession),
    "|",trim(orderable),"|",trim(proc_desc),"|",
    trim(order_alias),"|",trim(order_provider_last_name),"|",trim(order_provider_first_name),
    "|",trim(format(rad.start_dt_tm,"YYYYMMDDHHMMSS;;D")),"|",trim(cnvtstring(rad.order_id)),"|",
    trim(ms_full_blob),"|")
   IF (pl_row_cnt > 1)
    row + 1
   ENDIF
   col 0, ms_line
  WITH maxcol = 32000, maxrow = 1, noformfeed,
   format = variable, time = 300000
 ;end select
END GO
