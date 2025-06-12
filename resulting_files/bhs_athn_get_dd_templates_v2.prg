CREATE PROGRAM bhs_athn_get_dd_templates_v2
 FREE RECORD out_rec
 RECORD out_rec(
   1 templates[*]
     2 template_title = vc
     2 template_desc = vc
     2 template_id = vc
 ) WITH protect
 FREE RECORD req969505
 RECORD req969505(
   1 global_templates_ind = i2
   1 personal_templates_ind = i2
   1 labels[*]
     2 display_text = vc
     2 system_ind = i2
   1 user_id = f8
 ) WITH protect
 FREE RECORD rep969505
 RECORD rep969505(
   1 template_list[*]
     2 dd_ref_template_id = f8
     2 title_text = vc
     2 description_text = vc
     2 source_text = vc
     2 label_nkeys[*]
       3 display_text = vc
       3 system_ind = i2
       3 user_id = f8
       3 label_type_cd = vc
   1 status_data
     2 status = vc
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callreferencetemplatelist(null) = i2
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE idx = i4 WITH protect, noconstant(0)
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callreferencetemplatelist(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
#exit_script
 CALL echorecord(out_rec)
 CALL echojson(out_rec, $1)
 FREE RECORD out_rec
 FREE RECORD req969505
 FREE RECORD rep969505
 SUBROUTINE callreferencetemplatelist(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(3202004)
   DECLARE requestid = i4 WITH protect, constant(969505)
   DECLARE dcnt = i4 WITH protect, noconstant(0)
   SET req969505->user_id =  $2
   CALL echorecord(req969505)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req969505,
    "REC",rep969505,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep969505)
   IF ((rep969505->status_data.status="S"))
    SET stat = alterlist(out_rec->templates,size(rep969505->template_list,5))
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = value(size(rep969505->template_list,5)))
     PLAN (d
      WHERE d.seq > 0)
     ORDER BY cnvtupper(rep969505->template_list[d.seq].title_text)
     HEAD d.seq
      dcnt = (dcnt+ 1), out_rec->templates[dcnt].template_title = rep969505->template_list[d.seq].
      title_text, out_rec->templates[dcnt].template_desc = rep969505->template_list[d.seq].
      description_text,
      out_rec->templates[dcnt].template_id = cnvtstring(rep969505->template_list[d.seq].
       dd_ref_template_id)
     WITH nocounter, time = 30
    ;end select
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
