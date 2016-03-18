bhaa-racetec
============


| Field | BHAA Schema | Note | Racetec Field | Racetec Schema |
| ----- | ----------- | ---- | ------------- | -------------- |
| Postion	|raceresult.position	|Empty for Reg| Value for Export	|	
| Race Number	|raceresult.racenumber	|	[Event].Race Number & [Event].Import Key|	ea.RaceNo, ea.ImportKey|
| Runner ID|	runner.id|	4 digit BHAA num or 5 digit Day	|[Athlete].Member Number|	a.MemberNo|
| Time	|raceresult.time	|Empty for Reg| Value for Export		|
| Surname|	runner.surname	|	[Athlete].Last |Name|	a.LastName|
| Firstnane	|runner.firstname		|[Athlete].First |Name	|a.FirstName|
| Gender	|runner.gender	|M or F for racetec	|[Athlete].Gender|	a.GenderId|
| BHAA Standard|	runner.standard	|raceresult.standard	|[Event].Chip Number|	ea.ChipNo|
| Date Of Birth|	runner.dateofbirth	|YYYY-MM-DD	|[Athlete].Date of Birth|	a.DateOfBirth|
| Age Category	|raceresult.category|		Not imported||	
| Team Name	|team.name	|	[Event].Team Name	|et.TeamName|
| Team ID	|team.id	|BHAA Team ID	|[Athlete].PhoneHome	|a.PhoneHome|
| Comany Name|	company.name|		[Event].Club Name	|cl.ClubName|
| Company ID	|company.id	|BHAA Company ID	[Athlete].PhoneWork	|a.PhoneWork|
| Event	|event.tag_race.distance|	abc2012_5km	|[Event].Event|	
| RaceId	|raceresult.race|	Export only	|Not imported|	
| Email	|runner.email	|	[Athlete].Email|	a.Email|
| Newsletter	|runner.newsletter|	BHAA import only	|Not imported|	
| Mobile	|runner.mobile		|[Athlete].PhoneCell	|a.PhoneCell|
| TextAlert|	runner.textmessage	|BHAA import only	|Not imported	|
| Address1	|runner.address1	|BHAA import only	|[Athlete].Address1|	a.Address1|
| Address2	|runner.address2	|BHAA import only	|[Athlete].Address2|	a.Address2|
| Address3	|runner.address3	|BHAA import only	|[Athlete].Address3|	a.Address3|
| type|	type|	Option BHAA |reg fields	|Not imported|	
| last_modified|	last_modified,	Option BHAA reg fields	|Not imported	|

This is a backup of the racetec SQL reports for the BHAA.

The field mapping between BHAA and Racetec

| BHAA Field | Racetec Field |
| ---------- | ------------- |
| Team ID | [Athlete].PhoneHome |
| Team Name | [Event].ClubName |
| Company Name | [Athlete].ClubName |
| Company ID | [Athlete].PhoneWork |
| Standard | [Event].ChipNo |

Basically racetec uses the team name as the ID for all report, so
we need to map the BHAA uniqued ID this this field. We can still 
add the BHAA company name as an additional attr.

The BHAA standard is mapped to Chip number (slight hack since this field
isn't used in racetec).

For running team report there is a sequence

1 - Calculate team results : this calls a sp which populates the results table.
2 - The BHAA positions and class report then read data from this table.
3 - It is possible to tweak the class boundaries within the SQL.

-- racetec table export
id,runner,racenumber,event,firstname,surname,gender,dateofbirth,agecat,standard,address1,address2,address3,email,newsletter,mobile,textmessage,companyid,companyname,teamid,teamname,type,last_modified,
==> bhaa_racetec_import.dit

-- raceresult table export 
position,racenumber,id,racetime,surname,firstname,gender,dateofbirth,standard,category,teamname,teamid,companyname,companyid,event,race,email,newsletter,mobilephone,textmessage,address1,address2,address3,
==> bhaa_raceresult_import.dit

Populate the teams

exec RTSYs.dbo.[spComputeTeamFinishPositionsType3] 'RaceTec', 'RTSys',  <<RACEID>> ,  <<EVENTID>> , 0

select 'BHAA Racetec Results Calculated Successfully'
