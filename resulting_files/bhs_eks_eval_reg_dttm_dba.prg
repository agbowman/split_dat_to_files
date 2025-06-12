CREATE PROGRAM bhs_eks_eval_reg_dttm:dba
 SET eid = trigger_encntrid
 SET retval = - (1)
 CALL echo(build("eid:",eid))
 DECLARE end_date = i4 WITH noconstant(0), protect
 DECLARE start_date = i4 WITH noconstant(0), protect
 DECLARE md_eks_reg_date = dq8 WITH protect
 SET start_date = parameter(1,0)
 SET end_date = parameter(2,0)
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=eid)
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   md_eks_reg_date = e.reg_dt_tm
  WITH nocounter
 ;end select
 IF (cnvtdatetime(curdate,curtime) BETWEEN cnvtdatetime(datetimeadd(md_eks_reg_date,start_date)) AND
 cnvtdatetime(datetimeadd(md_eks_reg_date,end_date)))
  SET retval = 100
  SET log_message = build2("Success. in date range date between :",format(cnvtdatetime(datetimeadd(
      md_eks_reg_date,start_date)),";;q")," and ",format(cnvtdatetime(datetimeadd(md_eks_reg_date,
      end_date)),";;q"))
 ELSE
  SET retval = 0
  SET log_message = build2("False. out of range.",format(cnvtdatetime(datetimeadd(md_eks_reg_date,
      start_date)),";;q")," and ",format(cnvtdatetime(datetimeadd(md_eks_reg_date,end_date)),";;q"))
 ENDIF
#exit_prog
END GO
