CREATE PROGRAM bed_aud_rad_film_usage_by_proc
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
  )
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM film_usage f
   PLAN (f)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Procedures"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Catalog_Cd"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Film Sizes"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Film Types"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Default Quantity"
 SET reply->collist[5].data_type = 3
 SET reply->collist[5].hide_ind = 0
 SELECT INTO "NL:"
  o.primary_mnemonic, o.catalog_cd, f.film_size_cd,
  cv1.display, f.film_type_cd, cv2.display,
  f.standard_qty
  FROM film_usage f,
   order_catalog o,
   code_value cv1,
   code_value cv2
  PLAN (f)
   JOIN (o
   WHERE o.catalog_cd=f.catalog_cd
    AND o.active_ind=1)
   JOIN (cv1
   WHERE f.film_size_cd=cv1.code_value
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE f.film_type_cd=cv2.code_value
    AND cv2.active_ind=1)
  ORDER BY o.primary_mnemonic, cv2.display
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,50)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=0)
    stat = alterlist(reply->rowlist,(100+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,5), reply->rowlist[cnt].celllist[1].string_value = o
   .primary_mnemonic, reply->rowlist[cnt].celllist[2].double_value = o.catalog_cd,
   reply->rowlist[cnt].celllist[3].string_value = cv1.display, reply->rowlist[cnt].celllist[4].
   string_value = cv2.display, reply->rowlist[cnt].celllist[5].nbr_value = f.standard_qty
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("radnet_film_usage_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
