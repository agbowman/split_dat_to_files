CREATE PROGRAM bhs_gen_notconverted_comment:dba
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
  SET request->visit[1].encntr_id = 69216727
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
 DECLARE ms_displays = vc WITH protect, noconstant("")
 DECLARE ms_reol = vc WITH protect, constant("\par ")
 DECLARE ms_rtab = vc WITH protect, constant("\tab ")
 DECLARE ms_wr = vc WITH protect, constant("\f0 \fs18 \cb2 ")
 DECLARE ms_wb = vc WITH protect, constant("{\b\cb2")
 DECLARE ms_uf = vc WITH protect, constant(" }")
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
   1 dislay_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD com_list
 RECORD com_list(
   1 com_qual[*]
     2 comment = vc
     2 com_dt = vc
 )
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE l_rcd_flag = i4 WITH noconstant(0), protect
 DECLARE s_temp_disp = vc WITH noconstant(" ")
 DECLARE s_temp_disp1 = vc WITH noconstant(" ")
 DECLARE s_line_in = vc WITH noconstant(" ")
 DECLARE s_temp_disp2 = vc WITH noconstant(" ")
 DECLARE l_i = i4 WITH noconstant(0), protect
 DECLARE l_lidx = i4 WITH noconstant(0), protect
 DECLARE mf_modified_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"MODIFIED")), protect
 DECLARE mf_authverified_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")),
 protect
 DECLARE mf_primaryeventid_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18189,"PRIMARYEVENTID"
   )), protect
 DECLARE mf_ivmedsappropriateforconversion_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "IVMEDSAPPROPRIATEFORCONVERSION")), protect
 DECLARE mf_additionalrecommendationscomment_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ADDITIONALRECOMMENDATIONSCOMMENT")), protect
 DECLARE mf_ivmedsnotappropriateforconversion_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "IVMEDSNOTAPPROPRIATEFORCONVERSION")), protect
 DECLARE mf_commentsivmedicationnotconverted_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "COMMENTSIVMEDICATIONNOTCONVERTED")), protect
 DECLARE mf_plannedconversiondate_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PLANNEDCONVERSIONDATE")), protect
 DECLARE mf_ivtopoconversionexclusioncriteria_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "IVTOPOCONVERSIONEXCLUSIONCRITERIA")), protect
 SELECT INTO "nl:"
  FROM dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   clinical_event c1,
   clinical_event c2,
   clinical_event c3,
   ce_date_result cdr
  PLAN (dfa
   WHERE (dfa.encntr_id=request->visit[1].encntr_id)
    AND dfa.description="IV to PO Pharmacy Conversion")
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.parent_entity_name="CLINICAL_EVENT"
    AND dfac.component_cd=mf_primaryeventid_var)
   JOIN (c1
   WHERE c1.event_id=dfac.parent_entity_id
    AND c1.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   JOIN (c2
   WHERE c2.parent_event_id=c1.event_id
    AND c2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   JOIN (c3
   WHERE c3.parent_event_id=c2.event_id
    AND c3.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
    AND c3.event_cd IN (mf_ivmedsappropriateforconversion_cd, mf_additionalrecommendationscomment_cd,
   mf_ivmedsnotappropriateforconversion_cd, mf_commentsivmedicationnotconverted_cd,
   mf_ivtopoconversionexclusioncriteria_cd)
    AND ((c3.result_status_cd+ 0) IN (mf_authverified_var, mf_modified_var))
    AND c3.view_level=1)
   JOIN (cdr
   WHERE cdr.event_id=outerjoin(c3.event_id)
    AND cdr.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100,00:00:00")))
  ORDER BY c3.event_end_dt_tm DESC, c3.parent_event_id, c3.clinical_event_id
  HEAD REPORT
   cnt = 0
  HEAD c3.parent_event_id
   cnt = (cnt+ 1), stat = alterlist(com_list->com_qual,cnt), s_temp_disp1 = ""
  HEAD c3.event_id
   s_temp_disp1 = concat(trim(s_temp_disp1),reol,trim(uar_get_code_display(c3.event_cd)),": ",reol,
    " ",trim(c3.result_val),". ")
  FOOT  c3.parent_event_id
   com_list->com_qual[cnt].com_dt = format(c3.event_end_dt_tm,"@SHORTDATETIME"), com_list->com_qual[
   cnt].comment = s_temp_disp1,
   CALL echo(build("record_com = ",com_list->com_qual[cnt].comment))
  WITH nocounter
 ;end select
 CALL echorecord(com_list)
 IF (curqual > 0)
  SET l_rcd_flag = 1
 ENDIF
 FOR (l_i = 1 TO size(com_list->com_qual,5))
   SET maxval = 40
   SET s_line_in = com_list->com_qual[l_i].comment
   EXECUTE dcp_parse_text value(s_line_in), value(maxval)
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
    FOR (bb = 1 TO size(com_list->com_qual,5))
      l_lidx = (l_lidx+ 1)
      IF (mod(l_lidx,100)=1
       AND l_lidx > 1000)
       stat = alterlist(drec->line_qual,(l_lidx+ 99))
      ENDIF
      s_temp_disp = concat(rh2b,reol), s_temp_disp = concat(trim(s_temp_disp,3)," ",reol,trim(
        com_list->com_qual[bb].com_dt,3),rtab,
       com_list->com_qual[bb].comment), drec->line_qual[l_lidx].disp_line = trim(s_temp_disp,3)
    ENDFOR
   ELSE
    l_lidx = (l_lidx+ 1), s_temp_disp2 = concat(reol,"no orders"," "), drec->line_qual[l_lidx].
    disp_line = concat(wr,trim(s_temp_disp2),reol,wr)
   ENDIF
  FOOT REPORT
   stat = alterlist(drec->line_qual,l_lidx)
  WITH nocounter, maxcol = 1000
 ;end select
 SET reply->text = concat(rhead,rh2b,"All Comments.",reol)
 IF (size(com_list->com_qual,5) <= 0)
  SET reply->text = concat(reply->text,wb,"No Comments",reol)
 ELSE
  SET reply->text = concat(reply->text,rh2bu,"Date of Comments",rtab,"Comments")
  FOR (l_x = 1 TO l_lidx)
    SET reply->text = concat(reply->text,drec->line_qual[l_x].disp_line)
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echorecord(reply)
END GO
