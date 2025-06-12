CREATE PROGRAM bhs_rw_iv_end_by_fin
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Account Number/FIN:" = "",
  "Enter Begin Date:" = "CURDATE",
  "Enter End Date" = "CURDATE"
  WITH outdev, finnbr, beg_dt_tm,
  end_dt_tm
 FREE RECORD rw_request
 RECORD rw_request(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[*]
     2 encntr_id = f8
     2 sort_order = i4
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[*]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
 )
 SET rw_request->output_device =  $OUTDEV
 SET rw_request->visit_cnt = 1
 SET stat = alterlist(rw_request->visit,1)
 DECLARE cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 SELECT INTO "NL:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE ea.encntr_alias_type_cd=cs319_fin_cd
    AND (ea.alias= $FINNBR))
  DETAIL
   rw_request->visit[1].encntr_id = ea.encntr_id
  WITH nocounter
 ;end select
 FREE SET cs319_fin_cd
 SET rw_request->nv_cnt = 2
 SET stat = alterlist(rw_request->nv,2)
 SET rw_request->nv[1].pvc_name = "BEG_DT_TM"
 SET rw_request->nv[1].pvc_value =  $BEG_DT_TM
 SET rw_request->nv[2].pvc_name = "END_DT_TM"
 SET rw_request->nv[2].pvc_value =  $END_DT_TM
 CALL echorecord(rw_request)
 IF ((rw_request->visit[1].encntr_id <= 0.00))
  CALL echo("Invalid Account Number (FIN) passed in. Exiting Script")
 ELSE
  EXECUTE bhs_rw_iv_end_report  WITH replace(request,rw_request)
 ENDIF
#exit_script
END GO
