CREATE PROGRAM dcp_get_ref_text_by_facility:dba
 CALL echo("<--------------------------------------->")
 CALL echo("<- BEGIN: DCP_GET_REF_TEXT_BY_FACILITY ->")
 CALL echo("<--------------------------------------->")
 CALL echo("====================================================")
 CALL echo(build("===     Begin Dt/Tm: ",format(cnvtdatetime(curdate,curtime3),";;Q"),"      ==="))
 CALL echo("====================================================")
 DECLARE qtimerbegindttm = q8 WITH protect, noconstant(0.0)
 SET qtimerbegindttm = cnvtdatetime(curdate,curtime3)
 SET modify = predeclare
 RECORD reply(
   1 ref_text_list[*]
     2 text_type_cd = f8
     2 text_type_disp = c40
     2 text_type_mean = c12
     2 long_blob = gvc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE offset = i4 WITH noconstant(0)
 DECLARE retlen = i4 WITH noconstant(0)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3,"000"))
 DECLARE dentirescriptdiffinsec = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 CALL echo("**************************************")
 CALL echo("*** Start of reference text select ***")
 CALL echo("**************************************")
 SELECT INTO "nl:"
  rtfr.parent_entity_id, rtfr.parent_entity_name, rtfr.facility_cd,
  rtfr.text_type_cd, rtver.active_ind, lbr.long_blob_id,
  r_text_type_disp = uar_get_code_display(rtfr.text_type_cd), r_text_type_cdf = uar_get_code_meaning(
   rtfr.text_type_cd)
  FROM ref_text_facility_r rtfr,
   ref_text_version rtver,
   long_blob_reference lbr
  PLAN (rtfr
   WHERE (rtfr.parent_entity_id=request->parent_entity_id)
    AND (rtfr.parent_entity_name=request->parent_entity_name)
    AND (((rtfr.facility_cd=request->facility_cd)) OR (rtfr.facility_cd=0))
    AND (((request->text_type_cd=0)) OR ((request->text_type_cd > 0)
    AND (rtfr.text_type_cd=request->text_type_cd))) )
   JOIN (rtver
   WHERE rtver.ref_text_variation_id=rtfr.ref_text_variation_id
    AND rtver.active_ind=1)
   JOIN (lbr
   WHERE lbr.long_blob_id=rtver.long_blob_id)
  ORDER BY rtfr.text_type_cd, rtfr.facility_cd DESC
  HEAD REPORT
   count1 = 0
  HEAD rtfr.text_type_cd
   count1 = (count1+ 1)
   IF (count1 > size(reply->ref_text_list,5))
    stat = alterlist(reply->ref_text_list,(count1+ 10))
   ENDIF
   reply->ref_text_list[count1].text_type_cd = rtfr.text_type_cd, reply->ref_text_list[count1].
   text_type_disp = r_text_type_disp, reply->ref_text_list[count1].text_type_mean = r_text_type_cdf,
   offset = 0, retlen = 1, msg_buf = fillstring(32000," ")
   WHILE (retlen > 0)
     retlen = blobget(msg_buf,offset,lbr.long_blob)
     IF (retlen > 0)
      IF (retlen=size(msg_buf))
       reply->ref_text_list[count1].long_blob = concat(reply->ref_text_list[count1].long_blob,msg_buf
        )
      ELSE
       reply->ref_text_list[count1].long_blob = concat(reply->ref_text_list[count1].long_blob,
        substring(1,retlen,msg_buf))
      ENDIF
     ENDIF
     offset = (offset+ retlen)
   ENDWHILE
  FOOT REPORT
   stat = alterlist(reply->ref_text_list,count1)
  WITH nocounter, rdbarrayfetch = 1
 ;end select
 IF (curqual=0)
  CALL echo("No matching record found.")
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[0].targetobjectvalue = "No matching record was found."
 ELSE
  CALL echo("A matching record was found.")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[0].targetobjectvalue = "A matching record was found."
 ENDIF
 CALL echorecord(reply)
 SET last_mod = "002"
 SET dentirescriptdiffinsec = datetimediff(cnvtdatetime(curdate,curtime3),qtimerbegindttm,5)
 CALL echo("=====================================")
 CALL echo(build("===   Total Script Time in Seconds: ",dentirescriptdiffinsec,"   ==="))
 CALL echo("=====================================")
 CALL echo("<------------------------------------>")
 CALL echo("<- END DCP_GET_REF_TEXT_BY_FACILITY ->")
 CALL echo("<------------------------------------>")
END GO
