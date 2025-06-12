CREATE PROGRAM bed_get_onc_pos_by_pref:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE beg_psn = i4
 DECLARE end_psn = i4
 DECLARE equal_psn = i4
 DECLARE len = i4
 DECLARE start = i4
 DECLARE position_text = vc
 DECLARE position_cd = f8
 DECLARE pos_cnt = i4
 SET pos_cnt = 0
 SELECT INTO "nl:"
  FROM prefdir_entrydata p
  PLAN (p
   WHERE ((substring(1,71,p.dist_name)=
   "prefentry=column1,prefgroup=summary,prefgroup=oncology,prefgroup=module") OR (substring(1,71,p
    .dist_name)="prefentry=column2,prefgroup=summary,prefgroup=oncology,prefgroup=module"))
    AND substring(1,10,p.entry_data)="prefvalue:")
  DETAIL
   beg_psn = 0, beg_psn = findstring("prefgroup=",p.dist_name,72)
   IF (beg_psn > 0)
    end_psn = 0, end_psn = findstring(",",p.dist_name,beg_psn)
    IF (end_psn > 0)
     equal_psn = 0, equal_psn = findstring("=",p.dist_name,beg_psn)
     IF (equal_psn > 0)
      len = ((end_psn - equal_psn) - 1), start = (equal_psn+ 1), position_text = " ",
      position_text = substring(start,len,p.dist_name)
      IF (position_text > " ")
       IF (isnumeric(position_text))
        position_cd = cnvtreal(position_text), found_ind = 0, start = 1,
        num = 0
        IF (pos_cnt > 0)
         found_ind = locateval(num,start,pos_cnt,position_cd,reply->positions[num].code_value)
        ENDIF
        IF (found_ind=0)
         pos_cnt = (pos_cnt+ 1), stat = alterlist(reply->positions,pos_cnt), reply->positions[pos_cnt
         ].code_value = position_cd
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  FROM (dummyt d  WITH seq = pos_cnt),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_value=reply->positions[d.seq].code_value))
  DETAIL
   reply->positions[d.seq].display = cv.display, reply->positions[d.seq].mean = cv.cdf_meaning, reply
   ->positions[d.seq].active_ind = cv.active_ind
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
