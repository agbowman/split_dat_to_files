CREATE PROGRAM bhs_athn_add_sticky_note
 RECORD orequest(
   1 sticky_note_type_cd = f8
   1 parent_entity_name = c40
   1 parent_entity_id = f8
   1 sticky_note_text = vc
   1 sticky_note_status_cd = f8
   1 public_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
 )
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
 SET namelen = (textlen(username)+ 1)
 SET domainnamelen = (textlen(curdomain)+ 2)
 SET statval = memalloc(name,1,build("C",namelen))
 SET statval = memalloc(domainname,1,build("C",domainnamelen))
 SET name = username
 SET domainname = curdomain
 SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
 DECLARE t_line = vc
 SET t_request->param =  $6
 EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST",t_request), replace("REPLY",t_reply)
 SET t_line = t_reply->param
 SET orequest->parent_entity_id =  $2
 SET orequest->parent_entity_name = "PERSON"
 SET orequest->sticky_note_type_cd =  $4
 SET orequest->public_ind =  $5
 SET orequest->sticky_note_text = t_line
 SET stat = tdbexecute(3200000,3200090,500183,"REC",orequest,
  "REC",oreply)
 CALL echojson(oreply, $1)
END GO
