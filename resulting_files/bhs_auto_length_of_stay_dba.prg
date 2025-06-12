CREATE PROGRAM bhs_auto_length_of_stay:dba
 RECORD work(
   1 encntr_id = f8
   1 person_id = f8
   1 age_in_days = i4
   1 birth_dt_tm = dq8
   1 stay_length = vc
   1 admit_date = vc
 )
 IF (reflect(parameter(1,0)) > " ")
  SET work->encntr_id = cnvtreal( $1)
 ELSEIF (validate(request->visit[1].encntr_id,0.00) > 0.00)
  SET work->encntr_id = request->visit[1].encntr_id
 ELSE
  CALL echo("no encntr_id given. exiting script")
  GO TO exit_script
 ENDIF
 IF (validate(reply->text,"A")="A"
  AND validate(reply->text,"Z")="Z")
  RECORD reply(
    1 text = vc
  )
 ENDIF
 SELECT INTO "nl:"
  FROM encounter e,
   person p
  PLAN (e
   WHERE (work->encntr_id=e.encntr_id))
   JOIN (p
   WHERE e.person_id=p.person_id)
  DETAIL
   work->person_id = p.person_id, work->birth_dt_tm = p.birth_dt_tm, work->age_in_days = cnvtint(
    datetimediff(cnvtdatetime(curdate,curtime3),p.birth_dt_tm)),
   work->stay_length = trim(cnvtstring(cnvtint(datetimediff(cnvtdatetime(curdate,curtime3),e
       .reg_dt_tm))),3), work->admit_date = format(e.reg_dt_tm,"@SHORTDATETIME")
  WITH nocounter
 ;end select
 IF ((work->person_id <= 0.00))
  CALL echo("invalid encounter_id given. exiting script")
  GO TO exit_script
 ENDIF
 DECLARE print_out(header_text=vc,level=i2,required=i2,space_ind=i4) = null
 DECLARE beg_doc = vc WITH constant(
  "{\rtf1\ansi\deff0{\fonttbl{\f0\froman times new roman;}{\f1\fmodern courier new;}}\fs20 ")
 DECLARE end_doc = c1 WITH constant("}")
 DECLARE beg_lock = c44 WITH constant("{\*\txfieldstart\txfieldtype0\txfieldflags3}")
 DECLARE end_lock = c15 WITH constant("{\*\txfieldend}")
 DECLARE beg_bold = c2 WITH constant("\b")
 DECLARE end_bold = c3 WITH constant("\b0")
 DECLARE beg_ital = c2 WITH constant("\i")
 DECLARE end_ital = c3 WITH constant("\i0")
 DECLARE beg_uline = c3 WITH constant("\ul ")
 DECLARE end_uline = c4 WITH constant("\ul0 ")
 DECLARE newline = c6 WITH constant(concat("\par",char(10)))
 DECLARE blank_return = c2 WITH constant(concat(char(10),char(13)))
 DECLARE end_para = c5 WITH constant("\pard ")
 DECLARE indent0 = c4 WITH constant("\li0")
 DECLARE indent1 = c6 WITH constant("\li288")
 DECLARE indent2 = c6 WITH constant("\li576")
 DECLARE indent3 = c6 WITH constant("\li864")
 SET reply->text = concat(beg_doc,beg_bold," LOS ",trim(work->stay_length,3)," days",
  end_bold,end_doc)
#exit_script
 CALL echorecord(reply)
 CALL echorecord(work)
END GO
