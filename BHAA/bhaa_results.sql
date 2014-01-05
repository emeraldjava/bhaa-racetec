select <<ROWCOUNT>> RaceName, EventDescr, ea.OverallFinishPosition as Pos, Firstname + ' ' + Lastname as 'Name',
  Country, ea.RaceNo, eac.Category, eac.CategoryCode, Gender, GenderCode + CategoryCode as GenCateg,
  cl.ClubName as Club, et.TeamName, a.MedicalDetails as 'Company', ea.ChipNo as 'Standard',
  RTSys.dbo.GetFinishTime(ea.FinishTime) as 'Time', 
  RTSys.dbo.GetFinishTime(ea.FinishTime - Fas.FinishTime) as 'Time Behind Categ', 
  RTSys.dbo.GetFinishTime(ea.FinishTime - TBL.FinishTime) as 'Time Behind Winner', 
  ea.GenderFinishPosition as 'GenderPos',
  ea.CategoryFinishPosition as 'CategPos',
  ea.Points, RTSys.dbo.GetTimeDiff(ea.PenaltyTime) as Penalty
from
Athlete a
join EventAthlete ea
  on a.Athleteid = ea.AthleteId
left join EventAgeCategory eac
  on ea.RaceId = eac.RaceId
  and ea.EventId = eac.EventId
  and ea.AgeCategoryId = eac.AgeCategoryId
join RaceEvent re
  on ea.RaceId = re.RaceId
  and ea.EventId = re.EventId
left join RTSys.dbo.Race r
  on re.RaceId = r.RaceId
left join RTSys.dbo.Country cty
  on a.CountryId = cty.CountryId
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
join (select RaceId, EventId, GenderId, AgeCategoryId, min(FinishTime) as FinishTime
      from EventAthlete a join  Athlete b
        on a.AthleteId = b.AthleteId
      where
        RaceId =  <<RACEID>> 
        and EventId =  <<EVENTID>> 
      group by RaceId, EventId, GenderId, AgeCategoryId) Fas
  on ea.Raceid = Fas.RaceId
  and ea.EventId = Fas.EventId
  and ea.AgeCategoryId = Fas.AgeCategoryId
  and a.GenderId = Fas.GenderId
join (select RaceId, EventId, GenderId, min(FinishTime) as FinishTime
      from EventAthlete a join  Athlete b
        on a.AthleteId = b.AthleteId
      where
        RaceId =  <<RACEID>> 
        and EventId =  <<EVENTID>> 
      group by RaceId, EventId, GenderId) TBL
  on ea.Raceid = TBL.RaceId
  and ea.EventId = TBL.EventId
  and a.GenderId = TBL.GenderId
where
  ea.RaceId = <<RACEID>>
  and ea.EventId = <<EVENTID>>
  and ea.FinishStatusId = 4
order by ea.OverallFinishPosition
