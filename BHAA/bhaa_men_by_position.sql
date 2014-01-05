select 
  r.RaceName, 
  re.EventDescr, 
 -- (SELECT SUM(tx.TotalStd) FROM [RaceTec].[dbo].[EventTeamResultType2] tx
 --  where tx.RaceId=ea.RaceId and tx.EventId=ea.EventId and tx.TeamId=t2.TeamId and tx.TempTeamId=t2.TempTeamId) as [POC1],
 -- (SELECT NTILE(4) over (order by tx.TotalStd) FROM [RaceTec].[dbo].[EventTeamResultType2] tx
 --  where tx.RaceId=ea.RaceId and tx.EventId=ea.EventId and tx.TeamId=t2.TeamId and tx.TempTeamId=t2.TempTeamId) as [POC2],
  tt.TeamType, 
  t2.FinishPosition as [Team Pos], 
  t2.TempTeamId,
  t2.TotalPos as [Team Time],
  t2.TeamId as [Team ID],
  TeamName as [Team Name], 
  t2.TotalStd as [Team Std],
  tt.ResultAthleteCount as [No of Finishers Needed for Result],
  RaceNo, 
  Firstname + ' ' + Lastname as [Name], 
  g.Gender, 
  cl.ClubName,
  ea.OverallFinishPosition as [Overall Pos], 
  RTSys.dbo.GetFinishTime(ea.FinishTime) as [Finish Time],
  ea.ChipNo as [Std],
  qx.Q as [HUMM],

 -- (SELECT NTILE(4) over (order by TotalStd) FROM [RaceTec].[dbo].[EventTeamResultType2] where RaceId=12 and EventId=2 and TeamId=t2.TeamId and TeamTypeId=t2.TeamTypeId) as [Subselect],
--  (CASE NTILE(4) over (order by t2.TotalStd) when 1 then 'A' when 2 then 'B' when 3 then 'C' else 'D' end) as [Class],  
  
--  NTILE(4) over (ORDER by t2.TotalStd) as [klazz],
--NTILE(4) over (ORDER by t2.TotalPos) as [qpos],
  case NTILE(4) over (order by t2.TotalStd)
	when 1 then 'A' when 2 then 'B' when 3 then 'C' else 'D' end as [xxClass]
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
join EventTeamType tt
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
join (SELECT *, NTILE(4) over (order by TotalStd) as "Q" FROM [RaceTec].[dbo].[EventTeamResultType2]) qx
  on et.RaceId = qx.RaceId
  and et.EventId = qx.EventId
  and et.TeamId = qx.TeamId
  and et.TeamTypeId = qx.TeamTypeId
  and ea.Type2TeamId = qx.TempTeamId  
left join Club cl
  on ea.Clubid = cl.ClubId
join RTSys.dbo.Gender g
  on a.GenderId = g.GenderId
where
  ea.RaceId = 12
  and ea.EventId = 2 
  and IsNull(t2.FinishPosition, 1000000) <=  5000 
  and ea.FinishStatusId = 4
  and t2.GenderId = 1
--order by t2.FinishPosition, ea.OverallFinishPosition
--  order by t2.TeamID
order by tt.TeamType, t2.FinishPosition, ea.OverallFinishPosition,t2.TeamId

--  ea.RaceId =  <<RACEID>> 
--  and ea.EventId =  <<EVENTID>> 
--  and IsNull(t2.FinishPosition, 1000000) <=  <<GROUPCOUNT>> 
  