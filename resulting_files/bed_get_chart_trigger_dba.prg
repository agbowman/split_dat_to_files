CREATE PROGRAM bed_get_chart_trigger:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 chart_trigger_list[*]
      2 chart_trigger_id = f8
      2 trigger_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 DECLARE parsetext = vc WITH noconstant(""), protect
 DECLARE loadinactive = i2 WITH noconstant(0), protect
 DECLARE maxreply = i4 WITH constant(500), protect
 DECLARE error_flag = vc WITH noconstant(""), protect
 DECLARE ecnt = i4 WITH noconstant(0)
 DECLARE qualified_ct_cnt = i4 WITH noconstant(0)
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET parsetext = "ct.active_ind in (0,1)"
 IF (size(request->search_string,1) > 0)
  IF ((request->search_string > " "))
   SET parsetext = concat(parsetext," and cnvtupper(ct.trigger_name) = '")
   IF ((request->search_type_flag="C"))
    SET parsetext = build(parsetext,"*")
   ENDIF
   SET parsetext = build(parsetext,trim(cnvtupper(request->search_string),1),"*'")
  ENDIF
 ENDIF
 SET qualified_ct_cnt = 0
 SELECT INTO "nl:"
  hv_cnt = count(*)
  FROM chart_trigger ct
  PLAN (ct
   WHERE parser(parsetext))
  DETAIL
   qualified_ct_cnt = hv_cnt
  WITH nocounter
 ;end select
 CALL echo(qualified_ct_cnt)
 IF (qualified_ct_cnt <= maxreply)
  SET ecnt = 0
  SELECT INTO "nl:"
   FROM chart_trigger ct
   PLAN (ct
    WHERE parser(parsetext))
   ORDER BY ct.trigger_name
   DETAIL
    ecnt = (ecnt+ 1), stat = alterlist(reply->chart_trigger_list,ecnt), reply->chart_trigger_list[
    ecnt].chart_trigger_id = ct.chart_trigger_id,
    reply->chart_trigger_list[ecnt].trigger_name = ct.trigger_name
   WITH nocounter
  ;end select
 ENDIF
 IF (qualified_ct_cnt > maxreply)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
