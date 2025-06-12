CREATE PROGRAM dcp_solcap_rtz_reschedule:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 solcap[*]
      2 identifier = vc
      2 degree_of_use_num = i4
      2 degree_of_use_str = vc
      2 distinct_user_count = i4
      2 position[*]
        3 display = vc
        3 value_num = i4
        3 value_str = vc
      2 facility[*]
        3 display = vc
        3 value_num = i4
        3 value_str = vc
      2 other[*]
        3 category_name = vc
        3 value[*]
          4 display = vc
          4 value_num = i4
          4 value_str = vc
  )
 ENDIF
 FREE RECORD data
 RECORD data(
   1 facility[*]
     2 action_cnt = i4
     2 facility_cd = f8
   1 prsnl[*]
     2 prsnl_id = f8
 )
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE fac_idx = i4 WITH protect, noconstant(0)
 DECLARE act_cnt = i4 WITH protect, noconstant(0)
 DECLARE user_cnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE creschedule_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"RESCHEDULE"))
 DECLARE cdotresched_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6052,"DOTRESCHED"))
 SET dstat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2010.2.00087.1"
 SELECT INTO "nl:"
  oa.action_personnel_id, oa.order_id, oa.action_sequence
  FROM order_action oa,
   orders o,
   encounter enc
  PLAN (oa
   WHERE oa.action_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND oa.action_qualifier_cd=cdotresched_cd
    AND oa.action_type_cd=creschedule_cd)
   JOIN (o
   WHERE o.order_id=oa.order_id)
   JOIN (enc
   WHERE enc.encntr_id=o.encntr_id)
  ORDER BY oa.action_personnel_id, oa.order_id, oa.action_sequence
  HEAD oa.action_personnel_id
   user_cnt = (user_cnt+ 1)
  HEAD oa.order_id
   dstat = 0
  HEAD oa.action_sequence
   act_cnt = (act_cnt+ 1), fac_idx = locateval(lidx,1,fac_cnt,enc.loc_facility_cd,data->facility[lidx
    ].facility_cd)
   IF (fac_idx > 0)
    data->facility[fac_idx].action_cnt = (data->facility[fac_idx].action_cnt+ 1)
   ELSE
    fac_cnt = (fac_cnt+ 1)
    IF (mod(fac_cnt,10)=1)
     dstat = alterlist(data->facility,(fac_cnt+ 9))
    ENDIF
    data->facility[fac_cnt].action_cnt = 1, data->facility[fac_cnt].facility_cd = enc.loc_facility_cd
   ENDIF
  FOOT  oa.action_sequence
   dstat = 0
  FOOT  oa.order_id
   dstat = 0
  FOOT  oa.action_personnel_id
   dstat = 0
  WITH nocounter
 ;end select
 SET dstat = alterlist(data->facility,fac_cnt)
 SET reply->solcap[1].degree_of_use_num = act_cnt
 SET reply->solcap[1].distinct_user_count = user_cnt
 SET dstat = alterlist(reply->solcap[1].facility,fac_cnt)
 FOR (i = 1 TO fac_cnt)
  SET reply->solcap[1].facility[i].display = uar_get_code_display(data->facility[i].facility_cd)
  SET reply->solcap[1].facility[i].value_num = data->facility[i].action_cnt
 ENDFOR
 FREE RECORD data
 CALL echo("Modification Date: 12/03/10")
 CALL echo("Last_Mod: 001")
END GO
