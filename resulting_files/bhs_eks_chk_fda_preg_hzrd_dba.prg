CREATE PROGRAM bhs_eks_chk_fda_preg_hzrd:dba
 DECLARE mf_medications = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,"MEDICATIONS")
  )
 DECLARE ml_expnd_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 SET retval = 0
 SELECT INTO "NL:"
  FROM mltm_drug_id md,
   code_value cv
  PLAN (cv
   WHERE expand(ml_expnd_cnt,1,size(request->orderlist,5),cv.code_value,request->orderlist[
    ml_expnd_cnt].catalog_code))
   JOIN (md
   WHERE cv.cki=concat("MUL.ORD!",trim(md.drug_identifier))
    AND md.pregnancy_abbr IN ("D", "X"))
  HEAD REPORT
   ml_cnt = 0, ml_cnt = (ml_cnt+ 1), stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,
    ml_cnt),
   eksdata->tqual[tcurindex].qual[curindex].data[ml_cnt].misc = "<SPINDEX>", log_message = build(
    "*** IS class D or X *** ordering med FDA hazard class is in D or X.")
  DETAIL
   ml_cnt = (ml_cnt+ 1), stat = alterlist(eksdata->tqual[tcurindex].qual[curindex].data,ml_cnt),
   ml_pos = locateval(ml_expnd_cnt,1,size(request->orderlist,5),cv.code_value,request->orderlist[
    ml_expnd_cnt].catalog_code),
   eksdata->tqual[tcurindex].qual[curindex].data[ml_cnt].misc = build(ml_pos), retval = 100,
   log_message = build(log_message,"*** order position: ",ml_pos," display: -- ",cv.display,
    " -- catalog_cd is: ",cv.code_value),
   CALL echo(log_message)
  WITH nocounter
 ;end select
 IF (retval=0)
  SET log_message = build("*** NOT class D or X *** ordering med FDA hazard class is not D or X.")
  CALL echo(log_message)
 ENDIF
 CALL echo(build("retval ===",retval))
END GO
