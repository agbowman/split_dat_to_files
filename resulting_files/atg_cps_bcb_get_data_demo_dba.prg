CREATE PROGRAM atg_cps_bcb_get_data_demo:dba
 FREE RECORD data
 RECORD data(
   1 name = vc
   1 med_bcb_codes = vc
   1 alg_bcb_codes = vc
   1 diag_bcb_codes = vc
   1 weight = f8
   1 age = i4
   1 gender = c1
   1 pregnancy_length = i4
   1 lactation_ind = i2
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE mencntrid = f8 WITH protect, constant(request->visit[1].encntr_id)
 DECLARE mpersonid = f8 WITH protect, noconstant(0.0)
 DECLARE mprsnlid = f8 WITH protect, constant(reqinfo->updt_id)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE moutputdevice = vc WITH protect, constant(request->output_device)
 DECLARE temp_string = vc WITH protect, noconstant(" ")
 IF (mencntrid=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Data collection"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BRAD_TEST"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid encntr_id"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE e.encntr_id=mencntrid)
  DETAIL
   mpersonid = e.person_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET data->med_bcb_codes = "3292687@3064064@3225047@3575592@3309548@5558445"
 SET data->alg_bcb_codes = "7324@123"
 SET data->diag_bcb_codes = "J45"
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.person_id=mpersonid
   AND (ce.event_cd=
  (SELECT
   dp.pref_cd
   FROM dm_prefs dp
   WHERE dp.application_nbr=300000
    AND dp.pref_domain="PHARMNET"
    AND dp.pref_section="DEMOGRAPHICS"
    AND dp.pref_name="WEIGHT"))
   AND ce.valid_until_dt_tm > sysdate
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   data->weight = cnvtreal(ce.result_val)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET modify = cnvtage(0,0,12000)
 SELECT INTO "nl:"
  FROM person p
  WHERE p.person_id=mpersonid
  DETAIL
   davgdayspermonth = 30.416666667, data->age = cnvtint(round((datetimediff(sysdate,p.birth_dt_tm)/
     davgdayspermonth),0)), data->gender = trim(cnvtupper(substring(1,1,uar_get_code_display(p.sex_cd
       )))),
   data->name = p.name_full_formatted
  WITH nocounter
 ;end select
 SET modify = cnvtage(7,4,24)
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET data->pregnancy_length = 0
 SET data->lactation_ind = 0
 SET errcode = error(errmsg,0)
 WHILE (errcode > 0)
   SET data->err_cnt = (data->err_cnt+ 1)
   SET stat = alterlist(data->err,data->err_cnt)
   SET data->err[data->err_cnt].err_code = errcode
   SET data->err[data->err_cnt].err_msg = errmsg
   SET errcode = error(errmsg,0)
 ENDWHILE
 SELECT INTO value(moutputdevice)
  DETAIL
   temp_string = "<HTML>", col 0, temp_string,
   row + 1, temp_string = "<REPLYMESSAGE>", col 0,
   temp_string, row + 1, temp_string = build("<FULL_NAME>",data->name,"</FULL_NAME>"),
   col 0, temp_string, row + 1,
   temp_string = build("<MED_BCB_CODES>",data->med_bcb_codes,"</MED_BCB_CODES>"), col 0, temp_string,
   row + 1, temp_string = build("<ALG_BCB_CODES>",data->alg_bcb_codes,"</ALG_BCB_CODES>"), col 0,
   temp_string, row + 1, temp_string = build("<DIAG_BCB_CODES>",data->diag_bcb_codes,
    "</DIAG_BCB_CODES>"),
   col 0, temp_string, row + 1,
   temp_string = build("<WEIGHT>",cnvtint(round(data->weight,0)),"</WEIGHT>"), col 0, temp_string,
   row + 1, temp_string = build("<AGE>",data->age,"</AGE>"), col 0,
   temp_string, row + 1, temp_string = build("<GENDER>",data->gender,"</GENDER>"),
   col 0, temp_string, row + 1,
   temp_string = build("<PREGNANCY_LENGTH>",data->pregnancy_length,"</PREGNANCY_LENGTH>"), col 0,
   temp_string,
   row + 1, temp_string = build("<LACTATION_IND>",data->lactation_ind,"</LACTATION_IND>"), col 0,
   temp_string, row + 1, temp_string = "</REPLYMESSAGE>",
   col 0, temp_string, row + 1
   IF ((data->err_cnt > 0))
    temp_string = "<ERRORMESSAGE>", col 0, temp_string,
    row + 1
    FOR (idx = 1 TO size(data->err,5))
      temp_string = "<ERROR>", col 0, temp_string,
      row + 1, temp_string = build("<ERRCODE>",data->err[idx].err_code,"</ERRCODE>"), col 0,
      temp_string, row + 1, temp_string = build("<ERRMSG>",data->err[idx].err_msg,"</ERRMSG>"),
      col 0, temp_string, row + 1,
      temp_string = "</ERROR>", col 0, temp_string,
      row + 1
    ENDFOR
    temp_string = "</ERRORMESSAGE>", col 0, temp_string,
    row + 1
   ENDIF
   temp_string = "</HTML>", col 0, temp_string,
   row + 1
  WITH nocounter, maxrow = 1, maxcol = 500,
   formfeed = none, format = variable
 ;end select
 SET reply->status_data.status = "S"
 CALL echoxml(request,"atg_cps_demo_request.xml")
 CALL echoxml(reply,"atg_cps_demo_reply.xml")
 CALL echoxml(reqinfo,"atg_cps_demo_reqinfo.xml")
 CALL echoxml(data,"atg_cps_demo_data.xml")
#exit_script
END GO
