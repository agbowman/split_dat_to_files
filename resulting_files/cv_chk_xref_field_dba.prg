CREATE PROGRAM cv_chk_xref_field:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 RECORD check_rec(
   1 list[*]
     2 xref_field_id = f8
     2 display_name = vc
 )
 DECLARE underline = c1 WITH private, constant("_")
 DECLARE start = i2 WITH private, noconstant(0)
 DECLARE expect_cnt = i4 WITH private, noconstant(0)
 DECLARE actual_cnt = i4 WITH private, noconstant(0)
 DECLARE totlength = i4 WITH private, noconstant(0)
 DECLARE shortstr = c12 WITH private, noconstant(" ")
 DECLARE readme_type = vc WITH private, constant("CV_CHK_XREF_FIELD_UPDATE")
 IF (validate(type_a_ds_id,0.0)=0.0)
  DECLARE type_a_ds_id = f8 WITH private, noconstant(0.0)
 ENDIF
 IF (type_a_ds_id > 0)
  SET dataset_id_in = type_a_ds_id
 ENDIF
 IF (validate(type_b_ds_id,0)=0)
  DECLARE type_b_ds_id = f8 WITH private, noconstant(0.0)
 ENDIF
 CALL echo(build("TYPE_B_DS_ID:",type_b_ds_id))
 IF (type_b_ds_id > 0)
  SET dataset_id_in = type_b_ds_id
 ENDIF
 SELECT INTO "nl:"
  *
  FROM cv_xref cx,
   cv_xref_field cxf
  PLAN (cx
   WHERE cx.dataset_id=dataset_id_in
    AND cx.xref_id > 0)
   JOIN (cxf
   WHERE cx.xref_id=cxf.xref_id)
  HEAD REPORT
   expect_cnt = 0, stat = alterlist(check_rec->list,5)
  DETAIL
   expect_cnt = (expect_cnt+ 1)
   IF (expect_cnt > size(check_rec->list,5))
    stat = alterlist(check_rec->list,(expect_cnt+ 9))
   ENDIF
   start = (findstring(cx.xref_internal_name,"-")+ 1), totlength = ((size(cx.xref_internal_name,1) -
   start)+ 1), shortstr = substring(start,totlength,cx.xref_internal_name),
   check_rec->list[expect_cnt].xref_field_id = cxf.xref_field_id, check_rec->list[expect_cnt].
   display_name = shortstr
  FOOT REPORT
   stat = alterlist(check_rec->list,expect_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No such dataset in cv_database, exit!")
 ELSE
  CALL echorecord(check_rec)
 ENDIF
 SELECT INTO "nl:"
  display_name = cxf.display_name
  FROM (dummyt d  WITH seq = value(size(check_rec->list,5))),
   cv_xref cx,
   cv_xref_field cxf
  PLAN (cx
   WHERE cx.dataset_id=dataset_id_in
    AND cx.xref_id > 0)
   JOIN (cxf
   WHERE cx.xref_id=cxf.xref_id)
   JOIN (d
   WHERE (check_rec->list[d.seq].xref_field_id=cxf.xref_field_id))
  HEAD REPORT
   actual_cnt = 0
  DETAIL
   IF ((trim(cnvtupper(display_name))=check_rec->list[d.seq].display_name))
    actual_cnt = (actual_cnt+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (actual_cnt != expect_cnt)
  SET readme_data->message = concat(readme_type," Expected ",trim(cnvtstring(expect_cnt),3),
   " rows but found ",trim(cnvtstring(actual_cnt),3),
   " rows.")
  SET readme_data->status = "F"
  CALL echo("Readme Unsuccessful!")
 ELSE
  SET readme_data->message = concat(readme_type," Readme Successful. ",trim(cnvtstring(actual_cnt),3),
   " rows fixed (if 0, OK).")
  SET readme_data->status = "S"
  CALL echo("Readme Successful!")
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
END GO
