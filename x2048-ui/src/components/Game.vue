<template>
  <div class="top">
    <div class="user-details" v-if="enteringUserDetails">
      <form @submit.prevent="joinGame">
        <label>Please enter your name:</label><br>
        <input type="text" v-model="username" placeholder="Username"><br>
        <label>Please enter game ID:</label><br>
        <input type="text" v-model="gameId" placeholder="Game ID"><br>
        <button v-on:click="joinGame">Join</button>
      </form>
    </div>
    <div class="game" v-else>
      <div class="chat">
        <h3>Chat:</h3>
        <ul v-for="message of messages" :key="message.id">
          <li>
            <strong>{{message.username}}</strong>: {{message.body}}
          </li>
        </ul>
        <input type="text" v-model="message" v-on:keyup.13="sendMessage" placeholder="message...">
      </div>
      <div class="users">
        <h3>Online users:</h3>
        <ul v-for="user in users" :key="user">
          <li>
            {{user}}
          </li>
        </ul>
      </div>
      <div class="grid-container">
        <div class="grid-row">
          <div class="grid-cell">1</div>
          <div class="grid-cell">2</div>
          <div class="grid-cell">3</div>
          <div class="grid-cell">4</div>
          <div class="grid-cell">8</div>
          <div class="grid-cell">7</div>
        </div>
        <div class="grid-row">
          <div class="grid-cell">5</div>
          <div class="grid-cell">6</div>
          <div class="grid-cell">8</div>
          <div class="grid-cell">7</div>
          <div class="grid-cell">8</div>
          <div class="grid-cell">7</div>
        </div>
        <div class="grid-row">
          <div class="grid-cell">123</div>
          <div class="grid-cell">3</div>
          <div class="grid-cell">4</div>
          <div class="grid-cell">12</div>
          <div class="grid-cell">8</div>
          <div class="grid-cell">7</div>
        </div>
        <div class="grid-row">
          <div class="grid-cell">4</div>
          <div class="grid-cell">6</div>
          <div class="grid-cell">5</div>
          <div class="grid-cell">3</div>
          <div class="grid-cell">8</div>
          <div class="grid-cell">7</div>
        </div>
        <div class="grid-row">
          <div class="grid-cell">5</div>
          <div class="grid-cell">6</div>
          <div class="grid-cell">8</div>
          <div class="grid-cell">7</div>
          <div class="grid-cell">8</div>
          <div class="grid-cell">7</div>
        </div>
        <div class="grid-row">
          <div class="grid-cell">123</div>
          <div class="grid-cell">3</div>
          <div class="grid-cell">4</div>
          <div class="grid-cell">12</div>
          <div class="grid-cell">8</div>
          <div class="grid-cell">7</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { Socket, Presence } from 'phoenix'
// import { Socket } from 'phoenix'

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
      users: []
    }
  },
  methods: {
    sendMessage() {
      if (this.message !== "") {
        this.channel.push("new_msg", { body: this.message })
        this.message = ''
      }
    },

    joinGame() {
      this.enteringUserDetails = false
      this.socket = new Socket(`ws://${process.env.VUE_APP_BACKEND_HOST}/socket`, {
        params: {username: this.username}
      })
      this.socket.connect()
      this.channel = this.socket.channel(`game:${this.gameId}`, {});
      const presence = new Presence(this.channel)

      presence.onSync(() => {
        this.users = presence.list((user) => {
          return user
        })
      })

      this.channel.on("new_msg", payload => {
        payload.received_at = Date();
        this.messages.push(payload);
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

.game {
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
.grid-row {
  display: flex;
  flex: 1;
}
.grid-cell {
  display: flex;
  justify-content: center;
  align-items: center;
  flex: 1;
}
</style>
