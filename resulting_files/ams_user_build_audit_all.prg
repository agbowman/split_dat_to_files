CREATE PROGRAM ams_user_build_audit_all
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter a Username to Audit" = "",
  "Or Enter a Person ID to Audit" = 0,
  "Pipe Delimited or Excel Format?" = ""
  WITH outdev, username, personid,
  format
 RECORD parse(
   1 un[*]
     2 username = vc
 )
 RECORD temp(
   1 users[*]
     2 person_id = f8
     2 update_username = vc
     2 last_name = vc
     2 first_name = vc
     2 middle_name = vc
     2 suffix = vc
     2 title = vc
     2 sex = vc
     2 birthdate = vc
     2 username = vc
     2 position = vc
     2 active = i4
     2 ssn = vc
     2 usr_group = vc
     2 orgs = vc
     2 outreach = vc
     2 ppr = vc
     2 keychain = vc
     2 end_effective_dt_tm = vc
     2 logical_domain_id = f8
     2 output_ind = i2
 )
 DECLARE date_run = vc
 DECLARE temp_str = vc
 DECLARE head_str = vc
 DECLARE ssn_cd = f8
 DECLARE facility_cd = f8
 DECLARE hospital_cd = f8
 DECLARE current_cd = f8
 DECLARE inst_cd = f8
 DECLARE users = vc
 DECLARE find_pos = i4
 DECLARE cnt = i4
 DECLARE length = i4
 DECLARE num = i4
 DECLARE domain = vc
 DECLARE in_domain = i2
 DECLARE prog_name = vc
 DECLARE run_ind = i2
 SET ssn_cd = uar_get_code_by("MEANING",4,"SSN")
 SET facility_cd = uar_get_code_by("MEANING",222,"FACILITY")
 SET hospital_cd = uar_get_code_by("MEANING",278,"HOSPITAL")
 SET current_cd = uar_get_code_by("MEANING",213,"CURRENT")
 SET inst_cd = uar_get_code_by("MEANING",223,"INSTITUTION")
 SET domain = curdomain
 SET prog_name = "AMS_USER_BUILD_AUDIT_ALL"
 SET run_ind = 0
 SET run_ind = amsuser(reqinfo->updt_id)
 IF (run_ind=1)
  CALL echo(value( $USERNAME))
  CALL echo(textlen( $USERNAME))
  CALL echo(findstring(",", $USERNAME,1,0))
  IF (( $USERNAME > " "))
   SET length = textlen( $USERNAME)
   CALL echo(length)
   WHILE (find_pos < length)
     IF (find_pos=0)
      SET find_pos = findstring(",", $USERNAME,1,0)
      CALL echo(find_pos)
      SET users = substring(1,(findstring(",", $USERNAME,1,0) - 1), $USERNAME)
      CALL echo(users)
      SET cnt = (cnt+ 1)
      SET stat = alterlist(parse->un,cnt)
      SET parse->un[cnt].username = cnvtupper(users)
      IF (find_pos=0)
       SET find_pos = length
       SET parse->un[cnt].username = cnvtupper( $USERNAME)
      ENDIF
     ELSE
      SET users = substring((find_pos+ 1),((findstring(",", $USERNAME,(find_pos+ 1),0) - find_pos) -
       1), $USERNAME)
      CALL echo(users)
      SET find_pos = findstring(",", $USERNAME,(find_pos+ 1),0)
      CALL echo(find_pos)
      SET cnt = (cnt+ 1)
      SET stat = alterlist(parse->un,cnt)
      SET parse->un[cnt].username = users
      IF (find_pos=0)
       SET find_pos = length
       SET parse->un[cnt].username = trim(substring((findstring(",", $USERNAME,1,1)+ 1),15, $USERNAME
         ))
      ENDIF
     ENDIF
   ENDWHILE
   CALL echorecord(parse)
   SELECT DISTINCT INTO "nl:"
    FROM prsnl p,
     person r,
     person_name n,
     prsnl p2
    PLAN (p
     WHERE expand(num,1,size(parse->un,5),p.username,parse->un[num].username))
     JOIN (p2
     WHERE p.updt_id=p2.person_id)
     JOIN (r
     WHERE p.person_id=r.person_id)
     JOIN (n
     WHERE p.person_id=n.person_id
      AND n.name_type_cd=current_cd
      AND n.active_ind=1
      AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY p.name_full_formatted
    HEAD REPORT
     cnt = 0
    HEAD p.name_full_formatted
     cnt = (cnt+ 1), stat = alterlist(temp->users,cnt), temp->users[cnt].person_id = p.person_id,
     temp->users[cnt].end_effective_dt_tm = format(p.end_effective_dt_tm,"mm/dd/yyyy;;d"), temp->
     users[cnt].update_username = trim(p2.username), temp->users[cnt].last_name = trim(p.name_last),
     temp->users[cnt].first_name = trim(p.name_first), temp->users[cnt].middle_name = trim(n
      .name_middle), temp->users[cnt].suffix = trim(n.name_suffix),
     temp->users[cnt].title = trim(n.name_title), temp->users[cnt].sex = trim(uar_get_code_display(r
       .sex_cd)), temp->users[cnt].birthdate = format(r.birth_dt_tm,"mm/dd/yyyy;;d"),
     temp->users[cnt].username = trim(p.username), temp->users[cnt].position = trim(
      uar_get_code_display(p.position_cd)), temp->users[cnt].active = p.active_ind,
     temp->users[cnt].logical_domain_id = p.logical_domain_id
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM prsnl p,
     person r,
     person_name n,
     prsnl p2
    PLAN (p
     WHERE (p.person_id= $PERSONID))
     JOIN (p2
     WHERE p.updt_id=p2.person_id)
     JOIN (r
     WHERE p.person_id=r.person_id)
     JOIN (n
     WHERE p.person_id=n.person_id
      AND n.name_type_cd=current_cd
      AND n.active_ind=1
      AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY p.name_full_formatted
    HEAD REPORT
     cnt = 0
    HEAD p.name_full_formatted
     cnt = (cnt+ 1), stat = alterlist(temp->users,cnt), temp->users[cnt].person_id = p.person_id,
     temp->users[cnt].end_effective_dt_tm = format(p.end_effective_dt_tm,"mm/dd/yyyy;;d"), temp->
     users[cnt].update_username = trim(p2.username), temp->users[cnt].last_name = trim(p.name_last),
     temp->users[cnt].first_name = trim(p.name_first), temp->users[cnt].middle_name = trim(n
      .name_middle), temp->users[cnt].suffix = trim(n.name_suffix),
     temp->users[cnt].title = trim(n.name_title), temp->users[cnt].sex = trim(uar_get_code_display(r
       .sex_cd)), temp->users[cnt].birthdate = format(r.birth_dt_tm,"mm/dd/yyyy;;d"),
     temp->users[cnt].username = trim(p.username), temp->users[cnt].position = trim(
      uar_get_code_display(p.position_cd)), temp->users[cnt].active = p.active_ind,
     temp->users[cnt].logical_domain_id = p.logical_domain_id
    WITH nocounter
   ;end select
  ENDIF
  IF (size(temp->users,5) > 0)
   SELECT INTO "nl:"
    FROM person_alias p,
     (dummyt d  WITH seq = value(size(temp->users,5)))
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=temp->users[d.seq].person_id)
      AND p.person_alias_type_cd=ssn_cd
      AND p.active_ind=1)
    DETAIL
     temp->users[d.seq].ssn = trim(p.alias)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM prsnl_group_reltn p,
     prsnl_group g,
     (dummyt d  WITH seq = value(size(temp->users,5)))
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=temp->users[d.seq].person_id)
      AND p.active_ind=1)
     JOIN (g
     WHERE p.prsnl_group_id=g.prsnl_group_id)
    ORDER BY p.person_id
    HEAD p.person_id
     cnt = 0
    DETAIL
     IF ((temp->users[d.seq].usr_group=" "))
      temp->users[d.seq].usr_group = g.prsnl_group_name
     ELSE
      temp->users[d.seq].usr_group = build2(temp->users[d.seq].usr_group,",",g.prsnl_group_name)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM prsnl_org_reltn p,
     location l,
     (dummyt d  WITH seq = value(size(temp->users,5)))
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=temp->users[d.seq].person_id)
      AND  EXISTS (
     (SELECT
      "x"
      FROM org_type_reltn r
      WHERE p.organization_id=r.organization_id
       AND r.org_type_cd=hospital_cd))
      AND p.active_ind=1
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (l
     WHERE p.organization_id=l.organization_id
      AND l.location_type_cd=facility_cd)
    ORDER BY p.person_id
    HEAD p.person_id
     cnt = 0, string = " "
    DETAIL
     IF ((temp->users[d.seq].orgs=" "))
      temp->users[d.seq].orgs = uar_get_code_display(l.location_cd)
     ELSE
      temp->users[d.seq].orgs = build2(temp->users[d.seq].orgs,",",uar_get_code_display(l.location_cd
        ))
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM org_set_prsnl_r o,
     org_set s,
     (dummyt d  WITH seq = value(size(temp->users,5)))
    PLAN (d)
     JOIN (o
     WHERE (o.prsnl_id=temp->users[d.seq].person_id)
      AND o.active_ind=1
      AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (s
     WHERE o.org_set_id=s.org_set_id)
    ORDER BY o.prsnl_id
    HEAD o.prsnl_id
     cnt = 0, string = " "
    DETAIL
     IF ((temp->users[d.seq].outreach=" "))
      temp->users[d.seq].outreach = s.name
     ELSE
      temp->users[d.seq].outreach = build2(temp->users[d.seq].outreach,",",s.name)
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM prsnl_service_resource_reltn p,
     service_resource s,
     (dummyt d  WITH seq = value(size(temp->users,5)))
    PLAN (d)
     JOIN (p
     WHERE (p.prsnl_id=temp->users[d.seq].person_id))
     JOIN (s
     WHERE s.service_resource_cd=p.service_resource_cd
      AND s.service_resource_type_cd=inst_cd)
    DETAIL
     IF ((temp->users[d.seq].ppr=" "))
      temp->users[d.seq].ppr = uar_get_code_display(s.service_resource_cd)
     ELSE
      temp->users[d.seq].ppr = build2(temp->users[d.seq].ppr,",",uar_get_code_display(s
        .service_resource_cd))
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM sch_assoc s,
     sch_object o,
     (dummyt d  WITH seq = value(size(temp->users,5)))
    PLAN (d)
     JOIN (s
     WHERE s.assoc_type_meaning="PRSNLCHAIN"
      AND s.child_table="PERSON"
      AND s.parent_table="SCH_OBJECT"
      AND (s.child_id=temp->users[d.seq].person_id))
     JOIN (o
     WHERE s.parent_id=o.sch_object_id)
    DETAIL
     IF ((temp->users[d.seq].keychain=" "))
      temp->users[d.seq].keychain = o.mnemonic
     ELSE
      temp->users[d.seq].keychain = build2(temp->users[d.seq].keychain,",",o.mnemonic)
     ENDIF
   ;end select
  ENDIF
  FOR (a = 1 TO size(temp->users,5))
   SET in_domain = isuserindomain(reqinfo->updt_id,temp->users[a].logical_domain_id)
   IF (in_domain IN (- (1), 1))
    SET temp->users[a].output_ind = 1
   ENDIF
  ENDFOR
  IF (value( $FORMAT)="0")
   SET head_str = build2("Domain","|","Builder","|","Active Ind",
    "|","End Date","|","Last Name","|",
    "First Name","|","Middle Name","|","Suffix",
    "|","|","Title","|","|",
    "Gender","|","DOB","|","Username",
    "|","Position","|","SSN","|",
    "User Groups","|","Facilities","|","Org Groups",
    "|","|","PPR","|","|",
    "Scheduling")
   SELECT INTO  $1
    FROM (dummyt d  WITH seq = value(size(temp->users,5)))
    PLAN (d)
    ORDER BY d.seq
    HEAD d.seq
     IF ((temp->users[d.seq].output_ind=1))
      temp_str = trim(build2(trim(curdomain),"|",temp->users[d.seq].update_username,"|",temp->users[d
        .seq].active,
        "|",temp->users[d.seq].end_effective_dt_tm,"|",temp->users[d.seq].last_name,"|",
        temp->users[d.seq].first_name,"|",temp->users[d.seq].middle_name,"|",temp->users[d.seq].
        suffix,
        "|","|",temp->users[d.seq].title,"|","|",
        temp->users[d.seq].sex,"|",temp->users[d.seq].birthdate,"|",temp->users[d.seq].username,
        "|",temp->users[d.seq].position,"|",temp->users[d.seq].ssn,"|",
        temp->users[d.seq].usr_group,"|",temp->users[d.seq].orgs,"|",temp->users[d.seq].outreach,
        "|","|",temp->users[d.seq].ppr,"|","|",
        temp->users[d.seq].keychain,"|"))
      IF (d.seq=1)
       col 0, head_str, row + 1
      ENDIF
      col 0, temp_str, row + 1
     ENDIF
    WITH maxcol = 5000
   ;end select
  ELSE
   SELECT
    IF (cnvtint( $USERNAME)=1)
     WHERE trim(temp->users[d1.seq].username) > ""
    ELSE
    ENDIF
    INTO value( $OUTDEV)
    cur_domain = domain, last_updated_by = temp->users[d1.seq].update_username, active = temp->users[
    d1.seq].active,
    end_date = temp->users[d1.seq].end_effective_dt_tm, last_name = temp->users[d1.seq].last_name,
    first_name = temp->users[d1.seq].first_name,
    middle_name = temp->users[d1.seq].middle_name, suffix = temp->users[d1.seq].suffix, title = temp
    ->users[d1.seq].title,
    sex = temp->users[d1.seq].sex, birthdate = temp->users[d1.seq].birthdate, username = temp->users[
    d1.seq].username,
    position = temp->users[d1.seq].position, ssn = temp->users[d1.seq].ssn, user_groups = trim(
     substring(1,300,temp->users[d1.seq].usr_group)),
    organizations = trim(substring(1,300,temp->users[d1.seq].orgs)), org_groups = temp->users[d1.seq]
    .outreach, ppr_orgs = temp->users[d1.seq].ppr,
    keychains = temp->users[d1.seq].keychain
    FROM (dummyt d1  WITH seq = value(size(temp->users,5)))
    PLAN (d1
     WHERE (temp->users[d1.seq].output_ind=1))
    ORDER BY temp->users[d1.seq].last_name
    WITH format, skipreport = 1, separator = " ",
     maxcol = 5000
   ;end select
  ENDIF
  CALL updtdminfo(prog_name)
 ELSE
  SELECT INTO  $1
   FROM dummyt d
   HEAD REPORT
    row 3, col 20, "THIS PROGRAM IS INTENDED FOR USE BY AMS ASSOCIATES ONLY"
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE ce_flag = i4
   SET ce_flag = 0
   DECLARE ce_temp = vc WITH noconstant("")
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET ce_flag = 1
    ENDIF
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(ce_flag)
 END ;Subroutine
 DECLARE isuserindomain(user_id=f8,log_domain_id=f8) = i2
 SUBROUTINE isuserindomain(user_id,log_domain_id)
   DECLARE return_val = i2 WITH noconstant(- (1)), protect
   DECLARE b_logicaldomain = i4 WITH constant(column_exists("PRSNL","LOGICAL_DOMAIN_ID")), protect
   DECLARE user_domain_grp_id = f8 WITH noconstant(0.0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=reqinfo->updt_id))
     HEAD p.person_id
      user_domain_grp_id = p.logical_domain_grp_id
      IF (user_domain_grp_id=0.0)
       IF (p.logical_domain_id=log_domain_id)
        return_val = 1
       ELSE
        return_val = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    IF (user_domain_grp_id > 0.0)
     SELECT INTO "nl:"
      FROM logical_domain_grp_reltn ld
      PLAN (ld
       WHERE ld.logical_domain_grp_id=user_domain_grp_id
        AND ld.active_ind=1
        AND ld.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND ld.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
      HEAD ld.logical_domain_grp_id
       return_val = 0
      HEAD ld.logical_domain_id
       IF (ld.logical_domain_id=log_domain_id)
        return_val = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE updtdminfo(prog_name)
   DECLARE found = i2
   DECLARE info_nbr = i4
   SET found = 0
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="AMS_TOOLKIT"
     AND d.info_name=prog_name
    DETAIL
     found = 1, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=0)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=prog_name
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE amsuser(person_id)
   DECLARE user_ind = i2
   DECLARE prsnl_cd = f8
   SET user_ind = 0
   SET prsnl_cd = uar_get_code_by("MEANING",213,"PRSNL")
   SELECT
    p.person_id
    FROM person_name p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.name_type_cd=prsnl_cd
     AND p.name_title="Cerner AMS"
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     IF (p.person_id > 0)
      user_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   RETURN(user_ind)
 END ;Subroutine
END GO
