select r.RaceName, re.EventDescr, tt.TeamType, t2.FinishPosition as [Team Pos], t2.TotalPos as [Team Time],
  TeamName as [Team Name], t2.TotalStd as [Team Std],
  tt.ResultAthleteCount as [No of Finishers Needed for Result],
  RaceNo, Firstname + ' ' + Lastname as [Name], g.Gender, EventGunDescr as [Wave], cl.ClubName,
  ea.OverallFinishPosition as [Overall Pos], RTSys.dbo.GetFinishTime(ea.FinishTime) as [Finish Time],
  ea.ChipNo as [Std]
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
  and t2.GenderId = 2
  and IsNull(t2.FinishPosition, 1000000) <=  <<GROUPCOUNT>> 
order by tt.TeamType, IsNull(t2.FinishPosition, 1000000), ea.OverallFinishPosition