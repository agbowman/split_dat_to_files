CREATE PROGRAM cern_dcp_rpt_notes:dba
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 doc = vc
     2 date = vc
     2 text = vc
     2 title = vc
     2 tag = vc
     2 l_cnt = i2
     2 l_qual[*]
       3 line = vc
     2 add_cnt = i2
     2 add[*]
       3 add_title = vc
       3 l_cnt = i2
       3 l_qual[*]
         4 line = vc
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET name = fillstring(50," ")
 SET mrn = fillstring(50," ")
 SET unit = fillstring(50," ")
 SET room = fillstring(50," ")
 SET bed = fillstring(50," ")
 SET xxx = fillstring(50," ")
 SET person_id = 0
 SET context = 0
 SET status1 = 0
 SET pgwidth = 8
 SET cnvtto = 0
 SET ops_ind = "N"
 IF ((request->batch_selection > " "))
  SET ops_ind = "Y"
 ENDIF
 SET beg_ind = 0
 SET end_ind = 0
 SET beg_dt_tm = cnvtdatetime(curdate,curtime)
 SET end_dt_tm = cnvtdatetime(curdate,curtime)
 SET x2 = "  "
 SET x3 = "   "
 SET abc = fillstring(25," ")
 SET xyz = "  -   -       :  :  "
 CALL echo(build("xyz:",xyz))
 FOR (x = 1 TO request->nv_cnt)
   IF ((request->nv[x].pvc_name="BEG_DT_TM"))
    SET beg_ind = 1
    SET abc = trim(request->nv[x].pvc_value)
    SET stat = movestring(abc,7,xyz,1,2)
    SET x2 = substring(5,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,1,xyz,8,4)
    SET stat = movestring(abc,9,xyz,13,2)
    SET stat = movestring(abc,11,xyz,16,2)
    SET stat = movestring(abc,13,xyz,19,2)
    SET beg_dt_tm = cnvtdatetime(xyz)
   ELSEIF ((request->nv[x].pvc_name="END_DT_TM"))
    SET end_ind = 1
    SET abc = trim(request->nv[x].pvc_value)
    SET stat = movestring(abc,7,xyz,1,2)
    SET x2 = substring(5,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,1,xyz,8,4)
    SET stat = movestring(abc,9,xyz,13,2)
    SET stat = movestring(abc,11,xyz,16,2)
    SET stat = movestring(abc,13,xyz,19,2)
    SET end_dt_tm = cnvtdatetime(xyz)
   ENDIF
 ENDFOR
 IF (((end_ind=0) OR (beg_ind=0)) )
  IF (ops_ind="Y")
   SET beg_dt_tm = cnvtdatetime((curdate - 1),0)
   SET end_dt_tm = cnvtdatetime((curdate - 1),235959)
  ELSE
   SET beg_dt_tm = cnvtdatetime(curdate,0)
   SET end_dt_tm = cnvtdatetime(curdate,curtime)
  ENDIF
 ENDIF
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocfcomp_cd = code_value
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   (dummyt d1  WITH seq = 1),
   person_alias pa
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1)
  HEAD REPORT
   name = substring(1,30,p.name_full_formatted), mrn = substring(1,20,pa.alias), unit = substring(1,
    20,uar_get_code_display(e.loc_nurse_unit_cd)),
   room = substring(1,10,uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,
    uar_get_code_display(e.loc_bed_cd)), person_id = e.person_id
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  FROM note_type n,
   clinical_event c,
   clinical_event c2,
   ce_blob_result cbr,
   ce_blob cb,
   prsnl pl
  PLAN (n)
   JOIN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.event_cd=n.event_cd
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(end_dt_tm))
   JOIN (c2
   WHERE c2.parent_event_id=c.event_id
    AND c2.view_level=0
    AND c2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00")
    AND c2.publish_flag=1)
   JOIN (cbr
   WHERE cbr.event_id=c2.event_id
    AND cbr.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   JOIN (cb
   WHERE cb.event_id=c2.event_id
    AND cb.valid_until_dt_tm=cnvtdatetime("31-DEC-2100, 00:00:00"))
   JOIN (pl
   WHERE c.performed_prsnl_id=pl.person_id)
  ORDER BY c.event_end_dt_tm, c.event_cd, c2.parent_event_id
  HEAD REPORT
   temp->cnt = 0, hold_event_id = 0, cnt = 0,
   l_cnt = 0
  DETAIL
   IF (c2.parent_event_id=hold_event_id)
    cnt = (cnt+ 1), temp->qual[temp->cnt].add_cnt = cnt, stat = alterlist(temp->qual[temp->cnt].add,
     cnt),
    temp->qual[temp->cnt].add[cnt].add_title = c2.event_title_text, l_cnt = 0, blob_out = fillstring(
     32000," ")
    IF (cb.compression_cd=ocfcomp_cd)
     blob_out = fillstring(32000," "), blob_ret_len = 0, sze = textlen(cb.blob_contents),
     CALL uar_ocf_uncompress(cb.blob_contents,textlen(cb.blob_contents),blob_out,32000,blob_ret_len)
    ELSE
     blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
       - 8),cb.blob_contents)
    ENDIF
    blob_out = trim(blob_out,3),
    CALL uar_rtfcnvt_init(context,pgwidth,status1),
    CALL uar_rtfcnvt_put(context,nullterm(trim(blob_out)),status1),
    CALL uar_rtfcnvt_convert(context,cnvtto,status1)
    WHILE (status1=0)
      plinein = fillstring(300," "),
      CALL uar_rtfcnvt_get(context,plinein,status1), plinein = trim(plinein,3),
      l_cnt = (l_cnt+ 1), temp->qual[temp->cnt].add[cnt].l_cnt = l_cnt, stat = alterlist(temp->qual[
       temp->cnt].add[cnt].l_qual,l_cnt),
      temp->qual[temp->cnt].add[cnt].l_qual[l_cnt].line = plinein
    ENDWHILE
   ELSE
    temp->cnt = (temp->cnt+ 1), l_cnt = 0, blob_out = fillstring(32000," ")
    IF (cb.compression_cd=ocfcomp_cd)
     blob_out = fillstring(32000," "), blob_ret_len = 0, sze = textlen(cb.blob_contents),
     CALL uar_ocf_uncompress(cb.blob_contents,textlen(cb.blob_contents),blob_out,32000,blob_ret_len)
    ELSE
     blob_out = fillstring(32000," "), y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1
       - 8),cb.blob_contents)
    ENDIF
    stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].add_cnt = 0, cnt = 0,
    temp->qual[temp->cnt].date = format(c.event_end_dt_tm,"@SHORTDATETIME"), temp->qual[temp->cnt].
    doc = pl.name_full_formatted, temp->qual[temp->cnt].tag = c.event_tag,
    temp->qual[temp->cnt].title = c.event_title_text, blob_out = trim(blob_out,3),
    CALL uar_rtfcnvt_init(context,pgwidth,status1),
    CALL uar_rtfcnvt_put(context,nullterm(trim(blob_out)),status1),
    CALL uar_rtfcnvt_convert(context,cnvtto,status1)
    WHILE (status1=0)
      plinein = fillstring(300," "),
      CALL uar_rtfcnvt_get(context,plinein,status1), plinein = trim(plinein,3),
      l_cnt = (l_cnt+ 1), temp->qual[temp->cnt].l_cnt = l_cnt, stat = alterlist(temp->qual[temp->cnt]
       .l_qual,l_cnt),
      temp->qual[temp->cnt].l_qual[l_cnt].line = plinein
    ENDWHILE
    hold_event_id = c.event_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO request->output_device
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   "{f/12}{cpi/10}", row + 1, "{pos/240/50}{b}Notes Summary",
   row + 1, "{cpi/12}{f/8}", row + 1,
   "{pos/50/70}{b}Patient Name: {endb}", name, row + 1,
   "{pos/50/82}{b}Med Rec Num: {endb}", mrn, row + 1,
   xxx = concat(trim(unit),"/",trim(room),"/",trim(bed)), "{pos/50/94}{b}Location: {endb}", xxx,
   row + 1, ycol = 140
  DETAIL
   ycol = 140
   FOR (y = 1 TO temp->cnt)
     xcol = 50,
     CALL print(calcpos(xcol,ycol)), "{b}",
     temp->qual[y].date, row + 1, xcol = 200,
     CALL print(calcpos(xcol,ycol)), "{b}", temp->qual[y].tag,
     row + 1, ycol = (ycol+ 12)
     IF ((temp->qual[y].title > " "))
      xcol = 50,
      CALL print(calcpos(xcol,ycol)), "{b}",
      temp->qual[y].title, row + 1, ycol = (ycol+ 12)
     ENDIF
     FOR (x = 1 TO temp->qual[y].l_cnt)
       xcol = 50,
       CALL print(calcpos(xcol,ycol)), temp->qual[y].l_qual[x].line,
       row + 1, ycol = (ycol+ 12)
       IF (ycol > 690)
        BREAK
       ENDIF
     ENDFOR
     ycol = (ycol+ 12)
     IF (ycol > 690)
      BREAK
     ENDIF
     FOR (x = 1 TO temp->qual[y].add_cnt)
       xcol = 50,
       CALL print(calcpos(xcol,ycol)), "{b}",
       temp->qual[y].add[x].add_title, row + 1, ycol = (ycol+ 12)
       FOR (z = 1 TO temp->qual[y].add[x].l_cnt)
         xcol = 50,
         CALL print(calcpos(xcol,ycol)), temp->qual[y].add[x].l_qual[z].line,
         row + 1, ycol = (ycol+ 12)
         IF (ycol > 690)
          BREAK
         ENDIF
       ENDFOR
       ycol = (ycol+ 12)
       IF (ycol > 690)
        BREAK
       ENDIF
     ENDFOR
   ENDFOR
  FOOT PAGE
   ycol = 750, xcol = 250, "{f/8}{cpi/12}",
   row + 1,
   CALL print(calcpos(xcol,ycol)), "Page",
   curpage"##", row + 1, xcol = 310,
   CALL print(calcpos(xcol,ycol)), curdate, " ",
   curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 750
 ;end select
END GO
