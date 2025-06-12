CREATE PROGRAM bed_get_res_sch_physician:dba
 FREE SET reply
 RECORD reply(
   1 resources[*]
     2 sch_resource_code_value = f8
     2 person_id = f8
     2 name_full_formatted = vc
     2 mnemonic = vc
     2 booking_limit = i4
     2 position
       3 code_value = f8
       3 display = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 DECLARE schparse = vc
 DECLARE prsnlparse = vc
 SET prsnlparse = "p.person_id > 0 and p.name_full_formatted > ' '"
 IF ((request->name_last > " "))
  SET prsnlparse = concat(prsnlparse," and p.name_last_key = '",nullterm(cnvtalphanum(cnvtupper(trim(
       request->name_last)))),"*'")
  SET schparse = concat('s.mnemonic_key = "',trim(cnvtupper(cnvtalphanum(request->name_last))),
   '*" and ')
 ENDIF
 IF ((request->name_first > " "))
  SET prsnlparse = concat(prsnlparse," and p.name_first_key = '",nullterm(cnvtalphanum(cnvtupper(trim
      (request->name_first)))),"*'")
  SET schparse = concat('s.mnemonic_key = "*',trim(cnvtupper(cnvtalphanum(request->name_first))),
   '*" and ')
 ENDIF
 IF ((request->name_last > " ")
  AND (request->name_first > " "))
  SET schparse = concat('s.mnemonic_key = "',trim(cnvtupper(cnvtalphanum(request->name_last))),"*",
   trim(cnvtupper(cnvtalphanum(request->name_first))),'*" and ')
 ENDIF
 IF ((request->username > " "))
  SET prsnlparse = concat(prsnlparse," and cnvtupper(p.username) = '",trim(cnvtupper(request->
     username)),"*'")
 ENDIF
 SET prsnlparse = concat(prsnlparse," and p.active_ind = 1")
 SET schparse = concat(schparse," s.active_ind = 1")
 DECLARE phy_txt = vc
 SET phy_id = 0.0
 SELECT INTO "nl:"
  FROM br_name_value b
  PLAN (b
   WHERE b.br_nv_key1="SCHRESGROUP"
    AND b.br_name="PHY")
  DETAIL
   phy_id = b.br_name_value_id, phy_txt = build(b.br_name_value_id)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_name_value b,
   sch_resource s
  PLAN (b
   WHERE b.br_nv_key1="SCHRESGROUPRES"
    AND b.br_value=phy_txt)
   JOIN (s
   WHERE s.resource_cd=cnvtint(trim(b.br_name))
    AND parser(schparse)
    AND s.res_type_flag=1)
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->resources,100)
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->resources,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->resources[tot_cnt].sch_resource_code_value = s.resource_cd, reply->resources[tot_cnt].
   mnemonic = s.mnemonic, reply->resources[tot_cnt].booking_limit = s.quota
  FOOT REPORT
   stat = alterlist(reply->resources,tot_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p,
   sch_resource s
  PLAN (p
   WHERE parser(prsnlparse))
   JOIN (s
   WHERE s.person_id=outerjoin(p.person_id)
    AND s.res_type_flag=outerjoin(2)
    AND s.active_ind=outerjoin(1))
  HEAD REPORT
   cnt = 0, tot_cnt = size(reply->resources,5), stat = alterlist(reply->resources,(tot_cnt+ 100))
  DETAIL
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->resources,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->resources[tot_cnt].person_id = p.person_id, reply->resources[tot_cnt].name_full_formatted
    = p.name_full_formatted, reply->resources[tot_cnt].sch_resource_code_value = s.resource_cd,
   reply->resources[tot_cnt].mnemonic = s.mnemonic, reply->resources[tot_cnt].booking_limit = s.quota,
   reply->resources[tot_cnt].position.code_value = p.position_cd
  FOOT REPORT
   stat = alterlist(reply->resources,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tot_cnt)),
    code_value cv
   PLAN (d
    WHERE (reply->resources[d.seq].position.code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->resources[d.seq].position.code_value)
     AND cv.code_set=88
     AND cv.active_ind=1)
   ORDER BY d.seq
   DETAIL
    reply->resources[d.seq].position.display = cv.display
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF ((tot_cnt > request->max_reply)
  AND (request->max_reply > 0))
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
