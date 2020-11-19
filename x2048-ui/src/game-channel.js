import { Socket } from 'phoenix'

const socket = new Socket(`ws://${process.env.VUE_APP_BACKEND_HOST}/socket`)

socket.connect()
const channel = socket.channel("game:dev")

channel.on("new_msg", msg => console.log("Got message", msg))

channel.join()
  .receive("ok", ({game}) => console.log("catching up", game) )
  .receive("error", ({reason}) => console.log("failed join", reason) )
  .receive("timeout", () => console.log("Networking issue. Still waiting..."))

export default channel
