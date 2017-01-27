-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

create table players (id serial primary key, name varchar(100) not null);

create view registeredPlayers as 
select count(*) as registeredPlayers from players;

create table results (winner_id integer references players(id), 
loser_id integer references players(id),
primary key (winner_id, loser_id));

create view playerStandings as 
select p.id, p.name, coalesce(w.wins, 0) as wins, coalesce(w.wins, 0) + coalesce(l.losses, 0) as matches, 
row_number() over (order by coalesce(w.wins, 0) desc, coalesce(w.wins, 0) + coalesce(l.losses, 0)) as ranking 
from players as p 
left join (select winner_id, count(*) as wins from results group by winner_id) as w 
on p.id = w.winner_id 
left join (select loser_id, count(*) as losses from results group by loser_id) as l 
on p.id = l.loser_id;

create view swissPairings as 
select h.id as id1, h.name as name1, a.id as id2, a.name as name2
from (select * from playerStandings where ranking % 2 = 1) as h
left join (select * from playerStandings where ranking % 2 = 0) as a on h.ranking = (a.ranking-1);


