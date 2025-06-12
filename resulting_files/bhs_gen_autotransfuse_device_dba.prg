CREATE PROGRAM bhs_gen_autotransfuse_device:dba
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
  SET request->visit[1].encntr_id = 51906841
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
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SET rh2r = "\plain \f0 \fs18 \cf3 \pard\fi-100\li7000\ri7000 "
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD transfuse_ord
 RECORD transfuse_ord(
   1 encntr_id = f8
   1 cnttransfuse_ord = i4
   1 list[*]
     2 encntr_id = f8
     2 order_id = f8
     2 order_comment_ind = i2
     2 order_mnem = c35
     2 order_status = c18
     2 order_dt = c18
     2 ord_det_ln_cnt = i4
     2 transfuse_ord_det = vc
     2 transfuse_ord_com = vc
     2 ord_det_ln[*]
       3 line = vc
     2 ord_comment_ln[*]
       3 comment_line = vc
     2 bag[*]
       3 bag_num = vc
 )
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET auth_ver_cd = uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")
 SET modified_cd = uar_get_code_by("DISPLAYKEY",8,"MODIFIED")
 SET ord1 = uar_get_code_by("DISPLAYKEY",200,"AUTOTRANSFUSIONDEVICE")
 DECLARE rcd_flag = i4 WITH noconstant(0), public
 DECLARE temp_disp1 = c32000 WITH noconstant(fillstring(32000," ")), public
 DECLARE comment_line_in = c32000 WITH noconstant(fillstring(32000," ")), public
 DECLARE line_in = c32000 WITH noconstant(fillstring(32000," ")), public
 DECLARE temp_disp2 = c150 WITH noconstant(fillstring(150," ")), public
 DECLARE lidx = i4 WITH noconstant(0), public
 DECLARE autotransfusionbagnumber = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "AUTOTRANSFUSIONBAGNUMBER")), protect
 SELECT INTO "nl:"
  order_status = trim(uar_get_code_display(o.order_status_cd),3), order_date = format(o
   .current_start_dt_tm,"@SHORTDATETIMENOSEC"), order_stat_len = textlen(uar_get_code_display(o
    .order_status_cd))
  FROM orders o,
   order_comment oc,
   long_text lt,
   clinical_event ce
  PLAN (o
   WHERE (request->visit[1].encntr_id=o.encntr_id)
    AND ((o.active_ind+ 0)=1)
    AND o.cs_flag IN (0, 2)
    AND o.catalog_cd IN (ord1))
   JOIN (oc
   WHERE oc.order_id=outerjoin(o.order_id))
   JOIN (lt
   WHERE lt.long_text_id=outerjoin(oc.long_text_id)
    AND lt.active_ind=outerjoin(1))
   JOIN (ce
   WHERE outerjoin(o.encntr_id)=ce.encntr_id
    AND outerjoin(o.order_id)=ce.order_id
    AND outerjoin(autotransfusionbagnumber)=ce.event_cd)
  ORDER BY o.order_id, o.current_start_dt_tm DESC, ce.event_end_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   cnt = (cnt+ 1),
   CALL echo(build("COUNTER>>> :",cnt)), transfuse_ord->cnttransfuse_ord = cnt
   IF (cnt > size(transfuse_ord->list,5))
    stat = alterlist(transfuse_ord->list,10)
   ENDIF
   transfuse_ord->list[cnt].order_id = o.order_id, transfuse_ord->list[cnt].order_status =
   order_status, transfuse_ord->list[cnt].order_dt = order_date,
   transfuse_ord->list[cnt].order_mnem = o.order_mnemonic, transfuse_ord->list[cnt].order_comment_ind
    = o.order_comment_ind, transfuse_ord->list[cnt].transfuse_ord_com = lt.long_text,
   transfuse_ord->list[cnt].transfuse_ord_det = trim(o.clinical_display_line,3), cnt1 = 0
  DETAIL
   cnt1 = (cnt1+ 1)
   IF (cnt1 > size(transfuse_ord->list[cnt].bag,5))
    stat = alterlist(transfuse_ord->list[cnt].bag,10)
   ENDIF
   IF (o.order_id=ce.order_id
    AND o.encntr_id=ce.encntr_id)
    transfuse_ord->list[cnt].bag[cnt1].bag_num = concat(format(ce.event_end_dt_tm,
      "@SHORTDATETIMENOSEC")," ",trim(uar_get_code_display(ce.event_cd),3),"# ",trim(ce.result_val))
   ENDIF
  FOOT  o.order_id
   stat = alterlist(transfuse_ord->list[cnt].bag,cnt1)
  FOOT REPORT
   stat = alterlist(transfuse_ord->list,cnt)
  WITH outerjoin = d, nocounter, maxrec = 250
 ;end select
 CALL echorecord(transfuse_ord)
 IF (curqual > 0)
  SET rcd_flag = 1
 ENDIF
 FOR (i = 1 TO size(transfuse_ord->list,5))
   SET maxval = 40
   SET maxval_comm = 100
   SET line_in = transfuse_ord->list[i].transfuse_ord_det
   EXECUTE dcp_parse_text value(line_in), value(maxval)
   SET stat = alterlist(transfuse_ord->list[i].ord_det_ln,size(pt->lns,5))
   SET cnt_line = 0
   FOR (line_cnt = 1 TO pt->line_cnt)
    SET cnt_line = (cnt_line+ 1)
    SET transfuse_ord->list[i].ord_det_ln[line_cnt].line = trim(pt->lns[line_cnt].line)
   ENDFOR
   SET stat = alterlist(transfuse_ord->list[i].ord_det_ln,cnt_line)
   IF ((transfuse_ord->list[i].order_comment_ind=1))
    SET comment_line_in = trim(transfuse_ord->list[i].transfuse_ord_com,3)
    EXECUTE dcp_parse_text value(comment_line_in), value(maxval_comm)
    SET stat = alterlist(transfuse_ord->list[i].ord_comment_ln,size(pt->lns,5))
    SET cnt_line = 0
    FOR (line_cnt = 1 TO pt->line_cnt)
     SET cnt_line = (cnt_line+ 1)
     SET transfuse_ord->list[i].ord_comment_ln[line_cnt].comment_line = trim(pt->lns[line_cnt].line,3
      )
    ENDFOR
    SET stat = alterlist(transfuse_ord->list[i].ord_comment_ln,cnt_line)
    SET comment_line_in = ""
   ENDIF
   SET line_in = ""
 ENDFOR
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   stat = alterlist(drec->line_qual,1000)
  DETAIL
   lidx = (lidx+ 1)
   IF (rcd_flag=1)
    current_ord = transfuse_ord->list[1].order_id
    FOR (bb = 1 TO size(transfuse_ord->list,5))
      FOR (ord_det_count = 1 TO size(transfuse_ord->list[bb].ord_det_ln,5))
        lidx = (lidx+ 1)
        IF (mod(lidx,100)=1
         AND lidx > 1000)
         stat = alterlist(drec->line_qual,(lidx+ 99))
        ENDIF
        IF (ord_det_count=1)
         temp_disp1 = concat(rh2b,reol), temp_disp1 = concat(trim(temp_disp1,3)," ",trim(
           transfuse_ord->list[bb].order_dt,3),rtab,transfuse_ord->list[bb].order_mnem,
          rtab,transfuse_ord->list[bb].ord_det_ln[ord_det_count].line)
         IF ((current_ord=transfuse_ord->list[bb].order_id))
          drec->line_qual[lidx].disp_line = trim(temp_disp1,3)
         ELSE
          drec->line_qual[lidx].disp_line = concat(reol,trim(temp_disp1,3))
         ENDIF
        ELSE
         temp_disp1 = concat(rh2b,reol,rtab,rtab,rtab,
          rtab,rtab,rtab,rtab,rtab,
          rtab,transfuse_ord->list[bb].ord_det_ln[ord_det_count].line), drec->line_qual[lidx].
         disp_line = trim(temp_disp1,3)
        ENDIF
      ENDFOR
      IF ((transfuse_ord->list[bb].order_comment_ind=1))
       lidx = (lidx+ 1), temp_disp1 = concat(rh2bu,"Order Comment:"), drec->line_qual[lidx].disp_line
        = concat(reol,trim(temp_disp1,3))
       FOR (ord_comment_cnt = 1 TO size(transfuse_ord->list[bb].ord_comment_ln,5))
         lidx = (lidx+ 1)
         IF (mod(lidx,100)=1
          AND lidx > 1000)
          stat = alterlist(drec->line_qual,(lidx+ 99))
         ENDIF
         temp_disp1 = concat(rh2b,trim(transfuse_ord->list[bb].ord_comment_ln[ord_comment_cnt].
           comment_line)), drec->line_qual[lidx].disp_line = concat(reol,trim(temp_disp1,3))
       ENDFOR
      ENDIF
      IF (size(transfuse_ord->list[bb].bag,5) > 0)
       FOR (bag_cnt = 1 TO size(transfuse_ord->list[bb].bag,5))
         lidx = (lidx+ 1)
         IF (mod(lidx,100)=1
          AND lidx > 1000)
          stat = alterlist(drec->line_qual,(lidx+ 99))
         ENDIF
         temp_disp1 = concat(rh2b,transfuse_ord->list[bb].bag[bag_cnt].bag_num), drec->line_qual[lidx
         ].disp_line = concat(reol,trim(temp_disp1,3))
       ENDFOR
      ENDIF
    ENDFOR
   ELSE
    lidx = (lidx+ 1), temp_disp2 = concat(reol,"no orders"," "), drec->line_qual[lidx].disp_line =
    concat(wr,trim(temp_disp2),reol,wr)
   ENDIF
  FOOT REPORT
   stat = alterlist(drec->line_qual,lidx)
  WITH nocounter, maxcol = 1000, maxrow = 800
 ;end select
 SET reply->text = concat(rhead,rh2bu,"Autotransfusion Device orders ",reol)
 IF (size(transfuse_ord->list,5) <= 0)
  SET reply->text = concat(reply->text,wb,"No Orders",reol)
 ELSE
  SET reply->text = concat(reply->text,rh2bu,"Order Date",rtab,rtab,
   "Order Mnemonic")
  SET reply->text = concat(reply->text,rtab,rtab,rtab,rtab,
   "Order Details")
  FOR (x = 1 TO lidx)
    SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
