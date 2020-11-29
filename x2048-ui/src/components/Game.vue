<template>
  <div class="top">
    <div class="user-details" v-if="enteringUserDetails">
      <form @submit.prevent="joinGame">
        <label>Please enter your name:</label><br>
        <input type="text" v-model="username" placeholder="Username"><br>
        <label>Please enter game ID:</label><br>
        <input type="text" v-model="gameId" placeholder="Game ID"><br>
        <button @click="joinGame">Join</button>
      </form>
    </div>
    <div class="game-container" v-else>
      <div class="chat">
        <h3>Chat:</h3>
        <ul v-for="message of messages" :key="message.id">
          <li>
            <strong>{{message.username}}</strong>: {{message.body}}
          </li>
        </ul>
        <input type="text" v-model="message" @keyup.13="sendMessage" placeholder="message...">
      </div>
      <div class="users">
        <h3>Online users:</h3>
        <ul v-for="(vote, username) of players" :key="username">
          <li>
            {{username}} : {{vote}}
          </li>
        </ul>
      </div>
      <div class="game">
        {{mode}}
        <div class="grid-container"
             v-bind:class="{ ended: isEnded }"
             @keyup.up="move('up')"
             @keyup.down="move('down')"
             @keyup.left="move('left')"
             @keyup.right="move('right')"
             tabindex="0">
          <div class="grid-row" v-for="(row, i) of grid" :key="i">
            <div class="grid-cell" v-for="(cell, i) of row" :key="i">
              {{cell}}
            </div>
          </div>
        </div>
        <div class="game-buttons">
          <button @click="putObstacle">Put Obstacle</button>
          <button @click="dropObstacle">Drop Obstaclle</button>
          <button @click="toggleMode">Toggle Mode</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { Socket } from 'phoenix'

export default {
  name: 'Game',
  data() {
    return {
      socket: null,
      channel: null,
      username: "",
      gameId: "",
      enteringUserDetails: true,
      message: "",
      messages: [],
      grid: [],
      isEnded: false,
      mode: "anarchy",
      players: {}
    }
  },
  methods: {
    sendMessage() {
      if (this.message !== "") {
        this.channel.push("new_msg", { body: this.message })
        this.message = ''
      }
    },
    move(direction) {
      this.channel.push("turn", {direction})
    },
    putObstacle(){
      this.channel.push("put_obstacle", {})
    },
    dropObstacle(){
      this.channel.push("drop_obstacle", {})
    },
    toggleMode(){
      this.channel.push("toggle_mode", {})
    },
    joinGame() {
      this.enteringUserDetails = false
      this.socket = new Socket(`ws://${process.env.VUE_APP_BACKEND_HOST}/socket`, {
        params: {username: this.username}
      })
      this.socket.connect()
      this.channel = this.socket.channel(`game:${this.gameId}`, {});

      this.channel.on("new_msg", payload => {
        payload.received_at = Date();
        this.messages.push(payload);
      })

      this.channel.on("game_state", payload => {
        this.grid = payload["grid"]
        this.isEnded = payload["ended?"]
        this.mode = payload["mode"]
        this.players = payload["votes"]
      })
      
      this.channel.join()
        .receive("ok", response => { console.log("Joined successfully", response) })
        .receive("error", response => { console.log("Unable to join", response) })
    }
  }
}
</script>

<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}

.game-container {
  display: flex;
  justify-content: space-evenly;
}

.chat {
  height: 10cm;
  width: 10cm;
}

.grid-container {
  background-color: bisque;
  width: 10cm;
  height: 10cm;
  display: flex;
  flex-direction: column;
}
.grid-container.ended {
  background-color: rgb(247, 128, 98);
  width: 10cm;
  height: 10cm;
  display: flex;
  flex-direction: column;
}
.grid-row {
  display: flex;
  flex: 1;
}
.grid-cell {
  display: flex;
  justify-content: center;
  align-items: center;
  flex: 1;
  border: 1px solid gray;
}
</style>
