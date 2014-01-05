-- drop temp tables
exec RTSys.dbo.spDropTempTable #A
exec RTSys.dbo.spDropTempTable #B

-- copy the raw data to temp table
select 
  0 as Pos, 
  r.RaceName, 
  re.EventDescr,
  tt.TeamType, 
  t2.FinishPosition as [Team Pos], 
  t2.TeamTypeId,
  t2.TeamId,
  t2.TempTeamId,
  t2.TotalPos as [Team Total],
  TeamName as [Team Name], 
  t2.TotalStd as [Team Std],
  RaceNo, 
  Firstname + ' ' + Lastname as [Name], 
  g.Gender, 
  cl.ClubName as [Company],
  ea.OverallFinishPosition as [Overall Pos], 
  RTSys.dbo.GetFinishTime(ea.FinishTime) as [Finish Time],
  ea.ChipNo as [Std],
  '' as Class,
  a.PhoneHome as [Team No], 
  a.PhoneWork as [Company No],
  et.RaceId,
  et.EventId
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
  and IsNull(t2.FinishPosition, 1000000) <=  <<GROUPCOUNT>>
  and ea.FinishStatusId = 4
  and t2.GenderId = 1
order by tt.TeamType, IsNull(t2.FinishPosition, 1000000), ea.OverallFinishPosition

/*
  ea.RaceId =  <<RACEID>> 
  and ea.EventId =  <<EVENTID>> 
  and IsNull(t2.FinishPosition, 1000000) <=  <<GROUPCOUNT>>
*/

/*
select TeamType, Class, [Team Std], [Team Name] from ##A
group by TeamType, Class, [Team Std], [Team Name]
order by TeamType, Class, [Team Std]
select * from #a
select * from #b
*/

-- load team details from EventTeamResultType2 and calculate the team quartile values into temp table #b 
select 0 as Pos,
t2.RaceId,t2.EventId,t2.TeamId,t2.TempTeamId,t2.TeamTypeId,t2.TotalPos,t2.TotalStd,a.[Team Name],
case NTILE(4) over (order by t2.TotalStd) when 1 then 'A' when 2 then 'B' when 3 then 'C' else 'D' end as Class
into #b
from EventTeamResultType2 t2
inner join #a a on t2.TeamId=a.TeamId and t2.TempTeamId=a.TempTeamId
where t2.RaceId=<<RACEID>> and t2.EventId=<<EVENTID>>
group by t2.RaceId,t2.EventId,t2.TeamId,t2.TempTeamId,t2.TeamTypeId,t2.TotalPos,t2.TotalStd,a.[Team Name]
--select * from #b

-- update the position column in temp table based in class
update #b set Pos= subquery.Pos
FROM
(
select Row_Number() over (partition by TeamTypeId, Class order by TeamTypeId, Class, TotalPos) as Pos,TeamId,TempTeamId from #b
) subquery
inner join #b a on subquery.TeamId=a.TeamId and subquery.TempTeamId=a.TempTeamId
--select * from #b order by class,pos

-- merge back details from #b to the main #a table
update #A
set
	Pos = b.Pos,
	Class=b.Class
from
	#A a
	join #b b
		on a.TeamTypeId = b.TeamTypeId
		and a.[Team Name] = b.[Team Name]
		and a.TempTeamId = b.TempTeamId
		
--select * from #A
select * from #A order by Class, Pos,[Team Total]
