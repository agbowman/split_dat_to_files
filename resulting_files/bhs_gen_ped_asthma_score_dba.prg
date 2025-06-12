CREATE PROGRAM bhs_gen_ped_asthma_score:dba
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
  SET request->visit[1].encntr_id = 42449607.00
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
 DECLARE cnt = i4
 FREE RECORD pas
 RECORD pas(
   1 res_cnt = i4
   1 enc[*]
     2 time_stmp = c30
     2 pas_res = c20
 )
 FREE RECORD asthma_med_info
 RECORD asthma_med_info(
   1 med_cnt = i4
   1 enc[*]
     2 med_time_stamp = vc
     2 med_memonic = vc
     2 med_order_id = f8
     2 med_order_as = vc
     2 med_display1 = vc
     2 med_display2 = vc
     2 med_detail = vc
 )
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
 SET tblhead2 = concat("\trowd\trgaph108\trleft-108\trpaddl108\trpaddr108\trpaddf13\trpaddfr3 ")
 SET begin_row = concat("\cellx2500\cellx11500\pard\intbl",wr)
 SET dta1 = uar_get_code_by("DISPLAYKEY",72,"PEDIATRICASTHMASCORE")
 DECLARE g = i4
 SET med_dta1 = uar_get_code_by("DISPLAYKEY",72,"ALBUTEROL")
 SET med_dta2 = uar_get_code_by("DISPLAYKEY",72,"ALBUTEROLIPRATROPIUM")
 SET med_dta3 = uar_get_code_by("DISPLAYKEY",72,"EPOPROSTENOL")
 SET med_dta4 = uar_get_code_by("DISPLAYKEY",72,"IPRATROPIUM")
 DECLARE mf_med_dta5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"RACEPINEPHRINE"))
 CALL echo(build2("dta5: ",mf_med_dta5))
 DECLARE cs6000_pharm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 SET num_class = uar_get_code_by("DISPLAYKEY",53,"NUM")
 SET med_class = uar_get_code_by("DISPLAYKEY",53,"MED")
 SET auth_ver_cd = uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")
 SELECT INTO "nl:"
  time_stamp = format(c.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d")
  FROM clinical_event c
  WHERE (request->visit[1].encntr_id=c.encntr_id)
   AND c.event_cd=dta1
   AND c.event_class_cd=num_class
   AND c.result_status_cd=auth_ver_cd
  ORDER BY c.updt_dt_tm DESC
  HEAD REPORT
   cnt = 0, stat = alterlist(pas->enc,10)
  HEAD c.event_id
   cnt = (cnt+ 1), pas->res_cnt = cnt
   IF (mod(cnt,10)=1)
    stat = alterlist(pas->enc,(cnt+ 10))
   ENDIF
  DETAIL
   pas->enc[cnt].time_stmp = trim(time_stamp), pas->enc[cnt].pas_res = trim(c.result_val)
  FOOT REPORT
   stat = alterlist(pas->enc,cnt)
   IF ((cnt >= pas->res_cnt))
    pas->res_cnt = cnt
   ENDIF
 ;end select
 SELECT INTO "nl:"
  oc_cat_disp = uar_get_code_display(o.catalog_cd)
  FROM clinical_event ce1,
   orders o,
   ce_med_result cmr
  PLAN (ce1
   WHERE (request->visit[1].encntr_id=ce1.encntr_id)
    AND ce1.event_cd IN (med_dta1, med_dta2, med_dta3, med_dta4, mf_med_dta5)
    AND ce1.event_class_cd=med_class
    AND ce1.result_status_cd=auth_ver_cd
    AND ce1.event_end_dt_tm >= cnvtdatetime((curdate - 1),curtime))
   JOIN (o
   WHERE ce1.order_id=o.order_id
    AND o.catalog_type_cd=cs6000_pharm_cd)
   JOIN (cmr
   WHERE ce1.event_id=cmr.event_id)
  ORDER BY oc_cat_disp, cmr.admin_end_dt_tm DESC
  HEAD REPORT
   cnt2 = 0, stat = alterlist(asthma_med_info->enc,10)
  DETAIL
   cnt2 = (cnt2+ 1)
   IF (mod(cnt2,10)=1)
    stat = alterlist(asthma_med_info->enc,(cnt2+ 10))
   ENDIF
   IF (o.iv_ind=1)
    asthma_med_info->enc[cnt2].med_display1 = concat(trim(o.ordered_as_mnemonic),"    "),
    asthma_med_info->enc[cnt2].med_display2 = "    "
   ELSE
    asthma_med_info->enc[cnt2].med_display1 = trim(concat(trim(uar_get_code_display(o.catalog_cd)),
      "(",trim(o.ordered_as_mnemonic),")")), asthma_med_info->enc[cnt2].med_display2 = concat("(",
     trim(o.ordered_as_mnemonic),")")
   ENDIF
   asthma_med_info->enc[cnt2].med_detail = trim(substring(1,100,o.simplified_display_line)),
   asthma_med_info->enc[cnt2].med_time_stamp = trim(format(cmr.admin_end_dt_tm,"mm/dd/yyyy hh:mm;;d")
    )
  FOOT REPORT
   stat = alterlist(asthma_med_info->enc,cnt2)
   IF ((cnt2 >= asthma_med_info->med_cnt))
    asthma_med_info->med_cnt = cnt2
   ENDIF
 ;end select
 SET reply->text = concat(rhead,rh2bu,"Result Date/Time",rtab,"Pediatric Asthma Score",
  reol)
 FOR (i = 1 TO size(pas->enc,5))
   SET reply->text = concat(reply->text,rh2r,pas->enc[i].time_stmp,rtab,pas->enc[i].pas_res,
    reol)
 ENDFOR
 SET reply->text = concat(reply->text," \pard \ql ",reol,tblhead2)
 SET reply->text = concat(reply->text,begin_row,"Last Done Date/time",
  " \cell Medication Given in Last 24 hrs ")
 SET reply->text = concat(reply->text," \cell\row\par")
 FOR (j = 1 TO size(asthma_med_info->enc,5))
   SET reply->text = concat(reply->text," \pard \ql ",tblhead2)
   SET reply->text = concat(reply->text,begin_row,trim(asthma_med_info->enc[j].med_time_stamp),
    " \cell ",trim(asthma_med_info->enc[j].med_display1))
   SET reply->text = concat(reply->text,";",trim(asthma_med_info->enc[j].med_detail)," \cell\row\par"
    )
 ENDFOR
 SET reply->text = concat(reply->text,rtfeof)
END GO
