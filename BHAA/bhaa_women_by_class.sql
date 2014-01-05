exec RTSys.dbo.spDropTempTable #A
exec RTSys.dbo.spDropTempTable #B

select 0 as Pos, r.RaceName, re.EventDescr, tt.TeamType, t2.TempTeamId,
  t2.TotalPos as [Total Pos],
  TeamName as [Team Name], t2.TotalStd as [Team Std],
  RaceNo, Firstname + ' ' + Lastname as [Name], g.Gender, cl.ClubName as [Company],
  ea.OverallFinishPosition as [Overall Pos], RTSys.dbo.GetFinishTime(ea.FinishTime) as [Finish Time],
  case
	when t2.TotalStd between 1 and 30 then 'A'
	when t2.TotalStd between 31 and 36 then 'B'
	when t2.TotalStd between 37 and 42 then 'C'
	when t2.TotalStd between 43 and 90 then 'D'
  end as [Class], ea.ChipNo as [Std]
  into #A
from
EventAthlete ea
join EventTeam et
  on ea.RaceId = et.RaceId
  and ea.EventId = et.EventId
  and ea.teamId = et.TeamId
join RaceEvent re
  on ea.RaceId = re.RaceId
  and ea.EventId = re.EventId
join Athlete a
  on ea.AthleteId = a.AthleteId
left join RTSys.dbo.Race r
  on ea.RaceId = r.RaceId
left join EventTeamType tt
  on et.Raceid = tt.RaceId
  and et.EventId = tt.EventId
  and et.teamTypeId = tt.TeamTypeId
join EventGun eg
  on ea.RaceId = eg.RaceId
  and ea.EventId = eg.EventId
  and ea.EventGunId = eg.EventGunId
join EventTeamResultType2 t2
  on et.RaceId = t2.RaceId
  and et.EventId = t2.EventId
  and et.TeamId = t2.TeamId
  and et.TeamTypeId = t2.TeamTypeId
  and ea.Type2TeamId = t2.TempTeamId
left join Club cl
  on ea.Clubid = cl.ClubId
join RTSys.dbo.Gender g
  on a.GenderId = g.GenderId
where
  ea.RaceId =  <<RACEID>> 
  and ea.EventId =  <<EVENTID>> 
  and ea.FinishStatusId = 4
  and IsNull(t2.FinishPosition, 1000000) <=  <<GROUPCOUNT>> 
  and t2.GenderId = 2

/*
select TeamType, Class, [Team Std], [Team Name] from ##A
group by TeamType, Class, [Team Std], [Team Name]
order by TeamType, Class, [Team Std]

select * from #b
*/

select Row_Number() over (partition by TeamType, Class order by TeamType, Class, [Team Std]) as Pos, [Team Std],
  TeamType, Class, [Team Name], TempTeamId
into #B
from #A
group by TeamType, Class, [Team Name], [Team Std], TempTeamId


update #A
set
	Pos = b.Pos
from
	#A a
	join #B b
		on a.TeamType = b.TeamType
		and a.Class = b.Class
		and a.[Team Name] = b.[Team Name]
		and a.TempTeamId = b.TempTeamId
	
select * from #A
order by Class, Pos, [Team Std], [Team Name], [Overall Pos]

--select * from #b order by Class, Pos
