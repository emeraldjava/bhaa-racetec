select   
	
ea.OverallFinishPosition as [Pos], 
ea.RaceNo as [Race No],	
a.MemberNo as [MemberNo],
RTSys.dbo.GetFinishTimeDECR(ea.FinishTime,0, 0)  as [Time], 
a.Lastname as [Surname],
a.Firstname as [Name],	
case a.GenderId When 1 then 'M' else 'F' end as [Gender], 
a.PhoneFax as [Standard],
Convert(Varchar, a.DateOfBirth, 103) as [Date of Birth],
eac.Category as [Cat],
cl.ClubName as [Company],
a.PhoneHome as [Team No], 
et.TeamName as [Teamname],
a.PhoneWork as [Company No]

from
	Athlete a
	join EventAthlete ea
		on a.AthleteId = ea.AthleteId
	left join EventAgeCategory eac
		on ea.RaceId = eac.RaceId
		and ea.EventId = eac.EventId
		and ea.AgeCategoryId = eac.AgeCategoryId
	left join EventSecondaryCategory esc
		on ea.RaceId = esc.RaceId
		and ea.EventId = esc.EventId
		and ea.SecondaryCategoryId = esc.AgeCategoryId
	join RaceEvent re
		on ea.RaceId = re.RaceId
		and ea.EventId = re.EventId
	left join RTSys.dbo.Race r
		on re.RaceId = r.RaceId
	left join RTSys.dbo.Country cty
		on a.CountryId = cty.CountryId
	left join RTSys.dbo.State st
		on a.CountryId = st.CountryId
		and a.StateId = st.StateId
	join RTSys.dbo.Gender g
		on a.GenderId = g.GenderId
	join EventGun eg
		on ea.RaceId = eg.RaceId
		and ea.EventId = eg.EventId
		and ea.EventGunId = eg.EventGunId
	left join Club cl
		on ea.ClubId = cl.ClubId
	left join EventTeam et
		on ea.RaceId = et.RaceId
		and ea.EventId = et.EventId
		and ea.TeamId = et.TeamId
	left join EventTeamType ett
		on et.RaceId = ett.RaceId
		and et.EventId = ett.EventId
		and et.TeamTypeId = ett.TeamTypeId
	left join EventMedal em
		on ea.RaceId = em.RaceId
		and ea.EventId = em.EventId
		and ea.medalId = em.MedalId
	join RTSys.dbo.FinishStatus f
		on ea.FinishStatusId = f.FinishStatusId
	left join (	select ea.RaceId, ea.EventId, a.GenderId, ea.AgeCategoryId, min(ea.FinishTime) as FinishTime, count(*) as CategCount
				from 
					EventAthlete ea 
					join Athlete a
						on ea.AthleteId = a.AthleteId
				where
					ea.RaceId = <<RACEID>> 
					and ea.EventId = <<EVENTID>>
					and ea.FinishStatusId = 4 
				group by ea.RaceId, ea.EventId, a.GenderId, ea.AgeCategoryId
				) tbc
		on ea.RaceId = tbc.RaceId
		and ea.EventId = tbc.EventId
		and ea.AgeCategoryId = tbc.AgeCategoryId
		and a.GenderId = tbc.GenderId
	left join (	select ea.RaceId, ea.EventId, a.GenderId, min(ea.FinishTime) as FinishTime, count(*) as GenderCount
				from 
					EventAthlete ea 
					join Athlete a
						on ea.AthleteId = a.AthleteId
				where
					ea.RaceId = <<RACEID>> 
					and ea.EventId = <<EVENTID>>
					and ea.FinishStatusId = 4 
				group by ea.RaceId, ea.EventId, a.GenderId
				) tbg
		on ea.RaceId = tbg.RaceId
		and ea.EventId = tbg.EventId
		and a.GenderId = tbg.GenderId
	left join (	select ea.RaceId, ea.EventId, min(ea.FinishTime) as FinishTime, count(*) as OverallCount
				from 
					EventAthlete ea 
					join Athlete a
						on ea.AthleteId = a.AthleteId
				where
					ea.RaceId = <<RACEID>> 
					and ea.EventId = <<EVENTID>> 
					and ea.FinishStatusId = 4 
				group by ea.RaceId, ea.EventId
				) tbo
		on ea.RaceId = tbo.RaceId
		and ea.EventId = tbo.EventId
	left join (	select ea.RaceId, ea.EventId, a.GenderId, ea.AgeCategoryId, max(ea.NoLaps) as NoLaps, count(*) as CategCount
				from 
					EventAthlete ea 
					join Athlete a
						on ea.AthleteId = a.AthleteId
				where
					ea.RaceId = <<RACEID>> 
					and ea.EventId = <<EVENTID>>
					and ea.FinishStatusId = 4 
				group by ea.RaceId, ea.EventId, a.GenderId, ea.AgeCategoryId
				) lbc
		on ea.RaceId = lbc.RaceId
		and ea.EventId = lbc.EventId
		and ea.AgeCategoryId = lbc.AgeCategoryId
		and a.GenderId = lbc.GenderId
	left join (	select ea.RaceId, ea.EventId, max(ea.NoLaps) as NoLaps, count(*) as CategCount
				from 
					EventAthlete ea 
					join Athlete a
						on ea.AthleteId = a.AthleteId
				where
					ea.RaceId = <<RACEID>> 
					and ea.EventId = <<EVENTID>>
					and ea.FinishStatusId = 4 
				group by ea.RaceId, ea.EventId
				) lbo
		on ea.RaceId = lbo.RaceId
		and ea.EventId = lbo.EventId
	
	
	
 left join EventAthleteAttribute eaa1
   on ea.RaceId = eaa1.RaceId 
   and ea.EventId = eaa1.EventId 
   and ea.AthleteId = eaa1.AthleteId 
   and eaa1.AttributeId = 1

 left join EventAthleteAttribute eaa2
   on ea.RaceId = eaa2.RaceId 
   and ea.EventId = eaa2.EventId 
   and ea.AthleteId = eaa2.AthleteId 
   and eaa2.AttributeId = 2

where
	ea.RaceId = <<RACEID>>
	and ea.EventId = <<EVENTID>>
	and f.FinishStatus in ('Finished')
	
	
order by ea.OverallFinishPosition 
