run `./start_2048.sh` and navigate to http://localhost:8080/

ToDo:
  1. Use Vue-router for receiving GameId from window history object
  2. Test X2048.Game GenServer (:turn call at first)
  3. Add css transitions to the game state change. (By applying UUID for every tile and exploiting it in the algorithm)
  4. Write infrastructure scripts and deploy system to the Kubernetes cluster
  5. Write recurrent functions for clearing the games which was not touched by any user in 24h period
