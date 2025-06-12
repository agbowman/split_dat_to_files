CREATE PROGRAM bhs_eks_filter_spindex:dba
 DECLARE ml_logic_temp = i4 WITH protect, constant(3)
 DECLARE ml_all_ords = i4 WITH protect, constant( $1)
 DECLARE ml_remembered_ords = i4 WITH protect, constant( $2)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 SET ml_cnt = 1
 CALL alterlist(eksdata->tqual[tcurindex].qual[curindex].data,ml_cnt)
 SET eksdata->tqual[tcurindex].qual[curindex].data[ml_cnt].misc = "<SPINDEX>"
 SET log_message = build2("L",curindex," Spindex: ",eksdata->tqual[tcurindex].qual[curindex].data[
  ml_cnt].misc)
 FOR (i = 2 TO size(eksdata->tqual[ml_logic_temp].qual[ml_all_ords].data,5))
  SET ml_idx = locateval(ml_num,2,size(eksdata->tqual[ml_logic_temp].qual[ml_remembered_ords].data,5),
   eksdata->tqual[ml_logic_temp].qual[ml_all_ords].data[i].misc,eksdata->tqual[ml_logic_temp].qual[
   ml_remembered_ords].data[ml_num].misc)
  IF (ml_idx=0)
   SET ml_cnt = (ml_cnt+ 1)
   CALL alterlist(eksdata->tqual[tcurindex].qual[curindex].data,ml_cnt)
   SET eksdata->tqual[tcurindex].qual[curindex].data[ml_cnt].misc = eksdata->tqual[ml_logic_temp].
   qual[ml_all_ords].data[i].misc
   SET log_message = build2(log_message," ",eksdata->tqual[tcurindex].qual[curindex].data[ml_cnt].
    misc)
  ENDIF
 ENDFOR
 SET eksdata->tqual[tcurindex].qual[curindex].cnt = (ml_cnt - 1)
 SET retval = 100
END GO
