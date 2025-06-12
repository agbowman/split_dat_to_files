CREATE PROGRAM cdi_wrk_forms_followup_list:dba
 RECORD reply(
   1 attr_qual_cnt = i4
   1 attr_qual[*]
     2 attr_name = c31
     2 attr_label = c60
     2 attr_type = c8
     2 attr_hidden_ind = i2
     2 attr_validate_ind = i2
   1 query_qual_cnt = i4
   1 query_qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 reg_dt_tm = dq8
     2 full_name = vc
     2 gender = vc
     2 dob = dq8
     2 age = vc
     2 e_mrn = vc
     2 encntr_type = vc
     2 e_fin = vc
     2 facility = vc
     2 building = vc
     2 nurse_unit = vc
     2 discharge_dt_tm = dq8
     2 attend_physician = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 DECLARE incomplete_forms_ind = i2 WITH constant(1), protect
 DECLARE hmsg = i4 WITH noconstant(0), protect
 DECLARE hreq = i4 WITH noconstant(0), protect
 DECLARE hrep = i4 WITH noconstant(0), protect
 DECLARE hitem = i4 WITH noconstant(0), protect
 DECLARE hptitem = i4 WITH noconstant(0), protect
 DECLARE hencntritem = i4 WITH noconstant(0), protect
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE lfilterindex = i4 WITH noconstant(0), protect
 DECLARE lvalueindex = i4 WITH noconstant(0), protect
 DECLARE lattrindex = i4 WITH noconstant(0), protect
 DECLARE server_request_nbr = i4 WITH constant(4277036), protect
 DECLARE max_encounters = i4 WITH constant(500), protect
 SET reply->attr_qual_cnt = 15
 SET stat = alterlist(reply->attr_qual,reply->attr_qual_cnt)
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "person_id"
 SET reply->attr_qual[lattrindex].attr_label = "Person Id"
 SET reply->attr_qual[lattrindex].attr_type = "f8"
 SET reply->attr_qual[lattrindex].attr_hidden_ind = 1
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "encntr_id"
 SET reply->attr_qual[lattrindex].attr_label = "Encounter Id"
 SET reply->attr_qual[lattrindex].attr_type = "f8"
 SET reply->attr_qual[lattrindex].attr_hidden_ind = 1
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "reg_dt_tm"
 SET reply->attr_qual[lattrindex].attr_label = "Registration Date"
 SET reply->attr_qual[lattrindex].attr_type = "dq8"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "full_name"
 SET reply->attr_qual[lattrindex].attr_label = "Full Name"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "e_mrn"
 SET reply->attr_qual[lattrindex].attr_label = "MRN"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "encntr_type"
 SET reply->attr_qual[lattrindex].attr_label = "Encounter Type"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "e_fin"
 SET reply->attr_qual[lattrindex].attr_label = "FIN"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "dob"
 SET reply->attr_qual[lattrindex].attr_label = "Date of Birth"
 SET reply->attr_qual[lattrindex].attr_type = "dq8"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "age"
 SET reply->attr_qual[lattrindex].attr_label = "Age"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "gender"
 SET reply->attr_qual[lattrindex].attr_label = "Gender"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "facility"
 SET reply->attr_qual[lattrindex].attr_label = "Facility"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "building"
 SET reply->attr_qual[lattrindex].attr_label = "Building"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "nurse_unit"
 SET reply->attr_qual[lattrindex].attr_label = "Nurse Unit"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "discharge_dt_tm"
 SET reply->attr_qual[lattrindex].attr_label = "Discharge Date"
 SET reply->attr_qual[lattrindex].attr_type = "dq8"
 SET lattrindex += 1
 SET reply->attr_qual[lattrindex].attr_name = "attend_physician"
 SET reply->attr_qual[lattrindex].attr_label = "Attending Physician"
 SET reply->attr_qual[lattrindex].attr_type = "vc"
 SET hmsg = uar_srvselectmessage(server_request_nbr)
 SET hreq = uar_srvcreaterequest(hmsg)
 SET hrep = uar_srvcreatereply(hmsg)
 SET stat = uar_srvsetlong(hreq,"max_encounters",max_encounters)
 SET stat = uar_srvsetshort(hreq,"incomplete_forms_only_ind",incomplete_forms_ind)
 FOR (lfilterindex = 1 TO request->filter_cnt)
   FOR (lvalueindex = 1 TO request->filter[lfilterindex].filter_value_cnt)
     IF ((request->filter[lfilterindex].filter_value[lvalueindex].filter_numeric_value > 0))
      CASE (request->filter[lfilterindex].filter_key)
       OF "CDI_LOCATION":
        SET hitem = uar_srvadditem(hreq,"locations")
        SET stat = uar_srvsetdouble(hitem,"location_cd",request->filter[lfilterindex].filter_value[
         lvalueindex].filter_numeric_value)
       OF "CDI_ENCOUNTER_TYPE":
        SET hitem = uar_srvadditem(hreq,"encounter_types")
        SET stat = uar_srvsetdouble(hitem,"encounter_type_cd",request->filter[lfilterindex].
         filter_value[lvalueindex].filter_numeric_value)
       OF "CDI_MEDICAL_SERVICE":
        SET hitem = uar_srvadditem(hreq,"medical_services")
        SET stat = uar_srvsetdouble(hitem,"medical_service_cd",request->filter[lfilterindex].
         filter_value[lvalueindex].filter_numeric_value)
      ENDCASE
     ENDIF
   ENDFOR
 ENDFOR
 SET stat = uar_srvexecute(hmsg,hreq,hrep)
 CALL echo(build("EJS 382-Request#",server_request_nbr," status:",stat))
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "CALL"
  SET reply->status_data.subeventstatus[1].targetobjectname = build2("REQUEST ",server_request_nbr)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("stat=",stat)
  GO TO exit_script
 ENDIF
 IF (hrep)
  SET hstruct = uar_srvgetstruct(hrep,"status_data")
 ENDIF
 IF (((hrep=0) OR (hstruct=0)) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "CALL"
  SET reply->status_data.subeventstatus[1].targetobjectname = build2("REQUEST ",server_request_nbr)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No reply from server."
  GO TO exit_script
 ENDIF
 SET statusvalue = trim(uar_srvgetstringptr(hstruct,"status"))
 IF (statusvalue != "S")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "CALL"
  SET reply->status_data.subeventstatus[1].targetobjectname = build2("REQUEST ",server_request_nbr)
  SET hsubstatus = uar_srvgetitem(hstruct,"subeventstatus",0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = uar_srvgetstringptr(hsubstatus,
   "TargetObjectValue")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET lptcount = uar_srvgetitemcount(hrep,"patients")
 SET reply->query_qual_cnt = 0
 FOR (lptindex = 0 TO (lptcount - 1))
  SET hptitem = uar_srvgetitem(hrep,"patients",lptindex)
  IF (hptitem != 0)
   SET lencntrcount = uar_srvgetitemcount(hptitem,"encounters")
   SET dpersonid = uar_srvgetdouble(hptitem,"person_id")
   SET fullname = uar_srvgetstringptr(hptitem,"formatted_name")
   SET genderdisp = uar_get_code_display(uar_srvgetdouble(hptitem,"gender_cd"))
   SET age = uar_srvgetstringptr(hptitem,"age")
   FOR (lencntrindex = 0 TO (lencntrcount - 1))
    SET hencntritem = uar_srvgetitem(hptitem,"encounters",lencntrindex)
    IF (hencntritem != 0)
     SET reply->query_qual_cnt += 1
     IF (mod(reply->query_qual_cnt,100)=1)
      SET stat = alterlist(reply->query_qual,(reply->query_qual_cnt+ 99))
     ENDIF
     CALL uar_srvgetdate(hencntritem,"registration_dt_tm",reply->query_qual[reply->query_qual_cnt].
      reg_dt_tm)
     SET reply->query_qual[reply->query_qual_cnt].person_id = dpersonid
     SET reply->query_qual[reply->query_qual_cnt].encntr_id = uar_srvgetdouble(hencntritem,
      "encounter_id")
     SET reply->query_qual[reply->query_qual_cnt].full_name = fullname
     SET reply->query_qual[reply->query_qual_cnt].gender = genderdisp
     CALL uar_srvgetdate(hptitem,"birth_dt_tm",reply->query_qual[reply->query_qual_cnt].dob)
     SET reply->query_qual[reply->query_qual_cnt].age = age
     SET laliascnt = uar_srvgetitemcount(hencntritem,"aliases")
     SET reply->query_qual[reply->query_qual_cnt].e_mrn = ""
     FOR (laliasindex = 0 TO (laliascnt - 1))
       SET haliasitem = uar_srvgetitem(hencntritem,"aliases",laliasindex)
       SET aliastype = uar_srvgetstringptr(haliasitem,"type_meaning")
       IF (aliastype="MRN")
        SET reply->query_qual[reply->query_qual_cnt].e_mrn = uar_srvgetstringptr(haliasitem,"alias")
       ELSEIF (aliastype="FIN NBR")
        SET reply->query_qual[reply->query_qual_cnt].e_fin = uar_srvgetstringptr(haliasitem,"alias")
       ENDIF
     ENDFOR
     SET reply->query_qual[reply->query_qual_cnt].encntr_type = uar_get_code_display(uar_srvgetdouble
      (hencntritem,"encounter_type_cd"))
     SET reply->query_qual[reply->query_qual_cnt].facility = uar_get_code_display(uar_srvgetdouble(
       hencntritem,"facility_cd"))
     SET reply->query_qual[reply->query_qual_cnt].building = uar_get_code_display(uar_srvgetdouble(
       hencntritem,"building_cd"))
     SET reply->query_qual[reply->query_qual_cnt].nurse_unit = uar_get_code_display(uar_srvgetdouble(
       hencntritem,"nurse_unit_cd"))
     CALL uar_srvgetdate(hencntritem,"discharge_dt_tm",reply->query_qual[reply->query_qual_cnt].
      discharge_dt_tm)
     SET reply->query_qual[reply->query_qual_cnt].attend_physician = ""
     SET lreltncnt = uar_srvgetitemcount(hencntritem,"prsnl_reltns")
     FOR (lreltnindex = 0 TO (lreltncnt - 1))
       SET hreltnitem = uar_srvgetitem(hencntritem,"prsnl_reltns",lreltnindex)
       SET reltntype = uar_srvgetstringptr(hreltnitem,"type_meaning")
       IF (reltntype="ATTENDDOC")
        SET reply->query_qual[reply->query_qual_cnt].attend_physician = uar_srvgetstringptr(
         hreltnitem,"formatted_name")
        SET lreltnindex = lreltncnt
       ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 SET stat = alterlist(reply->query_qual,reply->query_qual_cnt)
 IF ((reply->query_qual_cnt < 1))
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
