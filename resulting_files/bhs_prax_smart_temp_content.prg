CREATE PROGRAM bhs_prax_smart_temp_content
 SET modify maxvarlen 10000000
 IF (( $6="SMART"))
  FREE RECORD request
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[*]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
    1 print_pref = i2
  ) WITH protect
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
  SET request->output_device =  $1
  SET request->script_name =  $4
  SET stat = alterlist(request->person,1)
  SET request->person_cnt = 1
  SET request->person[1].person_id =  $2
  SET request->visit_cnt = 1
  SET stat = alterlist(request->visit,1)
  SET request->visit[1].encntr_id =  $3
  SET request->prsnl_cnt = 1
  SET stat = alterlist(request->prsnl,1)
  SET request->prsnl[1].prsnl_id =  $7
  EXECUTE dcp_rpt_driver
  CALL echorecord(reply)
  SELECT INTO  $1
   txt = reply->text
   FROM dummyt d
   HEAD REPORT
    col 01, txt
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 32000, format = variable, maxrow = 0,
    time = 90
  ;end select
 ELSEIF (( $6="STANDARD"))
  SELECT INTO  $1
   blob_data = substring(1,30000,trim(l.long_blob,3))
   FROM long_blob l
   WHERE (l.parent_entity_id= $5)
    AND l.parent_entity_name="CLINICAL_NOTE_TEMPLATE"
   HEAD REPORT
    col 01, blob_data
   WITH nocounter, nullreport, formfeed = none,
    maxcol = 32000, format = variable, maxrow = 0,
    time = 90
  ;end select
 ENDIF
END GO
