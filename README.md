development start: `./start_2048.sh`

ToDo:
    1. Use Vue-router for receiving GameId from window history object
    2. Test X2048.Game GenServer (:turn call at first)
    3. Add democracy mode. (Possibly by using Presence module)
    4. Add css transitions to the game state change. (By applying UUID for every tile and exploiting it in the algorithm)
    5. Write infrastructure scripts and deploy system to the Kubernetes cluster
    6. Write recurrent functions for clearing the games which was not touched by any user in 24h period