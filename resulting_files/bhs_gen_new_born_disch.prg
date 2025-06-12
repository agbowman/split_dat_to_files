CREATE PROGRAM bhs_gen_new_born_disch
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->visit[1].encntr_id = 45132824.00
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern\fprq1\fcharset0 r_ansi;}}"
 SET rhead = concat(rhead,"{\colortbl;\red0\green0\blue0;\red0\green0\blue255;")
 SET rhead = concat(rhead,"\red0\green255\blue255;\red0\green255\blue0;\red255\green0\blue255;")
 SET rhead = concat(rhead,"\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;")
 SET rhead = concat(rhead,"\red0\green0\blue128;\red0\green128\blue128;\red0\green128\blue0;")
 SET rhead = concat(rhead,"\red128\green0\blue128;\red128\green0\blue0;\red128\green128\blue0;")
 SET rhead = concat(rhead,"\red128\green128\blue128;\red192\green192\blue192;}")
 SET rh2r = "\PLAIN \F0 \FS18 \CB2 \PARD\SL0 "
 SET rh2b = "\PLAIN \F0 \FS18 \B \CB2 \PARD\SL0 "
 SET rh2bu = "\PLAIN \F0 \FS18 \B \UL \CB2 \PARD\SL0 "
 SET rh2u = "\PLAIN \F0 \FS18 \U \CB2 \PARD\SL0 "
 SET rh2i = "\PLAIN \F0 \FS18 \I \CB2 \PARD\SL0 "
 SET reol = "\PAR "
 SET rtab = "\TAB "
 SET wr = " \PLAIN \F0 \FS18 "
 SET wb = " \PLAIN \F0 \FS18 \B \CB2 "
 SET wu = " \PLAIN \F0 \FS18 \UL \CB "
 SET wi = " \PLAIN \F0 \FS18 \I \CB2 "
 SET wbi = " \PLAIN \F0 \FS18 \B \I \CB2 "
 SET wiu = " \PLAIN \F0 \FS18 \I \UL \CB2 "
 SET wbiu = " \PLAIN \F0 \FS18 \B \UL \I \CB2 "
 SET rtfeof = "}"
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD blob
 RECORD blob(
   1 encntr_id = f8
   1 cntblob = i4
   1 list[*]
     2 encntr_id = f8
     2 order_status = c18
     2 order_dt = c18
     2 event_cd = f8
     2 result_status_cd = f8
     2 result_dt = c18
     2 collect_dt = c18
     2 parent_event_id = f8
     2 event_id = f8
     2 blob_contents = vc
     2 compression_cd = f8
 )
 DECLARE cnt = i4
 FREE RECORD pas
 RECORD hear_screen_nb(
   1 res_cnt = i4
   1 enc[*]
     2 time_stmp = c30
     2 pas_res = vc
 )
 SET auth_ver_cd = uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")
 SET modified_cd = uar_get_code_by("DISPLAYKEY",8,"MODIFIED")
 SET dta1 = uar_get_code_by("DISPLAYKEY",72,"RESULTSRECOMMENDATIONS")
 SET new_born_scr_cd = uar_get_code_by("DISPLAYKEY",72,"NEWBORNSCREENRESULTS")
 SET new_met_screen = uar_get_code_by("DISPLAYKEY",200,"NEWBORNMETABOLICSCREEN")
 DECLARE gen_lab = f8 WITH constant(uar_get_code_by("MEANING",106,"GENERALLAB")), protect
 DECLARE rcd_flag = i4 WITH noconstant(0), public
 DECLARE temp_disp1 = c32000 WITH noconstant(fillstring(32000," ")), public
 DECLARE temp_disp2 = c150 WITH noconstant(fillstring(150," ")), public
 DECLARE lidx = i4 WITH noconstant(0), public
 SELECT INTO "nl:"
  time_stamp = format(c.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d")
  FROM clinical_event c
  WHERE (request->visit[1].encntr_id=c.encntr_id)
   AND c.event_cd=dta1
   AND c.result_status_cd IN (auth_ver_cd)
  ORDER BY c.updt_dt_tm DESC
  HEAD REPORT
   cnt_hsn = 0, stat = alterlist(hear_screen_nb->enc,10)
  HEAD c.event_id
   cnt_hsn = (cnt_hsn+ 1), hear_screen_nb->res_cnt = cnt_hsn
   IF (mod(cnt,10)=1)
    stat = alterlist(hear_screen_nb->enc,(cnt_hsn+ 10))
   ENDIF
  DETAIL
   hear_screen_nb->enc[cnt_hsn].time_stmp = trim(time_stamp), hear_screen_nb->enc[cnt_hsn].pas_res =
   trim(c.result_val),
   CALL echo(build("hear screen:",c.result_val,"num ===",cnt_hsn))
  FOOT REPORT
   stat = alterlist(hear_screen_nb->enc,cnt_hsn)
   IF ((cnt_hsn >= hear_screen_nb->res_cnt))
    hear_screen_nb->res_cnt = cnt_hsn
   ENDIF
 ;end select
 SELECT INTO "nl:"
  c_event_disp = uar_get_code_display(c.event_cd), uar_get_code_display(c.record_status_cd),
  result_status = uar_get_code_display(c.result_status_cd),
  result_collect_dt = format(c.event_start_dt_tm,"@SHORTDATETIMENOSEC"), clinical_sig_result_dt =
  format(c.clinsig_updt_dt_tm,"@SHORTDATETIMENOSEC"), ceb_compression_disp = uar_get_code_display(ceb
   .compression_cd),
  order_status_lab = trim(uar_get_code_display(o.order_status_cd),3), order_date = format(o
   .current_start_dt_tm,"@SHORTDATETIMENOSEC"), order_stat_len = textlen(uar_get_code_display(o
    .order_status_cd))
  FROM clinical_event c,
   ce_blob ceb,
   orders o,
   dummyt d
  PLAN (o
   WHERE (request->visit[1].encntr_id=o.encntr_id)
    AND ((o.active_ind+ 0)=1)
    AND o.catalog_cd=new_met_screen)
   JOIN (d)
   JOIN (c
   WHERE o.encntr_id=c.encntr_id
    AND o.order_id=c.order_id
    AND ((c.view_level+ 0)=1)
    AND c.event_tag != "In Error"
    AND c.valid_until_dt_tm=cnvtdatetime("31-Dec-2100")
    AND c.event_cd=new_born_scr_cd)
   JOIN (ceb
   WHERE ceb.event_id=c.event_id
    AND ceb.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
  ORDER BY c.clinsig_updt_dt_tm DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(blob->list,1000)
  DETAIL
   cnt = (cnt+ 1), blob->cntblob = cnt
   IF (mod(cnt,100)=1
    AND cnt > 100)
    stat = alterlist(blob->list,(cnt+ 99))
   ENDIF
   blob->list[cnt].encntr_id = c.encntr_id, blob->list[cnt].event_cd = c.event_cd, blob->list[cnt].
   result_status_cd = c.result_status_cd,
   blob->list[cnt].result_dt = clinical_sig_result_dt, blob->list[cnt].collect_dt = trim(
    result_collect_dt,3), blob->list[cnt].parent_event_id = c.parent_event_id,
   blob->list[cnt].event_id = c.event_id, blob->list[cnt].order_status = order_status_lab, blob->
   list[cnt].order_dt = order_date
   IF (ceb.compression_cd=uar_get_code_by("MEANING",120,"OCFCOMP"))
    blob->list[cnt].compression_cd = ceb.compression_cd, blobout = fillstring(32000," "),
    blob_return_len = 0,
    CALL echo("ordstat11=",order_stat_len),
    CALL uar_ocf_uncompress(ceb.blob_contents,textlen(ceb.blob_contents),blobout,size(blobout),
    blob_return_len), blobout = replace(blobout,char(10),reol,0),
    get_blob = findstring("NEWBORN SCREEN RESULTS :",blobout,1,1), blobout = trim(substring((get_blob
      + 24),(get_blob+ 100),trim(blobout,3))), blob->list[cnt].blob_contents = blobout
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
  FOOT REPORT
   stat = alterlist(blob->list,cnt)
  WITH outerjoin = d, nocounter, maxrec = 250
 ;end select
 IF (curqual > 0)
  SET rcd_flag = 1
 ENDIF
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   stat = alterlist(drec->line_qual,1000)
  DETAIL
   lidx = (lidx+ 1)
   IF (rcd_flag=1)
    FOR (bb = 1 TO size(blob->list,5))
      lidx = (lidx+ 1)
      IF (mod(lidx,100)=1
       AND lidx > 1000)
       stat = alterlist(drec->line_qual,(lidx+ 99))
      ENDIF
      IF (textlen(trim(blob->list[bb].order_status)) <= 9)
       temp_disp1 = concat(rh2b,reol,trim(blob->list[bb].order_status,3),rtab)
      ELSE
       temp_disp1 = concat(rh2b,reol,trim(blob->list[bb].order_status,3),rtab)
      ENDIF
      temp_disp1 = concat(trim(temp_disp1,3)," ",trim(blob->list[bb].order_dt,3),rtab,trim(blob->
        list[bb].collect_dt,3),
       rtab,trim(uar_get_code_display(blob->list[bb].result_status_cd),3),rh2b,rtab,blob->list[bb].
       result_dt,
       trim(blob->list[bb].blob_contents,3)), drec->line_qual[lidx].disp_line = trim(temp_disp1,3)
    ENDFOR
   ELSE
    lidx = (lidx+ 1), temp_disp2 = concat(reol,"No Metabolic Screen Results"," "), drec->line_qual[
    lidx].disp_line = concat(wr,trim(temp_disp2),reol,wr)
   ENDIF
  FOOT REPORT
   stat = alterlist(drec->line_qual,lidx)
  WITH nocounter, maxcol = 1000, maxrow = 800,
   dio = postscript
 ;end select
 SET reply->text = concat(rhead,rh2bu,"Hearing Screening Newborn ")
 SET reply->text = concat(reply->text," ","Results/Recommendations",reol)
 IF (size(hear_screen_nb->enc,5) <= 0)
  SET reply->text = concat(reply->text,wb,"No results",reol)
 ELSE
  FOR (i = 1 TO size(hear_screen_nb->enc,5))
    SET reply->text = concat(reply->text,rh2b,hear_screen_nb->enc[i].time_stmp,hear_screen_nb->enc[i]
     .pas_res,reol)
  ENDFOR
 ENDIF
 SET reply->text = concat(reply->text,reol,reol,rh2bu,"Newborn Metabolic Screening")
 SET reply->text = concat(reply->text,reol,rh2bu,"Order Status",rtab,
  "Order Date",rtab,rtab,"Collect date",rtab,
  rtab,"Lab Status",rtab,rtab,"Result Date",
  rtab,"    Result")
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echorecord(hear_screen_nb)
END GO
