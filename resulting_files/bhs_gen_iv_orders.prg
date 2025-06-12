CREATE PROGRAM bhs_gen_iv_orders
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
  SET request->visit[1].encntr_id = 67838727
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
 FREE RECORD iv_ord
 RECORD iv_ord(
   1 encntr_id = f8
   1 cntiv_ord = i4
   1 list[*]
     2 encntr_id = f8
     2 order_id = f8
     2 order_comment_ind = i2
     2 order_mnem = c35
     2 order_status = c18
     2 order_dt = c18
     2 ord_det_ln_cnt = i4
     2 iv_ord_det = vc
     2 iv_ord_com = vc
     2 ord_det_ln[*]
       3 line = vc
     2 ord_comment_ln[*]
       3 comment_line = vc
 )
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE l_rcd_flag = i4 WITH noconstant(0), protect
 DECLARE s_temp_disp1 = vc WITH noconstant(" ")
 DECLARE s_line_in = vc WITH noconstant(" ")
 DECLARE s_temp_disp2 = vc WITH noconstant(" ")
 DECLARE l_lidx = i4 WITH noconstant(0), protect
 DECLARE mf_cs6004_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE l_i = i4 WITH noconstant(0), protect
 DECLARE l_x = i4 WITH noconstant(0), protect
 DECLARE mf_routeofadministration_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,
   "ROUTEOFADMINISTRATION")), protect
 DECLARE mf_scheduled_prn_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16449,"SCHEDULED / PRN"
   )), protect
 SELECT INTO "nl:"
  order_status = trim(uar_get_code_display(o.order_status_cd),3), order_date = format(o
   .orig_order_dt_tm,"@SHORTDATETIMENOSEC"), order_stat_len = textlen(uar_get_code_display(o
    .order_status_cd))
  FROM orders o,
   bhs_ordcatsyn_list bol,
   order_detail od,
   order_detail od2
  PLAN (o
   WHERE (request->visit[1].encntr_id=o.encntr_id)
    AND ((o.active_ind+ 0)=1)
    AND o.template_order_id=0
    AND o.order_status_cd=mf_cs6004_ordered_cd)
   JOIN (bol
   WHERE bol.catalog_cd=o.catalog_cd
    AND bol.list_key="IVTOPO"
    AND bol.active_ind=1)
   JOIN (od
   WHERE o.order_id=od.order_id
    AND od.oe_field_id=mf_routeofadministration_var
    AND od.oe_field_display_value IN ("Intramuscular", "IV Push", "IV Push Slowly", "IVPB",
   "Subcutaneous Infusion",
   "Subcutaneous Injection", "IV Intermittent Infusion"))
   JOIN (od2
   WHERE o.order_id=od2.order_id
    AND od2.oe_field_id=mf_scheduled_prn_var
    AND cnvtupper(od2.oe_field_display_value)="NO")
  ORDER BY o.current_start_dt_tm DESC, o.order_id
  HEAD REPORT
   cnt = 0
  HEAD o.order_id
   cnt = (cnt+ 1), iv_ord->cntiv_ord = cnt, stat = alterlist(iv_ord->list,cnt),
   iv_ord->list[cnt].order_id = o.order_id, iv_ord->list[cnt].order_status = order_status, iv_ord->
   list[cnt].order_dt = order_date,
   iv_ord->list[cnt].order_mnem = o.order_mnemonic, iv_ord->list[cnt].iv_ord_det = trim(o
    .clinical_display_line,3), iv_ord->list[cnt].order_comment_ind = o.order_comment_ind
  FOOT  o.order_id
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 CALL echorecord(iv_ord)
 IF (curqual > 0)
  SET l_rcd_flag = 1
 ENDIF
 FOR (l_i = 1 TO size(iv_ord->list,5))
   SET maxval = 40
   SET maxval_comm = 100
   SET s_line_in = iv_ord->list[l_i].iv_ord_det
   EXECUTE dcp_parse_text value(s_line_in), value(maxval)
   SET stat = alterlist(iv_ord->list[l_i].ord_det_ln,size(pt->lns,5))
   SET cnt_line = 0
   FOR (line_cnt = 1 TO pt->line_cnt)
    SET cnt_line = (cnt_line+ 1)
    SET iv_ord->list[l_i].ord_det_ln[line_cnt].line = trim(pt->lns[line_cnt].line)
   ENDFOR
   SET stat = alterlist(iv_ord->list[l_i].ord_det_ln,cnt_line)
   SET s_line_in = ""
 ENDFOR
 SELECT INTO "nl:"
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   stat = alterlist(drec->line_qual,1000)
  DETAIL
   l_lidx = (l_lidx+ 1)
   IF (l_rcd_flag=1)
    current_ord = iv_ord->list[1].order_id
    FOR (bb = 1 TO size(iv_ord->list,5))
      FOR (ord_det_count = 1 TO size(iv_ord->list[bb].ord_det_ln,5))
        l_lidx = (l_lidx+ 1)
        IF (mod(l_lidx,100)=1
         AND l_lidx > 1000)
         stat = alterlist(drec->line_qual,(l_lidx+ 99))
        ENDIF
        IF (ord_det_count=1)
         s_temp_disp1 = concat(rh2b,reol), s_temp_disp1 = concat(trim(s_temp_disp1,3)," ",trim(iv_ord
           ->list[bb].order_dt,3),rtab,iv_ord->list[bb].order_mnem), drec->line_qual[l_lidx].
         disp_line = trim(s_temp_disp1,3)
        ENDIF
      ENDFOR
    ENDFOR
   ELSE
    l_lidx = (l_lidx+ 1), s_temp_disp2 = concat(reol,"no orders"," "), drec->line_qual[l_lidx].
    disp_line = concat(wr,trim(s_temp_disp2),reol,wr)
   ENDIF
  FOOT REPORT
   stat = alterlist(drec->line_qual,l_lidx)
  WITH nocounter, maxcol = 1000
 ;end select
 SET reply->text = concat(rhead,rh2b,"All active qualified IV Orders.",reol)
 IF (size(iv_ord->list,5) <= 0)
  SET reply->text = concat(reply->text,wb,"No Orders",reol)
 ELSE
  SET reply->text = concat(reply->text,rh2bu,"Order Date",rtab,rtab,
   "Order Mnemonic")
  FOR (l_x = 1 TO l_lidx)
    SET reply->text = concat(reply->text,drec->line_qual[l_x].disp_line)
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
END GO
