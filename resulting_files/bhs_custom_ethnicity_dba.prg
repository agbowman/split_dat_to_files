CREATE PROGRAM bhs_custom_ethnicity:dba
 IF (validate(reply->text,"-1")="-1")
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
  ) WITH protect
 ENDIF
 SELECT INTO "n1:"
  FROM bhs_demographics bd
  WHERE (bd.person_id=request->person_id)
   AND trim(bd.description,3)="ethnicity 1"
   AND bd.active_ind=1
  ORDER BY bd.beg_effective_dt_tm DESC
  HEAD bd.person_id
   reply->text = concat("<html><body><p>",trim(uar_get_code_display(bd.code_value),3),
    "</p></body></html>")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->text = "<html><body><p></p></body></html>"
 ENDIF
 SET reply->format = 1
END GO
