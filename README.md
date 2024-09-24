# Stat Explorer

This Trackmania 2020 plugin allows you to export various stats to an api of your choice for later processing. One example for this is https://tmc.risyn.art

## Data format
Header fields:
  Content-Type: application/json
  ApiKey: {user specified API-Key (optional)}
Body json:
  {
    id: {Trackmania-Exchange-Map-ID},
    name: {Map name},
    medal: {Medal-ID see below},
    time: {achieved Time (is 0:00:00 when no time achieved)},
    tries: {your number of tries on the map},
    playtime: {your playtime, duh}
  }

## Medal format
I won't change existing IDs but might add new ones, if people want that functionality.
0: none
1: bronze
2: silver
3: gold
4: author
5: champion
6: world record
