# Stat Explorer

This Trackmania 2020 plugin allows you to export various stats to an api of your choice for later processing. One example for this is https://tmc.risyn.art

The only thing your API needs to do is return a status code coresponding to the success of the request (e.g. 200 if everything worked, 500 if something went wrong server side, etc.)
## Data format
Header fields:
  Content-Type: application/json
  ApiKey: {user specified API-Key (optional)}
Body json:
```
  {
    id: {Trackmania-Exchange-Map-ID},
    name: {Map name},
    medal: {Medal-ID see below},
    time: {achieved Time (is 0:00:00 when no time achieved)},
    tries: {your number of tries on the map},
    playtime: {your playtime, duh}
  }
```
## Medal format
I won't change existing IDs but might add new ones, if people want that functionality. You can choose if you want to prioritize Medals or world record in the settings. Currently if this is active WR will be prioritized over all medals (e.g. if you have CM and WR, 6 is returned, etc.), otherwise 6 is never returned.
```
0: none
1: bronze
2: silver
3: gold
4: author
5: champion
6: world record - not implemented yet
7: warrior medal
```
