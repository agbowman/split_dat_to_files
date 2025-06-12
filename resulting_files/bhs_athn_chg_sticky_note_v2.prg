CREATE PROGRAM bhs_athn_chg_sticky_note_v2
 FREE RECORD orequest
 RECORD orequest(
   1 sticky_note_id = f8
   1 sticky_note_type_cd = f8
   1 parent_entity_name = c40
   1 parent_entity_id = f8
   1 sticky_note_text = vc
   1 sticky_note_status_cd = f8
   1 public_ind = i2
 )
 FREE RECORD oreply
 RECORD oreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SET oreply->status_data.status = "F"
 RECORD t_request(
   1 param = vc
 )
 RECORD t_reply(
   1 param = vc
 )
 DECLARE username = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $3)
    AND p.active_ind=1)
  HEAD p.person_id
   username = p.username
  WITH nocounter, time = 30
 ;end select
 IF (textlen(username))
  SET namelen = (textlen(username)+ 1)
  SET domainnamelen = (textlen(curdomain)+ 2)
  SET statval = memalloc(name,1,build("C",namelen))
  SET statval = memalloc(domainname,1,build("C",domainnamelen))
  SET name = username
  SET domainname = curdomain
  SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
 ELSE
  GO TO end_prog
 ENDIF
 DECLARE t_line = vc
 SET t_request->param =  $6
 EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST",t_request), replace("REPLY",t_reply)
 SET t_line = t_reply->param
 SET orequest->sticky_note_id =  $2
 SET orequest->sticky_note_type_cd =  $4
 SET orequest->public_ind =  $5
 SET orequest->sticky_note_text = t_line
 SET stat = tdbexecute(600005,500196,500404,"REC",orequest,
  "REC",oreply)
#end_prog
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(oreply)
 ELSE
  CALL echojson(oreply, $1)
 ENDIF
END GO
