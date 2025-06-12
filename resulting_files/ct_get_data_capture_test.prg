CREATE PROGRAM ct_get_data_capture_test
 DECLARE consent_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE birth_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE race_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sex_cd = f8 WITH protect, noconstant(0.0)
 DECLARE subject_number = vc WITH protect, noconstant(request->person[1].enroll_ident)
 DECLARE cfailed = c1 WITH protect, noconstant("S")
 DECLARE item_group_cnt = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE sex_str = vc WITH protect, noconstant("")
 DECLARE race_str = vc WITH protect, noconstant("")
 DECLARE xml_str = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person[1].person_id))
  DETAIL
   birth_dt_tm = cnvtdatetime(p.birth_dt_tm), race_cd = p.race_cd, sex_cd = p.sex_cd
  WITH nocounter
 ;end select
 CALL echo(birth_dt_tm)
 CALL echo(race_cd)
 CALL echo(sex_cd)
 CALL echo(consent_dt_tm)
 CALL echo(subject_number)
 IF (sex_cd > 0)
  SET sex_str = substring(1,1,uar_get_code_meaning(sex_cd))
 ENDIF
 IF (race_cd > 0.0)
  SET race_str = uar_get_code_display(race_cd)
 ENDIF
 SET xml_str = concat('<ODM xmlns="http://www.cdisc.org/ns/odm/v1.3"',
  ' xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"',
  ' xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 ODM1-3-0.xsd" ODMVersion="1.3" FileOID="000-00-0000"',
  ' FileType="Snapshot" Description="CDASH Form" AsOfDateTime="',format(cnvtdatetime(curdate,curtime3
    ),"YYYY-MM-DDTHH:MM:SS-06:00;;D"),
  '"',' CreationDateTime="',format(cnvtdatetime(curdate,curtime3),"YYYY-MM-DDTHH:MM:SS-06:00;;D"),'"',
  ">")
 SET xml_str = concat(xml_str,'<ClinicalData StudyOID="',request->study_ident,
  '" MetaDataVersionOID="001">')
 SET xml_str = concat(xml_str,'<SubjectData SubjectKey="',subject_number,'">')
 SET xml_str = concat(xml_str,'<StudyEventData StudyEventOID="',"StudyEventOID",'">')
 SET xml_str = concat(xml_str,'<FormData FormOID="',"CDASH",'">')
 SET xml_str = concat(xml_str,'<ItemGroupData ItemGroupOID="','DM" ','ItemGroupRepeatKey="','1">')
 SET xml_str = concat(xml_str,'<ItemData ItemOID="SUBJID">',trim(subject_number),"</ItemData>")
 SET xml_str = concat(xml_str,'<ItemData ItemOID="SEX">',sex_str,"</ItemData>")
 SET xml_str = concat(xml_str,'<ItemData ItemOID="RACE">',race_str,"</ItemData>")
 SET xml_str = concat(xml_str,'<ItemData ItemOID="BRTHDTC">',format(birth_dt_tm,
   "YYYY-MM-DDTHH:MM:SS-06:00;;D"),"</ItemData>")
 SET xml_str = concat(xml_str,"</ItemGroupData>")
 SET xml_str = concat(xml_str,"</FormData>")
 SET xml_str = concat(xml_str,"</StudyEventData>")
 SET xml_str = concat(xml_str,"</SubjectData>")
 SET xml_str = concat(xml_str,"</ClinicalData>")
 SET xml_str = concat(xml_str,"</ODM>")
 SET reply->text = xml_str
#exit_script
 IF (cfailed != "S")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "May 19, 2009"
 SET trace = norecpersist
END GO
